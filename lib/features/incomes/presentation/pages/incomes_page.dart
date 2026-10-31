import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../shift/presentation/cubit/shift_cubit.dart';
import '../../domain/bar_income.dart';
import '../cubit/incomes_cubit.dart';
import '../widgets/new_income_dialog.dart';

/// "Kirimlar": the open shift's incomes, the shift's income total (and
/// its cash-drawer part), delete per row and "+ Yangi kirim".
///
/// Needs the [ShiftCubit] above it: every change refreshes the shift so the
/// expected cash on the close-shift screen stays right.
class IncomesPage extends StatelessWidget {
  const IncomesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocProvider(
      create: (_) => sl<IncomesCubit>()
        ..load()
        ..loadSuggestions(),
      child: WindowScaffold(
        body: Column(
          children: [
            Builder(
              builder: (context) => PageHeader(
                title: l10n.incomesTitle,
                actions: [
                  BlocBuilder<IncomesCubit, IncomesState>(
                    builder: (context, state) => IconButton(
                      tooltip: l10n.refresh,
                      onPressed: state.status == IncomesStatus.loading
                          ? null
                          : context.read<IncomesCubit>().load,
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
            const Expanded(child: _IncomesBody()),
          ],
        ),
      ),
    );
  }
}

class _IncomesBody extends StatelessWidget {
  const _IncomesBody();

  Future<void> _addIncome(BuildContext context) async {
    final incomesCubit = context.read<IncomesCubit>();
    final shiftCubit = context.read<ShiftCubit>();
    final saved = await showNewIncomeDialog(
      context,
      suggestions: incomesCubit.state.suggestions,
      newClientIncomeId: incomesCubit.newClientIncomeId,
      onSave: (draft) => incomesCubit.add(
        clientIncomeId: draft.clientIncomeId,
        name: draft.name,
        amountUzs: draft.amountUzs,
        receivedTo: draft.receivedTo,
        note: draft.note,
      ),
    );
    if (saved == null || !context.mounted) return;
    // Expected cash on the close-shift screen depends on the incomes.
    shiftCubit.load();
    final l10n = AppLocalization.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.incomeSaved(saved.name, formatUzs(saved.amountUzs))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomesCubit, IncomesState>(
      builder: (context, state) => Column(
        children: [
          if (state.status == IncomesStatus.loading && state.incomes.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          if (state.status == IncomesStatus.failure && state.incomes.isNotEmpty)
            _FailureBanner(state: state),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _TotalsCard(state: state),
                    ),
                    Expanded(child: _IncomesList(state: state)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => _addIncome(context),
                          icon: const Icon(PhosphorIconsRegular.plus, size: 20),
                          label: Text(
                            AppLocalization.of(context).incomeNew,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state});

  final IncomesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cashSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              PhosphorIconsRegular.handDeposit,
              color: AppColors.cash,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incomesShiftTotal,
                  style: AppTextStyles.kicker.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatUzs(state.totalUzs),
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          _Badge(
            icon: PhosphorIconsRegular.money,
            label: l10n.incomesFromCashTotal(formatUzs(state.cashUzs)),
            color: AppColors.cash,
          ),
        ],
      ),
    );
  }
}

class _IncomesList extends StatelessWidget {
  const _IncomesList({required this.state});

  final IncomesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    if (state.incomes.isEmpty) {
      return switch (state.status) {
        IncomesStatus.loading => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        IncomesStatus.failure => Center(
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
                onPressed: context.read<IncomesCubit>().load,
                icon: const Icon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 16,
                ),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
        IncomesStatus.loaded => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsRegular.receipt,
                  size: 40,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 12),
                Text(l10n.incomesEmpty, style: AppTextStyles.body),
                const SizedBox(height: 6),
                Text(
                  l10n.incomesEmptyHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.muted(
                    AppTextStyles.body,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      };
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.incomes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _IncomeRow(income: state.incomes[index]),
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.state});

  final IncomesState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.dangerSoft,
        border: Border(bottom: BorderSide(color: AppColors.dangerBorder)),
      ),
      child: Text(
        failureMessage(AppLocalization.of(context), state.failure!),
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          color: AppColors.danger,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  const _IncomeRow({required this.income});

  final BarIncome income;

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalization.of(context);
    final incomesCubit = context.read<IncomesCubit>();
    final shiftCubit = context.read<ShiftCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        icon: const Icon(
          PhosphorIconsRegular.trash,
          color: AppColors.danger,
          size: 32,
        ),
        title: Text(l10n.incomeDeleteTitle, style: AppTextStyles.h4),
        content: SizedBox(
          width: 380,
          child: Text(
            l10n.incomeDeleteMessage(income.name, formatUzs(income.amountUzs)),
            style: AppTextStyles.body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.incomeDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await incomesCubit.delete(income.id);
    result.fold(
      (failure) {
        // A stale list (already deleted / shift closed): expected cash too.
        shiftCubit.load();
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      },
      (_) {
        shiftCubit.load();
        messenger.showSnackBar(SnackBar(content: Text(l10n.incomeDeleted)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final muted = AppTextStyles.muted(
      AppTextStyles.body,
    ).copyWith(fontSize: 13);
    final note = income.note;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              DateFormat('HH:mm').format(income.receivedAt.toLocal()),
              style: muted.copyWith(
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      income.name,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    income.isToCash
                        ? _Badge(
                            icon: PhosphorIconsRegular.money,
                            label: l10n.receivedToCash,
                            color: AppColors.cash,
                          )
                        : _Badge(
                            icon: PhosphorIconsRegular.wallet,
                            label: l10n.receivedToOther,
                            color: AppColors.card,
                          ),
                  ],
                ),
                if (note != null) ...[
                  const SizedBox(height: 4),
                  Text(note, style: muted),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatUzs(income.amountUzs),
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: l10n.incomeDelete,
            onPressed: () => _delete(context),
            icon: const Icon(
              PhosphorIconsRegular.trash,
              size: 20,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

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
