import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../domain/bar_shift.dart';
import '../cubit/shift_cubit.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/summary_row.dart';

/// Screen 5: the shift's totals, the counted cash, the live difference and
/// the confirm that closes the shift.
class CloseShiftPage extends StatefulWidget {
  const CloseShiftPage({super.key});

  @override
  State<CloseShiftPage> createState() => _CloseShiftPageState();
}

class _CloseShiftPageState extends State<CloseShiftPage> {
  final _countedController = TextEditingController();
  final _noteController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fresh totals: refunds or sales from another session since the last
    // refresh must be in the numbers the cashier reconciles against.
    context.read<ShiftCubit>().load();
  }

  @override
  void dispose() {
    _countedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? get _counted => parseUzsInput(_countedController.text);

  Future<void> _confirm(BarShift shift) async {
    final counted = _counted;
    if (counted == null || _submitting) return;
    final l10n = AppLocalization.of(context);
    final difference = counted - shift.cashTotalUzs;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NocturneColors.surface,
        title: Text(l10n.closeShiftConfirmTitle, style: AppTextStyles.h4),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SummaryRow(label: l10n.countedCash, value: formatUzs(counted)),
              SummaryRow(
                label: l10n.cashDifference,
                value: formatSignedUzs(difference),
                valueColor: _differenceColor(difference),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.closeShiftConfirmMessage,
                style: AppTextStyles.muted(AppTextStyles.body),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.closeShift),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await context.read<ShiftCubit>().closeShift(
      countedCashUzs: counted,
      note: _noteController.text,
    );
    if (!mounted) return;
    await result.fold(
      (failure) async => setState(() {
        _submitting = false;
        _error = failureMessage(l10n, failure);
      }),
      (closed) async {
        await _showSummary(closed);
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  Future<void> _showSummary(BarShift closed) {
    final l10n = AppLocalization.of(context);
    final difference = closed.cashDifferenceUzs ?? 0;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NocturneColors.surface,
        icon: const Icon(
          PhosphorIconsRegular.checkCircle,
          color: NocturneColors.accent,
          size: 36,
        ),
        title: Text(l10n.shiftClosedTitle, style: AppTextStyles.h4),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SummaryRow(
                label: l10n.shiftPeriod,
                value:
                    '${_time(closed.openedAt)} – ${closed.closedAt == null ? '' : _time(closed.closedAt!)}',
              ),
              SummaryRow(
                label: l10n.paymentCash,
                value: formatUzs(closed.cashTotalUzs),
              ),
              SummaryRow(
                label: l10n.paymentCard,
                value: formatUzs(closed.cardTotalUzs),
              ),
              SummaryRow(
                label: l10n.receiptsCount,
                value: '${closed.salesCount}',
              ),
              SummaryRow(
                label: l10n.refundedCount,
                value: '${closed.refundedCount}',
              ),
              const Divider(height: 20),
              SummaryRow(
                label: l10n.total,
                value: formatUzs(closed.totalUzs),
                emphasize: true,
              ),
              SummaryRow(
                label: l10n.countedCash,
                value: formatUzs(closed.countedCashUzs ?? 0),
              ),
              SummaryRow(
                label: l10n.cashDifference,
                value: formatSignedUzs(difference),
                valueColor: _differenceColor(difference),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  static String _time(DateTime value) =>
      DateFormat('dd.MM HH:mm').format(value.toLocal());

  static Color _differenceColor(int difference) => difference == 0
      ? NocturneColors.accent300
      : (difference < 0 ? const Color(0xFFE5677A) : NocturneColors.warning);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return WindowScaffold(
      body: Column(
        children: [
          PageHeader(title: l10n.closeShift),
          Expanded(
            child: BlocBuilder<ShiftCubit, ShiftState>(
              builder: (context, state) {
                final shift = state.shift;
                if (state.status == ShiftStatus.none) {
                  return Center(
                    child: Text(
                      l10n.errorShiftNotOpen,
                      style: AppTextStyles.muted(AppTextStyles.body),
                    ),
                  );
                }
                if (shift == null) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return _buildForm(context, l10n, shift);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalization l10n,
    BarShift shift,
  ) {
    final counted = _counted;
    final difference = cashDifference(
      countedCashUzs: counted,
      cashTotalUzs: shift.cashTotalUzs,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Card(
                children: [
                  Text(
                    l10n.shiftOpenedAt(_time(shift.openedAt)),
                    style: AppTextStyles.muted(
                      AppTextStyles.body,
                    ).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SummaryRow(
                    label: l10n.paymentCash,
                    value: formatUzs(shift.cashTotalUzs),
                  ),
                  SummaryRow(
                    label: l10n.paymentCard,
                    value: formatUzs(shift.cardTotalUzs),
                  ),
                  SummaryRow(
                    label: l10n.receiptsCount,
                    value: '${shift.salesCount}',
                  ),
                  SummaryRow(
                    label: l10n.refundedCount,
                    value: '${shift.refundedCount}',
                  ),
                  const Divider(height: 22),
                  SummaryRow(
                    label: l10n.total,
                    value: formatUzs(shift.totalUzs),
                    emphasize: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                children: [
                  TextField(
                    controller: _countedController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsInputFormatter()],
                    style: AppTextStyles.h4,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _confirm(shift),
                    decoration: InputDecoration(
                      labelText: l10n.countedCash,
                      helperText: l10n.countedCashHint,
                      suffixText: "so'm",
                      prefixIcon: const Icon(
                        PhosphorIconsRegular.money,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SummaryRow(
                    label: l10n.expectedCash,
                    value: formatUzs(shift.cashTotalUzs),
                  ),
                  SummaryRow(
                    label: l10n.cashDifference,
                    value: difference == null
                        ? '—'
                        : formatSignedUzs(difference),
                    valueColor: difference == null
                        ? null
                        : _differenceColor(difference),
                    emphasize: true,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    maxLength: 500,
                    maxLines: 2,
                    minLines: 1,
                    inputFormatters: [LengthLimitingTextInputFormatter(500)],
                    decoration: InputDecoration(labelText: l10n.noteOptional),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: NocturneColors.danger,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: counted == null || _submitting
                      ? null
                      : () => _confirm(shift),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(PhosphorIconsRegular.lockKey, size: 20),
                  label: Text(
                    l10n.closeShift,
                    style: const TextStyle(fontSize: 16),
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

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NocturneColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
