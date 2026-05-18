import "package:flow/l10n/extensions.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/widgets/home/stats/stats_daily_expense_chart.dart";
import "package:flutter/material.dart";

class StatsDailyTrendsCard extends StatelessWidget {
  final IntervalFlowReport report;

  const StatsDailyTrendsCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: StatsTheme.cardFill,
        borderRadius: BorderRadius.circular(StatsTheme.cardRadius),
        border: Border.all(color: StatsTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "tabs.stats.dailyTrends".t(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: StatsTheme.titleInk,
                    ),
                  ),
                ),
                Text(
                  "tabs.stats.viewDetails".t(context),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: StatsTheme.primary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            StatsDailyExpenseChart(
              key: ValueKey(
                "${report.rangeData.range.encodeShort()}-${report.rangeData.transactions.length}-${report.primaryCurrency}",
              ),
              report: report,
            ),
          ],
        ),
      ),
    );
  }
}
