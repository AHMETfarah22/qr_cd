import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../services/statistics_service.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = Provider.of<StatisticsService>(context);
    final sessions = statsService.sessionHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'OTURUM GEÇMİŞİ',
          style: TextStyle(
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
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz kaydedilmiş bir oturum yok',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hemen odaklanmaya başla ve ilk kaydını oluştur!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Odaklanmaya Başla'),
                  ),
                ],
              ),
            )
            : Column(
                children: [
                  _buildWeeklySummary(statsService),
                  Expanded(
                    child: _buildSessionList(sessions),
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
    required BuildContext context,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    final timeAgo = _getTimeAgo(date);
    
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    String durationText;
    if (hours > 0) {
      durationText = '${hours}s ${minutes}dk';
    } else {
      durationText = '$minutes dakika';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? [
                  Colors.green.withValues(alpha: 0.15),
                  Colors.green.withValues(alpha: 0.05),
                ]
              : [
                  Colors.red.withValues(alpha: 0.15),
                  Colors.red.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
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
                      completed ? 'BAŞARILI' : 'YARIM KALDI',
                      style: TextStyle(
                        color: completed ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  durationText,
                  style: const TextStyle(
                    color: Colors.white,
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
                      category.displayName,
                      style: TextStyle(
                        color: category.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<Map<String, dynamic>> sessions) {
    // Group sessions by date
    final groupedSessions = <String, List<Map<String, dynamic>>>{};
    
    for (var session in sessions) {
      final date = session['date'] as DateTime;
      final dateKey = DateFormat('dd MMM yyyy', 'tr_TR').format(date);
      if (!groupedSessions.containsKey(dateKey)) {
        groupedSessions[dateKey] = [];
      }
      groupedSessions[dateKey]!.add(session);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                _getDateLabel(dateKey),
                style: const TextStyle(
                  color: AppColors.accent,
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

              return _buildSessionCard(
                duration: duration,
                completed: completed,
                date: date,
                category: category,
                context: context,
              );
            }),
          ],
        );
      },
    );
  }

  String _getDateLabel(String dateKey) {
    final now = DateTime.now();
    final today = DateFormat('dd MMM yyyy', 'tr_TR').format(now);
    final yesterday = DateFormat('dd MMM yyyy', 'tr_TR').format(now.subtract(const Duration(days: 1)));
    
    if (dateKey == today) return 'BUGÜN';
    if (dateKey == yesterday) return 'DÜN';
    return dateKey.toUpperCase();
  }

  Widget _buildWeeklySummary(StatisticsService stats) {
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
                  hasCertificate ? "HAFTALIK HEDEF TAMAM!" : "HEDEFE ULAŞILAMADI",
                  style: TextStyle(
                    color: hasCertificate ? Colors.blue : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bu hafta toplam $hours saat $minutes dakika odaklandın.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (!hasCertificate)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${(300 - weeklyMinutes)} dakika daha gerekli!",
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

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
}
