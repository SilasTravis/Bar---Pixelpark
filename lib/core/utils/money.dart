import 'package:flutter/services.dart';

/// Groups an integer's digits in threes with plain spaces:
/// `groupThousands(1450000) == "1 450 000"`, negatives keep their sign.
String groupThousands(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
  }
  return '${amount < 0 ? '-' : ''}$buffer';
}

/// Formats a so'm amount the way the cashier design does —
/// `formatUzs(145000) == "145 000 so'm"`.
String formatUzs(int amount) => "${groupThousands(amount)} so'm";

/// Like [formatUzs], but always shows the sign of a difference:
/// `+5 000 so'm`, `-2 000 so'm`, `0 so'm`.
String formatSignedUzs(int amount) =>
    amount > 0 ? '+${formatUzs(amount)}' : formatUzs(amount);

/// Reads a typed amount back: every non-digit (the grouping spaces) is
/// dropped. Empty input is `null`, not 0, so "nothing typed yet" stays
/// distinguishable from a counted drawer of zero.
int? parseUzsInput(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

/// Digits-only money field that re-groups thousands as the cashier types
/// (`1500000` → `1 500 000`) and keeps the caret at the end.
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDigits = 13});

  /// Caps the amount so it always fits a 64-bit int.
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    // Leading zeros carry no value ("007" → "7"), but a lone "0" is a
    // legitimate count of an empty drawer.
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = groupThousands(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
