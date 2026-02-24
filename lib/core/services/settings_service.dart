import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AlarmSound { bird, siren, zen, digital, nature, silent }

class SettingsService extends ChangeNotifier {
  AlarmSound _alarmSound = AlarmSound.bird;
  bool _vibrationEnabled = true;
  int _preferredFocusDurationMinutes = 25;
  bool _isDarkMode = true;
  bool _isOnboardingCompleted = false;
  bool _isLoaded = false;

  String? _userEmail;

  AlarmSound get alarmSound => _alarmSound;
  bool get vibrationEnabled => _vibrationEnabled;
  int get preferredFocusDurationMinutes => _preferredFocusDurationMinutes;
  bool get isDarkMode => _isDarkMode;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoaded => _isLoaded;

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
      
      _vibrationEnabled = prefs.getBool(_getKey('settings_vibration_enabled')) ?? true;
      _preferredFocusDurationMinutes = prefs.getInt(_getKey('settings_focus_duration')) ?? 25;
      _isDarkMode = prefs.getBool(_getKey('settings_is_dark_mode')) ?? true;
      _isOnboardingCompleted = prefs.getBool(_getKey('settings_onboarding_completed')) ?? false;
      
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

  Future<void> setOnboardingCompleted(bool completed) async {
    _isOnboardingCompleted = completed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey('settings_onboarding_completed'), completed);
    notifyListeners();
  }
}
