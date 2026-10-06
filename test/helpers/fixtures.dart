import 'package:bar_app/features/auth/domain/entities/bar_cashier.dart';
import 'package:bar_app/features/products/domain/bar_product.dart';
import 'package:bar_app/features/sale/domain/bar_sale.dart';

const bar = BarRef(id: 'bar-1', name: 'Bar Megaplanet');

const cola = BarProduct(
  id: 'p-cola',
  name: 'Coca-Cola 0.5',
  category: 'Ichimliklar',
  icon: 'ph ph-beer-bottle',
  priceUzs: 12000,
);

const coffee = BarProduct(
  id: 'p-coffee',
  name: 'Kofe',
  category: 'Issiq',
  icon: 'ph-coffee',
  priceUzs: 18000,
  sortOrder: 1,
);

const chips = BarProduct(
  id: 'p-chips',
  name: 'Chips',
  category: 'Gazaklar',
  icon: 'cookie',
  priceUzs: 9000,
  sortOrder: 2,
);

BarSale saleFixture({
  int receiptNo = 1,
  PaymentMethod method = PaymentMethod.cash,
  SaleStatus status = SaleStatus.completed,
  int totalUzs = 24000,
}) => BarSale(
  id: 'sale-$receiptNo',
  receiptNo: receiptNo,
  bar: bar,
  shiftId: 'shift-1',
  cashierId: 'c-1',
  cashierName: 'Aziz',
  paymentMethod: method,
  totalUzs: totalUzs,
  status: status,
  createdAt: DateTime.utc(2026, 10, 6, 9, 30),
  items: const [
    BarSaleItem(
      productId: 'p-cola',
      name: 'Coca-Cola 0.5',
      priceUzs: 12000,
      quantity: 2,
      lineTotalUzs: 24000,
    ),
  ],
);

/// [cola] after an admin raised its price.
const colaPricier = BarProduct(
  id: 'p-cola',
  name: 'Coca-Cola 0.5',
  category: 'Ichimliklar',
  icon: 'ph ph-beer-bottle',
  priceUzs: 15000,
);
