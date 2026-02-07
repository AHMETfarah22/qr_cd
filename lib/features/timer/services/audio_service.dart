import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../../../core/services/settings_service.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final SettingsService _settingsService;
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  AudioService(this._settingsService);

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _player.setVolume(0.0);
    } else {
      _player.setVolume(1.0);
    }
    notifyListeners();
  }

  Future<void> playAlarm() async {
    // Check if silent mode is selected in settings
    if (_settingsService.alarmSound == AlarmSound.silent) {
      debugPrint("AudioService: Silent mode active. Not playing sound.");
    } else {
      try {
        final soundAsset = _getSoundAsset(_settingsService.alarmSound);
        debugPrint("AudioService: Playing $soundAsset...");
        
        await _player.stop();
        await _player.setVolume(_isMuted ? 0.0 : 1.0);
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource(soundAsset));
        
        debugPrint("AudioService: Play command executed.");
      } catch (e) {
        debugPrint("AudioService ERROR: $e");
      }
    }

    // Handle Vibration
    if (_settingsService.vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
    }
  }

  String _getSoundAsset(AlarmSound sound) {
    switch (sound) {
      case AlarmSound.bird:
        return 'sounds/bird.mp3';
      case AlarmSound.siren:
        return 'sounds/siren.mp3';
      case AlarmSound.zen:
        return 'sounds/zen.mp3';
      case AlarmSound.digital:
        return 'sounds/digital.mp3';
      case AlarmSound.nature:
        return 'sounds/nature.mp3';
      case AlarmSound.silent:
        return '';
    }
  }

  Future<void> playStartSound() async {
    // Basic haptic feedback for start
    if (await Vibration.hasVibrator() ?? false) {
      if (await Vibration.hasAmplitudeControl() ?? false) {
        Vibration.vibrate(duration: 100, amplitude: 128);
      } else {
        Vibration.vibrate(duration: 100);
      }
    }
    debugPrint("AudioService: Play Start Sound (Vibration only for now)");
  }

  Future<void> stopAlarm() async {
    try {
      await _player.stop();
      Vibration.cancel();
    } catch (e) {
      debugPrint("AudioService Stop Error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
