import 'package:flutter/material.dart';

import '../models/tick.dart';

class TickRow extends StatelessWidget {
  const TickRow(this.tick, {super.key});

  final Tick tick;

  @override
  Widget build(BuildContext context) {
    final color = tick.isUp ? Colors.green : Colors.red;
    final arrow = tick.isUp ? '▲' : '▼';
    return ListTile(
      leading: CircleAvatar(child: Text(tick.symbol.substring(0, 1))),
      title: Text(tick.symbol),
      subtitle: Text(tick.price.toStringAsFixed(2)),
      trailing: Text(
        '$arrow ${tick.change.abs().toStringAsFixed(2)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
