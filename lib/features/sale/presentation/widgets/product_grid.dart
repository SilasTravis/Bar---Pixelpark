import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
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
            maxCrossAxisExtent: compact ? 170 : 200,
            mainAxisSpacing: compact ? 10 : 12,
            crossAxisSpacing: compact ? 10 : 12,
            // Every tile is the same size, so the photo area (whatever
            // the tile leaves after name + price) has one aspect across the
            // grid — ~1.1–1.3 : 1 — and the grid stays tidy.
            childAspectRatio: compact ? 0.8 : 0.78,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductTile(
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
          Icon(icon, size: 40, color: AppColors.textMuted),
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

/// One product: photo (or its icon), name and price. The whole tile is the
/// tap target; the photo never gates it — taps work while it loads, after
/// it fails, or when there is none.
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.qtyInCart,
    required this.onTap,
  });

  final BarProduct product;
  final int qtyInCart;
  final VoidCallback? onTap;

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    final inCart = qtyInCart > 0;
    // Room for exactly two name lines on every tile, so prices line up
    // across a row whatever the name length (and OS text scale).
    final nameHeight = MediaQuery.textScalerOf(context).scale(15 * 1.25 * 2);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: inCart
                ? Border.all(color: AppColors.accent, width: 2)
                : Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(product: product),
                    if (inCart)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _QtyBadge(quantity: qtyInCart),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: nameHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    product.name,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatUzs(product.priceUzs),
                    maxLines: 1,
                    style: AppTextStyles.price,
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

/// The product photo, cover-fit and rounded, filling whatever box it is
/// given. Shows [ProductIconFallback] when there is no URL, until the first
/// frame is decoded, and on any load/decode error.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product});

  final BarProduct product;

  @override
  Widget build(BuildContext context) {
    final fallback = ProductIconFallback(icon: product.icon);
    final url = product.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? fallback
          : LayoutBuilder(
              builder: (context, constraints) => Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                // Decode at tile size, not the photo's full resolution: a
                // 2000px upload costs the memory of a ~200px thumbnail.
                cacheWidth: _cacheWidth(
                  constraints.maxWidth,
                  MediaQuery.devicePixelRatioOf(context),
                ),
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    wasSynchronouslyLoaded || frame != null ? child : fallback,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
            ),
    );
  }

  /// Rounded up to a 64px bucket so resizing the window by a few pixels
  /// reuses the decoded image instead of decoding it again.
  static int? _cacheWidth(double logicalWidth, double devicePixelRatio) {
    if (!logicalWidth.isFinite || logicalWidth <= 0) return null;
    final px = logicalWidth * devicePixelRatio;
    return ((px / 64).ceil() * 64).clamp(64, 1024);
  }
}

/// The tile's icon on a soft brand tint — the no-photo look, and the
/// placeholder while a photo loads or after it fails.
class ProductIconFallback extends StatelessWidget {
  const ProductIconFallback({super.key, required this.icon});

  /// Phosphor class name, see [productIconFor].
  final String icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.accentSoft,
      child: Center(
        child: Icon(productIconFor(icon), size: 40, color: AppColors.accent),
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(15),
        // White ring keeps the badge legible on any photo.
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        '$quantity',
        style: const TextStyle(
          color: AppColors.onAccent,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
