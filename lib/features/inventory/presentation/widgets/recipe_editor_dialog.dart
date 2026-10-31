import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../../products/domain/bar_product.dart';
import '../../domain/stock_item.dart';
import '../cubit/inventory_cubit.dart';
import 'qty_field.dart';

Future<bool> showRecipeEditor(BuildContext context, BarProduct product) async {
  final cubit = context.read<InventoryCubit>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _RecipeEditorDialog(product: product),
    ),
  );
  return saved ?? false;
}

class _Line {
  _Line({this.itemId, this.qty});

  String? itemId;
  int? qty;
  final key = UniqueKey();
}

/// Recipe of one product: ingredients and the amount of each per portion
/// (`prepared`), or the single stock item a ready product takes per unit
/// sold (`ready`).
class _RecipeEditorDialog extends StatefulWidget {
  const _RecipeEditorDialog({required this.product});

  final BarProduct product;

  @override
  State<_RecipeEditorDialog> createState() => _RecipeEditorDialogState();
}

class _RecipeEditorDialogState extends State<_RecipeEditorDialog> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<StockItem> _items = const [];
  ProductSetup? _loaded;
  ProductKind _kind = ProductKind.prepared;
  final List<_Line> _lines = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cubit = context.read<InventoryCubit>();
    setState(() {
      _loading = true;
      _error = null;
    });
    final items = await cubit.fetchAllActive();
    final setup = await cubit.fetchSetup(widget.product.id);
    if (!mounted) return;
    final l10n = AppLocalization.of(context);
    final failure =
        items.fold((f) => f, (_) => null) ?? setup.fold((f) => f, (_) => null);
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failureMessage(l10n, failure);
      });
      return;
    }
    final loaded = setup.getOrElse(
      () => ProductSetup(
        productId: widget.product.id,
        kind: ProductKind.prepared,
      ),
    );
    setState(() {
      _items = items.getOrElse(() => const []);
      _loaded = loaded;
      _kind = loaded.kind;
      _lines
        ..clear()
        ..addAll(
          (loaded.kind == ProductKind.ready
                  ? [if (loaded.link != null) loaded.link!]
                  : loaded.recipe)
              .map((l) => _Line(itemId: l.stockItemId, qty: l.qty)),
        );
      _loading = false;
    });
  }

  StockItem? _item(String? id) => _items.where((i) => i.id == id).firstOrNull;

  Future<void> _save() async {
    final l10n = AppLocalization.of(context);
    final ids = _lines.map((l) => l.itemId).toList();
    if (_lines.any((l) => l.itemId == null || l.qty == null || l.qty! <= 0)) {
      setState(() => _error = l10n.recipeIncomplete);
      return;
    }
    if (ids.toSet().length != ids.length) {
      setState(() => _error = l10n.recipeDuplicate);
      return;
    }
    final lines = [
      for (final l in _lines) RecipeLine(stockItemId: l.itemId!, qty: l.qty!),
    ];
    final setup = ProductSetup(
      productId: widget.product.id,
      kind: _kind,
      link: _kind == ProductKind.ready ? lines.firstOrNull : null,
      recipe: _kind == ProductKind.prepared ? lines : const [],
      addonIds: _loaded?.addonIds ?? const [],
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await context.read<InventoryCubit>().saveSetup(setup);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _saving = false;
        _error = failureMessage(l10n, f);
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final ready = _kind == ProductKind.ready;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        l10n.recipeEditorTitle(widget.product.name),
        style: AppTextStyles.h4,
      ),
      content: SizedBox(
        width: 560,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<ProductKind>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ProductKind.prepared,
                          label: Text(l10n.recipeKindPrepared),
                        ),
                        ButtonSegment(
                          value: ProductKind.ready,
                          label: Text(l10n.recipeKindReady),
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: (s) => setState(() {
                        _kind = s.first;
                        if (_kind == ProductKind.ready && _lines.length > 1) {
                          _lines.removeRange(1, _lines.length);
                        }
                      }),
                    ),
                    const SizedBox(height: 14),
                    if (_items.isEmpty)
                      Text(l10n.recipeNoItems, style: AppTextStyles.body)
                    else ...[
                      if (_lines.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            l10n.recipeEmptyInfo,
                            style: AppTextStyles.muted(AppTextStyles.body),
                          ),
                        ),
                      for (final line in _lines)
                        _LineRow(
                          key: line.key,
                          line: line,
                          items: _items,
                          item: _item(line.itemId),
                          onChanged: () => setState(() {}),
                          onRemove: () => setState(() => _lines.remove(line)),
                        ),
                      if (!(ready && _lines.isNotEmpty))
                        TextButton.icon(
                          onPressed: () => setState(() => _lines.add(_Line())),
                          icon: const Icon(PhosphorIconsRegular.plus, size: 16),
                          label: Text(l10n.recipeAddIngredient),
                        ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        if (_loaded == null && !_loading)
          OutlinedButton(onPressed: _load, child: Text(l10n.retry))
        else
          FilledButton(
            onPressed: (_saving || _loading) ? null : _save,
            child: Text(l10n.inventorySave),
          ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    super.key,
    required this.line,
    required this.items,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final _Line line;
  final List<StockItem> items;
  final StockItem? item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              initialValue: item?.id,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.recipeIngredient),
              items: [
                for (final i in items)
                  DropdownMenuItem(value: i.id, child: Text(i.name)),
              ],
              onChanged: (id) {
                line.itemId = id;
                line.qty = null;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: item == null
                ? const SizedBox.shrink()
                : QtyField(
                    // A different ingredient may have a different unit.
                    key: ValueKey('${item!.id}-${item!.unit}'),
                    unit: item!.unit,
                    label: l10n.qtyLabel,
                    initialBase: line.qty,
                    onChanged: (v) => line.qty = v,
                  ),
          ),
          IconButton(
            tooltip: l10n.cancel,
            onPressed: onRemove,
            icon: const Icon(PhosphorIconsRegular.x, size: 18),
          ),
        ],
      ),
    );
  }
}
