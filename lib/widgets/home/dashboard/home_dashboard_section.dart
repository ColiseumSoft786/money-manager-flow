import "package:flow/data/exchange_rates.dart";
import "package:flow/data/home_dashboard_widget_id.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/home_dashboard_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/home/dashboard/home_dashboard_widgets.dart";
import "package:flow/widgets/home/home_income_expense_summary.dart";
import "package:flow/widgets/home/home_total_balance_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Modular Home dashboard: ordered cards from [HomeDashboardPreferences].
class HomeDashboardSection extends StatelessWidget {
  final Money income;
  final Money expense;
  final TimeRange? timeRange;
  final String primaryCurrency;
  final ExchangeRates? rates;
  final DateTime now;

  const HomeDashboardSection({
    super.key,
    required this.income,
    required this.expense,
    required this.timeRange,
    required this.primaryCurrency,
    required this.rates,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeDashboardPreferences.revision,
      builder: (context, _, _) {
        final List<HomeDashboardWidgetId> order =
            HomeDashboardPreferences.visibleOrder;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => context.push("/preferences/homeDashboard"),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(
                  Symbols.dashboard_customize_rounded,
                  size: 18.0,
                  color: context.colorScheme.primary,
                ),
                label: Text(
                  "home.dashboard.customize".t(context),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            for (final HomeDashboardWidgetId id in order) ...[
              _buildCard(context, id),
              if (id != order.last) const SizedBox(height: 16.0),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, HomeDashboardWidgetId id) {
    switch (id) {
      case HomeDashboardWidgetId.totalBalance:
        return const HomeTotalBalanceCard();
      case HomeDashboardWidgetId.incomeExpense:
        return HomeIncomeExpenseSummaryLoader(
          income: income,
          expense: expense,
          timeRange: timeRange,
          primaryCurrency: primaryCurrency,
          rates: rates,
          now: now,
        );
      case HomeDashboardWidgetId.netWorthSparkline:
        return const HomeNetWorthSparklineCard();
      case HomeDashboardWidgetId.budgetProgress:
        return const HomeBudgetProgressCard();
      case HomeDashboardWidgetId.topCategory:
        return const HomeTopCategoryCard();
      case HomeDashboardWidgetId.goalProgress:
        return const HomeGoalProgressCard();
      case HomeDashboardWidgetId.upcomingBills:
        return const HomeUpcomingBillsCard();
      case HomeDashboardWidgetId.exchangeRates:
        return const HomeExchangeRatesCard();
    }
  }
}
