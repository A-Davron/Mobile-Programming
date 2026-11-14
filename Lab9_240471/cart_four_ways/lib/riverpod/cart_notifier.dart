import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

/// T4: the API behind a provider, so a test can override it with a mock.
final checkoutApiProvider = Provider((ref) => CheckoutApi());

class CartNotifier extends Notifier<CartState> {
  final _history = <CartState>[]; // T5: previous states, newest last

  @override
  CartState build() => const CartState(); // 1. initial state, re-run on invalidate
  bool get canUndo => _history.isNotEmpty;

  /// Every cart mutation goes through here, so history is pushed once.
  void _mutate(CartState next) {
    _history.add(state);
    state = next; // 2. assignment notifies listeners
  }

  void add(Product p) =>
      _mutate(state.copyWith(lines: state.lines.withProduct(p)));

  void remove(String id) =>
      _mutate(state.copyWith(lines: state.lines.without(id)));

  // T1: reuses the pure helper from Part 1.
  void changeQty(String id, int delta) =>
      _mutate(state.copyWith(lines: state.lines.changeQty(id, delta)));

  // T2
  void applyCoupon(String code) {
    final entered = code.trim().toUpperCase();
    final valid = entered == kCouponCode;
    _mutate(
      state.copyWith(
        coupon: valid ? kCouponCode : null,
        couponError: valid ? null : 'Unknown coupon code',
      ),
    );
  }

  // T5
  void undo() {
    if (_history.isEmpty) return;
    state = _history.removeLast(); // not pushed: undo is not a mutation
  }

  // T4: status changes are not pushed onto the undo history.
  Future<void> checkout() async {
    state = state.copyWith(
      status: CheckoutStatus.submitting,
      checkoutError: null,
    );
    try {
      final orderId = await ref.read(checkoutApiProvider).submit(state.total);
      // No `mounted` check: the notifier lives in the container, not the tree.
      state = CartState(status: CheckoutStatus.success, orderId: orderId);
    } on CheckoutException catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        checkoutError: e.message,
      );
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// T5: it must watch `cartProvider`, because `canUndo` can only change as a
/// side effect of the state changing; the history itself is not observable.
final canUndoProvider = Provider<bool>((ref) {
  ref.watch(cartProvider);
  return ref.read(cartProvider.notifier).canUndo;
});
