import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/palette.dart';
import '../../../l10n/app_localizations.dart';
import '../services/ai_service.dart';

/// A short, localized explanation of why an AI request failed.
String aiErrorMessage(Object error, AppLocalizations l10n) {
  if (error is! AiException) return l10n.aiErrGeneric;
  switch (error.type) {
    case AiErrorType.missingKey:
      return l10n.aiErrMissingKey;
    case AiErrorType.invalidKey:
    case AiErrorType.noCredits:
      // Key/billing problems are the developer's to fix; students just see
      // that AI is unavailable.
      return l10n.aiErrUnavailable;
    case AiErrorType.busy:
      return l10n.aiErrBusy;
    case AiErrorType.rateLimited:
      return l10n.aiErrRateLimit;
    case AiErrorType.network:
      return l10n.aiErrNetwork;
    case AiErrorType.fileMissing:
      return l10n.aiErrFileMissing;
    case AiErrorType.badResponse:
      return l10n.aiErrBadResponse;
    case AiErrorType.unknown:
      return l10n.aiErrGeneric;
  }
}

/// True when no API key is configured at all (only in builds without
/// secrets.json), so entering one is the fix.
bool aiErrorNeedsKey(Object? error) =>
    error is AiException && error.type == AiErrorType.missingKey;

/// Asks for a Gemini API key and stores it. Returns true when a key was saved.
Future<bool> showGeminiKeyDialog(BuildContext context) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final p = Palette.of(ctx);
      final l10n = AppLocalizations.of(ctx)!;
      return AlertDialog(
        backgroundColor: p.dialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.key_rounded, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.apiKeyDialogTitle,
                style: GoogleFonts.poppins(
                  color: p.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.apiKeyDialogBody,
                style: GoogleFonts.poppins(
                  color: p.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                l10n.apiKeyWhere,
                style: GoogleFonts.poppins(
                  color: p.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: p.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'sk-... / AIza...',
                  hintStyle: TextStyle(color: p.textSecondary),
                  filled: true,
                  fillColor: p.cardMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.apiKeyRequired;
                  }
                  if (!AiService.looksLikeApiKey(val)) {
                    return l10n.apiKeyInvalidFormat;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: p.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await AiService.saveApiKey(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentDeep,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveBtn),
          ),
        ],
      );
    },
  );
  // The controller is not disposed here: the dialog's closing animation can
  // still rebuild the field that listens to it.
  return saved ?? false;
}
