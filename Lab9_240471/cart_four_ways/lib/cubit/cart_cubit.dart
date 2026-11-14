import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';

class CartCubit extends Cubit<CartState> {
  // T4: the API is injected through the constructor, so a test passes a mock.
  CartCubit(this._api) : super(const CartState()); // 1. initial state

  final CheckoutApi _api;
  final _history = <CartState>[]; // T5: previous states, newest last

  /// Every cart mutation goes through here, so history is pushed once and
  /// [CartState.canUndo] stays in sync with it.
  void _mutate(CartState next) {
    final candidate = next.copyWith(canUndo: true);
    // An unchanged state must not land in the history either: `emit` below is
    // dropped by bloc (`newState == state`), so nothing reaches `onChange`.
    if (candidate != state) _history.add(state);
    emit(candidate); // 2. emit, not assignment
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
    final previous = _history.removeLast();
    // Undo is not itself a mutation, so it does not push.
    emit(previous.copyWith(canUndo: _history.isNotEmpty));
  }

  // T4: status changes are not pushed onto the undo history.
  Future<void> checkout() async {
    emit(
      state.copyWith(
        status: CheckoutStatus.submitting,
        checkoutError: null,
      ),
    );
    try {
      final orderId = await _api.submit(state.total);
      if (isClosed) return; // the page may have been popped during the 1500 ms
      emit(
        CartState(status: CheckoutStatus.success, orderId: orderId),
      ); // success clears the cart
    } on CheckoutException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: e.message,
        ),
      ); // the cart is kept
    }
  }

  // T2: proof that an emit equal to the current state is dropped.
  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    debugPrint('[CartCubit] onChange → total=${change.nextState.total}');
  }
}
