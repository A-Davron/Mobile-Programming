// T6: no widgets anywhere — the state holder is tested on its own.
import 'package:cart_four_ways/models/cart.dart';
import 'package:cart_four_ways/riverpod/cart_notifier.dart';
import 'package:cart_four_ways/services/checkout_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutApi extends Mock implements CheckoutApi {}

void main() {
  final keyboard = catalog[0];

  test('two keyboards with SAVE10 total 88.2', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartProvider.notifier);
    cart.add(keyboard);
    cart.add(keyboard);
    cart.applyCoupon('SAVE10');

    expect(container.read(cartProvider).total, 88.2);
  });

  test('failed checkout sets status failure and keeps the lines', () async {
    final api = MockCheckoutApi();
    when(() => api.submit(any())).thenThrow(
      const CheckoutException('Card declined'),
    );
    final container = ProviderContainer(
      overrides: [checkoutApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    final cart = container.read(cartProvider.notifier);
    cart.add(keyboard);
    await cart.checkout();

    final state = container.read(cartProvider);
    expect(state.status, CheckoutStatus.failure);
    expect(state.checkoutError, 'Card declined');
    expect(state.lines, isNotEmpty);
    expect(state.lines.single.product.id, keyboard.id);
  });

  // T2: the observation the lab asks for, as an assertion instead of a
  // debugPrint — with `==` on CartState, an unchanged value notifies nobody.
  test('re-applying the same coupon does not notify', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartProvider.notifier);
    cart.add(keyboard);

    var notifications = 0;
    container.listen(cartProvider, (previous, next) => notifications++);

    cart.applyCoupon('SAVE10');
    expect(notifications, 1);

    cart.applyCoupon('SAVE10'); // same state → no notification
    expect(notifications, 1);

    cart.changeQty(keyboard.id, 1); // a real change → notification
    expect(notifications, 2);
  });

  // T5: undo restores the previous state and canUndoProvider follows it.
  test('undo restores the previous state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartProvider.notifier);
    expect(container.read(canUndoProvider), isFalse);

    cart.add(keyboard);
    expect(container.read(canUndoProvider), isTrue);
    expect(container.read(cartProvider).itemCount, 1);

    cart.undo();
    expect(container.read(cartProvider).lines, isEmpty);
    expect(container.read(canUndoProvider), isFalse);
  });
}
