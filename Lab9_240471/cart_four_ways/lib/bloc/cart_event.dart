import '../models/cart.dart';

sealed class CartEvent {
  // 1. sealed: handlers are exhaustive-checkable
  const CartEvent();
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded(this.product);
  final Product product;
}

final class CartProductRemoved extends CartEvent {
  const CartProductRemoved(this.productId);
  final String productId;
}

// T1
final class CartQtyChanged extends CartEvent {
  const CartQtyChanged(this.productId, this.delta);
  final String productId;
  final int delta;
}

// T2
final class CartCouponApplied extends CartEvent {
  const CartCouponApplied(this.code);
  final String code;
}

// T4
final class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}

// T5
final class CartUndone extends CartEvent {
  const CartUndone();
}

/// T5: which events are undoable, written as an exhaustive switch over the
/// sealed hierarchy — adding an event without deciding is a compile error.
bool isUndoable(CartEvent event) => switch (event) {
  CartProductAdded() ||
  CartProductRemoved() ||
  CartQtyChanged() ||
  CartCouponApplied() => true,
  CartCheckoutRequested() || CartUndone() => false,
};
