// T6: widget test for the setState version. Note how much of this test is about
// finding widgets rather than about cart logic.
import 'package:cart_four_ways/setstate/cart_page_setstate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('two keyboards with SAVE10 total 88.20', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SetStateCartPage()));

    await tester.tap(find.text('Keyboard · 49'));
    await tester.pump();
    await tester.tap(find.text('Keyboard · 49'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'SAVE10');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Apply'));
    await tester.pump();

    expect(find.text('88.20'), findsOneWidget);
  });
}
