import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/stock_item.dart';
import '../../domain/stock_qty.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/stock_badge.dart';
import '../widgets/stock_dialogs.dart';
import '../widgets/stock_item_sheet.dart';
import 'recipes_page.dart';

/// "Ombor": the bar's own stock. Search, "Kam qolganlar" filter, tap a row
/// for kirim / brak / sanash / edit / movements, "Yangi mahsulot", and the
/// recipes entry. Independent of the shift and of selling.
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocProvider(
      create: (_) => sl<InventoryCubit>()..load(),
      child: WindowScaffold(
        body: Column(
          children: [
            Builder(
              builder: (context) => PageHeader(
                title: l10n.inventoryTitle,
                actions: [
                  TextButton.icon(
                    onPressed: () => openRecipesPage(context),
                    icon: const Icon(PhosphorIconsRegular.cookingPot, size: 18),
                    label: Text(l10n.recipesButton),
                  ),
                  IconButton(
                    tooltip: l10n.refresh,
                    onPressed: context.read<InventoryCubit>().load,
                    icon: const Icon(
                      PhosphorIconsRegular.arrowsClockwise,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: _InventoryBody()),
          ],
        ),
      ),
    );
  }
}

class _InventoryBody extends StatefulWidget {
  const _InventoryBody();

  @override
  State<_InventoryBody> createState() => _InventoryBodyState();
}

class _InventoryBodyState extends State<_InventoryBody> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<InventoryCubit>().load(search: text);
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalization.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showItemFormDialog(context);
    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.inventorySaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _search,
                        onChanged: _onSearch,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: l10n.inventorySearchHint,
                          prefixIcon: const Icon(
                            PhosphorIconsRegular.magnifyingGlass,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<InventoryCubit, InventoryState>(
                        buildWhen: (a, b) => a.lowOnly != b.lowOnly,
                        builder: (context, state) => Row(
                          children: [
                            _FilterPill(
                              label: l10n.inventoryAll,
                              selected: !state.lowOnly,
                              onTap: () => context.read<InventoryCubit>().load(
                                lowOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _FilterPill(
                              label: l10n.inventoryLowFilter,
                              icon: PhosphorIconsRegular.warning,
                              selected: state.lowOnly,
                              onTap: () => context.read<InventoryCubit>().load(
                                lowOnly: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: _ItemList()),
              ],
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton.extended(
            extendedPadding: const EdgeInsets.symmetric(horizontal: 28),
            extendedTextStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            onPressed: _create,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.onAccent,
            icon: const Icon(PhosphorIconsRegular.plus),
            label: Text(l10n.inventoryNewItem),
          ),
        ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return switch (state.status) {
            InventoryStatus.loading => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            InventoryStatus.failure => _Message(
              text: _failureText(l10n, state.failure!),
              onRetry: context.read<InventoryCubit>().load,
            ),
            InventoryStatus.loaded => _Message(
              text: state.search.isNotEmpty
                  ? l10n.inventoryEmptySearch
                  : state.lowOnly
                  ? l10n.inventoryEmptyLow
                  : l10n.inventoryEmpty,
              hint: state.search.isEmpty && !state.lowOnly
                  ? l10n.inventoryEmptyHint
                  : null,
            ),
          };
        }
        return Column(
          children: [
            if (state.status == InventoryStatus.loading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: state.items.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == state.items.length) {
                    return Center(
                      child: TextButton(
                        onPressed: context.read<InventoryCubit>().loadMore,
                        child: Text(l10n.inventoryLoadMore),
                      ),
                    );
                  }
                  return _ItemRow(item: state.items[i]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// A 404 means the backend has no inventory API (yet): say so plainly,
  /// selling is unaffected.
  static String _failureText(AppLocalization l10n, Failure f) =>
      f is ServerFailure && f.statusCode == 404
      ? l10n.inventoryUnavailable
      : failureMessage(l10n, f);
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.hint, this.onRetry});

  final String text;
  final String? hint;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              PhosphorIconsRegular.package,
              size: 40,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: AppTextStyles.body),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: AppTextStyles.muted(
                  AppTextStyles.body,
                ).copyWith(fontSize: 14),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 16,
                ),
                label: Text(AppLocalization.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.accent : AppColors.textMuted;
    return Material(
      color: selected ? AppColors.accentSoft : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.accentBorder : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One stock item. The two things a bartender does all day, Kirim and Brak,
/// are one tap away on the row itself; tapping the row opens the detail
/// sheet (sanash, edit, history).
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final StockItem item;

  Future<void> _op(BuildContext context, StockBatchKind kind) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalization.of(context);
    final saved = await showStockOpDialog(context, kind: kind, item: item);
    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.inventorySaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final muted = AppTextStyles.muted(
      AppTextStyles.body,
    ).copyWith(fontSize: 14);
    final stripe = switch (item.status) {
      StockStatus.ok => AppColors.cash,
      StockStatus.low => AppColors.warning,
      StockStatus.out => AppColors.danger,
    };
    return Material(
      color: item.status == StockStatus.out
          ? AppColors.dangerSoft
          : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: item.status == StockStatus.out
              ? AppColors.dangerBorder
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () => showStockItemSheet(context, item.id),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: stripe),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StockBadge(status: item.status),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    [
                                      l10n.inventoryMinQty(
                                        formatQty(item.minQty, item.unit),
                                      ),
                                      if (!item.active) l10n.inventoryInactive,
                                    ].join('  ·  '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: muted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatQty(item.qtyOnHand, item.unit),
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: stripe == AppColors.cash
                              ? AppColors.text
                              : stripe == AppColors.warning
                              ? AppColors.warningText
                              : AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(112, 52),
                          backgroundColor: AppColors.cash,
                        ),
                        onPressed: () => _op(context, StockBatchKind.receipt),
                        icon: const Icon(PhosphorIconsBold.plus, size: 18),
                        label: Text(l10n.opReceipt),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(104, 52),
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.dangerBorder),
                        ),
                        onPressed: () => _op(context, StockBatchKind.writeoff),
                        icon: const Icon(PhosphorIconsRegular.trash, size: 18),
                        label: Text(l10n.opWriteoff),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
