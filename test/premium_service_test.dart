import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tscan/core/services/premium_service.dart';

Future<PremiumService> _service([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final service = PremiumService();
  await Future<void>.delayed(Duration.zero); // let _loadStatus finish
  return service;
}

void main() {
  test('free users can upload two PDFs, then need Premium', () async {
    final s = await _service();
    expect(s.canUploadPdf, isTrue);
    expect(s.freePdfRemaining, 2);

    await s.recordPdfUpload();
    expect(s.canUploadPdf, isTrue);
    expect(s.freePdfRemaining, 1);

    await s.recordPdfUpload();
    expect(s.canUploadPdf, isFalse);
    expect(s.freePdfRemaining, 0);
    expect(s.canUseFeature(PremiumFeature.unlimitedPdf), isFalse);
  });

  test('free quota survives an app restart', () async {
    final s = await _service({'free_pdf_uploads_used': 2});
    expect(s.canUploadPdf, isFalse);
  });

  test('plans cost 300 TL monthly and 600 TL yearly', () {
    expect(PremiumPlan.monthly.priceTl, 300);
    expect(PremiumPlan.yearly.priceTl, 600);
  });

  test('activating a plan unlocks uploads until it expires', () async {
    final s = await _service({'free_pdf_uploads_used': 2});
    await s.activatePlan(PremiumPlan.monthly);
    expect(s.isPremium, isTrue);
    expect(s.canUploadPdf, isTrue);
    expect(s.expiry!.difference(DateTime.now()).inDays, closeTo(30, 1));

    // Uploads while premium do not use up the free quota.
    await s.recordPdfUpload();
    expect(s.freePdfUsed, 2);
  });

  test('an expired plan is no longer premium', () async {
    final past = DateTime.now().subtract(const Duration(days: 1));
    final s = await _service({
      'is_premium_user': true,
      'premium_expiry_ms': past.millisecondsSinceEpoch,
      'free_pdf_uploads_used': 2,
    });
    expect(s.isPremium, isFalse);
    expect(s.canUploadPdf, isFalse);
  });

  test('legacy premium flag without expiry stays premium', () async {
    final s = await _service({'is_premium_user': true});
    expect(s.isPremium, isTrue);
  });
}
