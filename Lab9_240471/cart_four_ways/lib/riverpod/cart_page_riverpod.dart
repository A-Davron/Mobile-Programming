import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../widgets/cart_body.dart';
import 'cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider); // 3. subscribe: rebuild on change
    final cart = ref.read(
      cartProvider.notifier,
    ); // 4. handle to call methods, no subscription
    final canUndo = ref.watch(canUndoProvider); // T5

    // T4: side effects belong in listen, never in build.
    ref.listen(cartProvider.select((s) => s.status), (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      switch (next) {
        case CheckoutStatus.success:
          messenger
            ..hideCurrentMaterialBanner()
            ..showSnackBar(
              SnackBar(
                content: Text('Order ${ref.read(cartProvider).orderId} placed'),
              ),
            );
        case CheckoutStatus.failure:
          messenger.showMaterialBanner(
            MaterialBanner(
              content: Text(
                ref.read(cartProvider).checkoutError ?? 'Checkout failed',
              ),
              actions: [
                TextButton(
                  onPressed: messenger.hideCurrentMaterialBanner,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          );
        case CheckoutStatus.idle:
        case CheckoutStatus.submitting:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Riverpod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: canUndo ? cart.undo : null,
          ),
        ],
      ),
      body: CartBody(
        state: state,
        onAdd: cart.add,
        onRemove: cart.remove,
        onQtyChanged: cart.changeQty,
        onCouponApplied: cart.applyCoupon,
        onCheckout: cart.checkout,
        summary: const RiverpodSummaryCard(),
      ),
    );
  }
}

class RiverpodSummaryCard extends ConsumerWidget {
  const RiverpodSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(cartProvider.select(CartTotals.of));
    debugPrint('[RiverpodSummaryCard] build — total=${totals.total}');
    return CartSummaryCard(totals: totals);
  }
}