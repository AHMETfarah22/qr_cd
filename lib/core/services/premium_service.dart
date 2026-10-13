import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium abonelik durumunu yöneten servis.
/// Şimdilik basit flag-based kontrol, ileride In-App Purchase ile değiştirilecek.
class PremiumService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium_user';
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  PremiumService() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }

  /// Premium durumunu ayarlar (In-App Purchase sonrası çağrılacak).
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    notifyListeners();
  }

  /// Belirli bir özelliğin kullanılabilir olup olmadığını kontrol eder.
  bool canUseFeature(PremiumFeature feature) {
    if (_isPremium) return true;

    switch (feature) {
      case PremiumFeature.unlimitedPdf:
        return false;
      case PremiumFeature.aiTimeEstimate:
        return false;
      case PremiumFeature.aiQuiz:
        return false;
      case PremiumFeature.personalizedSpeed:
        return false;
      case PremiumFeature.wrongAnswerAnalysis:
        return false;
      case PremiumFeature.allAmbientSounds:
        return false;
      case PremiumFeature.advancedStats:
        return false;
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
