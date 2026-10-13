import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AlarmSound { bird, siren, zen, digital, nature, silent }

enum AmbientSound { none, rain, forest, cafe, whiteNoise, storm }

enum ReadingSpeed { slow, normal, fast }

class SettingsService extends ChangeNotifier {
  AlarmSound _alarmSound = AlarmSound.bird;
  bool _vibrationEnabled = true;
  int _preferredFocusDurationMinutes = 25;
  bool _isDarkMode = true;
  AmbientSound _ambientSound = AmbientSound.none;
  bool _isHardMode = false;
  bool _isOnboardingCompleted = false;
  bool _isLoaded = false;
  int _dailyFocusGoalMinutes = 60;
  ReadingSpeed _readingSpeed = ReadingSpeed.normal;

  String? _userEmail;

  AlarmSound get alarmSound => _alarmSound;
  bool get vibrationEnabled => _vibrationEnabled;
  int get preferredFocusDurationMinutes => _preferredFocusDurationMinutes;
  bool get isDarkMode => _isDarkMode;
  AmbientSound get ambientSound => _ambientSound;
  bool get isHardMode => _isHardMode;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoaded => _isLoaded;
  int get dailyFocusGoalMinutes => _dailyFocusGoalMinutes;
  ReadingSpeed get readingSpeed => _readingSpeed;

  SettingsService() {
    _loadSettings();
  }

  void setCurrentUser(String? email) {
    if (_userEmail != email) {
      _userEmail = email;
      _loadSettings();
    }
  }

  String _getKey(String key) {
    if (_userEmail == null) return key;
    return '${key}_$_userEmail';
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final soundIndex = prefs.getInt(_getKey('settings_alarm_sound')) ?? 0;
      if (soundIndex >= 0 && soundIndex < AlarmSound.values.length) {
        _alarmSound = AlarmSound.values[soundIndex];
      }

      _vibrationEnabled =
          prefs.getBool(_getKey('settings_vibration_enabled')) ?? true;
      _preferredFocusDurationMinutes =
          prefs.getInt(_getKey('settings_focus_duration')) ?? 25;
      _isDarkMode = prefs.getBool(_getKey('settings_is_dark_mode')) ?? true;

      final ambientIndex = prefs.getInt(_getKey('settings_ambient_sound')) ?? 0;
      if (ambientIndex >= 0 && ambientIndex < AmbientSound.values.length) {
        _ambientSound = AmbientSound.values[ambientIndex];
      }

      _isHardMode = prefs.getBool(_getKey('settings_is_hard_mode')) ?? false;
      _isOnboardingCompleted =
          prefs.getBool(_getKey('settings_onboarding_completed')) ?? false;
      _dailyFocusGoalMinutes =
          prefs.getInt(_getKey('settings_daily_focus_goal')) ?? 60;

      final readingSpeedIndex =
          prefs.getInt(_getKey('settings_reading_speed')) ??
          1; // Default to normal (index 1)
      if (readingSpeedIndex >= 0 &&
          readingSpeedIndex < ReadingSpeed.values.length) {
        _readingSpeed = ReadingSpeed.values[readingSpeedIndex];
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _isLoaded = true; // Use defaults on error
      notifyListeners();
    }
  }

  Future<void> setAlarmSound(AlarmSound sound) async {
    _alarmSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('settings_alarm_sound'), sound.index);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey('settings_vibration_enabled'), enabled);
    notifyListeners();
  }

  Future<void> setPreferredFocusDuration(int minutes) async {
    _preferredFocusDurationMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('settings_focus_duration'), minutes);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey('settings_is_dark_mode'), isDark);
    notifyListeners();
  }

  Future<void> setAmbientSound(AmbientSound sound) async {
    _ambientSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('settings_ambient_sound'), sound.index);
    notifyListeners();
  }

  Future<void> setHardMode(bool enabled) async {
    _isHardMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey('settings_is_hard_mode'), enabled);
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _isOnboardingCompleted = completed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey('settings_onboarding_completed'), completed);
    notifyListeners();
  }

  Future<void> setDailyFocusGoal(int minutes) async {
    _dailyFocusGoalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('settings_daily_focus_goal'), minutes);
    notifyListeners();
  }

  Future<void> setReadingSpeed(ReadingSpeed speed) async {
    _readingSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('settings_reading_speed'), speed.index);
    notifyListeners();
  }
}
