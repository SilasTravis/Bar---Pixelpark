import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../sale/domain/bar_sale.dart';
import '../../../shift/presentation/cubit/shift_cubit.dart';
import '../cubit/sales_history_cubit.dart';
import '../widgets/refund_dialog.dart';

/// Screen 4: the open shift's sales with the cashier refund.
class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocProvider(
      create: (_) => sl<SalesHistoryCubit>()..load(),
      child: WindowScaffold(
        body: Column(
          children: [
            Builder(
              builder: (context) => PageHeader(
                title: l10n.historyTitle,
                actions: [
                  BlocBuilder<SalesHistoryCubit, SalesHistoryState>(
                    builder: (context, state) => IconButton(
                      tooltip: l10n.refresh,
                      onPressed: state.status == HistoryStatus.loading
                          ? null
                          : context.read<SalesHistoryCubit>().load,
                      icon: const Icon(
                        PhosphorIconsRegular.arrowsClockwise,
                        size: 18,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: _HistoryBody()),
          ],
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<SalesHistoryCubit, SalesHistoryState>(
      builder: (context, state) {
        if (state.sales.isEmpty) {
          return switch (state.status) {
            HistoryStatus.loading => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            HistoryStatus.failure => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    failureMessage(l10n, state.failure!),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: context.read<SalesHistoryCubit>().load,
                    icon: const Icon(
                      PhosphorIconsRegular.arrowsClockwise,
                      size: 16,
                    ),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            HistoryStatus.loaded => Center(
              child: Text(
                l10n.historyEmpty,
                style: AppTextStyles.muted(AppTextStyles.body),
              ),
            ),
          };
        }
        return Column(
          children: [
            if (state.status == HistoryStatus.loading)
              const LinearProgressIndicator(minHeight: 2),
            if (state.status == HistoryStatus.failure)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.dangerSoft,
                  border: Border(
                    bottom: BorderSide(color: AppColors.dangerBorder),
                  ),
                ),
                child: Text(
                  failureMessage(l10n, state.failure!),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.sales.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _SaleCard(sale: state.sales[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final BarSale sale;

  Future<void> _refund(BuildContext context) async {
    final historyCubit = context.read<SalesHistoryCubit>();
    final shiftCubit = context.read<ShiftCubit>();
    final refunded = await showRefundDialog(
      context,
      sale: sale,
      onConfirm: (reason) => historyCubit.refund(sale.id, reason: reason),
    );
    if (refunded == null || !context.mounted) return;
    // Shift totals exclude refunded sales — refresh the header/close screen.
    shiftCubit.load();
    final l10n = AppLocalization.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.refundDone(refunded.receiptNo))),
    );
  }

  _Chip _paymentChip(AppLocalization l10n) => switch (sale.paymentMethod) {
    PaymentMethod.cash => _Chip(
      icon: PhosphorIconsRegular.money,
      label: l10n.paymentCash,
      color: AppColors.cash,
    ),
    PaymentMethod.card => _Chip(
      icon: PhosphorIconsRegular.creditCard,
      label: l10n.paymentCard,
      color: AppColors.card,
    ),
    PaymentMethod.mixed => _Chip(
      icon: PhosphorIconsRegular.arrowsSplit,
      label: l10n.paymentMixed,
      color: AppColors.accent,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final refunded = sale.isRefunded;
    final muted = AppTextStyles.muted(
      AppTextStyles.body,
    ).copyWith(fontSize: 13);
    return Opacity(
      opacity: refunded ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '#${sale.receiptNo}',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(sale.createdAt.toLocal()),
                        style: muted.copyWith(fontSize: 13),
                      ),
                      _paymentChip(l10n),
                      if (sale.isMixed)
                        Text(
                          l10n.mixedSplitShort(
                            groupThousands(sale.cashUzs),
                            groupThousands(sale.cardUzs),
                          ),
                          style: muted.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      if (refunded)
                        _Chip(
                          icon: PhosphorIconsRegular.arrowCounterClockwise,
                          label: l10n.statusRefunded,
                          color: AppColors.danger,
                        ),
                    ],
                  ),
                ),
                Text(
                  formatUzs(sale.totalUzs),
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: refunded ? AppColors.textMuted : AppColors.text,
                    decoration: refunded ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(width: 12),
                if (!refunded)
                  OutlinedButton.icon(
                    onPressed: () => _refund(context),
                    icon: const Icon(
                      PhosphorIconsRegular.arrowCounterClockwise,
                      size: 16,
                    ),
                    label: Text(l10n.refund),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            for (final item in sale.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name}  × ${item.quantity}',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ),
                    Text(
                      formatUzs(item.lineTotalUzs),
                      style: muted.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            if (refunded && (sale.refundReason?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 6),
              Text(l10n.refundReasonShown(sale.refundReason!), style: muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
