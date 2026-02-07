import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Helper function to hash passwords
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

class AuthService extends ChangeNotifier {
  String? _userEmail;
  String? _userName;
  bool _isLoggedIn = false;

  String? get userEmail => _userEmail;
  String? get userName => _userName;
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
      
      // Check if user already exists
      final existingPassword = prefs.getString('user_${normalizedEmail}_password');
      if (existingPassword != null) {
        return {'success': false, 'message': 'Bu e-posta adresi zaten kayıtlı'};
      }
      
      // Save user data with email prefix
      await prefs.setString('user_${normalizedEmail}_name', name);
      await prefs.setString('user_${normalizedEmail}_password', _hashPassword(password)); // Hash password!
      
      // Set current user
      await prefs.setString('current_user_email', normalizedEmail);
      await prefs.setBool('is_logged_in', true);

      _userName = name;
      _userEmail = normalizedEmail;
      _isLoggedIn = true;
      notifyListeners();

      return {'success': true, 'message': 'Kayıt başarılı!'};
    } catch (e) {
      return {'success': false, 'message': 'Kayıt sırasında hata oluştu'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
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
      
      // Get saved user data for this email
      final savedPassword = prefs.getString('user_${normalizedEmail}_password');
      final savedName = prefs.getString('user_${normalizedEmail}_name');

      // Check if user exists
      if (savedPassword == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı. Lütfen kayıt olun'};
      }

      // Verify credentials (compare hashed passwords)
      if (_hashPassword(password) == savedPassword) {
        // Set current user
        await prefs.setString('current_user_email', normalizedEmail);
        await prefs.setBool('is_logged_in', true);
        
        _userEmail = normalizedEmail;
        _userName = savedName;
        _isLoggedIn = true;
        notifyListeners();
        
        return {'success': true, 'message': 'Giriş başarılı!'};
      } else {
        return {'success': false, 'message': 'E-posta veya şifre hatalı'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Giriş sırasında hata oluştu'};
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user_email');
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
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
      final prefs = await SharedPreferences.getInstance();
      final savedPassword = prefs.getString('user_${_userEmail}_password');

      // Verify current password (compare hashed)
      if (savedPassword != _hashPassword(currentPassword)) {
        return {'success': false, 'message': 'Mevcut şifre hatalı'};
      }

      // Update password (hash new password)
      await prefs.setString('user_${_userEmail}_password', _hashPassword(newPassword));

      return {'success': true, 'message': 'Şifre başarıyla değiştirildi'};
    } catch (e) {
      return {'success': false, 'message': 'Şifre değiştirme sırasında hata oluştu'};
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (_userEmail == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Remove this user's data
    await prefs.remove('user_${_userEmail}_name');
    await prefs.remove('user_${_userEmail}_password');
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
    _isLoggedIn = false;
    notifyListeners();
  }
}
