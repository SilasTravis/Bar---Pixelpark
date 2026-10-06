import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/update/update_service.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../sales_history/presentation/pages/sales_history_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../shift/presentation/cubit/shift_cubit.dart';
import '../../../shift/presentation/pages/close_shift_page.dart';

enum _MenuAction { history, closeShift, settings, logout }

/// Bar name, cashier, the open shift's running total, and the menu
/// (history, close shift, settings, logout).
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final cashier = context.watch<SessionCubit>().state.cashier;
    final shiftState = context.watch<ShiftCubit>().state;
    final shift = shiftState.status == ShiftStatus.open
        ? shiftState.shift
        : null;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: NocturneColors.bg,
        border: Border(bottom: BorderSide(color: NocturneColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              color: NocturneColors.accent,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: NocturneColors.accent.withValues(alpha: .24),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cashier?.bar.name.isNotEmpty == true
                      ? cashier!.bar.name
                      : l10n.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(letterSpacing: -.25),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.user,
                      size: 13,
                      color: NocturneColors.neutral500,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        [
                          cashier?.fullName ?? '',
                          if (shift != null)
                            l10n.shiftOpenedAt(
                              DateFormat(
                                'HH:mm',
                              ).format(shift.openedAt.toLocal()),
                            ),
                        ].where((part) => part.isNotEmpty).join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.muted(
                          AppTextStyles.body,
                        ).copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (shift != null) _ShiftTotalChip(totalUzs: shift.totalUzs),
          const SizedBox(width: 12),
          const LanguageSwitcher(),
          const SizedBox(width: 8),
          _Menu(shiftOpen: shift != null),
        ],
      ),
    );
  }
}

class _ShiftTotalChip extends StatelessWidget {
  const _ShiftTotalChip({required this.totalUzs});

  final int totalUzs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: NocturneColors.accent900.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NocturneColors.accent.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            PhosphorIconsRegular.wallet,
            size: 18,
            color: NocturneColors.accent300,
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.shiftRevenue,
                style: AppTextStyles.kicker.copyWith(
                  color: NocturneColors.neutral400,
                ),
              ),
              Text(
                formatUzs(totalUzs),
                style: AppTextStyles.h5.copyWith(
                  color: NocturneColors.accent200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.shiftOpen});

  final bool shiftOpen;

  Future<void> _onSelected(BuildContext context, _MenuAction action) async {
    final shiftCubit = context.read<ShiftCubit>();
    final sessionCubit = context.read<SessionCubit>();
    switch (action) {
      case _MenuAction.history:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: shiftCubit,
              child: const SalesHistoryPage(),
            ),
          ),
        );
      case _MenuAction.closeShift:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: shiftCubit,
              child: const CloseShiftPage(),
            ),
          ),
        );
      case _MenuAction.settings:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: sessionCubit,
              child: const SettingsPage(),
            ),
          ),
        );
      case _MenuAction.logout:
        if (await confirmLogout(context)) await sessionCubit.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: sl<UpdateService>().hasUpdate,
      builder: (context, hasUpdate, _) => PopupMenuButton<_MenuAction>(
        tooltip: l10n.menu,
        position: PopupMenuPosition.under,
        color: NocturneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: NocturneColors.divider),
        ),
        onSelected: (action) => _onSelected(context, action),
        itemBuilder: (_) => [
          if (shiftOpen) ...[
            _item(
              _MenuAction.history,
              PhosphorIconsRegular.clockCounterClockwise,
              l10n.menuHistory,
            ),
            _item(
              _MenuAction.closeShift,
              PhosphorIconsRegular.lockKey,
              l10n.menuCloseShift,
            ),
          ],
          _item(
            _MenuAction.settings,
            PhosphorIconsRegular.gear,
            l10n.menuSettings,
            badge: hasUpdate,
          ),
          const PopupMenuDivider(),
          _item(_MenuAction.logout, PhosphorIconsRegular.signOut, l10n.logout),
        ],
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: NocturneColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: NocturneColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: hasUpdate,
                smallSize: 8,
                backgroundColor: NocturneColors.warning,
                child: const Icon(
                  PhosphorIconsRegular.list,
                  size: 18,
                  color: NocturneColors.accent,
                ),
              ),
              const SizedBox(width: 7),
              Text(l10n.menu, style: AppTextStyles.body.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_MenuAction> _item(
    _MenuAction value,
    IconData icon,
    String label, {
    bool badge = false,
  }) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 18, color: NocturneColors.accent),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (badge)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: NocturneColors.warning,
              shape: BoxShape.circle,
            ),
          ),
      ],
    ),
  );
}

/// Shared by the header menu and Settings. The open shift stays open on
/// the server; the next login on this till resumes it.
Future<bool> confirmLogout(BuildContext context) async {
  final l10n = AppLocalization.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: NocturneColors.surface,
      title: Text(l10n.logoutConfirmTitle, style: AppTextStyles.h4),
      content: SizedBox(
        width: 360,
        child: Text(l10n.logoutConfirmMessage, style: AppTextStyles.body),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.logout),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
