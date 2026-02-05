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
    _userEmail = prefs.getString('user_email');
    _userName = prefs.getString('user_name');
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
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
      
      // Save user data
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password); // In production, use encryption!
      await prefs.setBool('is_logged_in', true);

      _userName = name;
      _userEmail = email;
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
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      final savedName = prefs.getString('user_name');

      // Check if user exists
      if (savedEmail == null) {
        return {'success': false, 'message': 'Kullanıcı bulunamadı. Lütfen kayıt olun'};
      }

      // Verify credentials
      if (email == savedEmail && password == savedPassword) {
        await prefs.setBool('is_logged_in', true);
        
        _userEmail = savedEmail;
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
    _isLoggedIn = false;
    notifyListeners();
  }

  // Delete account
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userEmail = null;
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
