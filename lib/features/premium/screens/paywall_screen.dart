import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/theme/palette.dart';
import '../../../core/widgets/app_background.dart';
import '../../../l10n/app_localizations.dart';

class PaywallScreen extends StatefulWidget {
  /// True when opened because the free PDF uploads are used up.
  final bool limitReached;

  const PaywallScreen({super.key, this.limitReached = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  PremiumPlan _selectedPlan = PremiumPlan.yearly;
  bool _isProcessing = false;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    final l10n = AppLocalizations.of(context)!;
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    setState(() => _isProcessing = true);

    // Simulated store purchase; replace with In-App Purchase before release.
    await Future.delayed(const Duration(milliseconds: 1500));
    await premiumService.activatePlan(_selectedPlan);
    if (!mounted) return;

    setState(() => _isProcessing = false);
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final p = Palette.of(ctx);
        return AlertDialog(
          backgroundColor: p.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Center(
            child: Text(
              l10n.premiumActivatedTitle,
              style: GoogleFonts.poppins(
                color: p.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 72,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.premiumActivatedBody,
                style: GoogleFonts.poppins(
                  color: p.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // dialog
                    Navigator.pop(context); // paywall
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.greatBtn,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = Provider.of<PremiumService>(context);
    final l10n = AppLocalizations.of(context)!;
    final p = Palette.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: p.background,
      body: AppBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: p.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.25),
                                  AppColors.accent.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 52,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.paywallTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: p.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.paywallSubtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: p.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.limitReached &&
                              !premiumService.isPremium) ...[
                            const SizedBox(height: 20),
                            _buildLimitBanner(p, l10n),
                          ],
                          const SizedBox(height: 24),
                          _buildBenefit(
                            p,
                            Icons.library_books_rounded,
                            l10n.benefitUnlimitedPdf,
                            l10n.benefitUnlimitedPdfDesc,
                          ),
                          _buildBenefit(
                            p,
                            Icons.quiz_rounded,
                            l10n.benefitAiQuiz,
                            l10n.benefitAiQuizDesc,
                          ),
                          _buildBenefit(
                            p,
                            Icons.fact_check_rounded,
                            l10n.benefitWrongAnswers,
                            l10n.benefitWrongAnswersDesc,
                          ),
                          _buildBenefit(
                            p,
                            Icons.music_note_rounded,
                            l10n.benefitSounds,
                            l10n.benefitSoundsDesc,
                          ),
                          const SizedBox(height: 20),
                          _buildPlanCard(
                            p,
                            plan: PremiumPlan.yearly,
                            title: l10n.planYearly,
                            period: l10n.planPerYear,
                            note: l10n.planYearlyNote,
                            tag: l10n.planBestValue,
                          ),
                          _buildPlanCard(
                            p,
                            plan: PremiumPlan.monthly,
                            title: l10n.planMonthly,
                            period: l10n.planPerMonth,
                            note: l10n.planMonthlyNote,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isProcessing || premiumService.isPremium
                                  ? null
                                  : _handlePurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: AppColors.accent
                                    .withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      premiumService.isPremium
                                          ? (premiumService.expiry != null
                                                ? l10n.premiumActiveUntil(
                                                    DateFormat.yMMMd(
                                                      locale,
                                                    ).format(
                                                      premiumService.expiry!,
                                                    ),
                                                  )
                                                : l10n.premiumActivatedTitle)
                                          : '${l10n.subscribeNow} · ${_selectedPlan.priceTl} TL',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.paywallTerms,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: p.textSecondary.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.amber,
                  Colors.teal,
                  Colors.orange,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitBanner(Palette p, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.freeLimitReachedTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.freeLimitReachedBody,
                  style: GoogleFonts.poppins(
                    color: p.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(
    Palette p,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: p.accentText, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: p.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    Palette p, {
    required PremiumPlan plan,
    required String title,
    required String period,
    required String note,
    String? tag,
  }) {
    final isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.12) : p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.accent : p.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: p.softShadow,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? p.accentText : p.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: p.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: GoogleFonts.poppins(
                      color: p.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.priceTl} TL',
                  style: GoogleFonts.poppins(
                    color: isSelected ? p.accentText : p.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  period,
                  style: GoogleFonts.poppins(
                    color: p.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
