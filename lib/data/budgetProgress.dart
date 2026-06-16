import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:moment_dart/moment_dart.dart";

class BudgetProgress {
  final Budget budget;
  final Money spent;
  final Money limit;
  final TimeRange period;

  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.limit,
    required this.period,
  });

  double get fraction {
    if (limit.amount <= 0) return 0;
    return (spent.amount / limit.amount).clamp(0.0, 2.0);
  }

  double get percent => fraction * 100;

  bool get isOver => spent.amount > limit.amount;

  bool get shouldAlert => !isOver && fraction >= budget.alertThreshold;

  bool get isCritical => isOver || fraction >= 1.0;

  Money get remaining {
    final double left = limit.amount - spent.amount;
    return Money(left < 0 ? 0 : left, limit.currency);
  }
}

Future<BudgetProgress> computeBudgetProgress(Budget budget) async {
  final TimeRange period = budget.timeRange;
  final List<String> categoryUuids = budget.categoriesUuids ?? [];

  if (categoryUuids.isEmpty) {
    return BudgetProgress(
      budget: budget,
      spent: Money(0, budget.currency),
      limit: Money(budget.amount, budget.currency),
      period: period,
    );
  }

  final List<Transaction> transactions = await TransactionsService().findMany(
    TransactionFilter(
      range: TransactionFilterTimeRange.fromTimeRange(period),
      categories: StringMultiFilter.whitelist(categoryUuids),
      types: [TransactionType.expense],
      isPending: false,
      includeDeleted: false,
    ),
  );

  final MultiCurrencyFlow<void> flow = MultiCurrencyFlow();
  for (final Transaction t in transactions) {
    if (t.isTransfer) continue;
    flow.add(t.money);
  }

  final ExchangeRates? rates = await ExchangeRatesService().tryFetchRates(
    budget.currency,
  );

  final SingleCurrencyFlow<void> merged = flow.merge(budget.currency, rates);
  final double rawExpense = merged.totalExpense.amount.abs();

  return BudgetProgress(
    budget: budget,
    spent: Money(rawExpense, budget.currency),
    limit: Money(budget.amount, budget.currency),
    period: period,
  );
}
