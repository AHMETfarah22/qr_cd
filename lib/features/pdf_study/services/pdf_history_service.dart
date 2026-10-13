import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/pdf_document.dart';

class PdfHistoryService extends ChangeNotifier {
  static const int maxHistoryItems = 5;
  String? _currentUserEmail;
  List<PdfDocument> _history = [];

  List<PdfDocument> get history => _history;

  PdfHistoryService() {
    _loadHistory();
  }

  Future<void> setCurrentUser(String? email) async {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      await _loadHistory();
    }
  }

  String _getUserKey(String key) {
    if (_currentUserEmail == null) return key;
    return 'user_${_currentUserEmail}_$key';
  }

  Future<void> _loadHistory() async {
    _history = [];
    if (_currentUserEmail == null) {
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJsonStr = prefs.getString(_getUserKey('pdf_history_list'));
      if (historyJsonStr != null) {
        final List<dynamic> decodedList =
            jsonDecode(historyJsonStr) as List<dynamic>;
        _history = decodedList
            .map((item) => PdfDocument.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading PDF history: $e');
    }
    notifyListeners();
  }

  Future<void> _saveHistoryToPrefs() async {
    if (_currentUserEmail == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _history.map((doc) => doc.toJson()).toList();
      await prefs.setString(
        _getUserKey('pdf_history_list'),
        jsonEncode(listJson),
      );
    } catch (e) {
      debugPrint('Error saving PDF history: $e');
    }
  }

  Future<void> savePdf(PdfDocument doc) async {
    if (_currentUserEmail == null) return;

    // Remove if already exists with same id or fileName to avoid duplicates
    _history.removeWhere(
      (item) => item.id == doc.id || item.fileName == doc.fileName,
    );

    // Insert at top of list
    _history.insert(0, doc);

    // Limit to max items
    if (_history.length > maxHistoryItems) {
      _history = _history.sublist(0, maxHistoryItems);
    }

    await _saveHistoryToPrefs();
    notifyListeners();
  }

  Future<void> deletePdf(String docId) async {
    if (_currentUserEmail == null) return;

    _history.removeWhere((item) => item.id == docId);
    await _saveHistoryToPrefs();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    if (_currentUserEmail == null) return;

    _history.clear();
    await _saveHistoryToPrefs();
    notifyListeners();
  }
}
