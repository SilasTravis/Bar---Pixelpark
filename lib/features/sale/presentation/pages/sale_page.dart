import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/printing/bar_receipt_printer.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../shift/presentation/cubit/shift_cubit.dart';
import '../../domain/bar_sale.dart';
import '../cubit/sale_cubit.dart';
import '../widgets/cart_panel.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';

/// Screen 3: category tabs + product grid on the left, cart on the right.
class SalePage extends StatelessWidget {
  const SalePage({super.key, this.receiptPrinter});

  /// Defaults to the app's registered printer; injectable for tests.
  final BarReceiptPrinter? receiptPrinter;

  static const _cartPanel = ResponsivePanel(
    compact: 300,
    standard: 360,
    wide: 400,
  );

  @override
  Widget build(BuildContext context) {
    final compact = breakpointOfContext(context) == Breakpoint.compact;
    return BlocListener<SaleCubit, SaleState>(
      listenWhen: (previous, current) =>
          previous.outcome != current.outcome && current.outcome != null,
      listener: (context, state) => switch (state.outcome!) {
        SaleSucceeded(:final sale) => _onSold(context, sale),
        SaleFailed(:final failure) => _onFailed(context, failure),
      },
      child: Padding(
        padding: compact
            ? const EdgeInsets.fromLTRB(12, 12, 12, 14)
            : const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoryTabs(),
                  SizedBox(height: 12),
                  Expanded(child: ProductGrid()),
                ],
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            Container(
              width: _cartPanel.of(context),
              decoration: BoxDecoration(
                color: NocturneColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadow.sm,
              ),
              child: const CartPanel(),
            ),
          ],
        ),
      ),
    );
  }

  void _onSold(BuildContext context, BarSale sale) {
    final l10n = AppLocalization.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.saleCompleted(sale.receiptNo, formatUzs(sale.totalUzs)),
        ),
      ),
    );
    // Header total: the shift's sums are computed server-side.
    context.read<ShiftCubit>().load();

    final printer = receiptPrinter ?? sl<BarReceiptPrinter>();
    if (!printer.isConfigured) return;
    final cashierName =
        context.read<SessionCubit>().state.cashier?.fullName ??
        sale.cashierName;
    final printFailedText = l10n.receiptPrintFailed;
    // Fire-and-forget: the sale is done; a printer problem must never block
    // the next customer, it only earns a warning.
    unawaited(
      printer.printSale(sale, cashierName: cashierName).then((result) {
        if (result == ReceiptPrintResult.failed) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: NocturneColors.warning,
              content: Text(
                printFailedText,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }
      }),
    );
  }

  void _onFailed(BuildContext context, Failure failure) {
    if (isAccountBlocked(failure)) {
      context.read<SessionCubit>().endBecauseBlocked();
      return;
    }
    if (failure is ServerFailure &&
        failure.code == BarErrorCodes.shiftNotOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failureMessage(AppLocalization.of(context), failure)),
        ),
      );
      context.read<ShiftCubit>().markNoShift();
    }
    // Everything else is shown inline above the payment buttons.
  }
}
