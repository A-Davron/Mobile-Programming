import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Part 1 stub: proves a `ProviderScope` boots and a `ConsumerWidget` renders
/// before any ticker code exists. Part 3 replaces the body with the
/// `AsyncValue` switch.
class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: Center(child: Text('Ticker')));
  }
}
