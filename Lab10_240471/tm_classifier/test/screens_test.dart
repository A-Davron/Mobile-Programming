import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tm_classifier/models/classification.dart';
import 'package:tm_classifier/screens/history_screen.dart';
import 'package:tm_classifier/screens/result_screen.dart';
import 'package:tm_classifier/screens/welcome_screen.dart';
import 'package:tm_classifier/services/classifier.dart';
import 'package:tm_classifier/services/session_history.dart';
import 'package:tm_classifier/theme/app_theme.dart';

/// A small phone (iPhone SE size) to catch overflow stripes.
const _smallPhone = Size(320, 568);

Uint8List _png() => img.encodePng(img.Image(width: 40, height: 30));

Classification _entry() => Classification(
      bytes: _png(),
      origin: ImageOrigin.sample,
      predictions: const [
        Prediction('Magic mouse', 0.864),
        Prediction('Wallet', 0.079),
        Prediction('Phone', 0.031),
        Prediction('Notebook', 0.015),
        Prediction('Arm', 0.008),
        Prediction('Zayniddin', 0.003),
      ],
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = _smallPhone;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)));
}

void main() {
  testWidgets('History shows a designed empty state', (tester) async {
    await _pump(tester, HistoryScreen(history: SessionHistory()));

    expect(find.text('Nothing classified yet'), findsOneWidget);
  });

  testWidgets('Result shows every label with its percentage on a small phone', (tester) async {
    await _pump(tester, ResultScreen(classification: _entry()));

    expect(find.text('86.4%'), findsOneWidget);
    for (final label in ['Wallet', 'Phone', 'Notebook', 'Arm', 'Zayniddin']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Sample image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('History lists the newest entry first', (tester) async {
    final history = SessionHistory()
      ..add(_entry())
      ..add(Classification(
        bytes: _png(),
        origin: ImageOrigin.sample,
        predictions: const [Prediction('Arm', 0.9), Prediction('Phone', 0.1)],
      ));
    await _pump(tester, HistoryScreen(history: history));

    final titles = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title as Text).data).toList();
    expect(titles, ['Arm', 'Magic mouse']);
  });

  testWidgets('Welcome shows the missing model path instead of crashing', (tester) async {
    await _pump(
      tester,
      WelcomeScreen(
        classifier: null,
        error: const ClassifierException(
          'The model file could not be loaded.',
          detail: 'Expected assets/model/model_unquant.tflite',
        ),
        onGetStarted: () {},
      ),
    );

    expect(find.text('The model file could not be loaded.'), findsOneWidget);
    expect(find.textContaining('assets/model/model_unquant.tflite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
