// T6: blocTest asserts the *sequence* of emitted states, not just the end
// state like the Riverpod test does.
import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/cubit/cart_cubit.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog[0];
  CartLine line(int qty) => CartLine(product: keyboard, qty: qty);

  blocTest<CartCubit, CartState>(
    'two keyboards and SAVE10 emit exactly three states',
    build: () => CartCubit(MockCheckoutApi()),
    act: (c) {
      c.add(keyboard);
      c.add(keyboard);
      c.applyCoupon('SAVE10');
    },
    expect: () => [
      CartState(lines: [line(1)], canUndo: true),
      CartState(lines: [line(2)], canUndo: true),
      CartState(lines: [line(2)], coupon: kCouponCode, canUndo: true),
    ],
    verify: (c) => expect(c.state.total, 88.2),
  );

  blocTest<CartCubit, CartState>(
    'a failing checkout emits submitting then failure and keeps the cart',
    build: () {
      final api = MockCheckoutApi();
      when(
        () => api.submit(any()),
      ).thenThrow(const CheckoutException('Card declined'));
      return CartCubit(api);
    },
    act: (c) async {
      c.add(keyboard);
      await c.checkout();
    },
    expect: () => [
      CartState(lines: [line(1)], canUndo: true),
      CartState(
        lines: [line(1)],
        status: CheckoutStatus.submitting,
        canUndo: true,
      ),
      CartState(
        lines: [line(1)],
        status: CheckoutStatus.failure,
        checkoutError: 'Card declined',
        canUndo: true,
      ),
    ],
  );

  // T2: the second identical coupon produces no state at all.
  blocTest<CartCubit, CartState>(
    're-applying the same coupon is dropped',
    build: () => CartCubit(MockCheckoutApi()),
    act: (c) {
      c.applyCoupon('SAVE10');
      c.applyCoupon('SAVE10');
    },
    expect: () => [const CartState(coupon: kCouponCode, canUndo: true)],
  );
}
