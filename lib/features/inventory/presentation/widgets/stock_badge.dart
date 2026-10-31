import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n.dart';
import '../../domain/stock_item.dart';

/// ok = green, kam = amber, tugadi = red.
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.status});

  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final (label, fg, bg) = switch (status) {
      StockStatus.ok => (
        l10n.inventoryStatusOk,
        AppColors.cash,
        AppColors.cashSoft,
      ),
      StockStatus.low => (
        l10n.inventoryStatusLow,
        AppColors.warningText,
        const Color(0xFFFEF3C7),
      ),
      StockStatus.out => (
        l10n.inventoryStatusOut,
        AppColors.danger,
        AppColors.dangerSoft,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
