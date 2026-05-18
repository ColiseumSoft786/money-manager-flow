import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction/type.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pastel Income / Expense summary row (Home tab, under Total balance).
class HomeIncomeExpenseSummary extends StatefulWidget {
  final Money income;
  final Money expense;

  const HomeIncomeExpenseSummary({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  State<HomeIncomeExpenseSummary> createState() =>
      _HomeIncomeExpenseSummaryState();
}

class _HomeIncomeExpenseSummaryState extends State<HomeIncomeExpenseSummary> {
  final AutoSizeGroup _amountGroup = AutoSizeGroup();

  late bool _abbreviate;

  @override
  void initState() {
    super.initState();
    _abbreviate = !LocalPreferences().preferFullAmounts.get();
    LocalPreferences().preferFullAmounts.addListener(_onPreferFullAmounts);
  }

  @override
  void dispose() {
    LocalPreferences().preferFullAmounts.removeListener(_onPreferFullAmounts);
    super.dispose();
  }

  void _onPreferFullAmounts() {
    _abbreviate = !LocalPreferences().preferFullAmounts.get();
    if (mounted) setState(() {});
  }

  void _toggleAbbreviation() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }
    setState(() => _abbreviate = !_abbreviate);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle amountStyle =
        context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurface,
          height: 1.05,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurface,
          height: 1.05,
        );

    return Row(
      key: ValueKey(_abbreviate),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetricChip(
            background: _metricFillLight(
              Theme.of(context).brightness,
              kFlowHomeIncomeMetricFill,
              kFlowHomeIncomeMetricFillDark,
            ),
            accent: kFlowHomeIncomeMetricAccent,
            label: TransactionType.income.localizedNameContext(context),
            trendingIcon: Symbols.trending_up_rounded,
            child: SizedBox(
              height: MediaQuery.textScalerOf(context).scale(40.0),
              width: double.infinity,
              child: MoneyText(
                widget.income,
                initiallyAbbreviated: _abbreviate,
                autoSize: true,
                autoSizeGroup: _amountGroup,
                maxLines: 1,
                style: amountStyle,
                onTap: _toggleAbbreviation,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _MetricChip(
            background: _metricFillLight(
              Theme.of(context).brightness,
              kFlowHomeExpenseMetricFill,
              kFlowHomeExpenseMetricFillDark,
            ),
            accent: kFlowHomeExpenseMetricAccent,
            label: TransactionType.expense.localizedNameContext(context),
            trendingIcon: Symbols.trending_down_rounded,
            child: SizedBox(
              height: MediaQuery.textScalerOf(context).scale(40.0),
              width: double.infinity,
              child: MoneyText(
                widget.expense,
                displayAbsoluteAmount: true,
                initiallyAbbreviated: _abbreviate,
                autoSize: true,
                autoSizeGroup: _amountGroup,
                maxLines: 1,
                style: amountStyle,
                onTap: _toggleAbbreviation,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _metricFillLight(
    Brightness brightness,
    Color light,
    Color dark,
  ) => brightness == Brightness.light ? light : dark;
}

class _MetricChip extends StatelessWidget {
  final Color background;
  final Color accent;
  final String label;
  final IconData trendingIcon;
  final Widget child;

  const _MetricChip({
    required this.background,
    required this.accent,
    required this.label,
    required this.trendingIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trendingIcon,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.6,
                      height: 1.05,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            child,
          ],
        ),
      ),
    );
  }
}
