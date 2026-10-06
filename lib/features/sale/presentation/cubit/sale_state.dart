part of 'sale_cubit.dart';

enum ProductsStatus { initial, loading, loaded, failure }

/// One-shot result of a checkout attempt, for snackbars/printing.
/// Deliberately NOT [Equatable]: two identical failures in a row are still
/// two events, so state equality compares outcomes by identity.
sealed class SaleOutcome {
  const SaleOutcome();
}

class SaleSucceeded extends SaleOutcome {
  const SaleSucceeded(this.sale);

  final BarSale sale;
}

class SaleFailed extends SaleOutcome {
  const SaleFailed(this.failure);

  final Failure failure;
}

/// Category tabs: every distinct non-empty category, in catalog order (the
/// backend sorts products by `sortOrder, name`, so the admin's ordering of
/// products also orders the tabs).
List<String> categoriesOf(List<BarProduct> products) {
  final seen = <String>{};
  return [
    for (final product in products)
      if (product.category.isNotEmpty && seen.add(product.category))
        product.category,
  ];
}

class SaleState extends Equatable {
  const SaleState({
    this.productsStatus = ProductsStatus.initial,
    this.products = const [],
    this.productsFailure,
    this.selectedCategory,
    this.cart = Cart.empty,
    this.submittingMethod,
    this.outcome,
  });

  final ProductsStatus productsStatus;
  final List<BarProduct> products;
  final Failure? productsFailure;

  /// null = "Hammasi".
  final String? selectedCategory;
  final Cart cart;

  /// Non-null while `POST /v1/bar/sales` is in flight — which button spins.
  final PaymentMethod? submittingMethod;
  final SaleOutcome? outcome;

  bool get isSubmitting => submittingMethod != null;

  List<String> get categories => categoriesOf(products);

  List<BarProduct> get visibleProducts => selectedCategory == null
      ? products
      : products.where((p) => p.category == selectedCategory).toList();

  static const Object _unset = Object();

  SaleState copyWith({
    ProductsStatus? productsStatus,
    List<BarProduct>? products,
    Object? productsFailure = _unset,
    Object? selectedCategory = _unset,
    Cart? cart,
    Object? submittingMethod = _unset,
    Object? outcome = _unset,
  }) {
    return SaleState(
      productsStatus: productsStatus ?? this.productsStatus,
      products: products ?? this.products,
      productsFailure: identical(productsFailure, _unset)
          ? this.productsFailure
          : productsFailure as Failure?,
      selectedCategory: identical(selectedCategory, _unset)
          ? this.selectedCategory
          : selectedCategory as String?,
      cart: cart ?? this.cart,
      submittingMethod: identical(submittingMethod, _unset)
          ? this.submittingMethod
          : submittingMethod as PaymentMethod?,
      outcome: identical(outcome, _unset)
          ? this.outcome
          : outcome as SaleOutcome?,
    );
  }

  @override
  List<Object?> get props => [
    productsStatus,
    products,
    productsFailure,
    selectedCategory,
    cart,
    submittingMethod,
    outcome,
  ];
}
