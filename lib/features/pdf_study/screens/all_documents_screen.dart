import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/palette.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/book_illustration.dart';
import '../../../core/widgets/glass.dart';
import '../../../l10n/app_localizations.dart';
import '../services/pdf_history_service.dart';
import '../widgets/document_card.dart';

/// Every studied PDF, newest first. Opened from the AI Quest tab, which only
/// shows the latest few.
class AllDocumentsScreen extends StatelessWidget {
  const AllDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final l10n = AppLocalizations.of(context)!;
    final history = Provider.of<PdfHistoryService>(context).history;

    return Scaffold(
      backgroundColor: p.background,
      body: AppBackground(
        child: Column(
          children: [
            AppBar(
              title: Text(
                l10n.allDocsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: p.textPrimary,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: p.accentText),
              actions: [
                if (history.isNotEmpty)
                  IconButton(
                    tooltip: l10n.aiQuestClear,
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final historyService = Provider.of<PdfHistoryService>(
                        context,
                        listen: false,
                      );
                      final ok = await confirmDialog(
                        context,
                        l10n.aiQuestClearConfirm,
                      );
                      if (ok) historyService.clearHistory();
                    },
                  ),
              ],
            ),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BookIllustration(width: 170),
                          const SizedBox(height: 16),
                          Text(
                            l10n.aiQuestNoDocs,
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        24 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: GlassGroup(
                        children: [
                          for (final doc in history) DocumentCard(doc: doc),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
