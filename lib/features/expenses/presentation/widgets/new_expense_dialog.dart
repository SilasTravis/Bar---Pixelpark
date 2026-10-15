import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../domain/bar_expense.dart';

/// What the "Yangi chiqim" dialog submits.
class ExpenseDraft {
  const ExpenseDraft({
    required this.clientExpenseId,
    required this.name,
    required this.amountUzs,
    required this.paidFrom,
    this.note,
  });

  final String clientExpenseId;
  final String name;
  final int amountUzs;
  final ExpensePaidFrom paidFrom;
  final String? note;
}

/// The amount field's value when it is a valid expense amount, else null.
int? validExpenseAmount(String text) {
  final amount = parseUzsInput(text);
  if (amount == null || amount <= 0 || amount > ExpenseLimits.maxAmountUzs) {
    return null;
  }
  return amount;
}

/// "Yangi chiqim": quick-pick chips, name, amount, paid-from and an
/// optional note. Resolves to the saved expense, or null when cancelled.
///
/// [newClientExpenseId] supplies the idempotency key. The same key is
/// re-sent while the fields are unchanged (a retry after a lost answer
/// cannot record twice); edited fields get a fresh one.
Future<BarExpense?> showNewExpenseDialog(
  BuildContext context, {
  required List<ExpenseSuggestion> suggestions,
  required String Function() newClientExpenseId,
  required Future<Either<Failure, BarExpense>> Function(ExpenseDraft draft)
  onSave,
}) {
  return showDialog<BarExpense>(
    context: context,
    builder: (_) => NewExpenseDialog(
      suggestions: suggestions,
      newClientExpenseId: newClientExpenseId,
      onSave: onSave,
    ),
  );
}

class NewExpenseDialog extends StatefulWidget {
  const NewExpenseDialog({
    super.key,
    required this.suggestions,
    required this.newClientExpenseId,
    required this.onSave,
  });

  final List<ExpenseSuggestion> suggestions;
  final String Function() newClientExpenseId;
  final Future<Either<Failure, BarExpense>> Function(ExpenseDraft draft) onSave;

  @override
  State<NewExpenseDialog> createState() => _NewExpenseDialogState();
}

class _NewExpenseDialogState extends State<NewExpenseDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocus = FocusNode();
  ExpensePaidFrom _paidFrom = ExpensePaidFrom.cash;
  bool _submitting = false;
  bool _showValidation = false;
  String? _error;

  /// The key and the field values it was last sent with.
  String? _clientExpenseId;
  String? _sentSignature;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  String get _name => _nameController.text.trim();

  int? get _amount => validExpenseAmount(_amountController.text);

  void _pick(ExpenseSuggestion suggestion) {
    setState(() {
      _nameController.text = suggestion.name;
      _amountController.text = suggestion.lastAmountUzs > 0
          ? groupThousands(suggestion.lastAmountUzs)
          : '';
      _error = null;
    });
    _amountFocus.requestFocus();
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final amount = _amount;
    if (_name.isEmpty || amount == null) {
      setState(() => _showValidation = true);
      return;
    }
    final note = _noteController.text.trim();
    final signature = [_name, amount, _paidFrom.apiValue, note].join('\u0000');
    if (_clientExpenseId == null || signature != _sentSignature) {
      _clientExpenseId = widget.newClientExpenseId();
      _sentSignature = signature;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.onSave(
      ExpenseDraft(
        clientExpenseId: _clientExpenseId!,
        name: _name,
        amountUzs: amount,
        paidFrom: _paidFrom,
        note: note.isEmpty ? null : note,
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _submitting = false;
        _error = failureMessage(AppLocalization.of(context), failure);
      }),
      (saved) => Navigator.of(context).pop(saved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          const Icon(
            PhosphorIconsRegular.handCoins,
            color: AppColors.accent,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(l10n.expenseNew, style: AppTextStyles.h4),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.suggestions.isNotEmpty) ...[
                Text(
                  l10n.expenseQuickPick,
                  style: AppTextStyles.kicker.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final suggestion in widget.suggestions)
                      ActionChip(
                        onPressed: _submitting ? null : () => _pick(suggestion),
                        label: Text(
                          suggestion.lastAmountUzs > 0
                              ? '${suggestion.name} · ${groupThousands(suggestion.lastAmountUzs)}'
                              : suggestion.name,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _nameController,
                autofocus: true,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(ExpenseLimits.maxNameLength),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.expenseName,
                  hintText: l10n.expenseNameHint,
                  errorText: _showValidation && _name.isEmpty
                      ? l10n.expenseNameRequired
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                focusNode: _amountFocus,
                enabled: !_submitting,
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsInputFormatter(maxDigits: 10)],
                style: AppTextStyles.h4,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.expenseAmount,
                  suffixText: "so'm",
                  prefixIcon: const Icon(PhosphorIconsRegular.money, size: 20),
                  errorText: _showValidation && _amount == null
                      ? l10n.expenseAmountInvalid
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.expensePaidFrom,
                style: AppTextStyles.kicker.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ExpensePaidFrom>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ExpensePaidFrom.cash,
                    icon: const Icon(PhosphorIconsRegular.money, size: 18),
                    label: Text(l10n.paidFromCash),
                  ),
                  ButtonSegment(
                    value: ExpensePaidFrom.other,
                    icon: const Icon(PhosphorIconsRegular.wallet, size: 18),
                    label: Text(l10n.paidFromOther),
                  ),
                ],
                selected: {_paidFrom},
                onSelectionChanged: _submitting
                    ? null
                    : (selection) =>
                          setState(() => _paidFrom = selection.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                enabled: !_submitting,
                maxLength: ExpenseLimits.maxNoteLength,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(ExpenseLimits.maxNoteLength),
                ],
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(labelText: l10n.noteOptional),
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.expenseSave),
        ),
      ],
    );
  }
}
