import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:do_not_disturb/do_not_disturb.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/book_illustration.dart';
import '../../../core/services/settings_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final DoNotDisturbPlugin _dndPlugin = DoNotDisturbPlugin();

  bool _isDndGranted = false;
  bool _isPhoneGranted = false;

  // iOS has no app-controllable Do Not Disturb or phone-state permission,
  // so those onboarding pages are shown on Android only.
  final bool _showAndroidPermissionPages = Platform.isAndroid;
  int get _pageCount => _showAndroidPermissionPages ? 5 : 3;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!_showAndroidPermissionPages) return;
    final dndStatus = await _dndPlugin.isNotificationPolicyAccessGranted();
    final phoneStatus = await Permission.phone.isGranted;

    if (mounted) {
      setState(() {
        _isDndGranted = dndStatus;
        _isPhoneGranted = phoneStatus;
      });
    }
  }

  Future<void> _requestDnd() async {
    await _dndPlugin.openNotificationPolicyAccessSettings();
    // After returning from settings, check again
    await Future.delayed(const Duration(seconds: 1));
    final dndStatus = await _dndPlugin.isNotificationPolicyAccessGranted();
    if (mounted) {
      setState(() => _isDndGranted = dndStatus);
    }
  }

  Future<void> _requestPhone() async {
    final status = await Permission.phone.request();
    if (mounted) {
      setState(() => _isPhoneGranted = status.isGranted);
    }
  }

  void _onNext() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Provider.of<SettingsService>(
      context,
      listen: false,
    ).setOnboardingCompleted(true);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  _checkPermissions(); // Re-check when sliding back/forth
                },
                children: [
                  _buildWelcomePage(l10n),
                  _buildPdfAiPage(l10n),
                  _buildSensorPage(l10n),
                  if (_showAndroidPermissionPages) ...[
                    _buildDndPage(l10n),
                    _buildPhonePage(l10n),
                  ],
                ],
              ),
            ),
            _buildBottomControls(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return _buildPageContent(
      icon: Icons.auto_awesome_rounded,
      title: l10n.onboardingWelcome,
      description: l10n.onboardingWelcomeDesc,
    );
  }

  Widget _buildSensorPage(AppLocalizations l10n) {
    return _buildPageContent(
      icon: Icons.screen_rotation_rounded,
      title: l10n.onboardingSensorTitle,
      description: l10n.onboardingSensorDesc,
      extra: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.permissionGranted,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDndPage(AppLocalizations l10n) {
    return _buildPageContent(
      icon: Icons.do_not_disturb_on_rounded,
      title: l10n.onboardingDndTitle,
      description: l10n.onboardingDndDesc,
      extra: ElevatedButton.icon(
        onPressed: _isDndGranted ? null : _requestDnd,
        icon: Icon(_isDndGranted ? Icons.check : Icons.settings),
        label: Text(_isDndGranted ? l10n.permissionGranted : l10n.btnGrant),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isDndGranted ? Colors.grey[800] : AppColors.accent,
          foregroundColor: _isDndGranted ? Colors.white70 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPhonePage(AppLocalizations l10n) {
    return _buildPageContent(
      icon: Icons.phone_callback_rounded,
      title: l10n.onboardingPhoneTitle,
      description: l10n.onboardingPhoneDesc,
      extra: ElevatedButton.icon(
        onPressed: _isPhoneGranted ? null : _requestPhone,
        icon: Icon(_isPhoneGranted ? Icons.check : Icons.security),
        label: Text(_isPhoneGranted ? l10n.permissionGranted : l10n.btnGrant),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPhoneGranted
              ? Colors.grey[800]
              : AppColors.accent,
          foregroundColor: _isPhoneGranted ? Colors.white70 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPageContent({
    required IconData icon,
    required String title,
    required String description,
    Widget? extra,
    Widget? illustration,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            illustration ?? Icon(icon, size: 92, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (extra != null) ...[const SizedBox(height: 20), extra],
          ],
        );

        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: constraints.maxHeight < 500
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: content),
                )
              : Center(child: content),
        );
      },
    );
  }

  Widget _buildPdfAiPage(AppLocalizations l10n) {
    return _buildPageContent(
      icon: Icons.psychology_rounded,
      illustration: const BookIllustration(width: 200),
      title: l10n.onboardingPdfTitle,
      description: l10n.onboardingPdfDesc,
      extra: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.deepPurpleAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.onboardingPdfExtra,
              style: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicators
          Row(
            children: List.generate(_pageCount, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.accent
                      : AppColors.process,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next/Start Button
          ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == _pageCount - 1 ? l10n.btnStart : l10n.btnNext,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
