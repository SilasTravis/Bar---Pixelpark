import 'stock_item.dart';

/// An input unit a quantity can be typed in, with its factor to base units.
class QtyUnitOption {
  const QtyUnitOption(this.label, this.factor);

  final String label;
  final int factor;
}

/// `g` → [g, kg]; `ml` → [ml, l]; `pcs` → [dona].
List<QtyUnitOption> unitOptionsFor(StockUnit unit) => [
  QtyUnitOption(unit.baseLabel, 1),
  if (unit.bigLabel != null) QtyUnitOption(unit.bigLabel!, 1000),
];

/// Typed text ("1,5") in [option] → integer base units. Null when it is
/// not a positive number (or [allowZero] is false and it is zero).
int? parseQty(String text, QtyUnitOption option, {bool allowZero = false}) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return null;
  }
  final base = (value * option.factor).round();
  if (base > 1000000000) return null;
  if (base == 0 && !allowZero) return null;
  return base;
}

String _trimDecimals(double v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _group(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

/// Base units for display: kg / l from 1000, else g / ml / dona.
String formatQty(int base, StockUnit unit) {
  final big = unit.bigLabel;
  if (big != null && base.abs() >= 1000) {
    return '${_trimDecimals(base / 1000).replaceAll('.', ',')} $big';
  }
  return '${_group(base)} ${unit.baseLabel}';
}

/// Signed, for the movements journal (`+500 g`, `-1,5 kg`).
String formatQtyDelta(int delta, StockUnit unit) =>
    '${delta > 0 ? '+' : ''}${formatQty(delta, unit)}';
