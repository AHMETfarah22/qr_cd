import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/pdf_document.dart' as models;
import '../../timer/screens/timer_screen.dart';
import '../../auth/screens/account_screen.dart';
import 'ai_quest_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final models.PdfDocument? pdfDocument;
  final int? suggestedMinutes;
  final int initialTab;

  const MainScreen({
    super.key,
    this.pdfDocument,
    this.suggestedMinutes,
    this.initialTab = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _fadeController.forward(from: 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Back on a secondary tab returns to the home tab instead of closing the app.
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onTabTapped(0);
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.background : AppColors.lightBackground,
        body: FadeTransition(
          opacity: _fadeAnimation,
          // IndexedStack keeps every tab alive, so the timer screen does not
          // re-run its PDF setup or miss a session-complete transition while
          // another tab is visible.
          child: IndexedStack(
            index: _currentIndex,
            children: [
              TimerScreen(
                pdfDocument: widget.pdfDocument,
                suggestedMinutes: widget.suggestedMinutes,
              ),
              const AiQuestScreen(),
              const AccountScreen(),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
