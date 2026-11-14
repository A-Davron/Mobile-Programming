import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._api) : super(const CartState()) {
    on<CartProductAdded>(
      (e, emit) =>
          _mutate(e, emit, state.copyWith(lines: state.lines.withProduct(e.product))), // 2.
    );
    on<CartProductRemoved>(
      (e, emit) =>
          _mutate(e, emit, state.copyWith(lines: state.lines.without(e.productId))),
    );
    // T1
    on<CartQtyChanged>(
      (e, emit) => _mutate(
        e,
        emit,
        state.copyWith(lines: state.lines.changeQty(e.productId, e.delta)),
      ),
    );
    on<CartCouponApplied>(_onCoupon); // T2
    on<CartUndone>(_onUndo); // T5
    // T4: droppable — taps arriving while a checkout runs are thrown away.
    on<CartCheckoutRequested>(_onCheckout, transformer: droppable());
  }

  final CheckoutApi _api;
  final _history = <CartState>[]; // T5: previous states, newest last

  /// Pushes onto the history only for events [isUndoable] says are undoable,
  /// and keeps [CartState.canUndo] in sync so the UI can observe it.
  void _mutate(CartEvent event, Emitter<CartState> emit, CartState next) {
    if (!isUndoable(event)) {
      emit(next);
      return;
    }
    final candidate = next.copyWith(canUndo: true);
    if (candidate != state) _history.add(state);
    emit(candidate); // equal to state → dropped, nothing reaches onTransition
  }

  // T2
  void _onCoupon(CartCouponApplied e, Emitter<CartState> emit) {
    final valid = e.code.trim().toUpperCase() == kCouponCode;
    _mutate(
      e,
      emit,
      state.copyWith(
        coupon: valid ? kCouponCode : null,
        couponError: valid ? null : 'Unknown coupon code',
      ),
    );
  }

  // T5
  void _onUndo(CartUndone e, Emitter<CartState> emit) {
    if (_history.isEmpty) return;
    final previous = _history.removeLast();
    emit(previous.copyWith(canUndo: _history.isNotEmpty));
  }

  // T4: status changes are not undoable, so they never touch the history.
  Future<void> _onCheckout(
    CartCheckoutRequested e,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.submitting, checkoutError: null));
    try {
      final orderId = await _api.submit(state.total);
      if (emit.isDone) return; // the bloc was closed during the 1500 ms
      emit(
        CartState(status: CheckoutStatus.success, orderId: orderId),
      ); // success clears the cart
    } on CheckoutException catch (ex) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: ex.message,
        ),
      ); // the cart is kept
    }
  }
}
