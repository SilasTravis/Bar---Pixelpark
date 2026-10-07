import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../domain/bar_sale.dart';
import '../../domain/cart.dart';
import '../cubit/sale_cubit.dart';

/// Right column of the sale screen: cart lines with +/−/remove, the total,
/// the last checkout error, and the two big payment buttons.
class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<SaleCubit, SaleState>(
      buildWhen: (previous, current) =>
          previous.cart != current.cart ||
          previous.submittingMethod != current.submittingMethod ||
          previous.outcome != current.outcome,
      builder: (context, state) {
        final cubit = context.read<SaleCubit>();
        final cart = state.cart;
        final busy = state.isSubmitting;
        final failure = switch (state.outcome) {
          SaleFailed(:final failure) => failure,
          _ => null,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
              child: Row(
                children: [
                  Text(
                    l10n.cartTitle,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: cart.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            l10n.cartItemsCount(cart.itemCount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.muted(
                              AppTextStyles.body,
                            ).copyWith(fontSize: 14),
                          ),
                  ),
                  if (cart.isNotEmpty)
                    IconButton(
                      tooltip: l10n.cartClear,
                      onPressed: busy ? null : () => _confirmClear(context),
                      icon: const Icon(
                        PhosphorIconsRegular.trash,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              PhosphorIconsRegular.basket,
                              size: 40,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.cartEmpty,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.muted(AppTextStyles.body),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: cart.lines.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _CartLineRow(
                        line: cart.lines[index],
                        enabled: !busy,
                        onIncrement: () =>
                            cubit.increment(cart.lines[index].product.id),
                        onDecrement: () =>
                            cubit.decrement(cart.lines[index].product.id),
                        onRemove: () =>
                            cubit.removeLine(cart.lines[index].product.id),
                      ),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.accentBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.total,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Scales down instead of overflowing on a narrow
                        // window with a large total.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatUzs(cart.totalUzs),
                              maxLines: 1,
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (failure != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            PhosphorIconsRegular.warning,
                            size: 20,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              saleFailureMessage(l10n, failure),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PayButton(
                          label: l10n.paymentCash,
                          icon: PhosphorIconsRegular.money,
                          color: AppColors.cash,
                          loading: state.submittingMethod == PaymentMethod.cash,
                          onPressed: cart.isEmpty || busy
                              ? null
                              : () => cubit.checkout(PaymentMethod.cash),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PayButton(
                          label: l10n.paymentCard,
                          icon: PhosphorIconsRegular.creditCard,
                          color: AppColors.card,
                          loading: state.submittingMethod == PaymentMethod.card,
                          onPressed: cart.isEmpty || busy
                              ? null
                              : () => cubit.checkout(PaymentMethod.card),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = AppLocalization.of(context);
    final cubit = context.read<SaleCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.cartClearTitle, style: AppTextStyles.h4),
        content: Text(l10n.cartClearMessage, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.cartClear),
          ),
        ],
      ),
    );
    if (confirmed == true) cubit.clearCart();
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({
    required this.line,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartLine line;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 2, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatUzs(line.product.priceUzs)} × ${line.quantity} = ${formatUzs(line.lineTotalUzs)}',
                  style: AppTextStyles.muted(
                    AppTextStyles.body,
                  ).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: PhosphorIconsRegular.minus,
            tooltip: l10n.decrease,
            onTap: enabled ? onDecrement : null,
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${line.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(
            icon: PhosphorIconsRegular.plus,
            tooltip: l10n.increase,
            onTap: enabled && line.quantity < Cart.maxQuantity
                ? onIncrement
                : null,
          ),
          IconButton(
            tooltip: l10n.removeLine,
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? onRemove : null,
            icon: const Icon(
              PhosphorIconsRegular.x,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.borderStrong),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? AppColors.textDisabled : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;

  /// Cash green / card blue: the two buttons must never be confused.
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.onAccent,
          // While another payment is submitting, the other button keeps a
          // faded version of its own colour, so the two never look alike.
          disabledBackgroundColor: loading
              ? color
              : color.withValues(alpha: 0.12),
          disabledForegroundColor: loading
              ? AppColors.onAccent
              : color.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.h4.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: onPressed,
        // Scales down rather than overflowing: "Наличные" in a narrow cart.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onAccent,
                  ),
                )
              else
                Icon(icon, size: 26),
              const SizedBox(width: 10),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
