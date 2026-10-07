import '../../generated/l10n.dart';
import '../error/failure.dart';

/// The cashier-facing, localized text for any [Failure]. Known bar error
/// codes get fixed wording; anything else shows the backend's own Uzbek
/// message (the API localizes its errors).
String failureMessage(AppLocalization l10n, Failure failure) {
  if (failure is NoInternetFailure) return l10n.errorNoInternet;
  if (failure is! ServerFailure) return l10n.errorUnknown;
  switch (failure.code) {
    case BarErrorCodes.shiftNotOpen:
      return l10n.errorShiftNotOpen;
    case BarErrorCodes.shiftAlreadyOpen:
      return l10n.errorShiftAlreadyOpen;
    case BarErrorCodes.productUnavailable:
      return l10n.errorProductUnavailable;
    case BarErrorCodes.emptyCart:
      return l10n.errorEmptyCart;
    case BarErrorCodes.cashierInactive:
      return l10n.errorCashierInactive;
    case BarErrorCodes.barInactive:
      return l10n.errorBarInactive;
    case BarErrorCodes.saleNotInShift:
      return l10n.errorSaleNotInShift;
    case BarErrorCodes.saleAlreadyRefunded:
      return l10n.errorSaleAlreadyRefunded;
    case BarErrorCodes.invalidPaymentSplit:
      return l10n.errorInvalidPaymentSplit;
  }
  if (failure.statusCode == 429) return l10n.errorTooManyAttempts;
  if (failure.isServerError) return l10n.errorServer;
  return failure.message;
}

/// Checkout failures add what happened to the cart: after a network or
/// server error the cart (and its idempotency key) is kept, so pressing the
/// payment button again is a safe retry.
String saleFailureMessage(AppLocalization l10n, Failure failure) {
  if (failure is NoInternetFailure) return l10n.saleErrorNetwork;
  if (failure is ServerFailure && failure.code == null) {
    if (failure.isServerError) return l10n.saleErrorServer;
    if (failure.statusCode == null) return l10n.saleErrorUnknownOutcome;
  }
  return failureMessage(l10n, failure);
}

/// Login: a plain 401 means wrong username/password.
String loginFailureMessage(AppLocalization l10n, Failure failure) {
  if (failure is ServerFailure &&
      failure.code == null &&
      failure.statusCode == 401) {
    return l10n.loginInvalid;
  }
  return failureMessage(l10n, failure);
}
