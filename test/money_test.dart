import 'package:bar_app/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatUzs', () {
    test('groups thousands with spaces', () {
      expect(formatUzs(0), "0 so'm");
      expect(formatUzs(999), "999 so'm");
      expect(formatUzs(1000), "1 000 so'm");
      expect(formatUzs(145000), "145 000 so'm");
      expect(formatUzs(1450000), "1 450 000 so'm");
      expect(formatUzs(-2500), "-2 500 so'm");
    });

    test('signed variant shows + for a surplus', () {
      expect(formatSignedUzs(5000), "+5 000 so'm");
      expect(formatSignedUzs(-2000), "-2 000 so'm");
      expect(formatSignedUzs(0), "0 so'm");
    });
  });

  group('parseUzsInput', () {
    test('reads grouped input; empty is null, not zero', () {
      expect(parseUzsInput('1 450 000'), 1450000);
      expect(parseUzsInput('0'), 0);
      expect(parseUzsInput(''), isNull);
      expect(parseUzsInput("  so'm "), isNull);
    });
  });

  group('ThousandsInputFormatter', () {
    const formatter = ThousandsInputFormatter();

    TextEditingValue type(String text) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );

    test('re-groups as the cashier types and keeps the caret at the end', () {
      final value = type('1500000');
      expect(value.text, '1 500 000');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('drops non-digits and leading zeros but keeps a lone zero', () {
      expect(type('12a3').text, '123');
      expect(type('0070').text, '70');
      expect(type('0').text, '0');
      expect(type('').text, '');
    });

    test('caps the length', () {
      expect(type('9' * 20).text.replaceAll(' ', '').length, 13);
    });
  });
}
