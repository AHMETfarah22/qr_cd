import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AlarmSound { bird, siren, zen, digital, nature, silent }

class SettingsService extends ChangeNotifier {
  AlarmSound _alarmSound = AlarmSound.bird;
  bool _vibrationEnabled = true;
  int _preferredFocusDurationMinutes = 25;

  AlarmSound get alarmSound => _alarmSound;
  bool get vibrationEnabled => _vibrationEnabled;
  int get preferredFocusDurationMinutes => _preferredFocusDurationMinutes;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final soundIndex = prefs.getInt('settings_alarm_sound') ?? 0;
    _alarmSound = AlarmSound.values[soundIndex];
    
    _vibrationEnabled = prefs.getBool('settings_vibration_enabled') ?? true;
    _preferredFocusDurationMinutes = prefs.getInt('settings_focus_duration') ?? 25;
    
    notifyListeners();
  }

  Future<void> setAlarmSound(AlarmSound sound) async {
    _alarmSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_alarm_sound', sound.index);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_vibration_enabled', enabled);
    notifyListeners();
  }

  Future<void> setPreferredFocusDuration(int minutes) async {
    _preferredFocusDurationMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_focus_duration', minutes);
    notifyListeners();
  }
}
