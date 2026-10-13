import '../../../core/widgets/app_background.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../../core/models/quiz_question.dart';
import '../../auth/services/statistics_service.dart';
import '../services/ai_service.dart';
import '../../../l10n/app_localizations.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizResult result;
  final String documentText;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.documentText,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  String? _aiAnalysis;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (widget.result.scorePercent >= 80) {
      _confettiController.play();
    }

    // Eğer yanlış cevaplar varsa AI analizi başlat
    if (widget.result.wrongAnswers.isNotEmpty) {
      _loadAiAnalysis();
    }

    // İstatistik servisine quiz sonucunu kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticsService>(
        context,
        listen: false,
      ).completeQuiz(widget.result.scorePercent.round());
    });
  }

  Future<void> _loadAiAnalysis() async {
    setState(() => _isAnalyzing = true);
    try {
      final wrongData = widget.result.wrongAnswers
          .map((q) => q.toJson())
          .toList();
      final analysis = await AiService.analyzeWrongAnswers(
        widget.documentText,
        wrongData,
      );
      setState(() {
        _aiAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _aiAnalysis = null;
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final result = widget.result;
    final score = result.scorePercent;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.quizSonuclari,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score Circle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: score >= 80
                              ? [Colors.green.shade400, Colors.teal.shade400]
                              : score >= 50
                              ? [Colors.orange.shade400, Colors.amber.shade400]
                              : [Colors.red.shade400, Colors.pink.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (score >= 80 ? Colors.green : Colors.orange)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getEmoji(score),
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.dogruSoruSayisi(
                              result.correctCount,
                              result.totalCount,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMessage(score, l10n),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Analysis for wrong answers
                    if (_isAnalyzing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(
                            alpha: isDark ? 0.1 : 0.05,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.aiYanlisAnalizi,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                    if (_aiAnalysis != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(
                            alpha: isDark ? 0.1 : 0.05,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.psychology_rounded,
                                  color: Colors.blue,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.aiKocAnalizi,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _aiAnalysis!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.6,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Question Review
                    Text(
                      l10n.soruDetaylari,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...result.questions.asMap().entries.map(
                      (entry) => _buildQuestionReview(
                        entry.key + 1,
                        entry.value,
                        isDark,
                        theme,
                        l10n,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Back Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDeep,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.anaSayfayaDon,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  AppColors.accentDeep,
                  Colors.orange,
                  Colors.pink,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview(
    int number,
    QuizQuestion question,
    bool isDark,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isCorrect = question.isCorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: isDark ? 0.1 : 0.05)
            : Colors.red.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? Colors.green : Colors.red,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.soruNo(number),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.4,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          if (!isCorrect) ...[
            Text(
              l10n.seninCevabin(question.userAnswer ?? ''),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
            Text(
              l10n.dogruCevap(question.correctAnswer),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '💡 ${question.explanation}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (!isCorrect &&
              question.pageReference != null &&
              question.pageReference!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: Colors.red.shade400,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'İlgili Bölüm: ${question.pageReference}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmoji(double score) {
    if (score >= 80) return '🏆';
    if (score >= 60) return '👍';
    if (score >= 40) return '📚';
    return '💪';
  }

  String _getMessage(double score, AppLocalizations l10n) {
    if (score >= 80) return l10n.muhtesemKonuyaHakimsin;
    if (score >= 60) return l10n.iyiGidiyorsunTekrar;
    if (score >= 40) return l10n.gelismeAlaninVar;
    return l10n.tekrarCalismalisin;
  }
}
