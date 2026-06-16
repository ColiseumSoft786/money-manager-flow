import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// Daily (or monthly for year view) expense bars from [IntervalFlowReport] transactions.
class StatsDailyExpenseChart extends StatefulWidget {
  final IntervalFlowReport report;

  final double height;

  const StatsDailyExpenseChart({
    super.key,
    required this.report,
    this.height = 220.0,
  });

  @override
  State<StatsDailyExpenseChart> createState() => _StatsDailyExpenseChartState();
}

class _StatsDailyExpenseChartState extends State<StatsDailyExpenseChart> {
  int? _touchedIndex;

  @override
  void didUpdateWidget(StatsDailyExpenseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report != widget.report) {
      _touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_Bucket> buckets = _buildBuckets();
    if (buckets.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            "—",
            style: TextStyle(
              color: StatsTheme.subtitleInk(context).withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final double maxY = buckets
        .map((b) => b.amount)
        .fold<double>(0, math.max)
        .clamp(1.0, double.infinity);

    final int peakIndex = buckets.indexWhere(
      (b) => b.amount == maxY && b.amount > 0,
    );

    final int? highlightIndex =
        _touchedIndex ?? (peakIndex >= 0 ? peakIndex : null);

    final double barWidth = buckets.length > 20 ? 6.0 : 10.0;

    return SizedBox(
      height: widget.height,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.18,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: StatsTheme.divider(context),
              strokeWidth: 1.0,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(sideTitles: _bottomTitles(context, buckets)),
          ),
          barGroups: List.generate(buckets.length, (int index) {
            final bool highlighted =
                highlightIndex != null && index == highlightIndex;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: buckets[index].amount,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6.0),
                  ),
                  color: highlighted
                      ? StatsTheme.primary(context)
                      : StatsTheme.chartBarMuted(context),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.spot == null) {
                  _touchedIndex = null;
                  return;
                }
                _touchedIndex = response.spot!.touchedBarGroupIndex;
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => StatsTheme.chartTooltipFill(context),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final _Bucket bucket = buckets[groupIndex];
                final String amount = Money(
                  rod.toY,
                  widget.report.primaryCurrency,
                ).formattedCompact;
                return BarTooltipItem(
                  "${bucket.label}\n$amount",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  List<_Bucket> _buildBuckets() {
    final TimeRange range = widget.report.rangeData.range;
    final String currency = widget.report.primaryCurrency;
    final Map<DateTime, double> totals = {};

    for (final Transaction transaction
        in widget.report.rangeData.transactions) {
      if (transaction.isDeleted == true || transaction.isTransfer == true) {
        continue;
      }
      if (!range.contains(transaction.transactionDate)) continue;

      final Money? money = _expenseInPrimary(transaction, currency);
      if (money == null || money.amount >= 0) continue;

      final DateTime key = _bucketKey(transaction.transactionDate, range);
      totals[key] = (totals[key] ?? 0) + money.amount.abs();
    }

    if (range is YearTimeRange) {
      return _monthlyBuckets(range, totals);
    }

    return _dailyBuckets(range, totals);
  }

  DateTime _bucketKey(DateTime date, TimeRange range) {
    if (range is YearTimeRange) {
      return DateTime(date.year, date.month);
    }
    return date.startOfDay();
  }

  List<_Bucket> _dailyBuckets(TimeRange range, Map<DateTime, double> totals) {
    final List<_Bucket> buckets = [];
    DateTime cursor = range.from.startOfDay();
    final DateTime end = range.to.startOfDay();

    while (!cursor.isAfter(end)) {
      buckets.add(
        _Bucket(
          date: cursor,
          amount: totals[cursor] ?? 0,
          label: cursor.toMoment().format("D MMM"),
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return buckets;
  }

  List<_Bucket> _monthlyBuckets(
    YearTimeRange range,
    Map<DateTime, double> totals,
  ) {
    final List<_Bucket> buckets = [];
    for (int month = 1; month <= 12; month++) {
      final DateTime key = DateTime(range.year, month);
      buckets.add(
        _Bucket(
          date: key,
          amount: totals[key] ?? 0,
          label: key.toMoment().format("MMM"),
        ),
      );
    }
    return buckets;
  }

  Money? _expenseInPrimary(Transaction transaction, String currency) {
    if (transaction.currency == currency) {
      return transaction.money;
    }
    final ExchangeRates? rates = widget.report.rates;
    if (rates == null) return null;
    try {
      return transaction.money.convert(currency, rates);
    } catch (_) {
      return null;
    }
  }

  SideTitles _bottomTitles(BuildContext context, List<_Bucket> buckets) {
    final int count = buckets.length;
    if (count == 0) return const SideTitles(showTitles: false);

    final int stride = count <= 5
        ? 1
        : math.max((count / 4).floor(), 1);

    return SideTitles(
      showTitles: true,
      reservedSize: 30.0,
      getTitlesWidget: (value, meta) {
        final int index = value.toInt();
        if (index < 0 || index >= count) return const SizedBox.shrink();
        if (index % stride != 0 && index != count - 1) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            buckets[index].label,
            style: TextStyle(
              color: StatsTheme.subtitleInk(context),
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

class _Bucket {
  final DateTime date;
  final double amount;
  final String label;

  const _Bucket({
    required this.date,
    required this.amount,
    required this.label,
  });
}
