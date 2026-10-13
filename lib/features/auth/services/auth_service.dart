import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/security/password_hasher.dart';

class AuthService extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  final _uuid = const Uuid();

  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);

  String? _userEmail;
  String? _userName;
  String? _userImagePath;
  bool _isLoggedIn = false;

  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userImagePath => _userImagePath;
  bool get isLoggedIn => _isLoggedIn;

  AuthService() {
    _loadUserData();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _applySessionState({
    required String email,
    String? name,
    String? imagePath,
  }) {
    _userEmail = email;
    _userName = name;
    _userImagePath = imagePath;
    _isLoggedIn = true;
    notifyListeners();
  }

  void _clearSessionState() {
    _userEmail = null;
    _userName = null;
    _userImagePath = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  String _hashKey(String email) => 'user_${email}_hash';
  String _saltKey(String email) => 'user_${email}_salt';
  String _hashVersionKey(String email) => 'user_${email}_hash_version';
  String _lockoutAttemptsKey(String email) => 'auth_${email}_failed_attempts';
  String _lockoutUntilKey(String email) => 'auth_${email}_lockout_until';

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('current_user_email');
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (_isLoggedIn && _userEmail != null) {
      _userName = prefs.getString('user_${_userEmail}_name');
      _userImagePath = prefs.getString('user_${_userEmail}_image_path');
    }

    notifyListeners();
  }

  Future<void> _writeCredentials(String email, String password) async {
    final salt = _uuid.v4();
    final hashedPassword = PasswordHasher.hash(password, salt);
    await _storage.write(key: _saltKey(email), value: salt);
    await _storage.write(key: _hashKey(email), value: hashedPassword);
    await _storage.write(
      key: _hashVersionKey(email),
      value: PasswordHasher.currentVersion,
    );
  }

  Future<bool> _verifyStoredPassword(
    String email,
    String password,
    String salt,
    String storedHash,
  ) async {
    final hashVersion = await _storage.read(key: _hashVersionKey(email));
    return PasswordHasher.verify(
      password: password,
      salt: salt,
      storedHash: storedHash,
      hashVersion: hashVersion,
    );
  }

  Future<void> _upgradeToPbkdf2(String email, String password) async {
    await _writeCredentials(email, password);
  }

  Future<({int failedAttempts, DateTime? lockoutUntil})> _loadLockout(
    String email,
  ) async {
    final attemptsStr = await _storage.read(key: _lockoutAttemptsKey(email));
    final untilStr = await _storage.read(key: _lockoutUntilKey(email));

    var failedAttempts = int.tryParse(attemptsStr ?? '') ?? 0;
    DateTime? lockoutUntil = untilStr != null
        ? DateTime.tryParse(untilStr)
        : null;

    if (lockoutUntil != null && !DateTime.now().isBefore(lockoutUntil)) {
      await _clearLockout(email);
      failedAttempts = 0;
      lockoutUntil = null;
    }

    return (failedAttempts: failedAttempts, lockoutUntil: lockoutUntil);
  }

  Future<void> _clearLockout(String email) async {
    await _storage.delete(key: _lockoutAttemptsKey(email));
    await _storage.delete(key: _lockoutUntilKey(email));
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      return {'success': false, 'message': 'Lütfen adınızı girin'};
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return {'success': false, 'message': 'Geçerli bir e-posta adresi girin'};
    }
    if (password.length < 6) {
      return {'success': false, 'message': 'Şifre en az 6 karakter olmalıdır'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final normalizedEmail = _normalizeEmail(email);

      final existingHash = await _storage.read(key: _hashKey(normalizedEmail));
      final legacyPassword = prefs.getString(
        'user_${normalizedEmail}_password',
      );

      if (existingHash != null || legacyPassword != null) {
        return {'success': false, 'message': 'Bu e-posta adresi zaten kayıtlı'};
      }

      await _writeCredentials(normalizedEmail, password);

      await prefs.setString('user_${normalizedEmail}_name', name);
      await prefs.setString('current_user_email', normalizedEmail);
      await prefs.setBool('is_logged_in', true);

      _applySessionState(email: normalizedEmail, name: name);

      return {'success': true, 'message': 'Kayıt başarılı!'};
    } catch (e) {
      debugPrint('Registration Error: $e');
      return {'success': false, 'message': 'Kayıt sırasında hata oluştu'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      return {'success': false, 'message': 'Lütfen e-posta adresinizi girin'};
    }
    if (password.trim().isEmpty) {
      return {'success': false, 'message': 'Lütfen şifrenizi girin'};
    }

    final normalizedEmail = _normalizeEmail(email);

    final lockout = await _loadLockout(normalizedEmail);
    if (lockout.lockoutUntil != null &&
        DateTime.now().isBefore(lockout.lockoutUntil!)) {
      final remaining = lockout.lockoutUntil!.difference(DateTime.now());
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return {
        'success': false,
        'message':
            'Çok fazla başarısız deneme. Lütfen $minutes dk $seconds sn bekleyin.',
      };
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final storedSalt = await _storage.read(key: _saltKey(normalizedEmail));
      final storedHash = await _storage.read(key: _hashKey(normalizedEmail));
      final savedName = prefs.getString('user_${normalizedEmail}_name');
      final savedImagePath = prefs.getString(
        'user_${normalizedEmail}_image_path',
      );

      if (storedSalt != null && storedHash != null) {
        if (await _verifyStoredPassword(
          normalizedEmail,
          password,
          storedSalt,
          storedHash,
        )) {
          await _clearLockout(normalizedEmail);
          final hashVersion = await _storage.read(
            key: _hashVersionKey(normalizedEmail),
          );
          if (hashVersion != PasswordHasher.currentVersion) {
            await _upgradeToPbkdf2(normalizedEmail, password);
          }

          await prefs.setString('current_user_email', normalizedEmail);
          await prefs.setBool('is_logged_in', true);

          _applySessionState(
            email: normalizedEmail,
            name: savedName,
            imagePath: savedImagePath,
          );

          return {'success': true, 'message': 'Giriş başarılı!'};
        }
        return _handleFailedAttempt(normalizedEmail, lockout.failedAttempts);
      }

      final legacyPasswordHash = prefs.getString(
        'user_${normalizedEmail}_password',
      );
      if (legacyPasswordHash != null) {
        if (PasswordHasher.verifyLegacyPlain(password, legacyPasswordHash)) {
          await _clearLockout(normalizedEmail);
          await _upgradeToPbkdf2(normalizedEmail, password);
          await prefs.remove('user_${normalizedEmail}_password');

          await prefs.setString('current_user_email', normalizedEmail);
          await prefs.setBool('is_logged_in', true);

          _applySessionState(
            email: normalizedEmail,
            name: savedName,
            imagePath: savedImagePath,
          );

          return {
            'success': true,
            'message': 'Giriş başarılı (Güvenlik güncellendi)!',
          };
        }
        return _handleFailedAttempt(normalizedEmail, lockout.failedAttempts);
      }

      return {
        'success': false,
        'message': 'Kullanıcı bulunamadı. Lütfen kayıt olun',
      };
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Giriş sırasında hata oluştu'};
    }
  }

  Future<Map<String, dynamic>> _handleFailedAttempt(
    String email,
    int currentAttempts,
  ) async {
    final failedAttempts = currentAttempts + 1;

    if (failedAttempts >= _maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(_lockoutDuration);
      await _storage.write(
        key: _lockoutUntilKey(email),
        value: lockoutUntil.toIso8601String(),
      );
      await _storage.write(key: _lockoutAttemptsKey(email), value: '0');
      return {
        'success': false,
        'message':
            '5 kez hatalı giriş! Hesap güvenliği için 5 dakika kilitlendi.',
      };
    }

    await _storage.write(
      key: _lockoutAttemptsKey(email),
      value: failedAttempts.toString(),
    );
    return {
      'success': false,
      'message':
          'E-posta veya şifre hatalı. (Deneme: $failedAttempts/$_maxFailedAttempts)',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user_email');
    _clearSessionState();
  }

  Future<void> updateProfileImage(String path) async {
    if (_userEmail == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${_userEmail}_image_path', path);
    _userImagePath = path;
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_userEmail == null) {
      return {'success': false, 'message': 'Kullanıcı bilgisi bulunamadı'};
    }

    if (currentPassword.trim().isEmpty) {
      return {'success': false, 'message': 'Mevcut şifrenizi girin'};
    }
    if (newPassword.trim().isEmpty) {
      return {'success': false, 'message': 'Yeni şifrenizi girin'};
    }
    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': 'Yeni şifre en az 6 karakter olmalıdır',
      };
    }

    try {
      final email = _userEmail!;
      final storedSalt = await _storage.read(key: _saltKey(email));
      final storedHash = await _storage.read(key: _hashKey(email));

      if (storedSalt != null && storedHash != null) {
        if (!await _verifyStoredPassword(
          email,
          currentPassword,
          storedSalt,
          storedHash,
        )) {
          return {'success': false, 'message': 'Mevcut şifre hatalı'};
        }

        await _writeCredentials(email, newPassword);

        return {'success': true, 'message': 'Şifre başarıyla değiştirildi'};
      }

      return {
        'success': false,
        'message': 'Güvenlik hatası: Lütfen çıkış yapıp tekrar girin',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Şifre değiştirme sırasında hata oluştu',
      };
    }
  }

  Future<void> deleteAccount() async {
    if (_userEmail == null) return;

    final email = _userEmail!;
    final prefs = await SharedPreferences.getInstance();

    await _storage.delete(key: _saltKey(email));
    await _storage.delete(key: _hashKey(email));
    await _storage.delete(key: _hashVersionKey(email));
    await _clearLockout(email);

    await prefs.remove('user_${email}_name');
    await prefs.remove('user_${email}_password');
    await prefs.remove('user_${email}_image_path');
    await prefs.remove('user_${email}_stats_total_sessions');
    await prefs.remove('user_${email}_stats_completed_sessions');
    await prefs.remove('user_${email}_stats_cancelled_sessions');
    await prefs.remove('user_${email}_stats_total_minutes');
    await prefs.remove('user_${email}_stats_current_streak');
    await prefs.remove('user_${email}_stats_badges');
    await prefs.remove('user_${email}_stats_last_focus_date');
    await prefs.remove('user_${email}_stats_session_history');
    await prefs.remove('user_${email}_stats_total_pdf_sessions');
    await prefs.remove('user_${email}_stats_total_quizzes_taken');
    await prefs.remove('user_${email}_stats_total_quiz_score_sum');
    await prefs.remove('user_${email}_pdf_privacy_accepted');
    await prefs.remove('user_${email}_pdf_history_list');

    // Clean up user-specific settings keys
    await prefs.remove('settings_alarm_sound_$email');
    await prefs.remove('settings_vibration_enabled_$email');
    await prefs.remove('settings_focus_duration_$email');
    await prefs.remove('settings_is_dark_mode_$email');
    await prefs.remove('settings_ambient_sound_$email');
    await prefs.remove('settings_is_hard_mode_$email');
    await prefs.remove('settings_onboarding_completed_$email');
    await prefs.remove('settings_daily_focus_goal_$email');
    await prefs.remove('settings_reading_speed_$email');

    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user_email');

    _clearSessionState();
  }
}
