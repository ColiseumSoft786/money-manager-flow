import "package:flow/data/exchange_rates.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:moment_dart/moment_dart.dart";

/// Aggregations for modular Home dashboard cards.
class HomeDashboardData {
  HomeDashboardData._();

  /// Cumulative net-flow totals at each day-end for the last [days] days (sparkline).
  static Future<List<double>> netWorthSparkline({int days = 14}) async {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;
    final ExchangeRates? rates =
        await ExchangeRatesService().tryFetchRates(primaryCurrency);

    final DateTime end = Moment.startOfToday().add(const Duration(days: 1));
    final DateTime start = end.subtract(Duration(days: days));

    final Query<Transaction> q = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.isDeleted
              .isNull()
              .or(Transaction_.isDeleted.notEquals(true))
              .and(
                Transaction_.isPending
                    .isNull()
                    .or(Transaction_.isPending.notEquals(true)),
              )
              .and(Transaction_.transactionDate.lessThanDate(end)),
        )
        .build();

    final Map<int, double> deltaByDay = {};
    try {
      for (final Transaction t in q.find()) {
        if (t.isTransfer) continue;
        final DateTime day = Moment(t.transactionDate).startOfDay();
        if (day.isBefore(start)) continue;
        final int key = day.millisecondsSinceEpoch;
        final SingleCurrencyFlow slice = SingleCurrencyFlow(currency: primaryCurrency)
          ..add(t.money, rates);
        if (slice.hasMissingData) continue;
        deltaByDay[key] = (deltaByDay[key] ?? 0) + slice.totalFlow.amount;
      }
    } finally {
      q.close();
    }

    double baseline = 0;
    final Query<Transaction> baselineQ = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.isDeleted
              .isNull()
              .or(Transaction_.isDeleted.notEquals(true))
              .and(
                Transaction_.isPending
                    .isNull()
                    .or(Transaction_.isPending.notEquals(true)),
              )
              .and(
                Transaction_.transactionDate.lessThanDate(start),
              ),
        )
        .build();
    try {
      for (final Transaction t in baselineQ.find()) {
        if (t.isTransfer) continue;
        final SingleCurrencyFlow slice = SingleCurrencyFlow(currency: primaryCurrency)
          ..add(t.money, rates);
        if (!slice.hasMissingData) baseline += slice.totalFlow.amount;
      }
    } finally {
      baselineQ.close();
    }

    final List<double> series = [];
    double running = baseline;
    for (int i = 0; i < days; i++) {
      final DateTime day = start.add(Duration(days: i));
      final int key = Moment(day).startOfDay().millisecondsSinceEpoch;
      running += deltaByDay[key] ?? 0;
      series.add(running);
    }
    return series;
  }

  /// Pending or future-dated postings due soon.
  static List<Transaction> upcomingBills({
    int limit = 3,
    int horizonDays = 14,
  }) {
    final DateTime now = Moment.now().startOfNextMinute();
    final DateTime horizon = now.add(Duration(days: horizonDays));

    final Query<Transaction> q = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.isDeleted
              .isNull()
              .or(Transaction_.isDeleted.notEquals(true)),
        )
        .order(Transaction_.transactionDate)
        .build();

    try {
      return q
          .find()
          .where((t) {
            if (t.isTransfer) return false;
            final bool pending = t.isPending == true;
            final bool future = t.transactionDate.isAfter(now);
            if (!pending && !future) return false;
            if (t.transactionDate.isAfter(horizon)) return false;
            return true;
          })
          .take(limit)
          .toList();
    } finally {
      q.close();
    }
  }

  /// Distinct non-primary currencies used in accounts (for FX snapshot).
  static List<String> snapshotCurrencies({int max = 3}) {
    final String primary = UserPreferencesService().primaryCurrency;
    final Set<String> codes = {};
    for (final Account account in ObjectBox().box<Account>().getAll()) {
      if (account.currency != primary) codes.add(account.currency);
    }
    final List<String> sorted = codes.toList()..sort();
    return sorted.take(max).toList();
  }
}
