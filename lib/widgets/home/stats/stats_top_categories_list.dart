import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/blur_backgorund.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class _CategorySpend {
  final Category? category;
  final Money amount;

  const _CategorySpend({required this.category, required this.amount});
}

class StatsTopCategoriesList extends StatefulWidget {
  final TimeRange range;
  final int limit;

  const StatsTopCategoriesList({
    super.key,
    required this.range,
    this.limit = 5,
  });

  @override
  State<StatsTopCategoriesList> createState() => _StatsTopCategoriesListState();
}

class _StatsTopCategoriesListState extends State<StatsTopCategoriesList> {
  List<_CategorySpend> items = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(StatsTopCategoriesList oldWidget) {
    if (oldWidget.range != widget.range) {
      _fetch();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _fetch() async {
    setState(() => busy = true);

    try {
      final FlowAnalytics<Category?> result = await ObjectBox().flowByCategories(
        range: widget.range,
      );
      final String primaryCurrency = UserPreferencesService().primaryCurrency;
      final ExchangeRates? rates = ExchangeRatesService()
          .getPrimaryCurrencyRates();

      final List<_CategorySpend> spends = [];

      for (final flow in result.flow.values) {
        spends.add(
          _CategorySpend(
            category: flow.associatedData,
            amount: flow.merge(primaryCurrency, rates).totalExpense,
          ),
        );
      }

      spends.sort(
        (a, b) => b.amount.amount.abs().compareTo(a.amount.amount.abs()),
      );

      items = spends.take(widget.limit).toList();
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxAmount = items.isEmpty
        ? 1.0
        : items
              .map((e) => e.amount.amount.abs())
              .reduce((a, b) => a > b ? a : b);

    return BlurBackground(
      blur: busy,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: StatsTheme.cardFill,
          borderRadius: BorderRadius.circular(StatsTheme.cardRadius),
          border: Border.all(color: StatsTheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "tabs.stats.categories".t(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: StatsTheme.titleInk,
                      ),
                    ),
                  ),
                  Text(
                    "tabs.stats.expensesOnly".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: StatsTheme.sectionLabel,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (items.isEmpty && !busy)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "tabs.stats.chart.noData".t(context),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: StatsTheme.subtitleInk,
                    ),
                  ),
                )
              else
                ...List.generate(items.length, (int index) {
                  final _CategorySpend item = items[index];
                  final double fraction =
                      item.amount.amount.abs() / maxAmount;

                  return _CategoryRow(
                    category: item.category,
                    amount: item.amount,
                    fraction: fraction,
                    range: widget.range,
                    showDivider: index < items.length - 1,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category? category;
  final Money amount;
  final double fraction;
  final TimeRange range;
  final bool showDivider;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.fraction,
    required this.range,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent =
        category?.colorScheme?.primary ?? StatsTheme.primary(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: category == null
            ? null
            : () => context.push(
                "/category/${category!.id}?range=${Uri.encodeQueryComponent(range.encodeShort())}",
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: FlowIcon(
                      category?.icon ??
                          FlowIconData.icon(Symbols.category_rounded),
                      colorScheme: category?.colorScheme,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? "category.none".t(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                            color: StatsTheme.titleInk,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: fraction.clamp(0.0, 1.0),
                            minHeight: 4.0,
                            backgroundColor: StatsTheme.chartBarMuted,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  MoneyText(
                    amount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      color: StatsTheme.titleInk,
                    ),
                    tapToToggleAbbreviation: true,
                  ),
                ],
              ),
              if (showDivider)
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: StatsTheme.divider,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
