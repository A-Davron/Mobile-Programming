import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/tick.dart';
import 'providers/ticker_providers.dart';
import 'widgets/tick_row.dart';

class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticks = ref.watch(tickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ticker'),
        actions: [
          IconButton(
            tooltip: 'Break the feed after 5 ticks',
            icon: const Icon(Icons.flash_off),
            onPressed: () => ref.read(failAfterProvider.notifier).state = 5,
          ),
          IconButton(
            tooltip: 'Heal the feed',
            icon: const Icon(Icons.flash_on),
            onPressed: () => ref.read(failAfterProvider.notifier).state = null,
          ),
        ],
      ),
      // Arm order is a priority list: the specific arms sit above the general
      // ones, so stale data wins over a bare spinner or a bare error.
      body: switch (ticks) {
        // Error with stale data: rows dimmed, banner on top.
        AsyncError(:final error, :final value?) => Column(
          children: [
            MaterialBanner(
              content: Text('Feed error: $error — showing last prices'),
              actions: [
                TextButton(
                  onPressed: () => ref.invalidate(tickerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
            Expanded(child: Opacity(opacity: 0.5, child: _rows(value))),
          ],
        ),
        // Error with nothing to show.
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load ticker\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(tickerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        // Refresh or reload in progress, keep rows, show thin progress bar.
        AsyncValue(:final value?, isLoading: true) => Column(
          children: [
            const LinearProgressIndicator(),
            Expanded(child: _rows(value)),
          ],
        ),
        AsyncData(value: []) => const Center(
          child: Text('No symbols subscribed'),
        ),
        AsyncData(value: [final only]) => Center(child: TickRow(only)),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(tickerProvider.future),
          child: _rows(value),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _rows(List<Tick> ticks) => ListView(
    children: [for (final t in ticks) TickRow(t, key: ValueKey(t.symbol))],
  );
}
