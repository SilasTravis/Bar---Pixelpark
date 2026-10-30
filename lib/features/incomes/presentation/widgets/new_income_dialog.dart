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
import '../../domain/bar_income.dart';

/// What the "Yangi kirim" dialog submits.
class IncomeDraft {
  const IncomeDraft({
    required this.clientIncomeId,
    required this.name,
    required this.amountUzs,
    required this.receivedTo,
    this.note,
  });

  final String clientIncomeId;
  final String name;
  final int amountUzs;
  final IncomeReceivedTo receivedTo;
  final String? note;
}

/// The amount field's value when it is a valid income amount, else null.
int? validIncomeAmount(String text) {
  final amount = parseUzsInput(text);
  if (amount == null || amount <= 0 || amount > IncomeLimits.maxAmountUzs) {
    return null;
  }
  return amount;
}

/// "Yangi kirim": quick-pick chips, name, amount, received-to and an
/// optional note. Resolves to the saved income, or null when cancelled.
///
/// [newClientIncomeId] supplies the idempotency key. The same key is
/// re-sent while the fields are unchanged (a retry after a lost answer
/// cannot record twice); edited fields get a fresh one.
Future<BarIncome?> showNewIncomeDialog(
  BuildContext context, {
  required List<IncomeSuggestion> suggestions,
  required String Function() newClientIncomeId,
  required Future<Either<Failure, BarIncome>> Function(IncomeDraft draft)
  onSave,
}) {
  return showDialog<BarIncome>(
    context: context,
    builder: (_) => NewIncomeDialog(
      suggestions: suggestions,
      newClientIncomeId: newClientIncomeId,
      onSave: onSave,
    ),
  );
}

class NewIncomeDialog extends StatefulWidget {
  const NewIncomeDialog({
    super.key,
    required this.suggestions,
    required this.newClientIncomeId,
    required this.onSave,
  });

  final List<IncomeSuggestion> suggestions;
  final String Function() newClientIncomeId;
  final Future<Either<Failure, BarIncome>> Function(IncomeDraft draft) onSave;

  @override
  State<NewIncomeDialog> createState() => _NewIncomeDialogState();
}

class _NewIncomeDialogState extends State<NewIncomeDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocus = FocusNode();
  IncomeReceivedTo _receivedTo = IncomeReceivedTo.cash;
  bool _submitting = false;
  bool _showValidation = false;
  String? _error;

  /// The key and the field values it was last sent with.
  String? _clientIncomeId;
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

  int? get _amount => validIncomeAmount(_amountController.text);

  void _pick(IncomeSuggestion suggestion) {
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
    final signature = [
      _name,
      amount,
      _receivedTo.apiValue,
      note,
    ].join('\u0000');
    if (_clientIncomeId == null || signature != _sentSignature) {
      _clientIncomeId = widget.newClientIncomeId();
      _sentSignature = signature;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.onSave(
      IncomeDraft(
        clientIncomeId: _clientIncomeId!,
        name: _name,
        amountUzs: amount,
        receivedTo: _receivedTo,
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
            PhosphorIconsRegular.handDeposit,
            color: AppColors.accent,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(l10n.incomeNew, style: AppTextStyles.h4),
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
                  l10n.incomeQuickPick,
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
                  LengthLimitingTextInputFormatter(IncomeLimits.maxNameLength),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.incomeName,
                  hintText: l10n.incomeNameHint,
                  errorText: _showValidation && _name.isEmpty
                      ? l10n.incomeNameRequired
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
                  labelText: l10n.incomeAmount,
                  suffixText: "so'm",
                  prefixIcon: const Icon(PhosphorIconsRegular.money, size: 20),
                  errorText: _showValidation && _amount == null
                      ? l10n.incomeAmountInvalid
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.incomeReceivedTo,
                style: AppTextStyles.kicker.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<IncomeReceivedTo>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: IncomeReceivedTo.cash,
                    icon: const Icon(PhosphorIconsRegular.money, size: 18),
                    label: Text(l10n.receivedToCash),
                  ),
                  ButtonSegment(
                    value: IncomeReceivedTo.other,
                    icon: const Icon(PhosphorIconsRegular.wallet, size: 18),
                    label: Text(l10n.receivedToOther),
                  ),
                ],
                selected: {_receivedTo},
                onSelectionChanged: _submitting
                    ? null
                    : (selection) =>
                          setState(() => _receivedTo = selection.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                enabled: !_submitting,
                maxLength: IncomeLimits.maxNoteLength,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(IncomeLimits.maxNoteLength),
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
              : Text(l10n.incomeSave),
        ),
      ],
    );
  }
}
