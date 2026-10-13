import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/quiz_question.dart';
import '../services/ai_service.dart';
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
  String? _error;
  int _currentIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final questionsJson =
          await AiService.generateQuiz(widget.documentText, questionCount: 5, filePath: widget.filePath);

      final questions =
          questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      _stopwatch.start();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_questions == null) return;
    setState(() {
      _questions![_currentIndex].userAnswer = answer;
    });
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
        builder: (_) => QuizResultScreen(
          result: result,
          documentText: widget.documentText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizBasligi,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_questions != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  l10n.soruSayisi(_currentIndex + 1, _questions!.length),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.transparent),
          ),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState(l10n)
                : _error != null
                    ? _buildErrorState(l10n)
                    : _buildQuizContent(theme, isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aiSorulariHazirliyor,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.buBirkacSaniyeSurebilir,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.quizYuklenemedi,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuiz,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tekrarDene, style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(ThemeData theme, bool isDark, AppLocalizations l10n) {
    final question = _questions![_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions!.length,
              minHeight: 6,
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),

          const SizedBox(height: 24),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Text(
              question.question,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Options
          ...question.options.entries.map(
            (entry) => _buildOptionCard(
              entry.key,
              entry.value,
              question.userAnswer,
              isDark,
              theme,
            ),
          ),

          const SizedBox(height: 24),

          // Next / Finish button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: question.isAnswered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _currentIndex < _questions!.length - 1
                    ? l10n.sonrakiSoru
                    : l10n.sonuclariGor,
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
    String key,
    String value,
    String? selectedAnswer,
    bool isDark,
    ThemeData theme,
  ) {
    final isSelected = selectedAnswer == key;

    return GestureDetector(
      onTap: () => _selectAnswer(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.15)
              : isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.deepPurple
                    : Colors.deepPurple.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  key,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.deepPurple,
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
                  color: theme.colorScheme.onSurface,
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
