import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/palette.dart';
import '../../core/screens/main_screen.dart';
import '../../../core/models/session_category.dart';
import '../services/statistics_service.dart';
import 'package:tscan/l10n/app_localizations.dart';

class SessionHistoryScreen extends StatelessWidget {
  /// True when shown as a bottom-navigation tab (no back button).
  final bool embedded;

  const SessionHistoryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final statsService = Provider.of<StatisticsService>(context);
    final sessions = statsService.sessionHistory;
    final p = Palette.of(context);

    return Scaffold(
      backgroundColor: embedded ? Colors.transparent : p.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.historyTitle,
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
        automaticallyImplyLeading: false,
        leading: embedded
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: p.accentText),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: p.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noHistoryYet,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.startFocusNow,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => embedded
                        ? MainScreen.switchTab(context, 0)
                        : Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.startFocusingBtn),
                  ),
                ],
              ),
            )
            : Column(
                children: [
                  _buildWeeklySummary(context, statsService),
                  Expanded(
                    child: _buildSessionList(context, sessions),
                  ),
                ],
              ),
    );
  }

  Widget _buildSessionCard({
    required int duration,
    required bool completed,
    required DateTime date,
    required SessionCategory category,
    required String note,
    required BuildContext context,
  }) {
    final p = Palette.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', locale);
    final timeAgo = _getTimeAgo(date, context);

    final hours = duration ~/ 60;
    final minutes = duration % 60;
    String durationText;
    if (hours > 0) {
      durationText = '$hours${AppLocalizations.of(context)!.hoursShort} $minutes${AppLocalizations.of(context)!.minutesShort}';
    } else {
      durationText = AppLocalizations.of(context)!.mins(minutes);
    }

    final statusColor = completed ? Colors.green : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: p.cardDecoration(radius: 16).copyWith(
            gradient: LinearGradient(
              colors: [statusColor.withValues(alpha: 0.12), p.card],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.2),
          ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_circle : Icons.cancel,
              color: completed ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      completed ? AppLocalizations.of(context)!.successLabel : AppLocalizations.of(context)!.failedLabel,
                      style: TextStyle(
                        color: completed ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  durationText,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 14,
                      color: category.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.getDisplayName(context),
                      style: TextStyle(
                        color: category.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.cardMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 14,
                          color: p.accentText,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, List<Map<String, dynamic>> sessions) {
    final p = Palette.of(context);
    // Group sessions by calendar day
    final groupedSessions = <DateTime, List<Map<String, dynamic>>>{};

    for (var session in sessions) {
      final date = session['date'] as DateTime;
      final dateKey = DateTime(date.year, date.month, date.day);
      groupedSessions.putIfAbsent(dateKey, () => []).add(session);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groupedSessions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedSessions.keys.elementAt(index);
        final daySessions = groupedSessions[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Text(
                _getDateLabel(dateKey, context),
                style: TextStyle(
                  color: p.accentText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ...daySessions.map((session) {
              final duration = session['duration'] as int;
              final completed = session['completed'] as bool;
              final date = session['date'] as DateTime;
              final category = session['category'] as SessionCategory;
              final note = session['note'] as String? ?? '';

              return _buildSessionCard(
                duration: duration,
                completed: completed,
                date: date,
                category: category,
                note: note,
                context: context,
              );
            }),
          ],
        );
      },
    );
  }

  String _getDateLabel(DateTime day, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysAgo = today.difference(day).inDays;

    if (daysAgo == 0) return AppLocalizations.of(context)!.today;
    if (daysAgo == 1) return AppLocalizations.of(context)!.yesterday;
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('dd MMM yyyy', locale).format(day).toUpperCase();
  }

  Widget _buildWeeklySummary(BuildContext context, StatisticsService stats) {
    final weeklyMinutes = stats.weeklyTotalMinutes;
    final hours = weeklyMinutes ~/ 60;
    final minutes = weeklyMinutes % 60;
    final hasCertificate = stats.hasWeeklyCertificate;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasCertificate ? Colors.blue.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCertificate ? Colors.blue.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasCertificate ? Colors.blue.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 36,
              color: hasCertificate ? Colors.blue : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCertificate ? AppLocalizations.of(context)!.weeklyGoalSuccess : AppLocalizations.of(context)!.weeklyGoalFailed,
                  style: TextStyle(
                    color: hasCertificate ? Colors.blue : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.weeklyMinutesNote(hours, minutes),
                  style: TextStyle(
                    color: Palette.of(context).textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (!hasCertificate)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!.moreMinutesRequired(300 - weeklyMinutes),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inMinutes < 1) {
      return l10n.timeAgoJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeAgoMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHours(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.timeAgoDays(difference.inDays);
    } else if (difference.inDays < 30) {
      return l10n.timeAgoWeeks((difference.inDays / 7).floor());
    } else if (difference.inDays < 365) {
      return l10n.timeAgoMonths((difference.inDays / 30).floor());
    } else {
      return l10n.timeAgoYears((difference.inDays / 365).floor());
    }
  }
}
