import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/premium_service.dart';
import '../../premium/screens/paywall_screen.dart';
import '../../pdf_study/screens/pdf_upload_screen.dart';
import '../../pdf_study/services/pdf_history_service.dart';
import '../../pdf_study/screens/ai_analysis_screen.dart';
import '../../pdf_study/screens/quiz_screen.dart';
import '../../../core/models/pdf_document.dart';
import '../../auth/services/statistics_service.dart';
import '../../../l10n/app_localizations.dart';

class AiQuestScreen extends StatelessWidget {
  const AiQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final premiumService = Provider.of<PremiumService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background glow effects
              const SizedBox(height: 0),
              // Header
              _buildHeader(context, isDark, l10n),
              const SizedBox(height: 16),
              // Upload Card
              _buildUploadCard(context, isDark, premiumService, l10n),
              const SizedBox(height: 16),
              // Quiz Stats Summary
              Consumer<StatisticsService>(
                builder: (context, stats, _) {
                  return _buildQuizStats(context, stats, isDark, l10n);
                },
              ),
              const SizedBox(height: 16),
              // Recent Documents
              Consumer<PdfHistoryService>(
                builder: (context, historyService, _) {
                  if (historyService.history.isEmpty) {
                    return _buildEmptyState(context, isDark, l10n);
                  }
                  return _buildRecentDocuments(
                    context,
                    historyService,
                    isDark,
                    l10n,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navAiQuest,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                l10n.aiQuestSubtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard(
    BuildContext context,
    bool isDark,
    PremiumService premiumService,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () {
        if (premiumService.canUseFeature(PremiumFeature.unlimitedPdf)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PdfUploadScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.process : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.accent.withValues(alpha: 0.15)
                : AppColors.lightProcess,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120B5D36),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.lightProcess,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: isDark ? AppColors.accent : AppColors.lightTextPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.aiQuestUploadTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.aiQuestUploadDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.textSecondary : Colors.black54,
              ),
            ),
            if (!premiumService.canUseFeature(PremiumFeature.unlimitedPdf)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStats(
    BuildContext context,
    StatisticsService stats,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              _buildMiniStat(
                icon: Icons.picture_as_pdf_rounded,
                value: '${stats.totalPdfSessions}',
                label: l10n.oturum,
                color: Colors.deepPurple,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildMiniStat(
                icon: Icons.quiz_rounded,
                value: '${stats.totalQuizzesTaken}',
                label: l10n.sinav,
                color: Colors.tealAccent.shade400,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildMiniStat(
                icon: Icons.percent_rounded,
                value: '${stats.averageQuizScore.toStringAsFixed(0)}%',
                label: l10n.basariOrani,
                color: Colors.pinkAccent,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: isDark
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : Colors.black26,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.aiQuestNoDocs,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.aiQuestNoDocsDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondary.withValues(alpha: 0.6)
                      : Colors.black38,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDocuments(
    BuildContext context,
    PdfHistoryService historyService,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.aiQuestRecentDocs,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  l10n.aiQuestClearConfirm,
                  l10n,
                );
                if (ok) historyService.clearHistory();
              },
              child: Text(
                l10n.aiQuestClear,
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyService.history.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = historyService.history[index];
            return _buildDocumentCard(context, doc, isDark, l10n);
          },
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    PdfDocument doc,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withValues(alpha: 0.2),
                      Colors.blueAccent.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.deepPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.aiQuestDocMeta(doc.estimatedMinutes ?? 0, doc.pageCount),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Study again
              _buildActionIcon(
                icon: Icons.menu_book_rounded,
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiAnalysisScreen(document: doc),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Quiz
              _buildActionIcon(
                icon: Icons.quiz_rounded,
                color: Colors.tealAccent.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        documentId: doc.id,
                        documentName: doc.fileName,
                        documentText: doc.extractedText,
                        filePath: doc.filePath,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Delete
              _buildActionIcon(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                onTap: () async {
                  final historyService = Provider.of<PdfHistoryService>(
                    context,
                    listen: false,
                  );
                  final ok = await _confirm(
                    context,
                    l10n.aiQuestDeleteConfirm(doc.fileName),
                    l10n,
                  );
                  if (ok) historyService.deletePdf(doc.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.sil,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
