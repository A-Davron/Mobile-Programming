import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart.dart';
import '../services/checkout_api.dart';
import '../widgets/cart_body.dart';
import 'cart_bloc.dart';
import 'cart_event.dart';

class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CartBloc(CheckoutApi()),
    child: const _BlocCartView(),
  );
}

/// Same widget code as the Cubit page, except `.add(Event)` instead of
/// `.method()` — that is the whole difference on the widget side.
class _BlocCartView extends StatelessWidget {
  const _BlocCartView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart · Bloc'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.canUndo != c.canUndo,
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: state.canUndo
                  ? () => bloc.add(const CartUndone())
                  : null,
            ),
          ),
        ],
      ),
      body: BlocListener<CartBloc, CartState>(
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
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) => CartBody(
            state: state,
            onAdd: (p) => bloc.add(CartProductAdded(p)), // 3. add an event
            onRemove: (id) => bloc.add(CartProductRemoved(id)),
            onQtyChanged: (id, delta) => bloc.add(CartQtyChanged(id, delta)),
            onCouponApplied: (code) => bloc.add(CartCouponApplied(code)),
            onCheckout: () => bloc.add(const CartCheckoutRequested()),
            summary: const BlocSummaryCard(),
          ),
        ),
      ),
    );
  }
}

/// T3: the Part 4 summary card, parameterised on `CartBloc`.
class BlocSummaryCard extends StatelessWidget {
  const BlocSummaryCard({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CartBloc, CartState, CartTotals>(
        selector: CartTotals.of,
        builder: (context, totals) {
          debugPrint('[BlocSummaryCard] build — total=${totals.total}');
          return CartSummaryCard(totals: totals);
        },
      );
}
