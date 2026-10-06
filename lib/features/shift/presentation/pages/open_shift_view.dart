import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../cubit/shift_cubit.dart';

/// Screen 2: no open shift — one big "Smenani ochish" button.
class OpenShiftView extends StatelessWidget {
  const OpenShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocConsumer<ShiftCubit, ShiftState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && current.failure != null,
      listener: (context, state) {
        if (isAccountBlocked(state.failure!)) {
          context.read<SessionCubit>().endBecauseBlocked();
        }
      },
      builder: (context, state) {
        return Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: NocturneColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadow.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: NocturneColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.cashRegister,
                    color: NocturneColors.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(l10n.noOpenShiftTitle, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Text(
                  l10n.noOpenShiftMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.muted(AppTextStyles.body),
                ),
                if (state.failure case final failure?) ...[
                  const SizedBox(height: 14),
                  Text(
                    failureMessage(l10n, failure),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: NocturneColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    autofocus: true,
                    onPressed: state.isOpening
                        ? null
                        : () => context.read<ShiftCubit>().openShift(),
                    icon: state.isOpening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(PhosphorIconsRegular.lockOpen, size: 20),
                    label: Text(
                      l10n.openShift,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
