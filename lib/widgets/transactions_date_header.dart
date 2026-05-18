import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/navigation.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListDateHeader extends StatefulWidget {
  final TimeRange range;
  final List<Transaction> transactions;

  final Widget? action;

  /// Hides count and flow
  final bool pendingGroup;

  final bool resolveNonPrimaryCurrencies;

  final Widget? titleOverride;

  const TransactionListDateHeader({
    super.key,
    required this.transactions,
    required this.range,
    this.action,
    this.titleOverride,
    this.pendingGroup = false,
    this.resolveNonPrimaryCurrencies = true,
  });
  const TransactionListDateHeader.pendingGroup({
    super.key,
    required this.range,
    this.action,
    this.titleOverride,
    this.resolveNonPrimaryCurrencies = true,
  }) : pendingGroup = true,
       transactions = const [];

  @override
  State<TransactionListDateHeader> createState() =>
      _TransactionListDateHeaderState();
}

class _TransactionListDateHeaderState extends State<TransactionListDateHeader> {
  bool obscure = false;
  bool rangeTitleAlternative = false;

  @override
  void initState() {
    super.initState();

    TransitiveLocalPreferences().sessionPrivacyMode.addListener(
      _updatePrivacyMode,
    );

    obscure = TransitiveLocalPreferences().sessionPrivacyMode.get();
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().sessionPrivacyMode.removeListener(
      _updatePrivacyMode,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget title =
        widget.titleOverride ??
        GestureDetector(
          onLongPress: _handleRangeTextLongPress,
          onTap: _handleRangeTextTap,
          child: Text(_getRangeTitle()),
        );

    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        widget.transactions
            .where((transaction) => !transaction.isTransfer)
            .map((transaction) => transaction.money),
      );

    final bool containsNonPrimaryCurrency = widget.transactions.any(
      (transaction) => transaction.currency != primaryCurrency,
    );

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRatesCache, child) {
        final ExchangeRates? rates = exchangeRatesCache?.get(primaryCurrency);
        final bool showMissingExchangeRatesWarning =
            TransitiveLocalPreferences().usesNonPrimaryCurrency.get() &&
            rates == null;

        final SingleCurrencyFlow mergedFlow = flow.merge(
          primaryCurrency,
          rates,
        );

        final String exclamation = switch ((
          containsNonPrimaryCurrency,
          mergedFlow.hasMissingData,
        )) {
          (true, true) => "~",
          (true, false) => "+",
          _ => "",
        };

        final String countLabel = "tabs.home.transactionsCount".t(
          context,
          widget.transactions.renderableCount,
        );

        final bool light = Theme.of(context).brightness == Brightness.light;

        final Color titleInk = light
            ? kFlowHomeTransactionHeadingInk
            : context.colorScheme.onSurface;

        final Color countCapsColor = light
            ? kFlowHomeTransactionCaptionMuted
            : context.colorScheme.onSurfaceVariant;

        final Color mutedFlow = showMissingExchangeRatesWarning
            ? context.colorScheme.error
            : light
            ? kFlowHomeTransactionCaptionMuted
            : context.colorScheme.onSurfaceVariant;

        final TextStyle titleStyle = context.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: titleInk,
          height: 1.15,
        );

        final Widget countCaps = Text(
          countLabel.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: countCapsColor,
            letterSpacing: 0.65,
            fontWeight: FontWeight.w600,
            fontSize:
                (context.textTheme.labelSmall?.fontSize ?? 11.0) * 0.92,
          ),
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

        final Widget flowLine = MoneyTextBuilder(
          builder: (context, formattedSum, originalSum) => Text(
            "$formattedSum$exclamation",
            style: context.textTheme.bodySmall?.copyWith(color: mutedFlow),
          ),
          money: mergedFlow.totalFlow,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(style: titleStyle, child: title),
                  const SizedBox(height: 6.0),
                  flowLine,
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                countCaps,
                if (widget.action != null) ...[
                  const SizedBox(height: 6.0),
                  widget.action!,
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  void _updatePrivacyMode() {
    obscure = TransitiveLocalPreferences().sessionPrivacyMode.get();

    if (!mounted) return;
    setState(() {});
  }

  void _handleRangeTextTap() {
    rangeTitleAlternative = !rangeTitleAlternative;

    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    setState(() {});
  }

  void _handleRangeTextLongPress() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.mediumImpact();
    }

    NavigationService().add(
      "/transaction/new?transactionDate=${widget.range.from.toIso8601String()}",
    );
  }

  String _getRangeTitle() {
    return switch ((widget.range, rangeTitleAlternative)) {
      (DayTimeRange dayTimeRange, false) =>
        dayTimeRange.from.toMoment().calendar(omitHours: true),
      (DayTimeRange dayTimeRange, true) => dayTimeRange.from.toMoment().format(
        "ll",
      ),
      (TimeRange other, _) => other.format(),
    };
  }
}
