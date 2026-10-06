import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_navigator.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../sale/presentation/cubit/sale_cubit.dart';
import '../../../sale/presentation/pages/sale_page.dart';
import '../../../shift/presentation/cubit/shift_cubit.dart';
import '../../../shift/presentation/pages/open_shift_view.dart';
import '../widgets/home_header.dart';

/// The signed-in shell: header + either the open-shift screen or the sale
/// screen, depending on `GET /v1/bar/shifts/current`.
///
/// The [SaleCubit] lives here, above the shift gate, so the cart survives a
/// trip through the open-shift screen (e.g. a sale refused with
/// `BAR_SHIFT_NOT_OPEN`: the cashier opens the shift and the cart is still
/// there, with the same `clientSaleId`).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SessionCubit>()..refresh()),
        BlocProvider(create: (_) => sl<ShiftCubit>()..load()),
        BlocProvider(create: (_) => sl<SaleCubit>()..loadProducts()),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) => !previous.ended && current.ended,
        listener: (context, _) => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.login, (route) => false),
        child: const WindowScaffold(
          body: Column(
            children: [
              HomeHeader(),
              Expanded(child: _ShiftGate()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftGate extends StatelessWidget {
  const _ShiftGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftCubit, ShiftState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) => switch (state.status) {
        ShiftStatus.loading => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        ShiftStatus.failure => _LoadFailure(state: state),
        ShiftStatus.none => const OpenShiftView(),
        ShiftStatus.open => const SalePage(),
      },
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.state});

  final ShiftState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              PhosphorIconsRegular.wifiSlash,
              size: 40,
              color: NocturneColors.neutral500,
            ),
            const SizedBox(height: 14),
            Text(
              state.failure == null
                  ? l10n.errorUnknown
                  : failureMessage(l10n, state.failure!),
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => context.read<ShiftCubit>().load(),
                icon: const Icon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 16,
                ),
                label: Text(l10n.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
