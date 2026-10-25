import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` moved to the misc barrel in Riverpod 3.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ticker/models/tick.dart';
import 'package:riverpod_ticker/providers/ticker_providers.dart';
import 'package:riverpod_ticker/ticker_page.dart';

Widget harness(Override o) => ProviderScope(
  overrides: [o],
  child: const MaterialApp(home: TickerPage()),
);

final sample = [
  Tick(symbol: 'BTC', price: 100, change: 1.5, at: DateTime(2026)),
];

void main() {
  testWidgets('loading shows spinner', (tester) async {
    await tester.pumpWidget(
      harness(
        tickerProvider.overrideWith((ref) => const Stream<List<Tick>>.empty()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('data shows rows', (tester) async {
    await tester.pumpWidget(
      harness(tickerProvider.overrideWith((ref) => Stream.value(sample))),
    );
    await tester.pump();

    expect(find.text('BTC'), findsOneWidget);
    expect(find.textContaining('▲'), findsOneWidget);
  });

  testWidgets('error without data shows retry', (tester) async {
    await tester.pumpWidget(
      harness(
        tickerProvider.overrideWith((ref) => Stream<List<Tick>>.error('boom')),
      ),
    );
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(MaterialBanner), findsNothing);
  });

  // Exercise 5.3: this is the test that proves Part 4 works.
  testWidgets('error after data shows banner over rows', (tester) async {
    final controller = StreamController<List<Tick>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      harness(tickerProvider.overrideWith((ref) => controller.stream)),
    );

    controller.add(sample);
    await tester.pump();
    expect(find.text('BTC'), findsOneWidget);

    controller.addError(const FormatException('dropped'));
    await tester.pump();

    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
  });

  // Exercise 3.4: the empty-list arm must win over the general AsyncData arm.
  testWidgets('empty list shows the no-symbols message', (tester) async {
    await tester.pumpWidget(
      harness(
        tickerProvider.overrideWith((ref) => Stream.value(const <Tick>[])),
      ),
    );
    await tester.pump();

    expect(find.text('No symbols subscribed'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
