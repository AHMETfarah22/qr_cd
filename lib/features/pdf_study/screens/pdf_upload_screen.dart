import '../../../core/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';
import '../services/pdf_history_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/palette.dart';
import '../../../core/services/premium_service.dart';
import '../../premium/screens/paywall_screen.dart';
import '../../../core/models/pdf_document.dart';
import '../../../l10n/app_localizations.dart';
import '../services/pdf_parser_service.dart';
import '../services/ai_service.dart';
import 'ai_analysis_screen.dart';
import '../widgets/ai_feedback.dart';

class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  String _loadingMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<bool> _showApiKeyPromptDialog() => showGeminiKeyDialog(context);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<bool> _showPrivacyConsentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.process,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.gpp_maybe_rounded, color: AppColors.accentDeep),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.pdfGizlilikOnayiTitle,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.pdfGizlilikOnayiBody,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.reddet,
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.onayla,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickAndProcessPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingMessage = '';
    });

    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context, listen: false);
    final historyService = Provider.of<PdfHistoryService>(
      context,
      listen: false,
    );
    final premiumService = Provider.of<PremiumService>(context, listen: false);

    if (!premiumService.canUploadPdf) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaywallScreen(limitReached: true),
        ),
      );
      return;
    }

    try {
      final hasKey = await AiService.hasApiKey();
      if (!hasKey) {
        final success = await _showApiKeyPromptDialog();
        if (!success) return;
      }
      if (!mounted) return;

      setState(() => _loadingMessage = l10n.gizlilikKontrol);
      final email = authService.userEmail ?? 'anonymous';
      final privacyKey = 'user_${email}_pdf_privacy_accepted';

      final prefs = await SharedPreferences.getInstance();
      final hasAcceptedPrivacy = prefs.getBool(privacyKey) ?? false;
      if (!hasAcceptedPrivacy) {
        final accepted = await _showPrivacyConsentDialog();
        if (!accepted) return;
        await prefs.setBool(privacyKey, true);
      }
      if (!mounted) return;

      setState(() => _loadingMessage = l10n.pdfSeciliyor);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;
      if (!mounted) return;

      final filePath = result.files.single.path!;

      // Step 1: Parse PDF
      setState(() => _loadingMessage = l10n.pdfOkunuyor);
      final pdfDoc = await PdfParserService.parsePdf(filePath);
      if (!mounted) return;

      // Step 2: AI Analysis
      setState(() => _loadingMessage = l10n.aiAnalizEdiyor);
      final analysis = await AiService.estimateReadingTime(
        pdfDoc.extractedText,
        filePath: filePath,
      );

      pdfDoc.estimatedMinutes = analysis['estimatedMinutes'] as int?;
      pdfDoc.difficulty = analysis['difficulty'] as String?;
      pdfDoc.subject = analysis['subject'] as String?;
      pdfDoc.tips = analysis['tips'] as String?;

      // Save to local history and count it against the free quota
      await historyService.savePdf(pdfDoc);
      await premiumService.recordPdfUpload();
      if (!mounted) return;

      // Navigate to analysis screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AiAnalysisScreen(document: pdfDoc)),
      );
    } catch (e) {
      if (e is AiException && e.type == AiErrorType.invalidKey) {
        await AiService.clearApiKey();
      }
      if (mounted) setState(() => _errorMessage = aiErrorMessage(e, l10n));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final premiumService = Provider.of<PremiumService>(context);

    if (!premiumService.canUploadPdf) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.pdfStudyTitle,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 80,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.freeLimitReachedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Palette.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.freeLimitReachedBody,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Palette.of(context).textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PaywallScreen(limitReached: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentDeep,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.premiumYukselt,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.pdfStudyTitle,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.key_rounded, color: AppColors.accent),
              tooltip: 'API Anahtarını Güncelle',
              onPressed: () async {
                await _showApiKeyPromptDialog();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Ana İçerik
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Icon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentDeep,
                              AppColors.accentDeep,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentDeep.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.pdfDestekliCalisma,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      l10n.pdfYukleAciklama,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Dynamic Area: History List or "How it works"
                    Consumer<PdfHistoryService>(
                      builder: (context, historyService, _) {
                        if (historyService.history.isNotEmpty) {
                          return _buildHistoryList(
                            context,
                            historyService.history,
                          );
                        }

                        // Default: How it works
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Nasıl Çalışır?',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStep(
                                '1',
                                l10n.pdfStep1,
                                Icons.upload_file_rounded,
                              ),
                              _buildStep(
                                '2',
                                l10n.pdfStep2,
                                Icons.psychology_rounded,
                              ),
                              _buildStep(
                                '3',
                                l10n.pdfStep3,
                                Icons.timer_rounded,
                              ),
                              _buildStep(
                                '4',
                                l10n.pdfStep4,
                                Icons.quiz_rounded,
                                isLast: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _pickAndProcessPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDeep,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _loadingMessage,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.pdfDosyaSec,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<PdfDocument> history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Çalışılan Belgeler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<PdfHistoryService>(
                  context,
                  listen: false,
                ).clearHistory();
              },
              child: Text(
                'Temizle',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = history[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentDeep.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.accentDeep,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                            color: isDark ? Colors.white : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doc.estimatedMinutes ?? 0} dk • ${doc.pageCount} Sayfa • ${doc.wordCount} Kelime',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Study button
                  IconButton(
                    icon: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.accentDeep,
                      size: 20,
                    ),
                    tooltip: 'Tekrar Çalış',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiAnalysisScreen(document: doc),
                        ),
                      );
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: 'Sil',
                    onPressed: () {
                      Provider.of<PdfHistoryService>(
                        context,
                        listen: false,
                      ).deletePdf(doc.id);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep(
    String number,
    String title,
    IconData icon, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentDeep.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentDeep,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            size: 20,
            color: AppColors.accentDeep.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
