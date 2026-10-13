import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../services/statistics_service.dart';
import 'package:tscan/l10n/app_localizations.dart';

class StatisticsChartScreen extends StatelessWidget {
  const StatisticsChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = Provider.of<StatisticsService>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.statisticsTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Rate
            _buildSectionHeader(l10n.successRate.toUpperCase()),
            const SizedBox(height: 16),
            _buildSuccessRateChart(context, statsService),
            
            const SizedBox(height: 32),
            
            // Category Distribution
            _buildSectionHeader(l10n.categoryDistribution),
            const SizedBox(height: 16),
            _buildCategoryPieChart(context, statsService),
            
            const SizedBox(height: 32),
            
            // Weekly Activity
            _buildSectionHeader(l10n.weeklyActivity),
            const SizedBox(height: 16),
            _buildWeeklyActivityChart(context, statsService),
            
            const SizedBox(height: 32),
            
            // Contribution Heatmap
            _buildSectionHeader('AKTİVİTE YOĞUNLUĞU'),
            const SizedBox(height: 16),
            _buildContributionHeatmap(context, statsService),
            
            const SizedBox(height: 32),
            
            // Time Distribution
            _buildSectionHeader(l10n.timeDistribution),
            const SizedBox(height: 16),
            _buildTimeDistribution(context, statsService),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSuccessRateChart(BuildContext context, StatisticsService stats) {
    final successRate = stats.totalSessions > 0 
        ? (stats.completedSessions / stats.totalSessions * 100)
        : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.process.withValues(alpha: 0.6),
            AppColors.process.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
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
                        radius: 20,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: stats.cancelledSessions.toDouble(),
                        color: Colors.red,
                        radius: 20,
                        title: '',
                      ),
                      if (stats.totalSessions == 0)
                        PieChartSectionData(
                          value: 1,
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          radius: 20,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.successLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  label: AppLocalizations.of(context)!.successfulSessions,
                  value: '${stats.completedSessions}',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.cancel,
                  color: Colors.red,
                  label: AppLocalizations.of(context)!.cancelledSessionsCount,
                  value: '${stats.cancelledSessions}',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.calendar_today_rounded,
                  color: Colors.orange,
                  label: AppLocalizations.of(context)!.activeDaysCount,
                  value: '${stats.activeDays}',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.access_time,
                  color: AppColors.accent,
                  label: AppLocalizations.of(context)!.totalTime,
                  value: stats.totalTimeFormatted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
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
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, StatisticsService stats) {
    Map<SessionCategory, int> categoryCount = {};
    for (var session in stats.sessionHistory) {
      final category = session['category'] as SessionCategory;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!.noDataYet);
    }

    final total = categoryCount.values.reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 0,
                sections: categoryCount.entries.map((entry) {
                  final percentage = (entry.value / total * 100);
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: entry.key.color,
                    radius: 80,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categoryCount.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: entry.key.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key.getDisplayName(context)} (${entry.value})',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(BuildContext context, StatisticsService stats) {
    final now = DateTime.now();
    Map<int, int> weeklyData = {};
    for (int i = 0; i < 7; i++) {
      weeklyData[i] = 0;
    }
    
    for (var session in stats.sessionHistory) {
      final sessionDate = session['date'] as DateTime;
      final today = DateTime(now.year, now.month, now.day);
      final sDate = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      final daysDiff = today.difference(sDate).inDays;
      
      if (daysDiff >= 0 && daysDiff < 7 && session['completed'] == true) {
        weeklyData[6 - daysDiff] = (weeklyData[6 - daysDiff] ?? 0) + 1;
      }
    }

    final maxY = weeklyData.values.isEmpty ? 5.0 : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: weeklyData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: AppColors.accent,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(dayNames[date.weekday - 1], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
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

  Widget _buildTimeDistribution(BuildContext context, StatisticsService stats) {
    Map<SessionCategory, int> categoryTime = {};
    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final category = session['category'] as SessionCategory;
        categoryTime[category] = (categoryTime[category] ?? 0) + (session['duration'] as int);
      }
    }

    if (categoryTime.isEmpty) return _buildEmptyState(AppLocalizations.of(context)!.noDataYet);

    final totalTime = categoryTime.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: categoryTime.entries.map((entry) {
          final percentage = entry.value / totalTime;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.getDisplayName(context), style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Text('${entry.value} dk', style: TextStyle(color: entry.key.color, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppColors.process,
                  color: entry.key.color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContributionHeatmap(BuildContext context, StatisticsService stats) {
    final now = DateTime.now();
    final ninetyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
    Map<String, int> dailyActivity = {};
    
    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final date = session['date'] as DateTime;
        dailyActivity['${date.year}-${date.month}-${date.day}'] = 
            (dailyActivity['${date.year}-${date.month}-${date.day}'] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(13, (weekIndex) {
            return Column(
              children: List.generate(7, (dayIndex) {
                final dayOffset = (weekIndex * 7) + dayIndex;
                if (dayOffset >= 90) return const SizedBox.shrink();
                final date = ninetyDaysAgo.add(Duration(days: dayOffset));
                final count = dailyActivity['${date.year}-${date.month}-${date.day}'] ?? 0;
                
                Color color = AppColors.process.withValues(alpha: 0.1);
                if (count > 0) color = AppColors.accent.withValues(alpha: (count * 0.3).clamp(0.3, 1.0));

                return Container(
                  width: 12, height: 12, margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
