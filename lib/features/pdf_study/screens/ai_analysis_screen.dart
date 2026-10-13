import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/palette.dart';
import '../../../core/models/pdf_document.dart' as models;
import '../../../core/services/settings_service.dart';
import '../../../core/services/premium_service.dart';
import '../../core/screens/main_screen.dart';
import '../../../l10n/app_localizations.dart';

class AiAnalysisScreen extends StatelessWidget {
  final models.PdfDocument document;

  const AiAnalysisScreen({super.key, required this.document});

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'kolay':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'zor':
        return Colors.red;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  IconData _getDifficultyIcon(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'kolay':
        return Icons.sentiment_satisfied_rounded;
      case 'orta':
        return Icons.sentiment_neutral_rounded;
      case 'zor':
        return Icons.sentiment_dissatisfied_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diffColor = _getDifficultyColor(document.difficulty);

    final settingsService = Provider.of<SettingsService>(context);
    final premiumService = Provider.of<PremiumService>(context);

    int minutes = document.estimatedMinutes ?? 25;

    if (premiumService.canUseFeature(PremiumFeature.personalizedSpeed)) {
      switch (settingsService.readingSpeed) {
        case ReadingSpeed.slow:
          minutes = (minutes * 1.3).ceil();
          break;
        case ReadingSpeed.fast:
          minutes = (minutes * 0.75).floor();
          if (minutes < 5) minutes = 5;
          break;
        case ReadingSpeed.normal:
          break;
      }
    }

    final l10n = AppLocalizations.of(context)!;
    final p = Palette.of(context);

    return AppBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.aiAnalizSonuclari,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: p.accentText),
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                // Document Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Deep green keeps the white text readable.
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accentDeep, Color(0xFF0E4D2A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.16,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        document.fileName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.pagesWords(document.pageCount, document.wordCount),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Estimated Time - Big Number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: p.cardDecoration(radius: 24),
                  child: Column(
                    children: [
                      Icon(Icons.timer_rounded, size: 36, color: p.accentText),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tahminiOkumaSuresi,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tahminiSureDk(minutes),
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        icon: Icons.school_rounded,
                        label: l10n.dersAdi,
                        value: document.subject ?? 'Genel',
                        color: AppColors.accent,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        icon: _getDifficultyIcon(document.difficulty),
                        label: l10n.zorlukDerecesi,
                        value: document.difficulty ?? 'Bilinmiyor',
                        color: diffColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                // Tips
                if (document.tips != null && document.tips!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(
                        alpha: isDark ? 0.1 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            document.tips!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: p.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Start Focus Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to timer with the AI-suggested duration
                      MainScreen.startPdfSession(
                        context,
                        document: document,
                        suggestedMinutes: minutes,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentDeep,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          l10n.minuteFocus(minutes),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Custom Time Button
                TextButton(
                  onPressed: () {
                    _showCustomTimeDialog(context, minutes);
                  },
                  child: Text(
                    l10n.farkliSureSec,
                    style: GoogleFonts.poppins(
                      color: p.accentText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.process : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardGlow : AppColors.lightProcess,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCustomTimeDialog(BuildContext context, int suggestedMinutes) {
    int selectedMinutes = suggestedMinutes;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.sureSec,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mins(selectedMinutes),
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Palette.of(ctx).textPrimary,
                  ),
                ),
                Slider(
                  value: selectedMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: AppColors.accent,
                  label: l10n.minutesValue(selectedMinutes),
                  onChanged: (v) {
                    setDialogState(() => selectedMinutes = v.round());
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancelBtn, style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  MainScreen.startPdfSession(
                    context,
                    document: document,
                    suggestedMinutes: selectedMinutes,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.start,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
