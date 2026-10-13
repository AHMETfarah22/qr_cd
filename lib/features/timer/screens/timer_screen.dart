import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../../../core/models/pdf_document.dart' as models;
import '../../auth/services/statistics_service.dart';
import '../../pdf_study/screens/quiz_screen.dart';
import '../../../core/services/premium_service.dart';
import '../services/timer_service.dart';
import '../services/audio_service.dart';
import '../../../l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class TimerScreen extends StatefulWidget {
  final models.PdfDocument? pdfDocument;
  final int? suggestedMinutes;

  const TimerScreen({super.key, this.pdfDocument, this.suggestedMinutes});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;
  final _noteController = TextEditingController();
  TimerState? _previousState;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    // Scale: 1.0 → 1.12 for the glow ring
    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Opacity: 0.6 → 1.0 for the hint text fade
    _pulseOpacityAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _applyPdfSetup();
  }

  @override
  void didUpdateWidget(covariant TimerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // MainScreen hands over a new PDF session when the user starts focusing
    // from the AI analysis screen.
    if (widget.pdfDocument != oldWidget.pdfDocument ||
        widget.suggestedMinutes != oldWidget.suggestedMinutes) {
      _applyPdfSetup();
    }
  }

  void _applyPdfSetup() {
    if (widget.suggestedMinutes == null && widget.pdfDocument == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final timerService = Provider.of<TimerService>(context, listen: false);
      if (widget.suggestedMinutes != null) {
        timerService.setPdfDuration(widget.suggestedMinutes!);
      }
      if (widget.pdfDocument != null) {
        timerService.pdfName = widget.pdfDocument!.fileName;
        timerService.setCategory(SessionCategory.study);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _startAutomaticQuizFlow() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AutoQuizDialog(pdfDocument: widget.pdfDocument!),
    );
  }

  void _handleStateChange(TimerState newState) {
    if (_previousState == newState) return;

    if (newState == TimerState.success) {
      _confettiController.play();
      if (widget.pdfDocument != null) {
        final stats = Provider.of<StatisticsService>(context, listen: false);
        final timerService = Provider.of<TimerService>(context, listen: false);
        stats.completePdfSession((timerService.totalTimeSeconds / 60).ceil());

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _startAutomaticQuizFlow();
        });
      }
    } else if (newState == TimerState.failure) {
      _shakeController.forward(from: 0.0);
    } else if (newState == TimerState.idle) {
      _noteController.clear();
    }

    _previousState = newState;
  }

  Widget _buildShakeWidget(Widget child) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, _) {
        final double offset = sin(_shakeController.value * pi * 10.0) * 8.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final audioService = Provider.of<AudioService>(context);
    final premiumService = Provider.of<PremiumService>(context);
    final l10n = AppLocalizations.of(context)!;

    int totalSeconds = timerService.currentTimeSeconds;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String timerString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStateChange(timerService.state);
      timerService.updateLocalization({
        'successTitle': l10n.notifSuccessTitle,
        'successBody': l10n.notifSuccessBody,
        'breakEndTitle': l10n.notifBreakEndTitle,
        'breakEndBody': l10n.notifBreakEndBody,
      });
    });

    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final screenWidth = mq.size.width;
    // Small screens: height < 700 OR width < 380 (narrow phones)
    final isSmallScreen = screenHeight < 700 || screenWidth < 380;
    // Reduced radius so ring doesn't dominate the whole screen
    final double timerRadius = isSmallScreen ? 90.0 : 108.0;
    // The bottom nav bar lives in MainScreen's Scaffold.bottomNavigationBar,
    // which already removes its height from this screen's layout.
    final double bottomPad = mq.padding.bottom + 24;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildShakeWidget(
            SingleChildScrollView(
              // `physics` ensures it bounces naturally on both iOS & Android
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24.0, mq.padding.top + 8, 24.0, bottomPad),
              child: Column(
                // No mainAxisAlignment: center — doesn't work inside ScrollView
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 8 : 20),
                  // ── Title ──────────────────────────────────────────────
                  Text(
                    l10n.focusTimer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  if (timerService.level > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.level(timerService.level),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: isSmallScreen ? 20 : 36),
                  // ── Timer Ring ─────────────────────────────────────────
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow ring — only when running
                        if (timerService.state == TimerState.running)
                          AnimatedBuilder(
                            animation: _pulseScaleAnimation,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _pulseScaleAnimation.value,
                                child: Container(
                                  width: timerRadius * 2 + 12,
                                  height: timerRadius * 2 + 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.15),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        // Progress ring
                        CircularPercentIndicator(
                          radius: timerRadius,
                          lineWidth: isSmallScreen ? 7.0 : 9.0,
                          percent: timerService.progress.clamp(0.0, 1.0),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: AppColors.process.withValues(alpha: 0.3),
                          progressColor: timerService.state == TimerState.failure
                              ? AppColors.error
                              : AppColors.accent,
                        ),
                        // Time text + badge
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timerString,
                              style: TextStyle(
                                fontSize: hours > 0
                                    ? (isSmallScreen ? 36 : 44)
                                    : (isSmallScreen ? 48 : 58),
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusBadge(timerService, l10n),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 36),
                  // ── State-specific UI ──────────────────────────────────
                  if (timerService.state == TimerState.idle)
                    _buildIdleUI(timerService, l10n, audioService, premiumService),
                  if (timerService.state == TimerState.success)
                    _buildSuccessUI(timerService, l10n),
                  if (timerService.state != TimerState.idle &&
                      timerService.state != TimerState.success)
                    _buildActiveUI(timerService, l10n, audioService),
                  const SizedBox(height: 20),
                  // ── Status hint ────────────────────────────────────────
                  Text(
                    _getStatusMessage(timerService, l10n),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti always on top
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.accent, Colors.white, Colors.green, Colors.yellow, Colors.pink
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TimerService timerService, AppLocalizations l10n) {
    String text;
    Color color;
    switch (timerService.state) {
      case TimerState.idle: text = l10n.ready; color = AppColors.accent; break;
      case TimerState.running: text = l10n.focus; color = AppColors.accent; break;
      case TimerState.paused: text = l10n.paused; color = Colors.orange; break;
      case TimerState.failure: text = l10n.failed; color = AppColors.error; break;
      case TimerState.success: text = l10n.success; color = Colors.green; break;
      case TimerState.breakTime: text = l10n.breakLabel; color = Colors.blue; break;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ]
          ),
          child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
    );
  }

  Widget _buildIdleUI(TimerService timerService, AppLocalizations l10n, AudioService audioService, PremiumService premiumService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (timerService.level > 1)
          Slider(
            value: (timerService.totalTimeSeconds ~/ 60).toDouble().clamp(5.0, 120.0),
            min: 5, max: 120, divisions: 23,
            label: '${timerService.totalTimeSeconds ~/ 60} dk',
            onChanged: (v) => timerService.setDuration(v.toInt()),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
          children: SessionCategory.values
              .map((cat) => _buildCategoryChip(cat, timerService, l10n))
              .toList(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              timerService.startTimer();
              audioService.playStartSound();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
            ),
            child: Text(
              l10n.start,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(SessionCategory cat, TimerService timerService, AppLocalizations l10n) {
    final isSelected = timerService.currentCategory == cat;
    return GestureDetector(
      onTap: () => timerService.setCategory(cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cat.color.withValues(alpha: 0.2) : AppColors.process.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? cat.color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, size: 14, color: isSelected ? cat.color : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(cat.getDisplayName(context), style: TextStyle(color: isSelected ? cat.color : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessUI(TimerService timerService, AppLocalizations l10n) {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.accent, size: 60),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.process.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.addSessionNoteTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      maxLength: 60,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: l10n.sessionNoteHint,
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        counterText: "",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final stats = Provider.of<StatisticsService>(context, listen: false);
                      stats.updateLastSessionNote(_noteController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.saveBtn}!'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.saveBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // PDF Quiz Button
        if (widget.pdfDocument != null) ...[          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      documentId: widget.pdfDocument!.id,
                      documentName: widget.pdfDocument!.fileName,
                      documentText: widget.pdfDocument!.extractedText,
                      filePath: widget.pdfDocument!.filePath,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.quiz_rounded, size: 20),
              label: const Text('🤖 AI Quiz Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.breakTimeTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => timerService.startBreak(15), child: Text(l10n.minBreak(15))),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: () => timerService.startBreak(30), child: Text(l10n.minBreak(30))),
          ],
        ),
        TextButton(onPressed: () => timerService.resetTimer(), child: Text(l10n.dontTakeBreak)),
      ],
    );
  }

  Widget _buildActiveUI(TimerService timerService, AppLocalizations l10n, AudioService audioService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Flip your phone" hint — only shown when actively running
        if (timerService.state == TimerState.running) ...[
          Center(
            child: AnimatedBuilder(
              animation: _pulseOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseOpacityAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.screen_lock_rotation_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.flipPhoneHint,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        // Cancel / End break button
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              audioService.stopAlarm();
              if (timerService.state == TimerState.breakTime) {
                timerService.resetTimer();
              } else {
                final elapsed = timerService.totalTimeSeconds - timerService.currentTimeSeconds;
                timerService.cancelTimer((elapsed / 60).ceil().clamp(1, 120));
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.close_rounded, size: 20),
            label: Text(
              timerService.state == TimerState.breakTime ? l10n.endBreak : l10n.cancel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusMessage(TimerService timerService, AppLocalizations l10n) {
    switch (timerService.state) {
      case TimerState.idle: return timerService.level == 1 ? l10n.statusIdleLvl1 : l10n.statusIdle;
      case TimerState.running: return l10n.statusRunning;
      case TimerState.paused: return l10n.statusPaused;
      case TimerState.failure: return l10n.statusFailure;
      case TimerState.success: return timerService.completedSessions == 1 ? l10n.statusSuccessFirst : l10n.statusSuccess;
      case TimerState.breakTime: return l10n.statusBreak;
    }
  }
}

class _AutoQuizDialog extends StatefulWidget {
  final models.PdfDocument pdfDocument;

  const _AutoQuizDialog({required this.pdfDocument});

  @override
  State<_AutoQuizDialog> createState() => _AutoQuizDialogState();
}

class _AutoQuizDialogState extends State<_AutoQuizDialog> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _countdown = 2);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _countdown = 1);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          documentId: widget.pdfDocument.id,
          documentName: widget.pdfDocument.fileName,
          documentText: widget.pdfDocument.extractedText,
          filePath: widget.pdfDocument.filePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(AppLocalizations.of(context)!.autoQuizTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology_rounded, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.autoQuizDone,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.autoQuizStarting,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              Text(
                '$_countdown',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
