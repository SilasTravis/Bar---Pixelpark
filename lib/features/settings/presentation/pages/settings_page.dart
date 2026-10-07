import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:printing/printing.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/update/update_cubit.dart';
import '../../../../core/update/update_service.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../widgets/update_card.dart';

/// Screen 6: who is signed in, the receipt printer, app version + update
/// check, and logout.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final cashier = context.watch<SessionCubit>().state.cashier;
    final updateService = sl<UpdateService>();
    return WindowScaffold(
      body: Column(
        children: [
          PageHeader(title: l10n.menuSettings),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.accentSoft,
                                  child: Text(
                                    _initial(cashier?.fullName),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cashier?.fullName ?? '',
                                        style: AppTextStyles.h5,
                                      ),
                                      Text(
                                        '@${cashier?.username ?? ''}',
                                        style: AppTextStyles.muted(
                                          AppTextStyles.body,
                                        ).copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            _InfoRow(
                              label: l10n.barLabel,
                              value: cashier?.bar.name ?? '',
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: l10n.version,
                              value: updateService.currentVersion,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _PrinterCard(),
                      const SizedBox(height: 16),
                      BlocProvider<UpdateCubit>(
                        create: (_) => UpdateCubit(updateService),
                        child: const UpdateCard(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final session = context.read<SessionCubit>();
                            if (await confirmLogout(context)) {
                              await session.logout();
                            }
                          },
                          icon: const Icon(
                            PhosphorIconsRegular.signOut,
                            size: 16,
                          ),
                          label: Text(l10n.logout),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initial(String? name) =>
      (name == null || name.isEmpty) ? '?' : name[0].toUpperCase();
}

/// Receipt printer picker. "No printer" is the default: the bar works
/// without printing, and a receipt is only printed once a printer is picked
/// here.
class _PrinterCard extends StatefulWidget {
  const _PrinterCard();

  @override
  State<_PrinterCard> createState() => _PrinterCardState();
}

class _PrinterCardState extends State<_PrinterCard> {
  static const _none = '__none__';
  late Future<List<Printer>> _printers;

  @override
  void initState() {
    super.initState();
    _printers = _list();
  }

  /// Never fails: no printer subsystem just means an empty list.
  static Future<List<Printer>> _list() async {
    try {
      return await Printing.listPrinters();
    } catch (_) {
      return const [];
    }
  }

  void _refresh() => setState(() => _printers = _list());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final local = sl<LocalSource>();
    return _Card(
      child: FutureBuilder<List<Printer>>(
        future: _printers,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final printers = snapshot.data ?? const <Printer>[];
          final saved = local.getReceiptPrinterName();
          final names = printers.map((printer) => printer.name).toSet();
          // A saved printer that is unplugged right now stays selected (and
          // listed) so opening Settings never silently forgets it.
          final value = saved ?? _none;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.printer,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l10n.printerSettings, style: AppTextStyles.h5),
                  ),
                  IconButton(
                    tooltip: l10n.refresh,
                    onPressed: loading ? null : _refresh,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            PhosphorIconsRegular.arrowsClockwise,
                            size: 17,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('printer:$value:${names.length}'),
                initialValue: value,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.receiptPrinter,
                  prefixIcon: const Icon(
                    PhosphorIconsRegular.printer,
                    size: 18,
                  ),
                ),
                items: [
                  DropdownMenuItem(value: _none, child: Text(l10n.printerNone)),
                  if (saved != null && !names.contains(saved))
                    DropdownMenuItem(
                      value: saved,
                      child: Text(
                        l10n.printerUnavailable(saved),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  for (final printer in printers)
                    DropdownMenuItem(
                      value: printer.name,
                      child: Text(
                        printer.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (picked) async {
                  if (picked == null) return;
                  await local.setReceiptPrinterName(
                    picked == _none ? null : picked,
                  );
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.hasData && printers.isEmpty
                    ? l10n.noPrintersFound
                    : l10n.printerHint,
                style: AppTextStyles.muted(
                  AppTextStyles.body,
                ).copyWith(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.muted(AppTextStyles.body)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
