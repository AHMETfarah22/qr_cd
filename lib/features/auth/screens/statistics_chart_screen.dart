import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../../../core/theme/palette.dart';
import '../services/statistics_service.dart';
import 'package:tscan/l10n/app_localizations.dart';

class StatisticsChartScreen extends StatelessWidget {
  /// True when shown as a bottom-navigation tab (no back button).
  final bool embedded;

  const StatisticsChartScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final statsService = Provider.of<StatisticsService>(context);
    final l10n = AppLocalizations.of(context)!;
    final p = Palette.of(context);

    return Scaffold(
      backgroundColor: p.background,
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(p, Icons.emoji_events_rounded, l10n.successRate.toUpperCase()),
            _buildSuccessRateChart(context, p, statsService),
            _buildSectionHeader(p, Icons.pie_chart_rounded, l10n.categoryDistribution),
            _buildCategoryPieChart(context, p, statsService),
            _buildSectionHeader(p, Icons.bar_chart_rounded, l10n.weeklyActivity),
            _buildWeeklyActivityChart(context, p, statsService),
            _buildSectionHeader(p, Icons.grid_view_rounded, l10n.activityIntensity),
            _buildContributionHeatmap(p, statsService),
            _buildSectionHeader(p, Icons.timelapse_rounded, l10n.timeDistribution),
            _buildTimeDistribution(context, p, statsService),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: p.accentText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: p.accentText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateChart(BuildContext context, Palette p, StatisticsService stats) {
    final l10n = AppLocalizations.of(context)!;
    final successRate = stats.totalSessions > 0
        ? (stats.completedSessions / stats.totalSessions * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: p.cardDecoration().copyWith(
            gradient: LinearGradient(
              colors: [
                p.card,
                AppColors.accent.withValues(alpha: p.isDark ? 0.10 : 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.2),
          ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: stats.completedSessions.toDouble(),
                        color: Colors.green,
                        radius: 16,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: stats.cancelledSessions.toDouble(),
                        color: Colors.redAccent,
                        radius: 16,
                        title: '',
                      ),
                      if (stats.totalSessions == 0)
                        PieChartSectionData(
                          value: 1,
                          color: p.textSecondary.withValues(alpha: 0.25),
                          radius: 16,
                          title: '',
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${successRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.successLabel,
                      style: TextStyle(color: p.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(p,
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    label: l10n.successfulSessions,
                    value: '${stats.completedSessions}'),
                const SizedBox(height: 12),
                _buildStatRow(p,
                    icon: Icons.cancel_rounded,
                    color: Colors.redAccent,
                    label: l10n.cancelledSessionsCount,
                    value: '${stats.cancelledSessions}'),
                const SizedBox(height: 12),
                _buildStatRow(p,
                    icon: Icons.calendar_today_rounded,
                    color: Colors.orange,
                    label: l10n.activeDaysCount,
                    value: '${stats.activeDays}'),
                const SizedBox(height: 12),
                _buildStatRow(p,
                    icon: Icons.access_time_rounded,
                    color: p.accentText,
                    label: l10n.totalTime,
                    value: stats.totalTimeFormatted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    Palette p, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.textSecondary, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, Palette p, StatisticsService stats) {
    final categoryCount = <SessionCategory, int>{};
    for (var session in stats.sessionHistory) {
      final category = session['category'] as SessionCategory;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) {
      return _buildEmptyState(p, AppLocalizations.of(context)!.noDataYet);
    }

    final total = categoryCount.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: p.cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: categoryCount.entries.map((entry) {
                  final percentage = (entry.value / total * 100);
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: entry.key.color,
                    radius: 56,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categoryCount.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: entry.key.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.key.icon, size: 13, color: entry.key.color),
                    const SizedBox(width: 5),
                    Text(
                      '${entry.key.getDisplayName(context)} (${entry.value})',
                      style: TextStyle(color: p.textPrimary, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(BuildContext context, Palette p, StatisticsService stats) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toString();
    final weeklyData = {for (int i = 0; i < 7; i++) i: 0};

    for (var session in stats.sessionHistory) {
      final sessionDate = session['date'] as DateTime;
      final sDate = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      final daysDiff = today.difference(sDate).inDays;

      if (daysDiff >= 0 && daysDiff < 7 && session['completed'] == true) {
        weeklyData[6 - daysDiff] = weeklyData[6 - daysDiff]! + 1;
      }
    }

    final maxY = weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      height: 240,
      decoration: p.cardDecoration(),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: weeklyData.entries.map((entry) {
            final isToday = entry.key == 6;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: isToday ? AppColors.accent : AppColors.accent.withValues(alpha: 0.55),
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: TextStyle(color: p.textSecondary, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = today.subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.E(locale).format(date),
                      style: TextStyle(color: p.textSecondary, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildTimeDistribution(BuildContext context, Palette p, StatisticsService stats) {
    final l10n = AppLocalizations.of(context)!;
    final categoryTime = <SessionCategory, int>{};
    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final category = session['category'] as SessionCategory;
        categoryTime[category] = (categoryTime[category] ?? 0) + (session['duration'] as int);
      }
    }

    if (categoryTime.isEmpty) return _buildEmptyState(p, l10n.noDataYet);

    final totalTime = categoryTime.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: p.cardDecoration(),
      child: Column(
        children: categoryTime.entries.map((entry) {
          final percentage = totalTime == 0 ? 0.0 : entry.value / totalTime;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(entry.key.icon, size: 15, color: entry.key.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.key.getDisplayName(context),
                        style: TextStyle(color: p.textPrimary, fontSize: 13),
                      ),
                    ),
                    Text(
                      l10n.minutesValue(entry.value),
                      style: TextStyle(
                        color: entry.key.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: p.cardMuted,
                  color: entry.key.color,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContributionHeatmap(Palette p, StatisticsService stats) {
    final now = DateTime.now();
    final ninetyDaysAgo =
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
    final dailyActivity = <String, int>{};

    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final date = session['date'] as DateTime;
        final key = '${date.year}-${date.month}-${date.day}';
        dailyActivity[key] = (dailyActivity[key] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: p.cardDecoration(radius: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // start at the most recent week
        child: Row(
          children: List.generate(13, (weekIndex) {
            return Column(
              children: List.generate(7, (dayIndex) {
                final dayOffset = (weekIndex * 7) + dayIndex;
                if (dayOffset >= 90) return const SizedBox(width: 16, height: 16);
                final date = ninetyDaysAgo.add(Duration(days: dayOffset));
                final count = dailyActivity['${date.year}-${date.month}-${date.day}'] ?? 0;

                final color = count > 0
                    ? AppColors.accent.withValues(alpha: (count * 0.3).clamp(0.3, 1.0))
                    : p.cardMuted;

                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Palette p, String message) {
    return Container(
      padding: const EdgeInsets.all(36),
      width: double.infinity,
      decoration: p.cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: p.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: p.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
