import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../services/statistics_service.dart';

class StatisticsChartScreen extends StatelessWidget {
  const StatisticsChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = Provider.of<StatisticsService>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.statisticsTitle,
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
            // Success Rate Circular Chart
            _buildSectionHeader(AppLocalizations.of(context)!.successRate.toUpperCase()),
            const SizedBox(height: 16),
            _buildSuccessRateChart(statsService),
            
            const SizedBox(height: 32),
            
            // Category Distribution Pie Chart
            _buildSectionHeader(AppLocalizations.of(context)!.categoryDistribution),
            const SizedBox(height: 16),
            _buildCategoryPieChart(statsService),
            
            const SizedBox(height: 32),
            
            // Weekly Activity Bar Chart
            _buildSectionHeader(AppLocalizations.of(context)!.weeklyActivity),
            const SizedBox(height: 16),
            _buildWeeklyActivityChart(statsService),
            
            const SizedBox(height: 32),
            
            // Time Distribution
            _buildSectionHeader(AppLocalizations.of(context)!.timeDistribution),
            const SizedBox(height: 16),
            _buildTimeDistribution(statsService),
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

  Widget _buildSuccessRateChart(StatisticsService stats) {
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
          // Circular Progress
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
                      AppLocalizations.of(context)!.successRate.split(' ').first, // Just "Success" or localized
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
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  Widget _buildCategoryPieChart(StatisticsService stats) {
    // Calculate category distribution from session history
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
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                    Text(
                      '${entry.key.getDisplayName(context)} (${entry.value})',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(StatisticsService stats) {
    // Get last 7 days activity
    final now = DateTime.now();
    Map<int, int> weeklyData = {};
    
    for (int i = 6; i >= 0; i--) {
      weeklyData[i] = 0;
    }
    
    for (var session in stats.sessionHistory) {
      final sessionDate = session['date'] as DateTime;
      
      // Normalize dates to midnight for accurate day comparison
      final today = DateTime(now.year, now.month, now.day);
      final sDate = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      
      final daysDiff = today.difference(sDate).inDays;
      
      if (daysDiff >= 0 && daysDiff < 7) {
        if (session['completed'] == true) {
          weeklyData[6 - daysDiff] = (weeklyData[6 - daysDiff] ?? 0) + 1;
        }
      }
    }

    final maxY = weeklyData.values.isEmpty ? 5.0 : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 280,
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
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: weeklyData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
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
                    child: Text(
                      dayNames[date.weekday - 1],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildTimeDistribution(StatisticsService stats) {
    // Calculate time spent per category
    Map<SessionCategory, int> categoryTime = {};
    
    for (var session in stats.sessionHistory) {
      if (session['completed'] == true) {
        final category = session['category'] as SessionCategory;
        final duration = session['duration'] as int;
        categoryTime[category] = (categoryTime[category] ?? 0) + duration;
      }
    }

    if (categoryTime.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!.noDataYet);
    }

    final totalTime = categoryTime.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: categoryTime.entries.map((entry) {
          final percentage = (entry.value / totalTime);
          final hours = entry.value ~/ 60;
          final minutes = entry.value % 60;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(entry.key.icon, color: entry.key.color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          entry.key.getDisplayName(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      hours > 0 ? '${hours}${AppLocalizations.of(context)!.hoursShort} ${minutes}${AppLocalizations.of(context)!.minutesShort}' : '${minutes} ${AppLocalizations.of(context)!.minutesShort}',
                      style: TextStyle(
                        color: entry.key.color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.process,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              entry.key.color,
                              entry.key.color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.process.withValues(alpha: 0.6),
            AppColors.process.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
