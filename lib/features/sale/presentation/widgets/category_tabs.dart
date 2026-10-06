import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../generated/l10n.dart';
import '../cubit/sale_cubit.dart';

/// "Hammasi" + one tab per product category, and the catalog refresh.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<SaleCubit, SaleState>(
      buildWhen: (previous, current) =>
          previous.products != current.products ||
          previous.selectedCategory != current.selectedCategory ||
          previous.productsStatus != current.productsStatus,
      builder: (context, state) {
        final cubit = context.read<SaleCubit>();
        final loading = state.productsStatus == ProductsStatus.loading;
        return SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _Tab(
                      label: l10n.categoryAll,
                      selected: state.selectedCategory == null,
                      onTap: () => cubit.selectCategory(null),
                    ),
                    for (final category in state.categories)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _Tab(
                          label: category,
                          selected: state.selectedCategory == category,
                          onTap: () => cubit.selectCategory(category),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.refreshProducts,
                onPressed: loading ? null : cubit.loadProducts,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        PhosphorIconsRegular.arrowsClockwise,
                        size: 18,
                        color: NocturneColors.accent,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? NocturneColors.accent.withValues(alpha: 0.15)
          : NocturneColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? NocturneColors.accent : NocturneColors.divider,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: selected ? NocturneColors.accent : NocturneColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
