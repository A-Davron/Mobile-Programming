import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';

class SetStateCartPage extends StatefulWidget {
  const SetStateCartPage({super.key});

  @override
  State<SetStateCartPage> createState() => _SetStateCartPageState();
}

class _SetStateCartPageState extends State<SetStateCartPage> {
  CartState _state = const CartState();
  final List<CartState> _history = []; // T5: previous states, newest last
  final CheckoutApi _api = CheckoutApi();

  /// T5: every cart mutation goes through here, so history is pushed once.
  void _mutate(CartState next) => setState(() {
    // 2.
    _history.add(_state);
    _state = next;
  });

  void _add(Product p) =>
      _mutate(_state.copyWith(lines: _state.lines.withProduct(p)));

  void _remove(String id) =>
      _mutate(_state.copyWith(lines: _state.lines.without(id)));

  // T1
  void _changeQty(String id, int delta) =>
      _mutate(_state.copyWith(lines: _state.lines.changeQty(id, delta)));

  // T2
  void _applyCoupon(String code) {
    final entered = code.trim().toUpperCase();
    final valid = entered == kCouponCode;
    _mutate(
      _state.copyWith(
        coupon: valid ? kCouponCode : null,
        couponError: valid ? null : 'Unknown coupon code',
      ),
    );
  }

  // T5
  void _undo() {
    if (_history.isEmpty) return;
    setState(() => _state = _history.removeLast());
  }

  // T4
  Future<void> _checkout() async {
    // Checkout status changes are not pushed onto the undo history.
    setState(
      () => _state = _state.copyWith(
        status: CheckoutStatus.submitting,
        checkoutError: null,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      final orderId = await _api.submit(_state.total);
      if (!mounted) return; // the page may be gone after 1500 ms
      setState(
        () => _state = CartState(
          status: CheckoutStatus.success,
          orderId: orderId,
        ), // success clears the cart
      );
      messenger
        ..hideCurrentMaterialBanner()
        ..showSnackBar(SnackBar(content: Text('Order $orderId placed')));
    } on CheckoutException catch (e) {
      if (!mounted) return;
      setState(
        () => _state = _state.copyWith(
          status: CheckoutStatus.failure,
          checkoutError: e.message,
        ), // the cart is kept
      );
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart · setState'),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: _history.isEmpty ? null : _undo, // T5: disabled when empty
        ),
      ],
    ),
    body: CartBody(
      // 3.
      state: _state,
      onAdd: _add,
      onRemove: _remove,
      onQtyChanged: _changeQty,
      onCouponApplied: _applyCoupon,
      onCheckout: _checkout,
    ),
  );
}
