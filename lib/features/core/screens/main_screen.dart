import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/models/pdf_document.dart' as models;
import '../../timer/screens/timer_screen.dart';
import '../../auth/screens/account_screen.dart';
import '../../auth/screens/statistics_chart_screen.dart';
import '../../auth/screens/session_history_screen.dart';
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

  /// Switches the enclosing MainScreen to [index], e.g. from a tab's button.
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainScreenState>()?._onTabTapped(index);
  }

  static final ValueNotifier<_PdfSessionRequest?> _pdfSessionRequest =
      ValueNotifier(null);
  static int _mountedCount = 0;

  /// Returns to the root MainScreen and prepares the timer for [document]
  /// instead of stacking a second MainScreen (which would leave two timer
  /// screens reacting to the same session).
  static void startPdfSession(
    BuildContext context, {
    required models.PdfDocument document,
    int? suggestedMinutes,
  }) {
    final navigator = Navigator.of(context);
    if (_mountedCount == 0) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScreen(
            pdfDocument: document,
            suggestedMinutes: suggestedMinutes,
          ),
        ),
        (route) => false,
      );
      return;
    }
    navigator.popUntil((route) => route.isFirst);
    _pdfSessionRequest.value = _PdfSessionRequest(document, suggestedMinutes);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _PdfSessionRequest {
  final models.PdfDocument document;
  final int? suggestedMinutes;
  _PdfSessionRequest(this.document, this.suggestedMinutes);
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  models.PdfDocument? _pdfDocument;
  int? _suggestedMinutes;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pdfDocument = widget.pdfDocument;
    _suggestedMinutes = widget.suggestedMinutes;
    MainScreen._mountedCount++;
    MainScreen._pdfSessionRequest.addListener(_onPdfSessionRequested);
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

  void _onPdfSessionRequested() {
    final request = MainScreen._pdfSessionRequest.value;
    if (request == null || !mounted) return;
    MainScreen._pdfSessionRequest.value = null;
    setState(() {
      _pdfDocument = request.document;
      _suggestedMinutes = request.suggestedMinutes;
    });
    _onTabTapped(0);
  }

  @override
  void dispose() {
    MainScreen._mountedCount--;
    MainScreen._pdfSessionRequest.removeListener(_onPdfSessionRequested);
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
    // Back on a secondary tab returns to the home tab instead of closing the app.
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onTabTapped(0);
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FadeTransition(
            opacity: _fadeAnimation,
            // IndexedStack keeps every tab alive, so the timer screen does not
            // re-run its PDF setup or miss a session-complete transition while
            // another tab is visible.
            child: IndexedStack(
              index: _currentIndex,
              children: [
                TimerScreen(
                  pdfDocument: _pdfDocument,
                  suggestedMinutes: _suggestedMinutes,
                ),
                const AiQuestScreen(),
                const StatisticsChartScreen(embedded: true),
                const SessionHistoryScreen(embedded: true),
                const AccountScreen(),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
