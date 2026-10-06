import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../../sale/domain/bar_sale.dart';

/// Whole-sale refund: optional reason, explicit confirm. Resolves to the
/// refunded sale, or null when cancelled.
Future<BarSale?> showRefundDialog(
  BuildContext context, {
  required BarSale sale,
  required Future<Either<Failure, BarSale>> Function(String? reason) onConfirm,
}) {
  return showDialog<BarSale>(
    context: context,
    builder: (_) => _RefundDialog(sale: sale, onConfirm: onConfirm),
  );
}

class _RefundDialog extends StatefulWidget {
  const _RefundDialog({required this.sale, required this.onConfirm});

  final BarSale sale;
  final Future<Either<Failure, BarSale>> Function(String? reason) onConfirm;

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final reason = _reasonController.text.trim();
    final result = await widget.onConfirm(reason.isEmpty ? null : reason);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _submitting = false;
        _error = failureMessage(AppLocalization.of(context), failure);
      }),
      (refunded) => Navigator.of(context).pop(refunded),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return AlertDialog(
      backgroundColor: NocturneColors.surface,
      icon: const Icon(
        PhosphorIconsRegular.arrowCounterClockwise,
        color: Color(0xFFE5677A),
        size: 30,
      ),
      title: Text(
        l10n.refundTitle(widget.sale.receiptNo),
        style: AppTextStyles.h4,
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.refundMessage(formatUzs(widget.sale.totalUzs)),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reasonController,
              autofocus: true,
              enabled: !_submitting,
              maxLength: 300,
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l10n.refundReasonOptional),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE5677A), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: NocturneColors.danger),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.refundConfirm),
        ),
      ],
    );
  }
}
