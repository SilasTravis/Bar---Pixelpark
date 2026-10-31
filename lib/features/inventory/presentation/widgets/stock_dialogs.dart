import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/stock_item.dart';
import '../../domain/stock_qty.dart';
import '../cubit/inventory_cubit.dart';
import 'qty_field.dart';

/// Kirim / Brak / Sanash for one item. Returns true when saved. The request
/// id is taken once on open, so Enter / retry after a failure re-sends the
/// same key and cannot apply twice.
Future<bool> showStockOpDialog(
  BuildContext context, {
  required StockBatchKind kind,
  required StockItem item,
}) async {
  final cubit = context.read<InventoryCubit>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _StockOpDialog(kind: kind, item: item),
    ),
  );
  return saved ?? false;
}

class _StockOpDialog extends StatefulWidget {
  const _StockOpDialog({required this.kind, required this.item});

  final StockBatchKind kind;
  final StockItem item;

  @override
  State<_StockOpDialog> createState() => _StockOpDialogState();
}

class _StockOpDialogState extends State<_StockOpDialog> {
  late final String _requestId = context.read<InventoryCubit>().newRequestId();
  final _reason = TextEditingController();
  final _qtyKey = GlobalKey<QtyFieldState>();
  final _cost = TextEditingController();
  late int? _qty = widget.kind == StockBatchKind.count
      ? widget.item.qtyOnHand
      : null;
  String? _qtyError;
  String? _reasonError;
  String? _failure;
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    _cost.dispose();
    super.dispose();
  }

  int? get _costUzs => int.tryParse(_cost.text.replaceAll(RegExp(r'\D'), ''));

  /// The comment, plus (for a kirim) the purchase price line, so what was
  /// paid stays in the movements journal.
  String? _composeReason() {
    final parts = [
      if (_reason.text.trim().isNotEmpty) _reason.text.trim(),
      if (widget.kind == StockBatchKind.receipt &&
          _qty != null &&
          _costUzs != null)
        ?purchaseNote(_costUzs!, _qty!, widget.item.unit),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalization.of(context);
    final isCount = widget.kind == StockBatchKind.count;
    final isWriteoff = widget.kind == StockBatchKind.writeoff;
    final onHand = widget.item.qtyOnHand;
    final qtyError = _qty == null
        ? (isCount ? l10n.qtyCountInvalid : l10n.qtyInvalid)
        : (isWriteoff && _qty! > onHand
              ? l10n.opExceeds(formatQty(onHand, widget.item.unit))
              : null);
    final reasonError = isWriteoff && _reason.text.trim().length < 2
        ? l10n.opReasonRequired
        : null;
    if (qtyError != null || reasonError != null) {
      setState(() {
        _qtyError = qtyError;
        _reasonError = reasonError;
      });
      return;
    }
    setState(() {
      _qtyError = null;
      _reasonError = null;
      _failure = null;
      _saving = true;
    });
    final cubit = context.read<InventoryCubit>();
    final Either<Failure, Unit> result = await cubit.submit(
      widget.kind,
      requestId: _requestId,
      stockItemId: widget.item.id,
      qty: _qty!,
      reason: _composeReason(),
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _failure = failureMessage(l10n, failure);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final item = widget.item;
    final (title, icon) = switch (widget.kind) {
      StockBatchKind.receipt => (l10n.opReceipt, Icons.add_circle_outline),
      StockBatchKind.writeoff => (l10n.opWriteoff, Icons.delete_outline),
      StockBatchKind.count => (l10n.opCount, Icons.fact_check_outlined),
    };
    final isCount = widget.kind == StockBatchKind.count;
    final isWriteoff = widget.kind == StockBatchKind.writeoff;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      icon: Icon(icon, color: AppColors.accent, size: 30),
      title: Text('$title: ${item.name}', style: AppTextStyles.h4),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.inventoryOnHand}: ${formatQty(item.qtyOnHand, item.unit)}',
              style: AppTextStyles.muted(AppTextStyles.body),
            ),
            if (isCount) ...[
              const SizedBox(height: 4),
              Text(
                l10n.opCountHint,
                style: AppTextStyles.muted(
                  AppTextStyles.body,
                ).copyWith(fontSize: 13),
              ),
            ],
            const SizedBox(height: 14),
            QtyField(
              key: _qtyKey,
              unit: item.unit,
              label: l10n.qtyLabel,
              allowZero: isCount,
              autofocus: true,
              initialBase: isCount ? item.qtyOnHand : null,
              onChanged: (v) => setState(() => _qty = v),
              onSubmitted: isWriteoff ? null : _save,
            ),
            if (_qtyError != null) _ErrorText(_qtyError!),
            if (!isCount) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final step in _quickSteps(item.unit))
                    ActionChip(
                      label: Text(
                        '+ ${formatQty(step, item.unit)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      onPressed: () => _qtyKey.currentState?.addBase(step),
                    ),
                ],
              ),
            ],
            if (_qty != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.opAfter(
                  formatQty(switch (widget.kind) {
                    StockBatchKind.receipt => item.qtyOnHand + _qty!,
                    StockBatchKind.writeoff => item.qtyOnHand - _qty!,
                    StockBatchKind.count => _qty!,
                  }, item.unit),
                ),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
            if (widget.kind == StockBatchKind.receipt) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _cost,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: l10n.opCost,
                  hintText: l10n.opCostHint,
                  suffixText: l10n.receiptCurrency,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(),
              ),
              if (_qty != null && _costUzs != null)
                if (unitPriceText(_costUzs!, _qty!, item.unit)
                    case final price?)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      price,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.cash,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 14),
            if (isWriteoff) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in [
                    l10n.reasonBroken,
                    l10n.reasonExpired,
                    l10n.reasonSpilled,
                    l10n.reasonOther,
                  ])
                    ChoiceChip(
                      label: Text(r, style: const TextStyle(fontSize: 16)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      selected: _reason.text == r,
                      onSelected: (_) => setState(() => _reason.text = r),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _reason,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: isWriteoff ? l10n.opReason : l10n.opComment,
              ),
              onSubmitted: (_) => _save(),
            ),
            if (_reasonError != null) _ErrorText(_reasonError!),
            if (_failure != null) _ErrorText(_failure!),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(110, 52)),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(160, 52),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: isWriteoff ? AppColors.danger : null,
          ),
          onPressed: _saving ? null : _save,
          child: Text(l10n.inventorySave),
        ),
      ],
    );
  }

  /// Taps that cover most bar deliveries: grams/ml in 100s, pieces in 1/5/10.
  static List<int> _quickSteps(StockUnit unit) => unit == StockUnit.pcs
      ? const [1, 5, 10, 20]
      : const [100, 500, 1000, 5000];
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: const TextStyle(color: AppColors.danger, fontSize: 13),
    ),
  );
}

/// Create (item == null) or edit an item. The unit is fixed after creation.
Future<bool> showItemFormDialog(BuildContext context, {StockItem? item}) async {
  final cubit = context.read<InventoryCubit>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ItemFormDialog(item: item),
    ),
  );
  return saved ?? false;
}

class _ItemFormDialog extends StatefulWidget {
  const _ItemFormDialog({this.item});

  final StockItem? item;

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late StockUnit _unit = widget.item?.unit ?? StockUnit.g;
  late bool _active = widget.item?.active ?? true;
  late int? _minQty = widget.item?.minQty ?? 0;
  String? _nameError;
  String? _minError;
  String? _failure;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalization.of(context);
    final nameError = _name.text.trim().isEmpty ? l10n.itemNameRequired : null;
    final minError = _minQty == null ? l10n.itemMinQtyInvalid : null;
    if (nameError != null || minError != null) {
      setState(() {
        _nameError = nameError;
        _minError = minError;
      });
      return;
    }
    setState(() {
      _nameError = null;
      _minError = null;
      _failure = null;
      _saving = true;
    });
    final cubit = context.read<InventoryCubit>();
    final item = widget.item;
    final result = item == null
        ? await cubit.createItem(
            name: _name.text,
            unit: _unit,
            minQty: _minQty!,
          )
        : await cubit.updateItem(
            item.id,
            name: _name.text,
            minQty: _minQty,
            active: _active,
          );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _failure = failureMessage(l10n, failure);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final editing = widget.item != null;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        editing ? l10n.itemEditTitle : l10n.inventoryNewItem,
        style: AppTextStyles.h4,
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  hintText: l10n.itemNameHint,
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 14),
              Text(l10n.itemUnit, style: AppTextStyles.kicker),
              const SizedBox(height: 6),
              SegmentedButton<StockUnit>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: StockUnit.g, label: Text(l10n.unitGram)),
                  ButtonSegment(value: StockUnit.ml, label: Text(l10n.unitMl)),
                  ButtonSegment(
                    value: StockUnit.pcs,
                    label: Text(l10n.unitPcs),
                  ),
                ],
                selected: {_unit},
                // The unit cannot change once the item holds stock.
                onSelectionChanged: editing
                    ? null
                    : (s) => setState(() => _unit = s.first),
              ),
              const SizedBox(height: 14),
              // Re-keyed on unit so the unit switch (g/kg) matches the unit.
              QtyField(
                key: ValueKey(_unit),
                unit: _unit,
                label: l10n.itemMinQty,
                allowZero: true,
                initialBase: _minQty,
                onChanged: (v) => _minQty = v,
              ),
              if (_minError != null)
                Text(
                  _minError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              if (editing)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.itemActive),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              if (_failure != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _failure!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(110, 52)),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(160, 52)),
          onPressed: _saving ? null : _save,
          child: Text(l10n.inventorySave),
        ),
      ],
    );
  }
}
