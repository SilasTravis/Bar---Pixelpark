import 'package:bar_app/features/inventory/domain/stock_item.dart';
import 'package:bar_app/features/inventory/domain/stock_qty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockItem', () {
    test('parses, tolerating extra fields and string numbers', () {
      final item = StockItem.fromJson({
        'id': 'a',
        'name': 'Sut',
        'unit': 'ml',
        'qtyOnHand': '2500',
        'minQty': 1000,
        'active': true,
        'status': 'ok',
        'somethingNew': {'x': 1},
      });
      expect(item.unit, StockUnit.ml);
      expect(item.qtyOnHand, 2500);
      expect(item.status, StockStatus.ok);
    });

    test('derives low / out when the server sends no flags', () {
      StockItem at(int qty) => StockItem.fromJson({
        'id': 'a',
        'name': 'x',
        'unit': 'g',
        'qtyOnHand': qty,
        'minQty': 1000,
      });
      expect(at(1001).status, StockStatus.ok);
      expect(at(1000).status, StockStatus.low);
      expect(at(1).status, StockStatus.low);
      expect(at(0).status, StockStatus.out);
      expect(at(-5).status, StockStatus.out);
      expect(at(5).active, isTrue);
    });

    test('page falls back to the list length', () {
      final page = StockPage.fromJson({
        'items': [
          {'id': 'a', 'name': 'x', 'unit': 'pcs', 'qtyOnHand': 1, 'minQty': 0},
        ],
      });
      expect(page.total, 1);
      expect(page.items.single.unit, StockUnit.pcs);
    });
  });

  test('movement parses; unknown type is tolerated', () {
    final m = StockMovement.fromJson({
      'id': 'm',
      'stockItemId': 's',
      'type': 'writeoff',
      'qtyDelta': -300,
      'reason': 'Brak',
      'createdAt': '2026-10-30T10:00:00Z',
    });
    expect(m.type, StockMovementType.writeoff);
    expect(m.qtyDelta, -300);
    expect(StockMovementType.parse('zzz'), StockMovementType.other);
  });

  group('ProductSetup', () {
    test('prepared round-trips to the PUT body', () {
      final setup = ProductSetup.fromJson('p', {
        'productId': 'p',
        'kind': 'prepared',
        'link': null,
        'recipe': [
          {'stockItemId': 'coffee', 'qtyPerPortion': 10},
          {'stockItemId': 'milk', 'qtyPerPortion': 150},
        ],
        'addonIds': ['ad-1'],
        'barId': 'b',
      });
      expect(setup.recipe, hasLength(2));
      expect(setup.toRequest(), {
        'kind': 'prepared',
        'link': null,
        'recipe': [
          {'stockItemId': 'coffee', 'qtyPerPortion': 10},
          {'stockItemId': 'milk', 'qtyPerPortion': 150},
        ],
        'addonIds': ['ad-1'],
      });
    });

    test('ready sends the link and an empty recipe', () {
      const setup = ProductSetup(
        productId: 'p',
        kind: ProductKind.ready,
        link: RecipeLine(stockItemId: 'cola', qty: 1),
      );
      final body = setup.toRequest();
      expect(body['link'], {'stockItemId': 'cola', 'qtyPerUnit': 1});
      expect(body['recipe'], isEmpty);
      expect(
        ProductSetup.fromJson('p', {'kind': 'ready', 'recipe': []}).isEmpty,
        isTrue,
      );
    });
  });

  group('quantities', () {
    test('formatQty switches to kg / l from 1000', () {
      expect(formatQty(500, StockUnit.g), '500 g');
      expect(formatQty(1000, StockUnit.g), '1 kg');
      expect(formatQty(2500, StockUnit.ml), '2,5 l');
      expect(formatQty(12, StockUnit.pcs), '12 dona');
      expect(formatQty(1500, StockUnit.pcs), '1 500 dona');
      expect(formatQtyDelta(300, StockUnit.g), '+300 g');
      expect(formatQtyDelta(-1500, StockUnit.g), '-1,5 kg');
    });

    test('parseQty converts kg / l, accepts comma, rejects junk', () {
      final kg = unitOptionsFor(StockUnit.g)[1];
      final g = unitOptionsFor(StockUnit.g)[0];
      expect(parseQty('1,5', kg), 1500);
      expect(parseQty('250', g), 250);
      expect(parseQty('0', g), isNull);
      expect(parseQty('0', g, allowZero: true), 0);
      expect(parseQty('abc', g), isNull);
      expect(parseQty('', g), isNull);
      expect(parseQty('-3', g), isNull);
      expect(parseQty('2000000', kg), isNull, reason: 'over the 1e9 cap');
      expect(unitOptionsFor(StockUnit.pcs), hasLength(1));
    });
  });

  test('unit price: per kg / l / dona from the total', () {
    expect(unitPriceText(100000, 5000, StockUnit.g), "1 kg = 20 000 so'm");
    expect(unitPriceText(30000, 2000, StockUnit.ml), "1 l = 15 000 so'm");
    expect(unitPriceText(50000, 10, StockUnit.pcs), "1 dona = 5 000 so'm");
    expect(unitPriceText(0, 1000, StockUnit.g), isNull);
    expect(unitPriceText(1000, 0, StockUnit.g), isNull);
  });
}
