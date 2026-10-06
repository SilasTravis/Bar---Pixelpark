import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/nocturne_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../generated/l10n.dart';
import '../../../products/domain/bar_product.dart';
import '../../../products/presentation/product_icon.dart';
import '../cubit/sale_cubit.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return BlocBuilder<SaleCubit, SaleState>(
      buildWhen: (previous, current) =>
          previous.products != current.products ||
          previous.selectedCategory != current.selectedCategory ||
          previous.productsStatus != current.productsStatus ||
          previous.productsFailure != current.productsFailure ||
          previous.cart != current.cart ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final cubit = context.read<SaleCubit>();
        if (state.products.isEmpty) {
          if (state.productsStatus == ProductsStatus.failure) {
            return _Message(
              icon: PhosphorIconsRegular.wifiSlash,
              text: failureMessage(l10n, state.productsFailure!),
              action: OutlinedButton.icon(
                onPressed: cubit.loadProducts,
                icon: const Icon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 16,
                ),
                label: Text(l10n.retry),
              ),
            );
          }
          if (state.productsStatus == ProductsStatus.loaded) {
            return _Message(
              icon: PhosphorIconsRegular.package,
              text: l10n.productsEmpty,
            );
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final compact = breakpointOfContext(context) == Breakpoint.compact;
        final products = state.visibleProducts;
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: compact ? 160 : 180,
            mainAxisSpacing: compact ? 8 : 12,
            crossAxisSpacing: compact ? 8 : 12,
            childAspectRatio: compact ? 0.95 : 0.92,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductTile(
              product: product,
              qtyInCart: state.cart.quantityOf(product.id),
              onTap: state.isSubmitting
                  ? null
                  : () => cubit.addProduct(product),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: NocturneColors.neutral500),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted(AppTextStyles.body),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.qtyInCart,
    required this.onTap,
  });

  final BarProduct product;
  final int qtyInCart;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = qtyInCart > 0;
    return Material(
      color: NocturneColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inCart ? NocturneColors.accent : NocturneColors.divider,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: NocturneColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      productIconFor(product.icon),
                      size: 26,
                      color: NocturneColors.accent,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    product.name,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatUzs(product.priceUzs),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: NocturneColors.accent300,
                    ),
                  ),
                ],
              ),
              if (inCart)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: NocturneColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$qtyInCart',
                      style: const TextStyle(
                        color: NocturneColors.neutral100,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
