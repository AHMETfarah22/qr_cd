import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'sensor_service.dart';
import 'audio_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/models/session_category.dart';
import 'package:phone_state/phone_state.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/services/statistics_service.dart';

enum TimerState { idle, running, paused, failure, success, breakTime }

class TimerService extends ChangeNotifier with WidgetsBindingObserver {
  final SensorService _sensorService;
  final AudioService _audioService;
  final SettingsService _settingsService;
  final NotificationService _notificationService;
  StatisticsService? _statisticsService;
  final DoNotDisturbPlugin _doNotDisturb = DoNotDisturbPlugin(); // Doğru sınıf ismi
  StreamSubscription? _phoneStateSubscription;

  TimerService(this._sensorService, this._audioService, this._settingsService, this._notificationService) {
    WidgetsBinding.instance.addObserver(this);
    // Initialize with settings if not in level 1
    _updateInitialDuration();
  }

  void _startPhoneStateListener() {
    _phoneStateSubscription?.cancel();
    _phoneStateSubscription = PhoneState.stream.listen((event) {
      if (_state == TimerState.running && event.status == PhoneStateStatus.CALL_INCOMING) {
        debugPrint("TimerService: Phone is ringing! Failing timer...");
        _failTimer();
      }
    });
  }

  Future<void> _enableDND() async {
    bool isAllowed = await _doNotDisturb.isNotificationPolicyAccessGranted();
    // Sadece izin varsa DND'yi aktif et
    if (isAllowed) {
      await _doNotDisturb.setInterruptionFilter(InterruptionFilter.none);
      debugPrint("TimerService: DND Enabled");
    }
    // İzin yoksa ayarlara GİTME - timer başarısız olmasın
  }

  Future<void> _disableDND() async {
    // instance üzerinden çağırıyoruz
    bool isAllowed = await _doNotDisturb.isNotificationPolicyAccessGranted();
    if (isAllowed) {
      await _doNotDisturb.setInterruptionFilter(InterruptionFilter.all);
      debugPrint("TimerService: DND Disabled");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_state == TimerState.running) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        debugPrint("TimerService: User left the app! Failing timer...");
        _failTimer();
      }
    }
  }

  void _updateInitialDuration() {
    if (_level == 1) {
      _totalTimeSeconds = 30; // Level 1 is fixed at 30 seconds
    } else {
      _totalTimeSeconds = _settingsService.preferredFocusDurationMinutes * 60;
    }
    _currentTimeSeconds = _totalTimeSeconds;
  }

  TimerState _state = TimerState.idle;
  TimerState get state => _state;

  int _level = 1;
  int get level => _level;
  
  int _completedSessions = 0;
  int get completedSessions => _completedSessions;

  int _totalTimeSeconds = 30; 
  int get totalTimeSeconds => _totalTimeSeconds;
  int _currentTimeSeconds = 30;
  int get currentTimeSeconds => _currentTimeSeconds;
  double get progress => _currentTimeSeconds / _totalTimeSeconds;

  Timer? _timer;
  StreamSubscription<bool>? _sensorSubscription;
  bool _hasBeenFaceDown = false;
  SessionCategory _currentCategory = SessionCategory.other;

  SessionCategory get currentCategory => _currentCategory;

  void setCategory(SessionCategory category) {
    if (_state == TimerState.idle) {
      _currentCategory = category;
      notifyListeners();
    }
  }

  void setDuration(int minutes) {
    if (_state == TimerState.idle && _level > 1) {
      _totalTimeSeconds = minutes * 60;
      _currentTimeSeconds = _totalTimeSeconds;
      notifyListeners();
    }
  }

  // Sync state and dependencies
  void updateDependencies(StatisticsService statsService) {
    _statisticsService = statsService;
    
    if (_completedSessions != statsService.completedSessions) {
      _completedSessions = statsService.completedSessions;
      // Recalculate level
      _level = _completedSessions + 1;
      _updateInitialDuration();
      notifyListeners();
    }
  }

  void startTimer() {
    if (_state == TimerState.running) return;

    debugPrint("TimerService: STARTING TIMER flow...");
    _state = TimerState.running;
    _hasBeenFaceDown = false;
    _sensorService.startListening();
    _startSensorListener();
    _startPhoneStateListener();
    _enableDND();
    _startTicker();
    WakelockPlus.enable();
    
    // Notify statistics service
    _statisticsService?.startSession();
    
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    debugPrint("Ticker: INITIALIZED at $_currentTimeSeconds seconds");
    
    // Decrement immediately for better UX so user sees change at 0ms
    if (_currentTimeSeconds > 0) {
      _currentTimeSeconds--;
      notifyListeners();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTimeSeconds > 0) {
        _currentTimeSeconds--;
        debugPrint("Ticker: $_currentTimeSeconds seconds left (State: $_state)");
        notifyListeners();
      } else {
        debugPrint("Ticker: FINISHED");
        _completeTimer();
      }
    });
  }

  void _startSensorListener() {
    _sensorSubscription?.cancel();
    _sensorSubscription = _sensorService.isFaceDown.listen((isFaceDown) {
      if (_state == TimerState.running) {
        if (isFaceDown) {
          if (!_hasBeenFaceDown) {
            debugPrint("TimerService: Phone is now face down. Session active!");
            _hasBeenFaceDown = true;
          }
        } else if (_hasBeenFaceDown) {
          // Phone was face down, but now IT IS NOT.
          debugPrint("TimerService: Phone PICKED UP! Breaking focus...");
          _failTimer();
        }
      }
    });
  }

  void _failTimer() {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();
    _disableDND();
    _state = TimerState.failure;
    _audioService.playAlarm();
    WakelockPlus.disable();
    notifyListeners();
  }

  void _completeTimer() {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();
    _disableDND();
    _state = TimerState.success;
    _completedSessions++;
    
    if (_level == 1) {
      _level = 2;
    } else {
      _level++; 
    }
    
    // Always update duration after completion/level up
    _updateInitialDuration();

    // Notify statistics service
    if (_statisticsService != null) {
      final totalMinutes = (_totalTimeSeconds / 60).ceil();
      _statisticsService!.completeSession(totalMinutes, category: _currentCategory);
    }

    _notificationService.showNotification(
      id: 1,
      title: 'Tebrikler!',
      body: 'Odaklanma oturumu başarıyla tamamlandı. Harikasın!',
      payload: 'success',
      ongoing: true, // User requested persistent notification
      playSound: true,
    );

    WakelockPlus.disable();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    _phoneStateSubscription?.cancel();
    _disableDND();
    _sensorService.stopListening();
    _audioService.stopAlarm();
    WakelockPlus.disable();
    _state = TimerState.idle;
    
    // Use settings duration for current level
    _updateInitialDuration();
    
    notifyListeners();
  }

  // Cancel timer and record statistics
  void cancelTimer(int durationMinutes) {
    if (_state != TimerState.running && _state != TimerState.paused && _state != TimerState.breakTime && _state != TimerState.failure) return;
    
    // Record cancelled session to statistics before resetting
    // Check if it's a break time being cancelled
    if (_state == TimerState.breakTime) {
       _statisticsService?.cancelSession(
         durationMinutes > 0 ? durationMinutes : 1,
         category: SessionCategory.breakTime,
       );
    } else {
       _statisticsService?.cancelSession(
         durationMinutes > 0 ? durationMinutes : 1,
         category: _currentCategory,
       );
    }
    
    resetTimer();
  }

  void startBreak(int minutes) {
    _timer?.cancel();
    
    // Store previous category to restore after break (optional, or keep generic)
    // _previousCategory = _currentCategory;
    
    _state = TimerState.breakTime;
    _totalTimeSeconds = minutes * 60;
    _currentTimeSeconds = _totalTimeSeconds;
    
    // Record start of break session
    _statisticsService?.startSession();
    
    debugPrint("TimerService: Starting BREAK for $minutes minutes");
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTimeSeconds > 0) {
        _currentTimeSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        
        // Record completed break session
        _statisticsService?.completeSession(minutes, category: SessionCategory.breakTime);
        
        _state = TimerState.idle;
        _notificationService.showNotification(
          id: 2,
          title: 'Mola Bitti!',
          body: 'Yeni bir odaklanma seansına hazırsın.',
          playSound: true,
          ongoing: false,
        );
        
        // Play alarm sound for break end
        _audioService.playAlarm(); 
        
        _updateInitialDuration();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    _phoneStateSubscription?.cancel();
    _disableDND();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
}
