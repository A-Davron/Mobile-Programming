import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider lives in the legacy barrel since Riverpod 3.
import 'package:flutter_riverpod/legacy.dart';

import '../models/tick.dart';
import '../services/tick_feed.dart';

/// How many ticks the feed emits before it throws, or `null` for a feed that
/// never fails. Driving this from a provider keeps the error demo in the UI
/// instead of in a code edit.
final failAfterProvider = StateProvider<int?>((ref) => null);

/// Overridable in tests and in the error demo.
///
/// The feed sits behind its own provider so that tests can swap it without
/// touching [tickerProvider], and so a change to [failAfterProvider] rebuilds
/// the feed and restarts the stream.
final tickFeedProvider = Provider<TickFeed>((ref) {
  return TickFeed(failAfter: ref.watch(failAfterProvider));
});

final tickerProvider = StreamProvider.autoDispose<List<Tick>>(
  (ref) => ref.watch(tickFeedProvider).watch(),
  // Riverpod 3 retries a failed provider on its own, which would park the
  // state in AsyncLoading(retrying) instead of AsyncError. Returning null
  // turns that off so the error surfaces and the Retry button owns recovery.
  retry: (retryCount, error) => null,
);
