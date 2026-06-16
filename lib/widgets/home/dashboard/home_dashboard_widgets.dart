import "package:fl_chart/fl_chart.dart";
import "package:flow/data/budgetProgress.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/goalProgress.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/goal.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/providers/budget_provider.dart";
import "package:flow/providers/goal_provider.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/home_dashboard_data.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/budget_progressring.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/dashboard/home_dashboard_card_shell.dart";
import "package:flow/widgets/home/stats/most_spending_category.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class HomeNetWorthSparklineCard extends StatefulWidget {
  const HomeNetWorthSparklineCard({super.key});

  @override
  State<HomeNetWorthSparklineCard> createState() =>
      _HomeNetWorthSparklineCardState();
}

class _HomeNetWorthSparklineCardState extends State<HomeNetWorthSparklineCard> {
  List<double>? _series;
  int _reloadGeneration = 0;

  @override
  void initState() {
    super.initState();
    TransactionsService().addListener(_reload);
    ExchangeRatesService().exchangeRatesCache.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_reload);
    ExchangeRatesService().exchangeRatesCache.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    final int generation = ++_reloadGeneration;
    HomeDashboardData.netWorthSparkline().then((data) {
      if (!mounted || generation != _reloadGeneration) return;
      setState(() => _series = data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<double>? series = _series;
    if (series == null || series.isEmpty) {
      return HomeDashboardCardShell(
        titleKey: "home.dashboard.widget.netWorthSparkline.title",
        child: const SizedBox(
          height: 48.0,
          child: Center(child: Spinner()),
        ),
      );
    }

    final double minY = series.reduce((a, b) => a < b ? a : b);
    final double maxY = series.reduce((a, b) => a > b ? a : b);
    final double pad = (maxY - minY).abs() * 0.1 + 1;
    final Color line = context.colorScheme.primary;

    return HomeDashboardCardShell(
      titleKey: "home.dashboard.widget.netWorthSparkline.title",
      onTap: () => context.push(
        "/stats/category?range=${Uri.encodeQueryComponent(TimeRange.thisMonth().encodeShort())}",
      ),
      child: SizedBox(
        height: 52.0,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (series.length - 1).toDouble(),
            minY: minY - pad,
            maxY: maxY + pad,
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < series.length; i++)
                    FlSpot(i.toDouble(), series[i]),
                ],
                isCurved: true,
                color: line,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: line.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeBudgetProgressCard extends StatefulWidget {
  const HomeBudgetProgressCard({super.key});

  @override
  State<HomeBudgetProgressCard> createState() => _HomeBudgetProgressCardState();
}

class _HomeBudgetProgressCardState extends State<HomeBudgetProgressCard> {
  BudgetProgress? _top;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    TransactionsService().addListener(_load);
    ExchangeRatesService().exchangeRatesCache.addListener(_load);
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_load);
    ExchangeRatesService().exchangeRatesCache.removeListener(_load);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  void _load() {
    final int generation = ++_loadGeneration;
    _loadAsync(generation);
  }

  Future<void> _loadAsync(int generation) async {
    if (!mounted) return;

    final List<Budget> budgets = BudgetsProvider.of(context).budgets;
    if (budgets.isEmpty) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _top = null);
      }
      return;
    }

    final List<BudgetProgress> all = await Future.wait(
      budgets.map(computeBudgetProgress),
    );
    all.sort((a, b) => b.fraction.compareTo(a.fraction));

    if (!mounted || generation != _loadGeneration) return;
    setState(() => _top = all.first);
  }

  @override
  Widget build(BuildContext context) {
    final BudgetProgress? progress = _top;
    if (progress == null) return const SizedBox.shrink();

    return HomeDashboardCardShell(
      titleKey: "home.dashboard.widget.budgetProgress.title",
      onTap: () => context.push("/budgets"),
      child: Row(
        children: [
          BudgetProgressRing(progress: progress, size: 52),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.budget.name,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                MoneyText(
                  progress.spent,
                  style: context.textTheme.bodyMedium,
                  autoSize: true,
                ),
                Text(
                  "${progress.spent.formatMoney(compact: true)} / ${progress.limit.formatMoney(compact: true)}",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTopCategoryCard extends StatelessWidget {
  const HomeTopCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MostSpendingCategory(range: TimeRange.thisMonth());
  }
}

class HomeGoalProgressCard extends StatefulWidget {
  const HomeGoalProgressCard({super.key});

  @override
  State<HomeGoalProgressCard> createState() => _HomeGoalProgressCardState();
}

class _HomeGoalProgressCardState extends State<HomeGoalProgressCard> {
  GoalProgress? _lead;

  @override
  void initState() {
    super.initState();
    TransactionsService().addListener(_reload);
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_reload);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  void _reload() {
    if (!mounted) return;

    final List<Goal> goals = GoalsProvider.of(context).goals;
    if (goals.isEmpty) {
      setState(() => _lead = null);
      return;
    }

    final List<GoalProgress> list = goals.map(computeGoalProgress).toList();
    list.sort((a, b) => b.fraction.compareTo(a.fraction));
    setState(() => _lead = list.first);
  }

  @override
  Widget build(BuildContext context) {
    final GoalProgress? progress = _lead;
    if (progress == null) return const SizedBox.shrink();

    return HomeDashboardCardShell(
      titleKey: "home.dashboard.widget.goalProgress.title",
      onTap: () => context.push("/goals"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.goal.name,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${progress.displayPercentRounded}%",
                style: context.textTheme.labelLarge?.semi(context),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress.displayFraction,
              minHeight: 8.0,
            ),
          ),
          const SizedBox(height: 6.0),
          MoneyText(
            progress.saved,
            style: context.textTheme.bodySmall,
            autoSize: true,
          ),
        ],
      ),
    );
  }
}

class HomeUpcomingBillsCard extends StatefulWidget {
  const HomeUpcomingBillsCard({super.key});

  @override
  State<HomeUpcomingBillsCard> createState() => _HomeUpcomingBillsCardState();
}

class _HomeUpcomingBillsCardState extends State<HomeUpcomingBillsCard> {
  @override
  void initState() {
    super.initState();
    TransactionsService().addListener(_refresh);
    _refresh();
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final List<Transaction> bills = HomeDashboardData.upcomingBills();
    if (bills.isEmpty) return const SizedBox.shrink();

    return HomeDashboardCardShell(
      titleKey: "home.dashboard.widget.upcomingBills.title",
      child: Column(
        children: [
          for (int i = 0; i < bills.length; i++) ...[
            if (i > 0) const Divider(height: 16.0),
            _UpcomingBillRow(transaction: bills[i]),
          ],
        ],
      ),
    );
  }
}

class _UpcomingBillRow extends StatelessWidget {
  final Transaction transaction;

  const _UpcomingBillRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final String date = Moment(transaction.transactionDate).format("MMM D");
    return Row(
      children: [
        if (transaction.category.target != null)
          FlowIcon(transaction.category.target!.icon, size: 28.0, plated: true)
        else
          Icon(Symbols.schedule_rounded, size: 28.0),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title ??
                    transaction.category.target?.name ??
                    "—",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                date,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        MoneyText(transaction.money, style: context.textTheme.bodyMedium),
      ],
    );
  }
}

class HomeExchangeRatesCard extends StatelessWidget {
  const HomeExchangeRatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!TransitiveLocalPreferences().usesNonPrimaryCurrency.get()) {
      return const SizedBox.shrink();
    }

    final String primary = UserPreferencesService().primaryCurrency;
    final List<String> codes = HomeDashboardData.snapshotCurrencies();
    if (codes.isEmpty) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, cache, _) {
        final ExchangeRates? rates = cache?.get(primary);
        if (rates == null) return const SizedBox.shrink();

        return HomeDashboardCardShell(
          titleKey: "home.dashboard.widget.exchangeRates.title",
          child: Column(
            children: [
              for (int i = 0; i < codes.length; i++) ...[
                if (i > 0) const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(child: Text(codes[i])),
                    Text(
                      "1 $primary = ${rates.getRate(codes[i])?.toStringAsFixed(4) ?? "—"} ${codes[i]}",
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
