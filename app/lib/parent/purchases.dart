import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// The one-time "unlock everything" product.
/// TODO(store): create this id in App Store Connect and the Play Console.
const fullUnlockProductId = 'pips_world_full_unlock';

/// Free sampler: the first two levels of every world (PLAN 5.2).
const samplerLevels = 2;

/// Preview builds (the GitHub Pages web build) can unlock everything:
/// `--dart-define=PIP_UNLOCK_ALL=true`.
const unlockAllBuild = bool.fromEnvironment('PIP_UNLOCK_ALL');

/// Buying and restoring the full version. Only used from the parent area,
/// which is behind the parental gate; Pip never mentions it (CLAUDE.md).
abstract interface class PurchaseService {
  Future<bool> available();

  /// Localised price from the store, e.g. "€4.99", or null if unknown.
  Future<String?> price();
  Future<void> buy();
  Future<void> restore();

  /// Called when a purchase or restore unlocks the full version.
  set onUnlocked(VoidCallback callback);
  void dispose();
}

/// Web and desktop: no store.
class NoStorePurchaseService implements PurchaseService {
  @override
  Future<bool> available() async => false;

  @override
  Future<String?> price() async => null;

  @override
  Future<void> buy() async {}

  @override
  Future<void> restore() async {}

  @override
  set onUnlocked(VoidCallback callback) {}

  @override
  void dispose() {}
}

/// App Store / Google Play via in_app_purchase. The entitlement is kept on the
/// device only (no server, no account); restore brings it back.
class StorePurchaseService implements PurchaseService {
  StorePurchaseService([InAppPurchase? iap]) : _iap = iap ?? InAppPurchase.instance {
    _sub = _iap.purchaseStream.listen(handle, onError: (Object _) {});
  }

  final InAppPurchase _iap;
  late final StreamSubscription<List<PurchaseDetails>> _sub;
  ProductDetails? _product;
  VoidCallback? _onUnlocked;

  @override
  set onUnlocked(VoidCallback callback) => _onUnlocked = callback;

  @override
  Future<bool> available() => _iap.isAvailable();

  Future<ProductDetails?> _load() async {
    if (_product != null) return _product;
    if (!await available()) return null;
    final r = await _iap.queryProductDetails({fullUnlockProductId});
    return _product = r.productDetails.firstOrNull;
  }

  @override
  Future<String?> price() async => (await _load())?.price;

  @override
  Future<void> buy() async {
    final p = await _load();
    if (p != null) await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @visibleForTesting
  Future<void> handle(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == fullUnlockProductId &&
          (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored)) {
        _onUnlocked?.call();
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  @override
  void dispose() => _sub.cancel();
}

/// Levels a child can see: all when unlocked, else the sampler.
List<T> visibleLevels<T>(List<T> levels, {required bool unlocked}) =>
    unlocked ? levels : levels.take(samplerLevels).toList();
