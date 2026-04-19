import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPremiumProductId = 'com.minoapp.fortunemirror.premium_monthly';
const _kPremiumKey = 'is_premium';

class IapState {
  final bool isPremium;
  final bool isLoading;
  final ProductDetails? product;
  final String? error;

  const IapState({
    this.isPremium = false,
    this.isLoading = false,
    this.product,
    this.error,
  });

  IapState copyWith({
    bool? isPremium,
    bool? isLoading,
    ProductDetails? product,
    String? error,
    bool clearError = false,
  }) =>
      IapState(
        isPremium: isPremium ?? this.isPremium,
        isLoading: isLoading ?? this.isLoading,
        product: product ?? this.product,
        error: clearError ? null : (error ?? this.error),
      );
}

class IapNotifier extends StateNotifier<IapState> {
  IapNotifier() : super(const IapState()) {
    _init();
  }

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kPremiumKey) ?? false) {
      state = state.copyWith(isPremium: true);
    }

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);

    final available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails({kPremiumProductId});
    if (response.productDetails.isNotEmpty) {
      state = state.copyWith(product: response.productDetails.first);
    }

    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != kPremiumProductId) continue;

      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _setPremium(true);
        await _iap.completePurchase(p);
      } else if (p.status == PurchaseStatus.error) {
        state = state.copyWith(isLoading: false, error: p.error?.message);
      } else if (p.status == PurchaseStatus.canceled) {
        state = state.copyWith(isLoading: false);
      } else if (p.status == PurchaseStatus.pending) {
        state = state.copyWith(isLoading: false, error: 'pending');
      }
    }
    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _setPremium(bool value) async {
    state = state.copyWith(isPremium: value, clearError: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, value);
  }

  Future<void> purchase() async {
    final product = state.product;
    if (product == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _iap.restorePurchases();
    // If no purchases exist, the stream never emits and isLoading stays true.
    // Fall back to clearing after 4 seconds.
    await Future.delayed(const Duration(seconds: 4));
    if (state.isLoading) {
      state = state.copyWith(isLoading: false, error: 'restore_empty');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final iapProvider = StateNotifierProvider<IapNotifier, IapState>(
  (ref) => IapNotifier(),
);
