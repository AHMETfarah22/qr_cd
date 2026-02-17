import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// Helper function to hash passwords with salt
String _hashPassword(String password, String salt) {
  final bytes = utf8.encode(password + salt);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

// Legacy helper for migration (simple SHA-256)
String _legacyHashPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

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

  // Load user data from SharedPreferences
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

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validation
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
      final normalizedEmail = email.trim().toLowerCase();
      
      // Check if user already exists (check both secure storage and legacy SP)
      final existingHash = await _storage.read(key: 'user_${normalizedEmail}_hash');
      final legacyPassword = prefs.getString('user_${normalizedEmail}_password');

      if (existingHash != null || legacyPassword != null) {
        return {'success': false, 'message': 'Bu e-posta adresi zaten kayıtlı'};
      }
      
      // Generate Salt
      final salt = _uuid.v4();
      final hashedPassword = _hashPassword(password, salt);

      // Save sensitive data to Secure Storage
      await _storage.write(key: 'user_${normalizedEmail}_salt', value: salt);
      await _storage.write(key: 'user_${normalizedEmail}_hash', value: hashedPassword);
      
      // Save public data to SharedPreferences
      await prefs.setString('user_${normalizedEmail}_name', name);
      
      // Set current user
      await prefs.setString('current_user_email', normalizedEmail);
      await prefs.setBool('is_logged_in', true);

      _userName = name;
      _userEmail = normalizedEmail;
      _isLoggedIn = true;
      notifyListeners();

      return {'success': true, 'message': 'Kayıt başarılı!'};
    } catch (e) {
      debugPrint('Registration Error: $e');
      return {'success': false, 'message': 'Kayıt sırasında hata oluştu'};
    }
  }

  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // 1. Check Lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now());
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return {
        'success': false, 
        'message': 'Çok fazla başarısız deneme. Lütfen $minutes dk $seconds sn bekleyin.'
      };
    }

    // Validation
    if (email.trim().isEmpty) {
      return {'success': false, 'message': 'Lütfen e-posta adresinizi girin'};
    }
    if (password.trim().isEmpty) {
      return {'success': false, 'message': 'Lütfen şifrenizi girin'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final normalizedEmail = email.trim().toLowerCase();
      
      // Check Secure Storage first
      final storedSalt = await _storage.read(key: 'user_${normalizedEmail}_salt');
      final storedHash = await _storage.read(key: 'user_${normalizedEmail}_hash');
      final savedName = prefs.getString('user_${normalizedEmail}_name');
      final savedImagePath = prefs.getString('user_${normalizedEmail}_image_path');

      if (storedSalt != null && storedHash != null) {
        // Secure login check
        if (_hashPassword(password, storedSalt) == storedHash) {
             _resetLockout(); // Success!
             
             // Set current user
            await prefs.setString('current_user_email', normalizedEmail);
            await prefs.setBool('is_logged_in', true);
            
            _userEmail = normalizedEmail;
            _userName = savedName;
            _userImagePath = savedImagePath;
            _isLoggedIn = true;
            notifyListeners();
            
            return {'success': true, 'message': 'Giriş başarılı!'};
        } else {
             return _handleFailedAttempt();
        }
      } 
      
      // Legacy Check (Migration)
      final legacyPasswordHash = prefs.getString('user_${normalizedEmail}_password');
      if (legacyPasswordHash != null) {
        if (_legacyHashPassword(password) == legacyPasswordHash) {
          _resetLockout(); // Success!

          // MIGRATE to Secure Storage
          debugPrint('Migrating user to secure storage...');
          final newSalt = _uuid.v4();
          final newHash = _hashPassword(password, newSalt);
          
          await _storage.write(key: 'user_${normalizedEmail}_salt', value: newSalt);
          await _storage.write(key: 'user_${normalizedEmail}_hash', value: newHash);
          
          // Remove old insecure password
          await prefs.remove('user_${normalizedEmail}_password');

          // Log in
          await prefs.setString('current_user_email', normalizedEmail);
          await prefs.setBool('is_logged_in', true);
          
          _userEmail = normalizedEmail;
          _userName = savedName;
          _userImagePath = savedImagePath;
          _isLoggedIn = true;
          notifyListeners();
          
          return {'success': true, 'message': 'Giriş başarılı (Güvenlik güncellendi)!'};
        } else {
           return _handleFailedAttempt();
        }
      }

      return {'success': false, 'message': 'Kullanıcı bulunamadı. Lütfen kayıt olun'};
      
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Giriş sırasında hata oluştu'};
    }
  }

  void _resetLockout() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  Map<String, dynamic> _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(minutes: 5));
      _failedAttempts = 0; // Reset count so they get 5 more tries AFTER the block
      return {
        'success': false, 
        'message': '5 kez hatalı giriş! Hesap güvenliği için 5 dakika kilitlendi.'
      };
    }
    return {
      'success': false, 
      'message': 'E-posta veya şifre hatalı. (Deneme: $_failedAttempts/5)'
    };
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user_email');
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _userImagePath = null;
    notifyListeners();
  }

  // Update profile image
  Future<void> updateProfileImage(String path) async {
    if (_userEmail == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${_userEmail}_image_path', path);
    _userImagePath = path;
    notifyListeners();
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_userEmail == null) {
      return {'success': false, 'message': 'Kullanıcı bilgisi bulunamadı'};
    }

    // Validation
    if (currentPassword.trim().isEmpty) {
      return {'success': false, 'message': 'Mevcut şifrenizi girin'};
    }
    if (newPassword.trim().isEmpty) {
      return {'success': false, 'message': 'Yeni şifrenizi girin'};
    }
    if (newPassword.length < 6) {
      return {'success': false, 'message': 'Yeni şifre en az 6 karakter olmalıdır'};
    }

    try {
      final storedSalt = await _storage.read(key: 'user_${_userEmail}_salt');
      final storedHash = await _storage.read(key: 'user_${_userEmail}_hash');
      
      if (storedSalt != null && storedHash != null) {
         if (_hashPassword(currentPassword, storedSalt) != storedHash) {
           return {'success': false, 'message': 'Mevcut şifre hatalı'};
         }
         
         // Update with new salt and hash
         final newSalt = _uuid.v4();
         final newHash = _hashPassword(newPassword, newSalt);
         
         await _storage.write(key: 'user_${_userEmail}_salt', value: newSalt);
         await _storage.write(key: 'user_${_userEmail}_hash', value: newHash);
         
         return {'success': true, 'message': 'Şifre başarıyla değiştirildi'};
      }
      
      return {'success': false, 'message': 'Güvenlik hatası: Lütfen çıkış yapıp tekrar girin'};
    } catch (e) {
      return {'success': false, 'message': 'Şifre değiştirme sırasında hata oluştu'};
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (_userEmail == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Remove secure data
    await _storage.delete(key: 'user_${_userEmail}_salt');
    await _storage.delete(key: 'user_${_userEmail}_hash');

    // Remove this user's public data
    await prefs.remove('user_${_userEmail}_name');
    await prefs.remove('user_${_userEmail}_password'); // Just in case
    await prefs.remove('user_${_userEmail}_image_path');
    await prefs.remove('user_${_userEmail}_stats_total_sessions');
    await prefs.remove('user_${_userEmail}_stats_completed_sessions');
    await prefs.remove('user_${_userEmail}_stats_cancelled_sessions');
    await prefs.remove('user_${_userEmail}_stats_total_minutes');
    await prefs.remove('user_${_userEmail}_stats_current_streak');
    await prefs.remove('user_${_userEmail}_stats_badges');
    await prefs.remove('user_${_userEmail}_stats_last_focus_date');
    await prefs.remove('user_${_userEmail}_stats_session_history');
    
    // Clear current session
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user_email');
    
    _userEmail = null;
    _userName = null;
    _userImagePath = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
