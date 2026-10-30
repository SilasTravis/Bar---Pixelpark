import 'package:bar_app/features/incomes/domain/bar_income.dart';
import 'package:bar_app/features/incomes/presentation/widgets/new_income_dialog.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

/// Payloads shaped like the bar-incomes spec (2026-10-15).
void main() {
  group('BarIncome', () {
    test('full payload', () {
      final income = BarIncome.fromJson({
        'id': 'e-1',
        'bar': {'id': 'bar-1', 'name': 'Bar 1'},
        'shiftId': 'sh-1',
        'cashierId': 'c-1',
        'cashierName': 'Aziz',
        'createdBy': 'cashier',
        'name': 'Sut',
        'amountUzs': 25000,
        'receivedTo': 'other',
        'note': '2 litr',
        'receivedAt': '2026-10-15T07:05:00.000Z',
        'createdAt': '2026-10-15T07:06:00.000Z',
      });
      expect(income.id, 'e-1');
      expect(income.name, 'Sut');
      expect(income.amountUzs, 25000);
      expect(income.receivedTo, IncomeReceivedTo.other);
      expect(income.isToCash, isFalse);
      expect(income.note, '2 litr');
      expect(income.cashierName, 'Aziz');
      expect(income.receivedAt, DateTime.utc(2026, 10, 15, 7, 5));
      expect(income.createdAt, DateTime.utc(2026, 10, 15, 7, 6));
    });

    test('nulls, string amount, unknown receivedTo → cash', () {
      final income = BarIncome.fromJson({
        'id': 'e-2',
        'shiftId': null,
        'cashierId': null,
        'cashierName': null,
        'createdBy': 'admin',
        'name': 'Muz',
        'amountUzs': '12000',
        'note': '  ',
        'createdAt': '2026-10-15T08:00:00.000Z',
      });
      expect(income.amountUzs, 12000);
      expect(income.receivedTo, IncomeReceivedTo.cash);
      expect(income.note, isNull, reason: 'blank note is no note');
      expect(income.shiftId, isNull);
      expect(income.createdBy, 'admin');
      expect(
        income.receivedAt,
        income.createdAt,
        reason: 'receivedAt fallback',
      );
    });

    test('suggestion', () {
      final suggestion = IncomeSuggestion.fromJson({
        'name': 'Sut',
        'lastAmountUzs': 25000,
        'count': 7,
      });
      expect(suggestion.name, 'Sut');
      expect(suggestion.lastAmountUzs, 25000);
      expect(suggestion.count, 7);
    });

    test('totals: all and the cash-drawer part', () {
      final totals = incomeTotalsOf([
        incomeFixture(id: 'a', amountUzs: 25000),
        incomeFixture(
          id: 'b',
          amountUzs: 40000,
          receivedTo: IncomeReceivedTo.other,
        ),
        incomeFixture(id: 'c', amountUzs: 5000),
      ]);
      expect(totals.totalUzs, 70000);
      expect(totals.cashUzs, 30000);
      expect(incomeTotalsOf(const []), (totalUzs: 0, cashUzs: 0));
    });

    test('amount input validation', () {
      expect(validIncomeAmount(''), isNull);
      expect(validIncomeAmount('0'), isNull);
      expect(validIncomeAmount('25 000'), 25000);
      expect(validIncomeAmount('1 000 000 000'), 1000000000);
      expect(validIncomeAmount('1 000 000 001'), isNull);
    });
  });

  group('BarShift incomes', () {
    const base = {
      'id': 'sh-1',
      'bar': {'id': 'bar-1', 'name': 'Bar 1'},
      'cashierId': 'c-1',
      'cashierName': 'Aziz',
      'openedAt': '2026-10-15T04:00:00.000Z',
      'closedAt': null,
      'cashTotalUzs': 150000,
      'cardTotalUzs': 50000,
      'totalUzs': 200000,
      'salesCount': 9,
      'refundedCount': 0,
    };

    test('new backend: income fields as sent', () {
      final shift = BarShift.fromJson({
        ...base,
        'incomesUzs': 65000,
        'cashIncomesUzs': 25000,
        'expectedCashUzs': 175000,
      });
      expect(shift.incomesUzs, 65000);
      expect(shift.cashIncomesUzs, 25000);
      expect(shift.expectedCashUzs, 175000);
    });

    test('old backend: no income fields -> 0, expected = cash total', () {
      final shift = BarShift.fromJson(base);
      expect(shift.incomesUzs, 0);
      expect(shift.cashIncomesUzs, 0);
      expect(shift.expectedCashUzs, 150000);
    });

    test('expectedCashUzs missing -> derived with expenses and incomes', () {
      final shift = BarShift.fromJson({
        ...base,
        'cashExpensesUzs': 10000,
        'cashIncomesUzs': '30000',
      });
      expect(shift.expectedCashUzs, 170000);
    });
  });

  group('expected cash math', () {
    test('expected = cash sales - cash expenses + cash incomes', () {
      expect(
        expectedCashOf(
          cashTotalUzs: 150000,
          cashExpensesUzs: 10000,
          cashIncomesUzs: 25000,
        ),
        165000,
      );
      expect(expectedCashOf(cashTotalUzs: 150000, cashExpensesUzs: 0), 150000);
    });
  });
}
