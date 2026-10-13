import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PremiumPlan { monthly, yearly }

extension PremiumPlanInfo on PremiumPlan {
  /// Price in Turkish lira.
  int get priceTl => this == PremiumPlan.monthly ? 300 : 600;
  Duration get duration => this == PremiumPlan.monthly
      ? const Duration(days: 30)
      : const Duration(days: 365);
}

/// Premium abonelik durumunu yöneten servis.
/// Ücretsiz kullanıcılar [freePdfLimit] PDF yükleyebilir; sonrasında Premium istenir.
/// Satın alma şimdilik simüle ediliyor, ileride In-App Purchase ile değiştirilecek.
class PremiumService extends ChangeNotifier {
  static const int freePdfLimit = 2;

  static const String _premiumKey = 'is_premium_user';
  static const String _expiryKey = 'premium_expiry_ms';
  static const String _planKey = 'premium_plan';
  static const String _freePdfUsedKey = 'free_pdf_uploads_used';

  bool _isPremium = false;
  DateTime? _expiry;
  PremiumPlan? _plan;
  int _freePdfUsed = 0;

  /// Active premium. Older installs stored only a flag with no expiry date;
  /// those stay premium.
  bool get isPremium =>
      _isPremium && (_expiry == null || _expiry!.isAfter(DateTime.now()));
  DateTime? get expiry => _expiry;
  PremiumPlan? get plan => _plan;

  int get freePdfUsed => _freePdfUsed;
  int get freePdfRemaining =>
      (freePdfLimit - _freePdfUsed).clamp(0, freePdfLimit).toInt();
  bool get canUploadPdf => isPremium || _freePdfUsed < freePdfLimit;

  PremiumService() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    final expiryMs = prefs.getInt(_expiryKey);
    _expiry = expiryMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expiryMs);
    final planName = prefs.getString(_planKey);
    _plan = PremiumPlan.values.where((p) => p.name == planName).firstOrNull;
    _freePdfUsed = prefs.getInt(_freePdfUsedKey) ?? 0;
    notifyListeners();
  }

  /// Activates [plan] starting now (called after a successful purchase).
  Future<void> activatePlan(PremiumPlan plan) async {
    _isPremium = true;
    _plan = plan;
    _expiry = DateTime.now().add(plan.duration);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    await prefs.setInt(_expiryKey, _expiry!.millisecondsSinceEpoch);
    await prefs.setString(_planKey, plan.name);
    notifyListeners();
  }

  /// Premium durumunu ayarlar (eski kullanım; süresiz).
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    if (!value) {
      _expiry = null;
      _plan = null;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    if (!value) {
      await prefs.remove(_expiryKey);
      await prefs.remove(_planKey);
    }
    notifyListeners();
  }

  /// Counts one PDF upload against the free quota (no-op for premium users).
  Future<void> recordPdfUpload() async {
    if (isPremium) return;
    _freePdfUsed++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_freePdfUsedKey, _freePdfUsed);
    notifyListeners();
  }

  /// Belirli bir özelliğin kullanılabilir olup olmadığını kontrol eder.
  bool canUseFeature(PremiumFeature feature) {
    if (isPremium) return true;

    switch (feature) {
      case PremiumFeature.unlimitedPdf:
        // Free users get [freePdfLimit] uploads before Premium is required.
        return canUploadPdf;
      case PremiumFeature.aiTimeEstimate:
      case PremiumFeature.aiQuiz:
        // Included for the free PDFs so students can try the full flow.
        return true;
      case PremiumFeature.personalizedSpeed:
      case PremiumFeature.wrongAnswerAnalysis:
      case PremiumFeature.allAmbientSounds:
      case PremiumFeature.advancedStats:
      case PremiumFeature.noAds:
        return false;
    }
  }
}

enum PremiumFeature {
  unlimitedPdf,
  aiTimeEstimate,
  aiQuiz,
  personalizedSpeed,
  wrongAnswerAnalysis,
  allAmbientSounds,
  advancedStats,
  noAds,
}
