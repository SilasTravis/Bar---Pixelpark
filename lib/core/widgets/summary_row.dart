import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/nocturne_colors.dart';

/// `label ........ value` row used by the shift totals and summaries.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final base = emphasize
        ? AppTextStyles.h5.copyWith(color: NocturneColors.accent)
        : AppTextStyles.body.copyWith(fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.muted(
                AppTextStyles.body,
              ).copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: valueColor == null ? base : base.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
