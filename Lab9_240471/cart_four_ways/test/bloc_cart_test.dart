// T6: the same two tests as Part 4, plus the droppable() check.
import 'package:bloc_test/bloc_test.dart';
import 'package:cart_four_ways/bloc/cart_bloc.dart';
import 'package:cart_four_ways/bloc/cart_event.dart';
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog[0];
  CartLine line(int qty) => CartLine(product: keyboard, qty: qty);

  blocTest<CartBloc, CartState>(
    'two keyboards and SAVE10 emit exactly three states',
    build: () => CartBloc(MockCheckoutApi()),
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(CartProductAdded(keyboard))
      ..add(const CartCouponApplied('SAVE10')),
    expect: () => [
      CartState(lines: [line(1)], canUndo: true),
      CartState(lines: [line(2)], canUndo: true),
      CartState(lines: [line(2)], coupon: kCouponCode, canUndo: true),
    ],
    verify: (b) => expect(b.state.total, 88.2),
  );

  blocTest<CartBloc, CartState>(
    'a failing checkout emits submitting then failure and keeps the cart',
    build: () {
      final api = MockCheckoutApi();
      when(
        () => api.submit(any()),
      ).thenThrow(const CheckoutException('Card declined'));
      return CartBloc(api);
    },
    act: (b) => b
      ..add(CartProductAdded(keyboard))
      ..add(const CartCheckoutRequested()),
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

  // T4: droppable() throws away the taps that arrive while one checkout runs,
  // so exactly one `submitting` is emitted. With a Cubit all three would run.
  blocTest<CartBloc, CartState>(
    'droppable(): three fast checkout taps submit once',
    build: () {
      final api = MockCheckoutApi();
      when(() => api.submit(any())).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => 'ORD-1'),
      );
      return CartBloc(api);
    },
    act: (b) => b
      ..add(const CartCheckoutRequested())
      ..add(const CartCheckoutRequested())
      ..add(const CartCheckoutRequested()),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const CartState(status: CheckoutStatus.submitting),
      const CartState(status: CheckoutStatus.success, orderId: 'ORD-1'),
    ],
  );
}
