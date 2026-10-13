import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/theme/palette.dart';
import '../../../core/widgets/book_illustration.dart';
import '../../premium/screens/paywall_screen.dart';
import '../../pdf_study/screens/all_documents_screen.dart';
import '../../pdf_study/screens/pdf_upload_screen.dart';
import '../../pdf_study/services/pdf_history_service.dart';
import '../../pdf_study/widgets/document_card.dart';
import '../../auth/services/statistics_service.dart';
import '../../../l10n/app_localizations.dart';

class AiQuestScreen extends StatelessWidget {
  const AiQuestScreen({super.key});

  /// How many recent documents the tab shows; the rest are behind a button.
  static const int recentLimit = 3;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final premiumService = Provider.of<PremiumService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(p, l10n),
              const SizedBox(height: 16),
              _buildUploadCard(context, p, premiumService, l10n),
              const SizedBox(height: 16),
              Consumer<StatisticsService>(
                builder: (context, stats, _) => _buildQuizStats(p, stats, l10n),
              ),
              const SizedBox(height: 20),
              Consumer<PdfHistoryService>(
                builder: (context, historyService, _) {
                  if (historyService.history.isEmpty) {
                    return _buildEmptyState(p, l10n);
                  }
                  return _buildRecentDocuments(
                    context,
                    p,
                    historyService,
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

  Widget _buildHeader(Palette p, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E8A4C), AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navAiQuest,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              Text(
                l10n.aiQuestSubtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: p.textSecondary,
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
    Palette p,
    PremiumService premiumService,
    AppLocalizations l10n,
  ) {
    final canUpload = premiumService.canUploadPdf;

    void onTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => canUpload
              ? const PdfUploadScreen()
              : const PaywallScreen(limitReached: true),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: p
            .cardDecoration(radius: 22)
            .copyWith(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: p.isDark ? 0.16 : 0.18),
                  p.card,
                ],
              ),
            ),
        child: Column(
          children: [
            const BookIllustration(width: 170),
            const SizedBox(height: 6),
            Text(
              l10n.aiQuestUploadTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.aiQuestUploadDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: p.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(
                  canUpload
                      ? Icons.upload_file_rounded
                      : Icons.workspace_premium_rounded,
                ),
                label: Text(
                  canUpload ? l10n.pdfStudyTitle : l10n.premiumYukselt,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canUpload
                      ? AppColors.accentDeep
                      : Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  // No fixed height: Poppins' tall line box clipped the label.
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (!premiumService.isPremium) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canUpload
                        ? Icons.card_giftcard_rounded
                        : Icons.lock_rounded,
                    size: 14,
                    color: canUpload ? p.accentText : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      canUpload
                          ? l10n.freePdfRemaining(
                              premiumService.freePdfRemaining,
                            )
                          : l10n.freeLimitReachedTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: canUpload
                            ? p.textPrimary
                            : Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStats(
    Palette p,
    StatisticsService stats,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: p.cardDecoration(),
      child: Row(
        children: [
          _buildMiniStat(
            p,
            Icons.menu_book_rounded,
            '${stats.totalPdfSessions}',
            l10n.oturum,
            const Color(0xFF1E8A4C),
          ),
          _buildDivider(p),
          _buildMiniStat(
            p,
            Icons.quiz_rounded,
            '${stats.totalQuizzesTaken}',
            l10n.sinav,
            Colors.teal,
          ),
          _buildDivider(p),
          _buildMiniStat(
            p,
            Icons.percent_rounded,
            '${stats.averageQuizScore.toStringAsFixed(0)}%',
            l10n.basariOrani,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    Palette p,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: p.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Palette p) {
    return Container(width: 1, height: 44, color: p.border);
  }

  Widget _buildEmptyState(Palette p, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: p.cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.auto_stories_rounded, size: 40, color: p.textSecondary),
          const SizedBox(height: 12),
          Text(
            l10n.aiQuestNoDocs,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.aiQuestNoDocsDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: p.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments(
    BuildContext context,
    Palette p,
    PdfHistoryService historyService,
    AppLocalizations l10n,
  ) {
    final history = historyService.history;
    final recent = history.take(recentLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiQuestRecentDocs,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final doc in recent) ...[
          DocumentCard(doc: doc),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllDocumentsScreen()),
            ),
            icon: const Icon(Icons.folder_open_rounded),
            label: Text(
              l10n.aiQuestAllDocs(history.length),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: p.accentText.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
