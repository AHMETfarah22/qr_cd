import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/session_category.dart';

class StatisticsService extends ChangeNotifier {
  String? _currentUserEmail;
  int _totalSessions = 0;
  int _completedSessions = 0;
  int _cancelledSessions = 0;
  int _totalMinutes = 0;
  int _currentStreak = 0;
  DateTime? _lastFocusDate;
  List<String> _badges = [];
  List<Map<String, dynamic>> _sessionHistory = [];

  // PDF & Quiz stats
  int _totalPdfSessions = 0;
  int _totalQuizzesTaken = 0;
  int _totalQuizScoreSum = 0;

  int get totalSessions => _totalSessions;
  int get completedSessions => _completedSessions;
  int get cancelledSessions => _cancelledSessions;
  int get totalMinutes => _totalMinutes;
  int get currentStreak => _currentStreak;
  List<String> get badges => _badges;
  List<Map<String, dynamic>> get sessionHistory => _sessionHistory;

  int get totalPdfSessions => _totalPdfSessions;
  int get totalQuizzesTaken => _totalQuizzesTaken;
  double get averageQuizScore =>
      _totalQuizzesTaken == 0 ? 0.0 : _totalQuizScoreSum / _totalQuizzesTaken;

  // Calculate unique days with activity from history
  int get activeDays {
    if (_sessionHistory.isEmpty) return 0;
    try {
      final uniqueDays = <String>{};
      for (var session in _sessionHistory) {
        final date = session['date'] as DateTime;
        uniqueDays.add('${date.year}-${date.month}-${date.day}');
      }
      return uniqueDays.length;
    } catch (e) {
      debugPrint('Error calculating active days: $e');
      return 0;
    }
  }

  String get totalTimeFormatted {
    final hours = _totalMinutes ~/ 60;
    final minutes = _totalMinutes % 60;
    if (hours > 0) {
      return '$hours saat $minutes dakika';
    }
    return '$minutes dakika';
  }

  // Calculate total minutes for the current week (starting Monday)
  int get weeklyTotalMinutes {
    final now = DateTime.now();
    // Monday = 1, Sunday = 7
    // Calculate start of week (Monday)
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysToSubtract));

    int total = 0;
    for (var session in _sessionHistory) {
      if (session['completed'] == true) {
        final date = session['date'] as DateTime;
        if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
          total += session['duration'] as int;
        }
      }
    }
    return total;
  }

  bool get hasWeeklyCertificate =>
      weeklyTotalMinutes >= 300; // 5 hours = 300 minutes

  StatisticsService() {
    _loadStatistics();
  }

  // Set current user and load their statistics
  Future<void> setCurrentUser(String? email) async {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      await _loadStatistics();
    }
  }

  // Get key prefix for current user
  String _getUserKey(String key) {
    if (_currentUserEmail == null) return key;
    return 'user_${_currentUserEmail}_$key';
  }

  // Load statistics from SharedPreferences
  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    // If no user is logged in, reset all stats
    _currentUserEmail ??= prefs.getString('current_user_email');

    if (_currentUserEmail == null) {
      _resetLocalStats();
      notifyListeners();
      return;
    }

    _totalSessions = prefs.getInt(_getUserKey('stats_total_sessions')) ?? 0;
    _completedSessions =
        prefs.getInt(_getUserKey('stats_completed_sessions')) ?? 0;
    _cancelledSessions =
        prefs.getInt(_getUserKey('stats_cancelled_sessions')) ?? 0;
    _totalMinutes = prefs.getInt(_getUserKey('stats_total_minutes')) ?? 0;
    _currentStreak = prefs.getInt(_getUserKey('stats_current_streak')) ?? 0;
    _badges = prefs.getStringList(_getUserKey('stats_badges')) ?? [];

    // PDF & Quiz stats
    _totalPdfSessions =
        prefs.getInt(_getUserKey('stats_total_pdf_sessions')) ?? 0;
    _totalQuizzesTaken =
        prefs.getInt(_getUserKey('stats_total_quizzes_taken')) ?? 0;
    _totalQuizScoreSum =
        prefs.getInt(_getUserKey('stats_total_quiz_score_sum')) ?? 0;

    final lastDateStr = prefs.getString(_getUserKey('stats_last_focus_date'));
    if (lastDateStr != null) {
      _lastFocusDate = DateTime.parse(lastDateStr);
      _checkStreakReset();
    }

    // Load session history
    final historyJson =
        prefs.getStringList(_getUserKey('stats_session_history')) ?? [];
    try {
      _sessionHistory = historyJson
          .map((json) {
            final parts = json.split('|');
            if (parts.length < 3) return null; // Skip invalid entries

            return {
              'duration': int.parse(parts[0]),
              'completed': parts[1] == 'true',
              'date': DateTime.parse(parts[2]),
              'category': parts.length > 3
                  ? SessionCategoryExtension.fromString(parts[3])
                  : SessionCategory.other,
              'note': parts.length > 4 ? parts[4] : '',
            };
          })
          .where((element) => element != null)
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      debugPrint('Error loading session history: $e');
      _sessionHistory = [];
    }

    notifyListeners();
  }

  void _resetLocalStats() {
    _totalSessions = 0;
    _completedSessions = 0;
    _cancelledSessions = 0;
    _totalMinutes = 0;
    _currentStreak = 0;
    _lastFocusDate = null;
    _badges = [];
    _sessionHistory = [];
    _totalPdfSessions = 0;
    _totalQuizzesTaken = 0;
    _totalQuizScoreSum = 0;
  }

  void _checkStreakReset() {
    if (_lastFocusDate == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      _lastFocusDate!.year,
      _lastFocusDate!.month,
      _lastFocusDate!.day,
    );

    final difference = today.difference(last).inDays;
    if (difference > 1) {
      _currentStreak = 0;
    }
  }

  // Start a new session
  Future<void> startSession() async {
    if (_currentUserEmail == null) return;

    _totalSessions++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getUserKey('stats_total_sessions'), _totalSessions);
    notifyListeners();
  }

  // Complete a session
  Future<void> completeSession(
    int durationMinutes, {
    SessionCategory category = SessionCategory.other,
    String note = '',
  }) async {
    if (_currentUserEmail == null) return;

    _completedSessions++;
    _totalMinutes += durationMinutes;

    final now = DateTime.now();

    // Update Streak
    final today = DateTime(now.year, now.month, now.day);
    DateTime? last;
    if (_lastFocusDate != null) {
      last = DateTime(
        _lastFocusDate!.year,
        _lastFocusDate!.month,
        _lastFocusDate!.day,
      );
    }

    if (last == null) {
      _currentStreak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        _currentStreak++;
      } else if (diff > 1) {
        _currentStreak = 1;
      }
    }
    _lastFocusDate = now;

    // Check for Badges
    _checkBadges(durationMinutes, now);

    // Add to history with category
    _sessionHistory.insert(0, {
      'duration': durationMinutes,
      'completed': true,
      'date': now,
      'category': category,
      'note': note,
    });

    if (_sessionHistory.length > 500) {
      _sessionHistory = _sessionHistory.sublist(0, 500);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getUserKey('stats_completed_sessions'),
      _completedSessions,
    );
    await prefs.setInt(_getUserKey('stats_total_minutes'), _totalMinutes);
    await prefs.setInt(_getUserKey('stats_current_streak'), _currentStreak);
    await prefs.setString(
      _getUserKey('stats_last_focus_date'),
      _lastFocusDate!.toIso8601String(),
    );
    await prefs.setStringList(_getUserKey('stats_badges'), _badges);
    await _saveHistory(prefs);

    notifyListeners();
  }

  void _checkBadges(int durationMinutes, DateTime now) {
    // Early Bird: Focus before 9 AM
    if (now.hour < 9 && !_badges.contains('Erkenci Kuş')) {
      _badges.add('Erkenci Kuş');
    }

    // Night Owl: Focus after 11 PM
    if (now.hour >= 23 && !_badges.contains('Gece Kuşu')) {
      _badges.add('Gece Kuşu');
    }

    // Weekend Warrior: Focus on Saturday or Sunday
    if ((now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) &&
        !_badges.contains('Hafta Sonu Savaşçısı')) {
      _badges.add('Hafta Sonu Savaşçısı');
    }

    // Marathoner: Total time > 180 minutes
    if (_totalMinutes >= 180 && !_badges.contains('Maratoncu')) {
      _badges.add('Maratoncu');
    }

    // Focus Master: 1 hour in a single session
    if (durationMinutes >= 60 && !_badges.contains('Odaklanma Ustası')) {
      _badges.add('Odaklanma Ustası');
    }

    // Veteran: 10 completed sessions
    if (_completedSessions >= 10 && !_badges.contains('Usta Odaklanıcı')) {
      _badges.add('Usta Odaklanıcı');
    }

    // Elite: 50 completed sessions
    if (_completedSessions >= 50 && !_badges.contains('Elit Odaklanıcı')) {
      _badges.add('Elit Odaklanıcı');
    }

    // Streak King: 7 day streak
    if (_currentStreak >= 7 && !_badges.contains('Seri Kralı')) {
      _badges.add('Seri Kralı');
    }

    // Busy Bee: 3 sessions in one day
    int sessionsToday = 0;
    final todayStr = '${now.year}-${now.month}-${now.day}';
    for (var session in _sessionHistory) {
      final date = session['date'] as DateTime;
      if ('${date.year}-${date.month}-${date.day}' == todayStr) {
        sessionsToday++;
      }
    }
    if (sessionsToday >= 3 && !_badges.contains('Çalışkan Arı')) {
      _badges.add('Çalışkan Arı');
    }
  }

  // Cancel a session
  Future<void> cancelSession(
    int durationMinutes, {
    SessionCategory category = SessionCategory.other,
  }) async {
    if (_currentUserEmail == null) return;

    _cancelledSessions++;
    _totalMinutes += durationMinutes;

    // Add to history with category
    _sessionHistory.insert(0, {
      'duration': durationMinutes,
      'completed': false,
      'date': DateTime.now(),
      'category': category,
    });

    // Keep only last 20 sessions
    if (_sessionHistory.length > 500) {
      _sessionHistory = _sessionHistory.sublist(0, 500);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getUserKey('stats_cancelled_sessions'),
      _cancelledSessions,
    );
    await prefs.setInt(_getUserKey('stats_total_minutes'), _totalMinutes);
    await _saveHistory(prefs);

    notifyListeners();
  }

  // Get total minutes focused today
  int get dailyFocusMinutes {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    int total = 0;
    for (var session in _sessionHistory) {
      if (session['completed'] == true) {
        final date = session['date'] as DateTime;
        if ('${date.year}-${date.month}-${date.day}' == todayStr) {
          total += session['duration'] as int;
        }
      }
    }
    return total;
  }

  // Save session history
  Future<void> _saveHistory(SharedPreferences prefs) async {
    final historyJson = _sessionHistory.map((session) {
      final category = session['category'] as SessionCategory;
      final note = (session['note'] as String? ?? '').replaceAll('|', ' ');
      return '${session['duration']}|${session['completed']}|${session['date'].toIso8601String()}|${category.name}|$note';
    }).toList();
    await prefs.setStringList(
      _getUserKey('stats_session_history'),
      historyJson,
    );
  }

  // Reset all statistics
  Future<void> resetStatistics() async {
    if (_currentUserEmail == null) return;

    _resetLocalStats();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserKey('stats_total_sessions'));
    await prefs.remove(_getUserKey('stats_completed_sessions'));
    await prefs.remove(_getUserKey('stats_cancelled_sessions'));
    await prefs.remove(_getUserKey('stats_total_minutes'));
    await prefs.remove(_getUserKey('stats_session_history'));
    await prefs.remove(_getUserKey('stats_current_streak'));
    await prefs.remove(_getUserKey('stats_badges'));
    await prefs.remove(_getUserKey('stats_last_focus_date'));
    await prefs.remove(_getUserKey('stats_total_pdf_sessions'));
    await prefs.remove(_getUserKey('stats_total_quizzes_taken'));
    await prefs.remove(_getUserKey('stats_total_quiz_score_sum'));

    notifyListeners();
  }

  // Reset streak (Hard Mode penalty)
  Future<void> resetStreak() async {
    if (_currentUserEmail == null) return;
    _currentStreak = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getUserKey('stats_current_streak'), 0);
    notifyListeners();
  }

  // Update note for the last completed session
  Future<void> updateLastSessionNote(String note) async {
    if (_sessionHistory.isNotEmpty) {
      _sessionHistory[0]['note'] = note;
      final prefs = await SharedPreferences.getInstance();
      await _saveHistory(prefs);
      notifyListeners();
    }
  }

  // Get success rate percentage
  double get successRate {
    if (_totalSessions == 0) return 0.0;
    return (_completedSessions / _totalSessions) * 100;
  }

  // Record a completed PDF study session
  Future<void> completePdfSession(int durationMinutes) async {
    if (_currentUserEmail == null) return;
    _totalPdfSessions++;

    // Custom Badge: Akademisyen (Focus on PDF 5 times)
    if (_totalPdfSessions >= 5 && !_badges.contains('Akademisyen')) {
      _badges.add('Akademisyen');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getUserKey('stats_total_pdf_sessions'),
      _totalPdfSessions,
    );
    await prefs.setStringList(_getUserKey('stats_badges'), _badges);
    notifyListeners();
  }

  // Record a completed AI Quiz
  Future<void> completeQuiz(int scorePercentage) async {
    if (_currentUserEmail == null) return;
    _totalQuizzesTaken++;
    _totalQuizScoreSum += scorePercentage;

    // Custom Badge: Dahi (Get 100 on any Quiz)
    if (scorePercentage == 100 && !_badges.contains('Dahi')) {
      _badges.add('Dahi');
    }

    // Custom Badge: Bilgin (Take 5 Quizzes)
    if (_totalQuizzesTaken >= 5 && !_badges.contains('Bilgin')) {
      _badges.add('Bilgin');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getUserKey('stats_total_quizzes_taken'),
      _totalQuizzesTaken,
    );
    await prefs.setInt(
      _getUserKey('stats_total_quiz_score_sum'),
      _totalQuizScoreSum,
    );
    await prefs.setStringList(_getUserKey('stats_badges'), _badges);
    notifyListeners();
  }
}
