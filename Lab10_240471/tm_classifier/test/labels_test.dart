import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  group('parseLabels', () {
    test('strips the index from a plain labels.txt', () {
      expect(parseLabels('0 Mug\n1 Bottle\n'), ['Mug', 'Bottle']);
    });

    test('survives CRLF endings, a blank line and a label with a space', () {
      const raw = '0 Mug\r\n1 Bottle\r\n2 Car keys\r\n\r\n';

      expect(parseLabels(raw), ['Mug', 'Bottle', 'Car keys']);
    });
  });
}
