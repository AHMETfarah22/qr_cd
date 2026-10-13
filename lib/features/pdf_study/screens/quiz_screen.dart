import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/quiz_question.dart';
import '../../../core/theme/palette.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/book_illustration.dart';
import '../services/ai_service.dart';
import '../widgets/ai_feedback.dart';
import 'quiz_result_screen.dart';
import '../../../l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  final String documentId;
  final String documentName;
  final String documentText;
  final String? filePath;

  const QuizScreen({
    super.key,
    required this.documentId,
    required this.documentName,
    required this.documentText,
    this.filePath,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion>? _questions;
  bool _isLoading = true;
  Object? _error;
  int _currentIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Ask for the key up front instead of failing with "key not found".
    if (!await AiService.hasApiKey()) {
      if (!mounted) return;
      final saved = await showGeminiKeyDialog(context);
      if (!saved) {
        if (mounted) {
          setState(() {
            _error = const AiException(AiErrorType.missingKey);
            _isLoading = false;
          });
        }
        return;
      }
    }

    try {
      final questionsJson = await AiService.generateQuiz(
        widget.documentText,
        questionCount: 5,
        filePath: widget.filePath,
      );
      final questions = questionsJson
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _stopwatch.start();
    } catch (e) {
      if (e is AiException && e.type == AiErrorType.invalidKey) {
        await AiService.clearApiKey();
      }
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _enterKeyAndRetry() async {
    final saved = await showGeminiKeyDialog(context);
    if (saved) _loadQuiz();
  }

  void _selectAnswer(String answer) {
    if (_questions == null) return;
    setState(() => _questions![_currentIndex].userAnswer = answer);
  }

  void _nextQuestion() {
    if (_questions == null) return;
    if (_currentIndex < _questions!.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _stopwatch.stop();
    final result = QuizResult(
      documentId: widget.documentId,
      documentName: widget.documentName,
      questions: _questions!,
      completedAt: DateTime.now(),
      totalTimeSeconds: _stopwatch.elapsed.inSeconds,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizResultScreen(result: result, documentText: widget.documentText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = Palette.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.quizBasligi,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: p.accentText),
          actions: [
            if (_questions != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    l10n.soruSayisi(_currentIndex + 1, _questions!.length),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: _isLoading
              ? _buildLoadingState(p, l10n)
              : _error != null
              ? _buildErrorState(p, l10n)
              : _buildQuizContent(p, l10n),
        ),
      ),
    );
  }

  Widget _buildLoadingState(Palette p, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookIllustration(width: 190),
            const SizedBox(height: 20),
            Text(
              l10n.aiSorulariHazirliyor,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.buBirkacSaniyeSurebilir,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: p.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
                color: AppColors.accent,
                backgroundColor: p.cardMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Palette p, AppLocalizations l10n) {
    final needsKey = aiErrorNeedsKey(_error);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: p.cardDecoration(radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                needsKey ? Icons.key_rounded : Icons.cloud_off_rounded,
                size: 56,
                color: needsKey ? Colors.amber.shade700 : Colors.redAccent,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.quizYuklenemedi,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aiErrorMessage(_error!, l10n),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: p.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              if (needsKey)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enterKeyAndRetry,
                    icon: const Icon(Icons.key_rounded),
                    label: Text(l10n.enterApiKeyBtn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentDeep,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (needsKey) const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadQuiz,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tekrarDene),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: p.accentText.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(Palette p, AppLocalizations l10n) {
    final question = _questions![_currentIndex];
    final isLast = _currentIndex == _questions!.length - 1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions!.length,
            minHeight: 7,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: p.cardMuted,
            color: AppColors.accent,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: p.cardDecoration(radius: 20),
            child: Text(
              question.question,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...question.options.entries.map(
            (entry) => _buildOptionCard(
              p,
              entry.key,
              entry.value,
              question.userAnswer,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: question.isAnswered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDeep,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accentDeep.withValues(
                  alpha: 0.3,
                ),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              child: Text(
                isLast ? l10n.sonuclariGor : l10n.sonrakiSoru,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    Palette p,
    String key,
    String value,
    String? selectedAnswer,
  ) {
    final isSelected = selectedAnswer == key;

    return GestureDetector(
      onTap: () => _selectAnswer(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.16) : p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : p.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: p.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accentDeep
                    : AppColors.accent.withValues(alpha: 0.14),
              ),
              child: Center(
                child: Text(
                  key,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : p.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: p.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
