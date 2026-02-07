import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await prefs.setString('user_${normalizedEmail}_password', password); // In production, use encryption!
      
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

      // Verify credentials
      if (password == savedPassword) {
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
