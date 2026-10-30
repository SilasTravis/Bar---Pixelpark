import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/failure_message.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/title_bar.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../products/domain/bar_product.dart';
import '../../../products/domain/products_repository.dart';
import '../../../products/presentation/product_icon.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/recipe_editor_dialog.dart';

/// "Retseptlar": the bar's sale products; tapping one opens its recipe
/// editor. (The app has no product management screen, so recipes live here.)
/// Needs the [InventoryCubit] above it.
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late Future<List<BarProduct>> _products = _load();
  String? _error;

  Future<List<BarProduct>> _load() async {
    final result = await sl<ProductsRepository>().fetchProducts();
    return result.fold((f) {
      _error = failureMessage(AppLocalization.of(context), f);
      return <BarProduct>[];
    }, (list) => list);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    return WindowScaffold(
      body: Column(
        children: [
          PageHeader(title: l10n.recipesTitle),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Text(
                        l10n.recipesHint,
                        style: AppTextStyles.muted(AppTextStyles.body),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<BarProduct>>(
                        future: _products,
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          final products = snap.data!;
                          if (products.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error ?? l10n.recipesEmpty),
                                  if (_error != null)
                                    TextButton(
                                      onPressed: () => setState(() {
                                        _error = null;
                                        _products = _load();
                                      }),
                                      child: Text(l10n.retry),
                                    ),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: products.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = products[i];
                              return Material(
                                color: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                  leading: Icon(
                                    productIconFor(p.icon),
                                    color: AppColors.accent,
                                  ),
                                  title: Text(
                                    p.name,
                                    style: AppTextStyles.h4.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${p.category}  ·  ${formatUzs(p.priceUzs)}',
                                  ),
                                  trailing: const Icon(
                                    PhosphorIconsRegular.caretRight,
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final saved = await showRecipeEditor(
                                      context,
                                      p,
                                    );
                                    if (saved) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.recipeSaved),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens [RecipesPage] sharing the page's cubit.
Future<void> openRecipesPage(BuildContext context) {
  final cubit = context.read<InventoryCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const RecipesPage()),
    ),
  );
}
