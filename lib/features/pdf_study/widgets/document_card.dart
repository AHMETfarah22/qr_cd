import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/pdf_document.dart';
import '../../../core/theme/palette.dart';
import '../../../l10n/app_localizations.dart';
import '../screens/ai_analysis_screen.dart';
import '../screens/quiz_screen.dart';
import '../services/pdf_history_service.dart';

/// A studied PDF row with shortcuts to study again, take the quiz or delete it.
class DocumentCard extends StatelessWidget {
  final PdfDocument doc;

  const DocumentCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l10n = AppLocalizations.of(context)!;

    // A row, not a card: lists group these inside one GlassGroup.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E8A4C), Color(0xFF0F5A30)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 22,
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
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.aiQuestDocMeta(doc.estimatedMinutes ?? 0, doc.pageCount),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _ActionIcon(
            icon: Icons.play_circle_fill_rounded,
            color: p.accentText,
            tooltip: l10n.tekrarCalis,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiAnalysisScreen(document: doc),
              ),
            ),
          ),
          _ActionIcon(
            icon: Icons.quiz_rounded,
            color: Colors.teal,
            tooltip: l10n.aiQuizBaslat,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  documentId: doc.id,
                  documentName: doc.fileName,
                  documentText: doc.extractedText,
                  filePath: doc.filePath,
                ),
              ),
            ),
          ),
          _ActionIcon(
            icon: Icons.delete_outline_rounded,
            color: Colors.redAccent,
            tooltip: l10n.sil,
            onTap: () async {
              final historyService = Provider.of<PdfHistoryService>(
                context,
                listen: false,
              );
              final ok = await confirmDialog(
                context,
                l10n.aiQuestDeleteConfirm(doc.fileName),
              );
              if (ok) historyService.deletePdf(doc.id);
            },
          ),
        ],
      ),
    );
  }
}

/// Simple cancel / delete confirmation.
Future<bool> confirmDialog(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context)!;
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
    );
  }
}
