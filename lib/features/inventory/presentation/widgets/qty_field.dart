import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/stock_item.dart';
import '../../domain/stock_qty.dart';

/// A quantity input: a number plus a unit switch (g/kg, ml/l, dona). Reports
/// the value in integer base units (null while empty / invalid).
class QtyField extends StatefulWidget {
  const QtyField({
    super.key,
    required this.unit,
    required this.onChanged,
    this.label,
    this.initialBase,
    this.allowZero = false,
    this.autofocus = false,
    this.onSubmitted,
  });

  final StockUnit unit;
  final ValueChanged<int?> onChanged;
  final String? label;
  final int? initialBase;
  final bool allowZero;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  @override
  State<QtyField> createState() => QtyFieldState();
}

class QtyFieldState extends State<QtyField> {
  late final List<QtyUnitOption> _options = unitOptionsFor(widget.unit);
  late final TextEditingController _controller;
  late int _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBase;
    _selected = 0;
    var text = '';
    if (initial != null) {
      final big = _options.length > 1 && initial >= 1000 && initial % 1000 == 0;
      if (big) _selected = 1;
      final shown = initial / _options[_selected].factor;
      text = shown == shown.roundToDouble()
          ? shown.round().toString()
          : shown.toString();
    }
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Quick-add chips: adds [base] (in base units) to what is typed, shown in
  /// the currently selected unit.
  void addBase(int base) {
    final current =
        parseQty(_controller.text, _options[_selected], allowZero: true) ?? 0;
    final shown = (current + base) / _options[_selected].factor;
    _controller.text = shown == shown.roundToDouble()
        ? shown.round().toString()
        : shown.toString();
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _report();
  }

  void _report() => widget.onChanged(
    parseQty(
      _controller.text,
      _options[_selected],
      allowZero: widget.allowZero,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            decoration: InputDecoration(labelText: widget.label),
            onChanged: (_) => _report(),
            onSubmitted: (_) => widget.onSubmitted?.call(),
          ),
        ),
        const SizedBox(width: 10),
        if (_options.length == 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _options.first.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (var i = 0; i < _options.length; i++)
                  ButtonSegment(value: i, label: Text(_options[i].label)),
              ],
              selected: {_selected},
              onSelectionChanged: (s) {
                setState(() => _selected = s.first);
                _report();
              },
            ),
          ),
      ],
    );
  }
}
