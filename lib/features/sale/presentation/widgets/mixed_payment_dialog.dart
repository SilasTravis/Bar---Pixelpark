import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../generated/l10n.dart';
import '../../domain/mixed_split.dart';

/// "Aralash" — asks how much of [totalUzs] is paid in cash; the card part is
/// the rest. Resolves to the cash part of a valid split (`0 < cash <
/// total`), or null when cancelled.
Future<int?> showMixedPaymentDialog(
  BuildContext context, {
  required int totalUzs,
}) => showDialog<int>(
  context: context,
  builder: (_) => MixedPaymentDialog(totalUzs: totalUzs),
);

/// Two big fields, Naqd and Karta: whichever the cashier types in drives,
/// the other is filled with the rest of the total. Enter pays, Esc cancels.
class MixedPaymentDialog extends StatefulWidget {
  const MixedPaymentDialog({super.key, required this.totalUzs});

  final int totalUzs;

  @override
  State<MixedPaymentDialog> createState() => _MixedPaymentDialogState();
}

class _MixedPaymentDialogState extends State<MixedPaymentDialog> {
  late MixedSplit _split = MixedSplit(widget.totalUzs);
  final _cashController = TextEditingController();
  final _cardController = TextEditingController();
  final _cashFocus = FocusNode();

  @override
  void dispose() {
    _cashController.dispose();
    _cardController.dispose();
    _cashFocus.dispose();
    super.dispose();
  }

  static String _fieldText(int? amount) =>
      amount == null ? '' : groupThousands(amount);

  // Writing the other controller programmatically does not fire its
  // onChanged, so the two fields never ping-pong.
  void _onCashChanged(String text) => setState(() {
    _split = _split.editCash(parseUzsInput(text));
    _cardController.text = _fieldText(_split.cardUzs);
  });

  void _onCardChanged(String text) => setState(() {
    _split = _split.editCard(parseUzsInput(text));
    _cashController.text = _fieldText(_split.cashUzs);
  });

  void _useCashSuggestion(int amount) {
    final text = groupThousands(amount);
    _cashController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _onCashChanged(text);
    _cashFocus.requestFocus();
  }

  void _confirm() {
    if (_split.isValid) Navigator.of(context).pop(_split.cashUzs);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final suggestions = cashSuggestions(widget.totalUzs);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(
              PhosphorIconsRegular.arrowsSplit,
              color: AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(l10n.mixedTitle),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.mixedTotal(formatUzs(widget.totalUzs)),
                    maxLines: 1,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AmountField(
                          key: const ValueKey('mixed-cash'),
                          controller: _cashController,
                          focusNode: _cashFocus,
                          autofocus: true,
                          label: l10n.paymentCash,
                          icon: PhosphorIconsRegular.money,
                          color: AppColors.cash,
                          onChanged: _onCashChanged,
                          onSubmit: _confirm,
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final amount in suggestions)
                                ActionChip(
                                  label: Text(groupThousands(amount)),
                                  labelStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cash,
                                  ),
                                  backgroundColor: AppColors.cashSoft,
                                  side: BorderSide(
                                    color: AppColors.cash.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _useCashSuggestion(amount),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AmountField(
                      key: const ValueKey('mixed-card'),
                      controller: _cardController,
                      label: l10n.paymentCard,
                      icon: PhosphorIconsRegular.creditCard,
                      color: AppColors.card,
                      onChanged: _onCardChanged,
                      onSubmit: _confirm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fixed height: the hint appearing must not shift the buttons
              // under the cashier's finger.
              SizedBox(
                height: 22,
                child: _split.showsInvalidHint
                    ? Row(
                        children: [
                          const Icon(
                            PhosphorIconsRegular.warning,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.mixedInvalid,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            key: const ValueKey('mixed-pay'),
            style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
            onPressed: _split.isValid ? _confirm : null,
            icon: const Icon(PhosphorIconsRegular.check, size: 18),
            label: Text(l10n.mixedPay),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    required this.onChanged,
    required this.onSubmit,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String label;
  final IconData icon;

  /// Cash green / card blue, as on the payment buttons.
  final Color color;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: const [ThousandsInputFormatter()],
      style: AppTextStyles.h3.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      onChanged: onChanged,
      // onEditingComplete instead of onSubmitted: Enter must not drop the
      // focus when the split is still invalid.
      onEditingComplete: onSubmit,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        suffixText: "so'm",
        prefixIcon: Icon(icon, size: 22, color: color),
        floatingLabelStyle: TextStyle(color: color),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
