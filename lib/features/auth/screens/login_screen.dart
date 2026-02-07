
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_text_field.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'account_screen.dart';
import '../../timer/screens/timer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen e-posta ve şifrenizi girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TimerScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (authService.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.person_rounded, color: AppColors.accent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
            const SizedBox(height: 20),
            // Logo or Icon Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 60,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Hoş Geldiniz",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Odaklanmaya ve üretkenliğe bugün başlayın.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("E-posta *", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            CommonTextField(
              controller: _emailController,
              hintText: 'eposta@ornek.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Şifre *", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _passwordController,
              hintText: 'Şifrenizi giriniz',
              obscureText: true,
              showPasswordToggle: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.accent)
                : CommonButton(
                    text: "Giriş Yap",
                    onPressed: _handleLogin,
                  ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                const Text("Hesabınız yok mu? ", style: TextStyle(color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
