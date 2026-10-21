import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tick.dart';
import '../services/tick_feed.dart';

/// Overridable in tests and in the error demo.
///
/// The feed sits behind its own provider so that tests can swap it without
/// touching [tickerProvider], and so Part 4 can rebuild it from a
/// `failAfter` setting.
final tickFeedProvider = Provider<TickFeed>((ref) => TickFeed());

final tickerProvider = StreamProvider.autoDispose<List<Tick>>((ref) {
  return ref.watch(tickFeedProvider).watch();
});
