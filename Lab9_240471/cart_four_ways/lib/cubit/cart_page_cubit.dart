import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import 'cart_cubit.dart';

class CubitCartPage extends StatelessWidget {
  const CubitCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // 3. scoped to this subtree, closed on dispose
    create: (_) => CartCubit(CheckoutApi()),
    child: const _CubitCartView(),
  );
}

/// Separate widget so `context.read<CartCubit>()` sits *below* the provider.
class _CubitCartView extends StatelessWidget {
  const _CubitCartView();

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>(); // 5. lookup without subscribing
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Cubit'),
        actions: [
          // T5: canUndo lives in the state, so BlocBuilder can observe it.
          BlocBuilder<CartCubit, CartState>(
            buildWhen: (p, c) => p.canUndo != c.canUndo,
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: state.canUndo ? cart.undo : null,
            ),
          ),
        ],
      ),
      // T4: side effects belong in a listener, never in a builder.
      body: BlocListener<CartCubit, CartState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          switch (state.status) {
            case CheckoutStatus.success:
              messenger
                ..hideCurrentMaterialBanner()
                ..showSnackBar(
                  SnackBar(content: Text('Order ${state.orderId} placed')),
                );
            case CheckoutStatus.failure:
              messenger.showMaterialBanner(
                MaterialBanner(
                  content: Text(state.checkoutError ?? 'Checkout failed'),
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
        },
        child: BlocBuilder<CartCubit, CartState>(
          // 4. subscribe: rebuild on new state
          builder: (context, state) => CartBody(
            state: state,
            onAdd: cart.add,
            onRemove: cart.remove,
            onQtyChanged: cart.changeQty,
            onCouponApplied: cart.applyCoupon,
            onCheckout: cart.checkout,
            summary: const CubitSummaryCard(),
          ),
        ),
      ),
    );
  }
}

/// T3: a `BlocSelector` on the derived values only — typing in the coupon field
/// leaves all four equal, so this does not rebuild.
class CubitSummaryCard extends StatelessWidget {
  const CubitSummaryCard({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartCubit, CartState, CartTotals>(
        selector: CartTotals.of,
        builder: (context, totals) {
          debugPrint('[CubitSummaryCard] build — total=${totals.total}');
          return CartSummaryCard(totals: totals);
        },
      );
}
