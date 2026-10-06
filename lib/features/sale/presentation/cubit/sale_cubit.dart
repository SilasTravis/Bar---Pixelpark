import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../products/domain/bar_product.dart';
import '../../../products/domain/products_repository.dart';
import '../../domain/bar_sale.dart';
import '../../domain/cart.dart';
import '../../domain/sales_repository.dart';

part 'sale_state.dart';

/// The sale screen: product catalog + category filter + cart + checkout.
///
/// Retry safety lives in [Cart]: [checkout] stamps the cart with a
/// `clientSaleId` once and every failure keeps that stamped cart, so pressing
/// "Naqd"/"Karta" again re-sends the same id. Only a success (cart replaced
/// by an empty one) or a content change (new cart without an id) moves on to
/// a new id.
class SaleCubit extends Cubit<SaleState> {
  SaleCubit(this._products, this._sales, {String Function()? newClientSaleId})
    : _newClientSaleId = newClientSaleId ?? _uuidV4,
      super(const SaleState());

  final ProductsRepository _products;
  final SalesRepository _sales;
  final String Function() _newClientSaleId;

  static String _uuidV4() => const Uuid().v4();

  Future<void> loadProducts() async {
    if (state.productsStatus == ProductsStatus.loading) return;
    _emit(state.copyWith(productsStatus: ProductsStatus.loading));
    final result = await _products.fetchProducts();
    result.fold(
      (failure) => _emit(
        state.copyWith(
          productsStatus: ProductsStatus.failure,
          productsFailure: failure,
        ),
      ),
      (products) {
        final categories = categoriesOf(products);
        final selected = state.selectedCategory;
        _emit(
          state.copyWith(
            productsStatus: ProductsStatus.loaded,
            products: products,
            productsFailure: null,
            // A refreshed catalog may drop a product the cart holds, or
            // change its price — re-read the cart against it. While a
            // checkout is in flight the cart is frozen; the next refresh
            // catches up.
            cart: state.isSubmitting
                ? state.cart
                : state.cart.syncWith(products),
            selectedCategory: selected != null && categories.contains(selected)
                ? selected
                : null,
          ),
        );
      },
    );
  }

  void selectCategory(String? category) =>
      _emit(state.copyWith(selectedCategory: category));

  void addProduct(BarProduct product) => _editCart((cart) => cart.add(product));

  void increment(String productId) =>
      _editCart((cart) => cart.increment(productId));

  void decrement(String productId) =>
      _editCart((cart) => cart.decrement(productId));

  void removeLine(String productId) =>
      _editCart((cart) => cart.remove(productId));

  void clearCart() => _editCart((cart) => cart.clear());

  Future<void> checkout(PaymentMethod method) async {
    if (state.isSubmitting || state.cart.isEmpty) return;
    final cart = state.cart.withClientSaleId(_newClientSaleId);
    _emit(state.copyWith(cart: cart, submittingMethod: method));

    final result = await _sales.createSale(cart: cart, paymentMethod: method);
    result.fold(
      (failure) {
        // Every failure keeps the stamped cart: after a timeout or a 5xx the
        // sale may exist server-side, and only the same id makes the retry
        // safe.
        _emit(
          state.copyWith(submittingMethod: null, outcome: SaleFailed(failure)),
        );
        if (failure is ServerFailure &&
            failure.code == BarErrorCodes.productUnavailable) {
          // Something in the cart was deactivated: reload the catalog, which
          // also drops the dead lines from the cart.
          loadProducts();
        }
      },
      (sale) => _emit(
        state.copyWith(
          cart: Cart.empty,
          submittingMethod: null,
          outcome: SaleSucceeded(sale),
        ),
      ),
    );
  }

  void _editCart(Cart Function(Cart cart) edit) {
    // The cart is frozen while a checkout is in flight: the request already
    // carries this exact content, so editing it now would desync the
    // screen from what is being charged.
    if (state.isSubmitting) return;
    final next = edit(state.cart);
    if (identical(next, state.cart)) return;
    // The last outcome described the previous cart; drop it.
    _emit(state.copyWith(cart: next, outcome: null));
  }

  void _emit(SaleState next) {
    if (!isClosed) emit(next);
  }
}
