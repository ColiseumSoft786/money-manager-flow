import "package:flow/data/exchange_rates.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/reports/range_forecast_report.dart";
import "package:flow/reports/report.dart";
import "package:flow/reports/trends_report.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/blur_backgorund.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flow/widgets/home/stats/stats_daily_trends_card.dart";
import "package:flow/widgets/home/stats/stats_summary_cards.dart";
import "package:flow/widgets/home/stats/stats_tab_header.dart";
import "package:flow/widgets/home/stats/stats_top_categories_list.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StatsTab({super.key, this.onBackToHome});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();

  List<Transaction> transactions = [];

  RangeForecastReport? rangeForecastReport;
  IntervalFlowReport? intervalFlowReport;
  IntervalFlowReport? previousIntervalFlowReport;
  TrendsReport? trendsReport;

  bool busy = false;

  ExchangeRates? rates;

  @override
  void initState() {
    super.initState();

    fetch();

    rates = ExchangeRatesService().getPrimaryCurrencyRates();
    ExchangeRatesService().exchangeRatesCache.addListener(_updateRates);
  }

  @override
  void dispose() {
    ExchangeRatesService().exchangeRatesCache.removeListener(_updateRates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (busy && intervalFlowReport == null) {
      return const ColoredBox(
        color: StatsTheme.canvas,
        child: Spinner.center(),
      );
    }

    final bool hasData =
        intervalFlowReport != null && intervalFlowReport!.data.isNotEmpty;

    final bool showForecast =
        intervalFlowReport?.rangeData.range.contains(DateTime.now()) == true &&
        rangeForecastReport != null;

    final bool showMissingExchangeRatesWarning =
        rates == null &&
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

    return ColoredBox(
      color: StatsTheme.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              child: StatsTabHeader(
                range: range,
                onRangeChanged: updateRange,
                onBack: widget.onBackToHome,
              ),
            ),
          ),
          if (showMissingExchangeRatesWarning) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0),
              child: RatesMissingErrorBox(),
            ),
          ],
          Expanded(
            child: hasData
                ? BlurBackground(
                    blur: busy,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StatsSummarySection(
                            report: intervalFlowReport!,
                            previousReport: previousIntervalFlowReport,
                            expenseOverride: showForecast
                                ? rangeForecastReport!.forecast.totalExpense
                                : null,
                          ),
                          const SizedBox(height: 16.0),
                          StatsDailyTrendsCard(report: intervalFlowReport!),
                          const SizedBox(height: 16.0),
                          StatsTopCategoriesList(range: range),
                          const SizedBox(height: 8.0),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: () => context.push(
                                "/stats/category?range=${Uri.encodeQueryComponent(range.encodeShort())}",
                              ),
                              label: Text(
                                "tabs.stats.categories.seeAll".t(context),
                              ),
                              icon: const LeChevron(),
                              iconAlignment: IconAlignment.end,
                              style: TextButton.styleFrom(
                                foregroundColor: StatsTheme.primary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SafeArea(
                    child: NoData(
                      selectTimeRange: () => updateRange(TimeRange.thisMonth()),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void updateRange(TimeRange value) {
    range = value;
    fetch();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> fetch() async {
    setState(() {
      busy = true;
    });

    try {
      final String primaryCurrency = UserPreferencesService().primaryCurrency;

      transactions = await ObjectBox().transcationsByRange(
        range,
        includeTransfers: false,
      );

      final TimeRange? previousRange = range is PageableRange
          ? (range as PageableRange).last
          : null;

      final List<Transaction>? previousRangeTransactions = previousRange != null
          ? await ObjectBox().transcationsByRange(
              previousRange,
              includeTransfers: false,
            )
          : null;

      final RangeData currentRangeData = RangeData(
        range: range,
        transactions: transactions,
      );
      final RangeData previousRangeData = previousRange != null
          ? RangeData(
              range: previousRange,
              transactions: previousRangeTransactions ?? [],
            )
          : RangeData(
              range: CustomTimeRange(
                range.from - range.duration,
                range.to - range.duration,
              ),
              transactions: [],
            );

      rangeForecastReport =
          (previousRange != null && previousRangeData.transactions.isNotEmpty)
          ? RangeForecastReport(
              rates: rates,
              primaryCurrency: primaryCurrency,
              previousRangeData: previousRangeData,
              currentRangeData: currentRangeData,
            )
          : null;

      final Duration interval = RangeData.getOptimalInterval(range);

      intervalFlowReport = IntervalFlowReport(
        interval: interval,
        rangeData: currentRangeData,
        rates: rates,
        primaryCurrency: primaryCurrency,
      );
      previousIntervalFlowReport = previousRange != null
          ? IntervalFlowReport(
              interval: interval,
              rangeData: previousRangeData,
              rates: rates,
              primaryCurrency: primaryCurrency,
            )
          : null;
      trendsReport = TrendsReport(
        rates: rates,
        primaryCurrency: primaryCurrency,
        transactions: transactions,
      );
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateRates() {
    rates = ExchangeRatesService().getPrimaryCurrencyRates();
    fetch();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
