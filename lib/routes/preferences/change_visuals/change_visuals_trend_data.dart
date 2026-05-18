import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:moment_dart/moment_dart.dart";

class ChangeVisualsTrendData {
  final bool hasComparison;
  final Money incomeCurrent;
  final Money? incomePrevious;
  final Money expenseCurrent;
  final Money? expensePrevious;

  const ChangeVisualsTrendData({
    required this.hasComparison,
    required this.incomeCurrent,
    required this.incomePrevious,
    required this.expenseCurrent,
    required this.expensePrevious,
  });

  static const ChangeVisualsTrendData empty = ChangeVisualsTrendData(
    hasComparison: false,
    incomeCurrent: Money.zeroUSD,
    incomePrevious: null,
    expenseCurrent: Money.zeroUSD,
    expensePrevious: null,
  );
}

abstract final class ChangeVisualsTrendLoader {
  static Future<ChangeVisualsTrendData> load() async {
    final String currency = UserPreferencesService().primaryCurrency;
    final ExchangeRates? rates = ExchangeRatesService().getPrimaryCurrencyRates();
    final TimeRange currentRange = TimeRange.thisMonth();

    final ({RangeData current, RangeData? previous}) rangeData =
        await FlowReport.prepareRangeDataWithPrevious(currentRange);

    final SingleCurrencyFlow currentFlow = SingleCurrencyFlow(currency: currency);
    _addTransactions(currentFlow, rangeData.current.transactions, rates);

    SingleCurrencyFlow? previousFlow;
    if (rangeData.previous != null &&
        rangeData.previous!.transactions.isNotEmpty) {
      previousFlow = SingleCurrencyFlow(currency: currency);
      _addTransactions(previousFlow, rangeData.previous!.transactions, rates);
    }

    return ChangeVisualsTrendData(
      hasComparison: previousFlow != null,
      incomeCurrent: currentFlow.totalIncome,
      incomePrevious: previousFlow?.totalIncome,
      expenseCurrent: currentFlow.totalExpense,
      expensePrevious: previousFlow?.totalExpense,
    );
  }

  static void _addTransactions(
    SingleCurrencyFlow flow,
    List<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    for (final Transaction transaction in transactions) {
      if (transaction.isDeleted == true) {
        continue;
      }
      if (transaction.isTransfer) {
        continue;
      }
      if (transaction.isPending == true) {
        continue;
      }

      flow.add(transaction.money, rates);
    }
  }
}
