import 'package:flutter/material.dart';

import '../models/cart.dart';

class CartBody extends StatelessWidget {
  const CartBody({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onCouponApplied,
    required this.onCheckout,
  });

  final CartState state;
  final void Function(Product) onAdd;
  final void Function(String productId) onRemove;
  final void Function(String productId, int delta) onQtyChanged;
  final void Function(String code) onCouponApplied;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final lines = state.lines;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final p in catalog)
                ActionChip(
                  label: Text('${p.name} · ${p.price.toStringAsFixed(0)}'),
                  onPressed: () => onAdd(p),
                ),
            ],
          ),
        ),
        Expanded(
          child: lines.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView(
                  children: [
                    for (final l in lines)
                      ListTile(
                        key: ValueKey(l.product.id),
                        title: Text(l.product.name),
                        subtitle: Text('× ${l.qty}'),
                        // T1: the delete icon became a − / + stepper.
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              tooltip: 'Decrease',
                              onPressed: () => onQtyChanged(l.product.id, -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Increase',
                              onPressed: () => onQtyChanged(l.product.id, 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        _CouponField(
          coupon: state.coupon,
          error: state.couponError,
          onApply: onCouponApplied,
        ),
        _SummaryCard(state: state),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  lines.isEmpty || state.status == CheckoutStatus.submitting
                  ? null
                  : onCheckout,
              child: state.status == CheckoutStatus.submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Checkout'),
            ),
          ),
        ),
      ],
    );
  }
}

/// T2: owns only the `TextEditingController`, so `CartBody` stays stateless and
/// style-independent. The applied coupon and its error still live in the state.
class _CouponField extends StatefulWidget {
  const _CouponField({
    required this.coupon,
    required this.error,
    required this.onApply,
  });

  final String? coupon;
  final String? error;
  final void Function(String code) onApply;

  @override
  State<_CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<_CouponField> {
  late final _controller = TextEditingController(text: widget.coupon ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Coupon code',
              errorText: widget.error,
              errorStyle: const TextStyle(color: Colors.red),
            ),
            onSubmitted: widget.onApply,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton(
            onPressed: () => widget.onApply(_controller.text),
            child: const Text('Apply'),
          ),
        ),
      ],
    ),
  );
}

/// T3: reads getters off `CartState`; it stores nothing itself.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _row('Items', '${state.itemCount}'),
          _row('Subtotal', state.subtotal.toStringAsFixed(2)),
          _row('Discount', '-${state.discount.toStringAsFixed(2)}'),
          _row('Total', state.total.toStringAsFixed(2)),
        ],
      ),
    ),
  );

  Widget _row(String label, String value) =>
      ListTile(dense: true, title: Text(label), trailing: Text(value));
}
