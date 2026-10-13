import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../../../core/theme/palette.dart';
import '../services/statistics_service.dart';
import 'package:tscan/l10n/app_localizations.dart';

/// Student-focused statistics: how much was studied (total and this week vs.
/// the weekly goal), streak, success and quiz average, minutes per day for
/// the last week and time per subject.
class StatisticsChartScreen extends StatelessWidget {
  /// True when shown as a bottom-navigation tab (no back button).
  final bool embedded;

  const StatisticsChartScreen({super.key, this.embedded = false});

  /// Matches StatisticsService.hasWeeklyCertificate (5 hours).
  static const int weeklyGoalMinutes = 300;

  @override
  Widget build(BuildContext context) {
    final stats = Provider.of<StatisticsService>(context);
    final l10n = AppLocalizations.of(context)!;
    final p = Palette.of(context);

    return Scaffold(
      backgroundColor: embedded ? Colors.transparent : p.background,
      appBar: AppBar(
        title: Text(
          l10n.statisticsTitle,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(p, l10n, stats),
            const SizedBox(height: 12),
            _buildTiles(p, l10n, stats),
            _buildSectionHeader(
              p,
              Icons.bar_chart_rounded,
              l10n.statsDailyMinutes,
            ),
            _buildDailyMinutesChart(context, p, stats),
            _buildSectionHeader(p, Icons.school_rounded, l10n.statsBySubject),
            _buildSubjectTime(context, p, l10n, stats),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(AppLocalizations l10n, int minutes) {
    if (minutes < 60) return l10n.minutesValue(minutes);
    return l10n.hoursMinutesShort(minutes ~/ 60, minutes % 60);
  }

  Widget _buildHeroCard(
    Palette p,
    AppLocalizations l10n,
    StatisticsService stats,
  ) {
    final weekly = stats.weeklyTotalMinutes;
    final progress = (weekly / weeklyGoalMinutes).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E8A4C), Color(0xFF0E4D2A)],
        ),
        boxShadow: p.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statsThisWeek,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMinutes(l10n, weekly),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.statsWeeklyGoal(weeklyGoalMinutes ~/ 60),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${l10n.statsTotalStudy}: ${_formatMinutes(l10n, stats.totalMinutes)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiles(
    Palette p,
    AppLocalizations l10n,
    StatisticsService stats,
  ) {
    final tiles = [
      _tile(
        p,
        Icons.local_fire_department_rounded,
        Colors.deepOrange,
        '${stats.currentStreak}',
        l10n.statsStreak,
      ),
      _tile(
        p,
        Icons.check_circle_rounded,
        Colors.green,
        '${stats.completedSessions}',
        l10n.statsSessions,
      ),
      _tile(
        p,
        Icons.emoji_events_rounded,
        Colors.amber.shade700,
        '${stats.successRate.round()}%',
        l10n.statsSuccess,
      ),
      _tile(
        p,
        Icons.quiz_rounded,
        Colors.teal,
        stats.totalQuizzesTaken == 0
            ? '–'
            : '${stats.averageQuizScore.round()}%',
        l10n.statsQuizAvg,
      ),
    ];
    return Column(
      children: [
        Row(children: [tiles[0], const SizedBox(width: 12), tiles[1]]),
        const SizedBox(height: 12),
        Row(children: [tiles[2], const SizedBox(width: 12), tiles[3]]),
      ],
    );
  }

  Widget _tile(
    Palette p,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: p.cardDecoration(radius: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(Palette p, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: p.accentText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMinutesChart(
    BuildContext context,
    Palette p,
    StatisticsService stats,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toString();
    final minutesPerDay = {for (int i = 0; i < 7; i++) i: 0};

    for (var session in stats.sessionHistory) {
      if (session['completed'] != true) continue;
      final d = session['date'] as DateTime;
      final daysAgo = today.difference(DateTime(d.year, d.month, d.day)).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        minutesPerDay[6 - daysAgo] =
            minutesPerDay[6 - daysAgo]! + (session['duration'] as int);
      }
    }

    final maxMinutes = minutesPerDay.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxMinutes == 0 ? 30.0 : (maxMinutes * 1.25).ceilToDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 12, 10),
      height: 220,
      decoration: p.cardDecoration(),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  p.isDark ? Colors.white : const Color(0xFF122E1F),
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                AppLocalizations.of(context)!.minutesValue(rod.toY.round()),
                TextStyle(
                  color: p.isDark ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          barGroups: minutesPerDay.entries.map((entry) {
            final isToday = entry.key == 6;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: isToday
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.55),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: p.cardMuted,
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = today.subtract(
                    Duration(days: 6 - value.toInt()),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat.E(locale).format(date),
                      style: TextStyle(
                        color: value.toInt() == 6
                            ? p.textPrimary
                            : p.textSecondary,
                        fontSize: 11,
                        fontWeight: value.toInt() == 6
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildSubjectTime(
    BuildContext context,
    Palette p,
    AppLocalizations l10n,
    StatisticsService stats,
  ) {
    final minutesBySubject = <SessionCategory, int>{};
    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final category = session['category'] as SessionCategory;
        minutesBySubject[category] =
            (minutesBySubject[category] ?? 0) + (session['duration'] as int);
      }
    }

    if (minutesBySubject.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        width: double.infinity,
        decoration: p.cardDecoration(),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 36, color: p.textSecondary),
            const SizedBox(height: 8),
            Text(
              l10n.noDataYet,
              style: TextStyle(color: p.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final entries = minutesBySubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxMinutes = entries.first.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      decoration: p.cardDecoration(),
      child: Column(
        children: entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: entry.key.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.key.icon, size: 16, color: entry.key.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key.getDisplayName(context),
                              style: TextStyle(
                                color: p.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            _formatMinutes(l10n, entry.value),
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: maxMinutes == 0 ? 0 : entry.value / maxMinutes,
                        backgroundColor: p.cardMuted,
                        color: entry.key.color,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
