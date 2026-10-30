import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/stock_item.dart';
import '../../domain/stock_qty.dart';
import '../cubit/inventory_cubit.dart';
import 'stock_badge.dart';
import 'stock_dialogs.dart';

Future<void> showStockItemSheet(BuildContext context, String itemId) {
  final cubit = context.read<InventoryCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    constraints: const BoxConstraints(maxWidth: 680),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _StockItemSheet(itemId: itemId),
    ),
  );
}

/// Kirim / Brak / Sanash / edit and the item's recent movements. Reads the
/// item from the cubit so the quantity refreshes after each operation.
class _StockItemSheet extends StatefulWidget {
  const _StockItemSheet({required this.itemId});

  final String itemId;

  @override
  State<_StockItemSheet> createState() => _StockItemSheetState();
}

class _StockItemSheetState extends State<_StockItemSheet> {
  late Future<Either<Failure, MovementsPage>> _movements = _loadMovements();

  Future<Either<Failure, MovementsPage>> _loadMovements() =>
      context.read<InventoryCubit>().movements(widget.itemId);

  void _reloadMovements() {
    final next = _loadMovements();
    setState(() {
      _movements = next;
    });
  }

  Future<void> _op(StockBatchKind kind, StockItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalization.of(context);
    final saved = await showStockOpDialog(context, kind: kind, item: item);
    if (!saved || !mounted) return;
    _reloadMovements();
    messenger.showSnackBar(SnackBar(content: Text(l10n.inventorySaved)));
  }

  Future<void> _edit(StockItem item) async {
    final saved = await showItemFormDialog(context, item: item);
    if (saved && mounted) _reloadMovements();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        final item = state.items
            .where((i) => i.id == widget.itemId)
            .firstOrNull;
        if (item == null) {
          // Gone from the (filtered) list, e.g. no longer "low" after a kirim.
          return const SizedBox(height: 120, child: Center(child: Text('—')));
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    StockBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.inventoryOnHand}: ${formatQty(item.qtyOnHand, item.unit)}'
                  '   ·   ${l10n.inventoryMinQty(formatQty(item.minQty, item.unit))}',
                  style: AppTextStyles.muted(AppTextStyles.body),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _op(StockBatchKind.receipt, item),
                      icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                      label: Text(l10n.opReceipt),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      onPressed: () => _op(StockBatchKind.writeoff, item),
                      icon: const Icon(PhosphorIconsRegular.trash, size: 18),
                      label: Text(l10n.opWriteoff),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _op(StockBatchKind.count, item),
                      icon: const Icon(
                        PhosphorIconsRegular.listChecks,
                        size: 18,
                      ),
                      label: Text(l10n.opCount),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _edit(item),
                      icon: const Icon(
                        PhosphorIconsRegular.pencilSimple,
                        size: 18,
                      ),
                      label: Text(l10n.inventoryEdit),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.inventoryMovements, style: AppTextStyles.kicker),
                const SizedBox(height: 8),
                Flexible(
                  child: FutureBuilder<Either<Failure, MovementsPage>>(
                    future: _movements,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return snap.data!.fold(
                        (f) => Text(failureMessage(l10n, f)),
                        (page) => page.items.isEmpty
                            ? Text(
                                l10n.inventoryNoMovements,
                                style: AppTextStyles.muted(AppTextStyles.body),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: [
                                  for (final m in page.items)
                                    _MovementRow(movement: m, unit: item.unit),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.unit});

  final StockMovement movement;
  final StockUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final label = switch (movement.type) {
      StockMovementType.receipt => l10n.movReceipt,
      StockMovementType.sale => l10n.movSale,
      StockMovementType.refund => l10n.movRefund,
      StockMovementType.writeoff => l10n.movWriteoff,
      StockMovementType.adjustment => l10n.movAdjustment,
      StockMovementType.other => l10n.movOther,
    };
    final reason = movement.reason;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              DateFormat('dd.MM HH:mm').format(movement.createdAt.toLocal()),
              style: AppTextStyles.muted(
                AppTextStyles.body,
              ).copyWith(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              reason ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.muted(
                AppTextStyles.body,
              ).copyWith(fontSize: 13),
            ),
          ),
          Text(
            formatQtyDelta(movement.qtyDelta, unit),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: movement.qtyDelta < 0 ? AppColors.danger : AppColors.cash,
            ),
          ),
        ],
      ),
    );
  }
}
