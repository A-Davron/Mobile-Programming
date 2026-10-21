import 'dart:async';
import 'dart:math';

import '../models/tick.dart';

/// Thrown by [TickFeed] once it has emitted [TickFeed.failAfter] ticks.
class FeedException implements Exception {
  const FeedException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Simulated market feed: a new batch of ticks every 500 ms, and an error on
/// demand so every [AsyncValue] state is reachable without a network.
class TickFeed {
  TickFeed({this.symbols = const ['BTC', 'ETH', 'SOL'], this.failAfter});

  final List<String> symbols;
  final int? failAfter; // emit this many ticks, then throw

  final _rng = Random();
  final _prices = <String, double>{};

  Stream<List<Tick>> watch() async* {
    var count = 0;
    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    ); // visible first load
    while (true) {
      if (failAfter != null && count >= failAfter!) {
        throw const FeedException('Feed disconnected');
      }
      yield [for (final s in symbols) _next(s)];
      count++;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Tick _next(String symbol) {
    final prev = _prices[symbol] ?? 100 + _rng.nextDouble() * 900;
    final change = (_rng.nextDouble() - 0.5) * 4;
    final price = (prev + change).clamp(1, double.infinity).toDouble();
    _prices[symbol] = price;
    return Tick(
      symbol: symbol,
      price: price,
      change: change,
      at: DateTime.now(),
    );
  }
}
