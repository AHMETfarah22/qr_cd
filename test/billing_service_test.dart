import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tscan/core/services/billing_service.dart';
import 'package:tscan/core/services/premium_service.dart';

void main() {
  test('store product IDs map to plans and back', () {
    expect(BillingService.planForProduct('tscan_premium_monthly'), PremiumPlan.monthly);
    expect(BillingService.planForProduct('tscan_premium_yearly'), PremiumPlan.yearly);
    expect(BillingService.planForProduct('something_else'), isNull);
    for (final plan in PremiumPlan.values) {
      expect(BillingService.planForProduct(BillingService.productForPlan(plan)), plan);
    }
  });

  test('a restore grace window never shortens a paid period', () async {
    SharedPreferences.setMockInitialValues({});
    final premium = PremiumService();
    await Future<void>.delayed(Duration.zero);

    await premium.activatePlan(PremiumPlan.yearly);
    final paidUntil = premium.expiry!;

    await premium.activatePlan(PremiumPlan.yearly, validFor: BillingService.restoreGrace);
    expect(premium.expiry, paidUntil);
  });

  test('restore grace keeps an owned subscription active for a few days', () async {
    SharedPreferences.setMockInitialValues({});
    final premium = PremiumService();
    await Future<void>.delayed(Duration.zero);

    await premium.activatePlan(PremiumPlan.monthly, validFor: BillingService.restoreGrace);
    expect(premium.isPremium, isTrue);
    expect(premium.expiry!.difference(DateTime.now()).inDays, closeTo(3, 1));
  });
}
