import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";

class StatsNetFlowCard extends StatelessWidget {
  final Money netFlow;
  final Money? previousNetFlow;

  const StatsNetFlowCard({
    super.key,
    required this.netFlow,
    required this.previousNetFlow,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _StatsCardShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "tabs.stats.netFlow".t(context).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: StatsTheme.sectionLabel,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    fontSize: 11.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                MoneyText(
                  netFlow,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28.0,
                    color: StatsTheme.titleInk,
                  ),
                  tapToToggleAbbreviation: true,
                  initiallyAbbreviated:
                      !LocalPreferences().preferFullAmounts.get(),
                ),
              ],
            ),
          ),
          _DeltaBadge(
            trend: Trend.fromMoney(
              current: netFlow,
              previous: previousNetFlow,
            ),
          ),
        ],
      ),
    );
  }
}

class StatsIncomeExpenseRow extends StatelessWidget {
  final Money income;
  final Money expense;
  final Money? previousIncome;
  final Money? previousExpense;
  const StatsIncomeExpenseRow({
    super.key,
    required this.income,
    required this.expense,
    required this.previousIncome,
    required this.previousExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TintedMetricCard(
            label: "tabs.stats.intervalReport.averages.income".t(context)
                .toUpperCase(),
            money: income,
            fill: StatsTheme.incomeFill,
            ink: StatsTheme.incomeInk,
            trend: Trend.fromMoney(current: income, previous: previousIncome),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _TintedMetricCard(
            label: "tabs.stats.intervalReport.averages.expense".t(context)
                .toUpperCase(),
            money: expense,
            fill: StatsTheme.expenseFill,
            ink: StatsTheme.expenseInk,
            trend: Trend.fromMoney(
              current: expense,
              previous: previousExpense,
            ),
          ),
        ),
      ],
    );
  }
}

class _TintedMetricCard extends StatelessWidget {
  final String label;
  final Money money;
  final Color fill;
  final Color ink;
  final Trend trend;
  const _TintedMetricCard({
    required this.label,
    required this.money,
    required this.fill,
    required this.ink,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(StatsTheme.cardRadius),
        border: Border.all(color: StatsTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontSize: 11.0,
              ),
            ),
            const SizedBox(height: 6.0),
            MoneyText(
              money,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
                color: StatsTheme.titleInk,
              ),
              tapToToggleAbbreviation: true,
              initiallyAbbreviated: !LocalPreferences().preferFullAmounts.get(),
            ),
            const SizedBox(height: 6.0),
            DefaultTextStyle(
              style: theme.textTheme.bodySmall!.copyWith(
                color: ink,
                fontSize: 11.5,
              ),
              child: trend,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  final Trend trend;

  const _DeltaBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
          ),
          child: trend,
        ),
      ),
    );
  }
}

class _StatsCardShell extends StatelessWidget {
  final Widget child;

  const _StatsCardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StatsTheme.cardFill,
        borderRadius: BorderRadius.circular(StatsTheme.cardRadius),
        border: Border.all(color: StatsTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

/// Convenience builder using [IntervalFlowReport] totals (same data as before).
class StatsSummarySection extends StatelessWidget {
  final IntervalFlowReport report;
  final IntervalFlowReport? previousReport;

  /// When set (e.g. forecast for current month), shown in the expense card only.
  final Money? expenseOverride;

  const StatsSummarySection({
    super.key,
    required this.report,
    this.previousReport,
    this.expenseOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatsNetFlowCard(
          netFlow: report.totalFlow,
          previousNetFlow: previousReport?.totalFlow,
        ),
        const SizedBox(height: 12.0),
        StatsIncomeExpenseRow(
          income: report.totalIncome,
          expense: expenseOverride ?? report.totalExpense,
          previousIncome: previousReport?.totalIncome,
          previousExpense: previousReport?.totalExpense,
        ),
      ],
    );
  }
}
