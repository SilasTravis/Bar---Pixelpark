import 'package:bar_app/features/sale/domain/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

void main() {
  var counter = 0;
  String nextId() => 'id-${++counter}';

  setUp(() => counter = 0);

  group('content', () {
    test('add creates a line and adding again increments it', () {
      final cart = Cart.empty.add(cola).add(coffee).add(cola);
      expect(cart.lines.map((l) => l.product.id), ['p-cola', 'p-coffee']);
      expect(cart.quantityOf('p-cola'), 2);
      expect(cart.quantityOf('p-coffee'), 1);
      expect(cart.quantityOf('missing'), 0);
      expect(cart.itemCount, 3);
    });

    test('increment / decrement, and decrement to zero removes the line', () {
      var cart = Cart.empty.add(cola).increment('p-cola').increment('p-cola');
      expect(cart.quantityOf('p-cola'), 3);
      cart = cart.decrement('p-cola');
      expect(cart.quantityOf('p-cola'), 2);
      cart = cart.decrement('p-cola').decrement('p-cola');
      expect(cart.isEmpty, isTrue);
      expect(cart, Cart.empty);
    });

    test('remove drops one line and keeps the rest', () {
      final cart = Cart.empty.add(cola).add(coffee).remove('p-cola');
      expect(cart.lines.single.product, coffee);
    });

    test('total is the sum of price x quantity', () {
      final cart = Cart.empty.add(cola).add(cola).add(coffee).add(chips);
      expect(cart.totalUzs, 12000 * 2 + 18000 + 9000);
      expect(cart.lines.first.lineTotalUzs, 24000);
      expect(Cart.empty.totalUzs, 0);
    });

    test('unknown ids are no-ops that return the same cart', () {
      final cart = Cart.empty.add(cola).withClientSaleId(nextId);
      expect(identical(cart.increment('x'), cart), isTrue);
      expect(identical(cart.decrement('x'), cart), isTrue);
      expect(identical(cart.remove('x'), cart), isTrue);
    });

    test('quantity is capped at 999 per line', () {
      var cart = Cart.empty.add(cola);
      for (var i = 0; i < 1100; i++) {
        cart = cart.increment('p-cola');
      }
      expect(cart.quantityOf('p-cola'), Cart.maxQuantity);
    });

    test('request items carry productId + quantity', () {
      final cart = Cart.empty.add(cola).add(cola).add(coffee);
      expect(cart.toRequestItems(), [
        {'productId': 'p-cola', 'quantity': 2},
        {'productId': 'p-coffee', 'quantity': 1},
      ]);
    });
  });

  group('clientSaleId', () {
    test('a fresh cart has none; it is minted on the first checkout', () {
      final cart = Cart.empty.add(cola);
      expect(cart.clientSaleId, isNull);
      expect(cart.withClientSaleId(nextId).clientSaleId, 'id-1');
    });

    test('is stable across retries (minted only once)', () {
      final stamped = Cart.empty.add(cola).withClientSaleId(nextId);
      final retry1 = stamped.withClientSaleId(nextId);
      final retry2 = retry1.withClientSaleId(nextId);
      expect(retry1.clientSaleId, 'id-1');
      expect(retry2.clientSaleId, 'id-1');
      expect(counter, 1);
    });

    test('is reset by every content change', () {
      final stamped = Cart.empty.add(cola).add(coffee).withClientSaleId(nextId);
      expect(stamped.add(chips).clientSaleId, isNull);
      expect(stamped.add(cola).clientSaleId, isNull);
      expect(stamped.increment('p-cola').clientSaleId, isNull);
      expect(stamped.decrement('p-coffee').clientSaleId, isNull);
      expect(stamped.remove('p-cola').clientSaleId, isNull);
      expect(stamped.clear().clientSaleId, isNull);
    });

    test('a changed cart gets a NEW id at its next checkout', () {
      final first = Cart.empty.add(cola).withClientSaleId(nextId);
      final second = first.add(coffee).withClientSaleId(nextId);
      expect(first.clientSaleId, 'id-1');
      expect(second.clientSaleId, 'id-2');
    });
  });

  group('syncWith (catalog refresh)', () {
    test('an unchanged catalog keeps the very same cart and its id', () {
      final cart = Cart.empty.add(cola).add(coffee).withClientSaleId(nextId);
      final synced = cart.syncWith([cola, coffee, chips]);
      expect(identical(synced, cart), isTrue);
      expect(synced.clientSaleId, 'id-1');
    });

    test('drops lines whose product disappeared and resets the id', () {
      final cart = Cart.empty.add(cola).add(coffee).withClientSaleId(nextId);
      final synced = cart.syncWith([coffee]);
      expect(synced.lines.single.product, coffee);
      expect(synced.clientSaleId, isNull);
    });

    test('refreshes changed prices and resets the id', () {
      final cart = Cart.empty.add(cola).add(cola).withClientSaleId(nextId);
      final synced = cart.syncWith([colaPricier]);
      expect(synced.lines.single.product.priceUzs, 15000);
      expect(synced.quantityOf('p-cola'), 2);
      expect(synced.totalUzs, 30000);
      expect(synced.clientSaleId, isNull);
    });
  });
}
