import "dart:math" as math;
import "dart:ui" as ui;

import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_accent_colors.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Income / Expense summary row on the Home dashboard.
class HomeIncomeExpenseSummary extends StatefulWidget {
  final Money income;
  final Money expense;
  final Money? previousIncome;
  final Money? previousExpense;
  final List<double>? incomeSeries;
  final List<double>? expenseSeries;

  const HomeIncomeExpenseSummary({
    super.key,
    required this.income,
    required this.expense,
    this.previousIncome,
    this.previousExpense,
    this.incomeSeries,
    this.expenseSeries,
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final FlowAccentColors accent = context.flowAccent;
    final Color incomeAccent = accent.primary;
    final Color expenseAccent = _expenseAccent(scheme);

    return Row(
      key: ValueKey(_abbreviate),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetricChip(
            accent: incomeAccent,
            label: TransactionType.income.localizedNameContext(context),
            headerIcon: Symbols.attach_money_rounded,
            isExpense: false,
            trend: Trend.fromMoney(
              current: widget.income,
              previous: widget.previousIncome,
            ),
            showTrend: widget.previousIncome != null,
            current: widget.income,
            previous: widget.previousIncome,
            series: widget.incomeSeries,
            child: SizedBox(
              height: MediaQuery.textScalerOf(context).scale(30.0),
              width: double.infinity,
              child: MoneyText(
                widget.income,
                initiallyAbbreviated: _abbreviate,
                autoSize: true,
                autoSizeGroup: _amountGroup,
                maxLines: 1,
                style: _amountStyle(context),
                onTap: _toggleAbbreviation,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _MetricChip(
            accent: expenseAccent,
            label: TransactionType.expense.localizedNameContext(context),
            headerIcon: Symbols.credit_card_rounded,
            isExpense: true,
            trend: Trend.fromMoney(
              current: widget.expense,
              previous: widget.previousExpense,
            ),
            showTrend: widget.previousExpense != null,
            current: widget.expense,
            previous: widget.previousExpense,
            series: widget.expenseSeries,
            child: SizedBox(
              height: MediaQuery.textScalerOf(context).scale(30.0),
              width: double.infinity,
              child: MoneyText(
                widget.expense,
                displayAbsoluteAmount: true,
                initiallyAbbreviated: _abbreviate,
                autoSize: true,
                autoSizeGroup: _amountGroup,
                maxLines: 1,
                style: _amountStyle(context),
                onTap: _toggleAbbreviation,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _expenseAccent(ColorScheme scheme) {
    if (scheme.secondary != scheme.primary) return scheme.secondary;
    return Color.lerp(scheme.primary, scheme.tertiary, 0.55) ?? scheme.tertiary;
  }

  TextStyle _amountStyle(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          height: 1.0,
          letterSpacing: -0.4,
          fontSize: 22.0,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          height: 1.0,
          fontSize: 22.0,
        );
  }
}

/// Loads previous-period totals for [timeRange] and builds [HomeIncomeExpenseSummary].
class HomeIncomeExpenseSummaryLoader extends StatefulWidget {
  final Money income;
  final Money expense;
  final TimeRange? timeRange;
  final String primaryCurrency;
  final ExchangeRates? rates;
  final DateTime now;

  const HomeIncomeExpenseSummaryLoader({
    super.key,
    required this.income,
    required this.expense,
    required this.timeRange,
    required this.primaryCurrency,
    required this.rates,
    required this.now,
  });

  @override
  State<HomeIncomeExpenseSummaryLoader> createState() =>
      _HomeIncomeExpenseSummaryLoaderState();
}

class _HomeIncomeExpenseSummaryLoaderState
    extends State<HomeIncomeExpenseSummaryLoader> {
  Money? _previousIncome;
  Money? _previousExpense;
  List<double>? _incomeSeries;
  List<double>? _expenseSeries;
  Object? _loadKey;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant HomeIncomeExpenseSummaryLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Object key = (
      widget.timeRange?.encodeShort(),
      widget.primaryCurrency,
      widget.rates,
    );
    if (key != _loadKey) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    _loadKey = (
      widget.timeRange?.encodeShort(),
      widget.primaryCurrency,
      widget.rates,
    );
    _loadPrevious();
    _loadSeries();
  }

  Future<void> _loadPrevious() async {
    final TimeRange? range = widget.timeRange;
    if (range is! PageableRange) {
      if (mounted) {
        setState(() {
          _previousIncome = null;
          _previousExpense = null;
        });
      }
      return;
    }

    final TimeRange previousRange = range.last;
    final List<Transaction> transactions = await ObjectBox()
        .transcationsByRange(previousRange, includeTransfers: false);

    final SingleCurrencyFlow flow = SingleCurrencyFlow(
      currency: widget.primaryCurrency,
    )..addAll(
        transactions
            .where(
              (transaction) =>
                  !transaction.transactionDate.isAfter(widget.now),
            )
            .map((transaction) => transaction.money),
        widget.rates,
      );

    if (!mounted) return;
    setState(() {
      _previousIncome = flow.totalIncome;
      _previousExpense = flow.totalExpense;
    });
  }

  Future<void> _loadSeries() async {
    final TimeRange? range = widget.timeRange;
    if (range == null) {
      if (mounted) {
        setState(() {
          _incomeSeries = null;
          _expenseSeries = null;
        });
      }
      return;
    }

    final List<Transaction> transactions = await ObjectBox()
        .transcationsByRange(range, includeTransfers: false);

    final int days = math.max(1, range.duration.inDays);
    final List<double> dailyIncome = List.filled(days, 0);
    final List<double> dailyExpense = List.filled(days, 0);
    final DateTime rangeStart = Moment(range.from).startOfDay();

    for (final Transaction transaction in transactions) {
      if (transaction.transactionDate.isAfter(widget.now)) continue;

      final int offset = Moment(transaction.transactionDate)
          .startOfDay()
          .difference(rangeStart)
          .inDays;
      if (offset < 0 || offset >= days) continue;

      final SingleCurrencyFlow slice = SingleCurrencyFlow(
        currency: widget.primaryCurrency,
      )..add(transaction.money, widget.rates);
      if (slice.hasMissingData) continue;

      dailyIncome[offset] += slice.totalIncome.amount;
      dailyExpense[offset] += slice.totalExpense.amount.abs();
    }

    double incomeRunning = 0;
    double expenseRunning = 0;
    final List<double> incomeSeries = <double>[];
    final List<double> expenseSeries = <double>[];
    for (int i = 0; i < days; i++) {
      incomeRunning += dailyIncome[i];
      expenseRunning += dailyExpense[i];
      incomeSeries.add(incomeRunning);
      expenseSeries.add(expenseRunning);
    }

    if (incomeSeries.length == 1) {
      incomeSeries.insert(0, 0);
      expenseSeries.insert(0, 0);
    }

    if (!mounted) return;
    setState(() {
      _incomeSeries = incomeSeries;
      _expenseSeries = expenseSeries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeIncomeExpenseSummary(
      income: widget.income,
      expense: widget.expense,
      previousIncome: _previousIncome,
      previousExpense: _previousExpense,
      incomeSeries: _incomeSeries,
      expenseSeries: _expenseSeries,
    );
  }
}

class _MetricChip extends StatelessWidget {
  final Color accent;
  final String label;
  final IconData headerIcon;
  final bool isExpense;
  final Trend trend;
  final bool showTrend;
  final Money current;
  final Money? previous;
  final List<double>? series;
  final Widget child;

  const _MetricChip({
    required this.accent,
    required this.label,
    required this.headerIcon,
    required this.isExpense,
    required this.trend,
    required this.showTrend,
    required this.current,
    required this.previous,
    required this.series,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool light = scheme.brightness == Brightness.light;
    final Color iconInk = light ? accent : GlassPanel.accentInk(context);
    final String upperLabel = label.toUpperCase();

    return GlassPanel(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      blurBehind: true,
      tint: light ? accent : null,
      borderColor: GlassPanel.resolveProminentBorder(context),
      padding: const EdgeInsetsDirectional.fromSTEB(14.0, 12.0, 14.0, 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: light ? 0.14 : 0.2),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: accent.withValues(alpha: light ? 0.22 : 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(headerIcon, color: iconInk, size: 15.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  upperLabel,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: GlassPanel.mutedInk(context),
                    height: 1.0,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showTrend) _HeaderTrendArrow(trend: trend, isExpense: isExpense),
            ],
          ),
          const SizedBox(height: 10.0),
          _MetricSparkline(
            data: series ?? const <double>[0, 0],
            color: iconInk,
          ),
          const SizedBox(height: 12.0),
          Text(
            upperLabel,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: GlassPanel.mutedInk(context),
              height: 1.0,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),
          child,
          if (showTrend && previous != null) ...[
            const SizedBox(height: 8.0),
            _MetricTrendFooter(
              trend: trend,
              current: current,
              previous: previous!,
              isExpense: isExpense,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderTrendArrow extends StatelessWidget {
  final Trend trend;
  final bool isExpense;

  const _HeaderTrendArrow({required this.trend, required this.isExpense});

  @override
  Widget build(BuildContext context) {
    final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;
    final bool arrowUp = switch ((isExpense, trend.delta.isNegative)) {
      (true, true) => changeVisuals.expenseIncreaseUpArrow,
      (true, false) => !changeVisuals.expenseIncreaseUpArrow,
      (false, true) => !changeVisuals.incomeIncreaseUpArrow,
      (false, false) => changeVisuals.incomeIncreaseUpArrow,
    };

    final Color color = _trendColor(context, isExpense: isExpense, delta: trend.delta);

    return Icon(
      arrowUp ? Symbols.arrow_upward_rounded : Symbols.arrow_downward_rounded,
      size: 18.0,
      color: color,
    );
  }
}

class _MetricTrendFooter extends StatelessWidget {
  final Trend trend;
  final Money current;
  final Money previous;
  final bool isExpense;

  const _MetricTrendFooter({
    required this.trend,
    required this.current,
    required this.previous,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _trendColor(context, isExpense: isExpense, delta: trend.delta);
    final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;
    final bool arrowUp = switch ((isExpense, trend.delta.isNegative)) {
      (true, true) => changeVisuals.expenseIncreaseUpArrow,
      (true, false) => !changeVisuals.expenseIncreaseUpArrow,
      (false, true) => !changeVisuals.incomeIncreaseUpArrow,
      (false, false) => changeVisuals.incomeIncreaseUpArrow,
    };

    final Money deltaMoney = (current - previous).abs();
    final String percent = "${(trend.delta.abs() * 100).toStringAsFixed(1)}%";
    final TextStyle style = context.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 11.0,
      color: color,
      height: 1.0,
    );

    return Row(
      children: [
        Icon(
          arrowUp ? Symbols.arrow_upward_rounded : Symbols.arrow_downward_rounded,
          size: 14.0,
          color: color,
        ),
        const SizedBox(width: 4.0),
        MoneyText(
          deltaMoney,
          displayAbsoluteAmount: true,
          initiallyAbbreviated: true,
          tapToToggleAbbreviation: false,
          style: style,
        ),
        const SizedBox(width: 4.0),
        Text("($percent)", style: style),
      ],
    );
  }
}

Color _trendColor(
  BuildContext context, {
  required bool isExpense,
  required double delta,
}) {
  final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;

  return switch ((isExpense, delta.isNegative)) {
    (true, true) =>
      changeVisuals.expenseIncreaseRed
          ? context.flowColors.expense
          : context.flowColors.income,
    (true, false) =>
      changeVisuals.expenseIncreaseRed
          ? context.flowColors.income
          : context.flowColors.expense,
    (false, true) =>
      changeVisuals.incomeIncreaseGreen
          ? context.flowColors.expense
          : context.flowColors.income,
    (false, false) =>
      changeVisuals.incomeIncreaseGreen
          ? context.flowColors.income
          : context.flowColors.expense,
  };
}

class _MetricSparkline extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _MetricSparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.0,
      width: double.infinity,
      child: CustomPaint(
        painter: _MetricSparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _MetricSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _MetricSparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final List<double> values = data.length == 1 ? <double>[data.first, data.first] : data;

    final double minY = values.reduce(math.min);
    final double maxY = values.reduce(math.max);
    final double range = (maxY - minY).abs();
    final double pad = range * 0.12 + (range == 0 ? 1 : 0);
    final double lo = minY - pad;
    final double hi = maxY + pad;
    final double span = hi - lo;

    final List<Offset> points = List.generate(values.length, (int i) {
      final double x = values.length == 1 ? 0 : i / (values.length - 1) * size.width;
      final double normalized = span == 0 ? 0.5 : (values[i] - lo) / span;
      final double y = size.height - normalized * size.height;
      return Offset(x, y);
    });

    final Path linePath = _smoothPath(points);
    final Path fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          color.withValues(alpha: 0.32),
          color.withValues(alpha: 0.04),
          color.withValues(alpha: 0.0),
        ],
        <double>[0.0, 0.55, 1.0],
      );
    canvas.drawPath(fillPath, fillPaint);

    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(linePath, glowPaint);

    final Paint linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);
  }

  Path _smoothPath(List<Offset> points) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length < 2) return path;

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];
      final double controlX = (current.dx + next.dx) / 2;
      path.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _MetricSparklinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.data != data;
  }
}
