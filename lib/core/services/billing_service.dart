import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';

enum BillingError { storeUnavailable, productNotFound, purchaseFailed }

/// Google Play / App Store subscriptions for TScan Premium.
///
/// Store setup (Play Console → Monetize → Subscriptions, App Store Connect
/// → Subscriptions) must use the product IDs below:
///   tscan_premium_monthly — 300 TL / month
///   tscan_premium_yearly  — 600 TL / year
///
/// Active subscriptions are re-checked with the store on every app start;
/// each check keeps Premium valid for [restoreGrace], so a cancelled
/// subscription stops working shortly after the store stops reporting it.
/// Purchases are not verified on a server yet.
class BillingService extends ChangeNotifier {
  static const String monthlyId = 'tscan_premium_monthly';
  static const String yearlyId = 'tscan_premium_yearly';
  static const Set<String> productIds = {monthlyId, yearlyId};
  static const Duration restoreGrace = Duration(days: 3);

  static PremiumPlan? planForProduct(String productId) => switch (productId) {
    monthlyId => PremiumPlan.monthly,
    yearlyId => PremiumPlan.yearly,
    _ => null,
  };

  static String productForPlan(PremiumPlan plan) =>
      plan == PremiumPlan.monthly ? monthlyId : yearlyId;

  final PremiumService _premium;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _storeAvailable = false;
  bool _loading = true;
  bool _purchasePending = false;
  BillingError? _lastError;
  final Map<PremiumPlan, ProductDetails> _products = {};

  bool get storeAvailable => _storeAvailable;
  bool get loading => _loading;
  bool get purchasePending => _purchasePending;
  BillingError? get lastError => _lastError;

  BillingService(this._premium) {
    _init();
  }

  Future<void> _init() async {
    try {
      _storeAvailable = await InAppPurchase.instance.isAvailable();
    } catch (e) {
      debugPrint('Billing: store check failed: $e');
      _storeAvailable = false;
    }

    if (_storeAvailable) {
      _subscription = InAppPurchase.instance.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) {
          debugPrint('Billing: purchase stream error: $e');
          _purchasePending = false;
          _lastError = BillingError.purchaseFailed;
          notifyListeners();
        },
      );
      try {
        final response = await InAppPurchase.instance.queryProductDetails(
          productIds,
        );
        for (final details in response.productDetails) {
          final plan = planForProduct(details.id);
          // Subscriptions with several offers come back once per offer;
          // keep the first (base plan).
          if (plan != null) _products.putIfAbsent(plan, () => details);
        }
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint(
            'Billing: products not found in store: ${response.notFoundIDs}',
          );
        }
        await InAppPurchase.instance.restorePurchases();
      } catch (e) {
        debugPrint('Billing: product query failed: $e');
      }
    }

    _loading = false;
    notifyListeners();
  }

  /// Store-formatted price (e.g. "₺300,00"), or the list price when the
  /// store has not returned product details.
  String priceLabel(PremiumPlan plan) =>
      _products[plan]?.price ?? '${plan.priceTl} TL';

  /// Starts the store purchase flow. Returns false when it could not start;
  /// [lastError] says why. Premium is granted when the store confirms.
  Future<bool> buy(PremiumPlan plan) async {
    _lastError = null;
    final product = _products[plan];

    if (!_storeAvailable || product == null) {
      if (kDebugMode) {
        // Debug builds installed over USB cannot reach Play Billing; grant
        // Premium so the rest of the app can still be tested.
        debugPrint(
          'Billing: store unavailable in debug build, simulating purchase',
        );
        await _premium.activatePlan(plan);
        return true;
      }
      _lastError = _storeAvailable
          ? BillingError.productNotFound
          : BillingError.storeUnavailable;
      notifyListeners();
      return false;
    }

    _purchasePending = true;
    notifyListeners();
    try {
      final started = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        _purchasePending = false;
        _lastError = BillingError.purchaseFailed;
        notifyListeners();
      }
      return started;
    } catch (e) {
      debugPrint('Billing: purchase failed to start: $e');
      _purchasePending = false;
      _lastError = BillingError.purchaseFailed;
      notifyListeners();
      return false;
    }
  }

  /// Asks the store for subscriptions this account already owns.
  Future<void> restore() async {
    if (!_storeAvailable) {
      _lastError = BillingError.storeUnavailable;
      notifyListeners();
      return;
    }
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final plan = planForProduct(purchase.productID);
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
        case PurchaseStatus.purchased:
          if (plan != null) await _premium.activatePlan(plan);
          _purchasePending = false;
        case PurchaseStatus.restored:
          // Still owned according to the store: keep Premium for a short
          // window; the next app start checks again.
          if (plan != null) {
            await _premium.activatePlan(plan, validFor: restoreGrace);
          }
          _purchasePending = false;
        case PurchaseStatus.error:
          debugPrint('Billing: purchase error: ${purchase.error}');
          _purchasePending = false;
          _lastError = BillingError.purchaseFailed;
        case PurchaseStatus.canceled:
          _purchasePending = false;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
