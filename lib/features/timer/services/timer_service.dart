import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'sensor_service.dart';
import 'audio_service.dart';
import '../../../core/services/settings_service.dart';
import 'package:phone_state/phone_state.dart';
import 'package:do_not_disturb/do_not_disturb.dart';

enum TimerState { idle, running, paused, failure, success }

class TimerService extends ChangeNotifier with WidgetsBindingObserver {
  final SensorService _sensorService;
  final AudioService _audioService;
  final SettingsService _settingsService;
  final DoNotDisturbPlugin _doNotDisturb = DoNotDisturbPlugin(); // Doğru sınıf ismi
  StreamSubscription? _phoneStateSubscription;

  TimerService(this._sensorService, this._audioService, this._settingsService) {
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
    // Android'de bazen null dönebilir, false kabul edelim
    if (isAllowed) {
      // InterruptionFilter enum'ı doğru
      await _doNotDisturb.setInterruptionFilter(InterruptionFilter.none);
      debugPrint("TimerService: DND Enabled");
    } else {
      await _doNotDisturb.openDndSettings();
    }
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
  int _currentTimeSeconds = 30;
  int get currentTimeSeconds => _currentTimeSeconds;
  double get progress => _currentTimeSeconds / _totalTimeSeconds;

  Timer? _timer;
  StreamSubscription<bool>? _sensorSubscription;
  bool _hasBeenFaceDown = false;

  void setDuration(int minutes) {
    if (_state == TimerState.idle && _level > 1) {
      _totalTimeSeconds = minutes * 60;
      _currentTimeSeconds = _totalTimeSeconds;
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

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
