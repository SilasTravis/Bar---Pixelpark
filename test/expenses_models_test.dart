import 'package:bar_app/features/expenses/domain/bar_expense.dart';
import 'package:bar_app/features/expenses/presentation/widgets/new_expense_dialog.dart';
import 'package:bar_app/features/shift/domain/bar_shift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixtures.dart';

/// Payloads shaped like the bar-expenses spec (2026-10-15).
void main() {
  group('BarExpense', () {
    test('full payload', () {
      final expense = BarExpense.fromJson({
        'id': 'e-1',
        'bar': {'id': 'bar-1', 'name': 'Bar 1'},
        'shiftId': 'sh-1',
        'cashierId': 'c-1',
        'cashierName': 'Aziz',
        'createdBy': 'cashier',
        'name': 'Sut',
        'amountUzs': 25000,
        'paidFrom': 'other',
        'note': '2 litr',
        'spentAt': '2026-10-15T07:05:00.000Z',
        'createdAt': '2026-10-15T07:06:00.000Z',
      });
      expect(expense.id, 'e-1');
      expect(expense.name, 'Sut');
      expect(expense.amountUzs, 25000);
      expect(expense.paidFrom, ExpensePaidFrom.other);
      expect(expense.isFromCash, isFalse);
      expect(expense.note, '2 litr');
      expect(expense.cashierName, 'Aziz');
      expect(expense.spentAt, DateTime.utc(2026, 10, 15, 7, 5));
      expect(expense.createdAt, DateTime.utc(2026, 10, 15, 7, 6));
    });

    test('nulls, string amount, unknown paidFrom → cash', () {
      final expense = BarExpense.fromJson({
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
      expect(expense.amountUzs, 12000);
      expect(expense.paidFrom, ExpensePaidFrom.cash);
      expect(expense.note, isNull, reason: 'blank note is no note');
      expect(expense.shiftId, isNull);
      expect(expense.createdBy, 'admin');
      expect(expense.spentAt, expense.createdAt, reason: 'spentAt fallback');
    });

    test('suggestion', () {
      final suggestion = ExpenseSuggestion.fromJson({
        'name': 'Sut',
        'lastAmountUzs': 25000,
        'count': 7,
      });
      expect(suggestion.name, 'Sut');
      expect(suggestion.lastAmountUzs, 25000);
      expect(suggestion.count, 7);
    });

    test('totals: all and the cash-drawer part', () {
      final totals = expenseTotalsOf([
        expenseFixture(id: 'a', amountUzs: 25000),
        expenseFixture(
          id: 'b',
          amountUzs: 40000,
          paidFrom: ExpensePaidFrom.other,
        ),
        expenseFixture(id: 'c', amountUzs: 5000),
      ]);
      expect(totals.totalUzs, 70000);
      expect(totals.cashUzs, 30000);
      expect(expenseTotalsOf(const []), (totalUzs: 0, cashUzs: 0));
    });

    test('amount input validation', () {
      expect(validExpenseAmount(''), isNull);
      expect(validExpenseAmount('0'), isNull);
      expect(validExpenseAmount('25 000'), 25000);
      expect(validExpenseAmount('1 000 000 000'), 1000000000);
      expect(validExpenseAmount('1 000 000 001'), isNull);
    });
  });

  group('BarShift expenses', () {
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

    test('new backend: expense fields as sent', () {
      final shift = BarShift.fromJson({
        ...base,
        'expensesUzs': 65000,
        'cashExpensesUzs': 25000,
        'expectedCashUzs': 125000,
      });
      expect(shift.expensesUzs, 65000);
      expect(shift.cashExpensesUzs, 25000);
      expect(shift.expectedCashUzs, 125000);
    });

    test('old backend: no expense fields → 0, expected = cash total', () {
      final shift = BarShift.fromJson(base);
      expect(shift.expensesUzs, 0);
      expect(shift.cashExpensesUzs, 0);
      expect(shift.expectedCashUzs, 150000);
    });

    test('expectedCashUzs missing but cash expenses present → derived', () {
      final shift = BarShift.fromJson({...base, 'cashExpensesUzs': '30000'});
      expect(shift.expectedCashUzs, 120000);
    });
  });

  group('expected cash math', () {
    test('expected = cash sales − cash expenses', () {
      expect(expectedCashOf(cashTotalUzs: 150000, cashExpensesUzs: 0), 150000);
      expect(
        expectedCashOf(cashTotalUzs: 150000, cashExpensesUzs: 25000),
        125000,
      );
      // Expenses can exceed the cash taken (drawer float).
      expect(
        expectedCashOf(cashTotalUzs: 10000, cashExpensesUzs: 25000),
        -15000,
      );
    });

    test('difference is counted − expected', () {
      final expected = expectedCashOf(
        cashTotalUzs: 150000,
        cashExpensesUzs: 25000,
      );
      expect(
        cashDifference(countedCashUzs: 125000, expectedCashUzs: expected),
        0,
      );
      expect(
        cashDifference(countedCashUzs: 120000, expectedCashUzs: expected),
        -5000,
      );
      expect(
        cashDifference(countedCashUzs: null, expectedCashUzs: expected),
        isNull,
      );
    });
  });
}
