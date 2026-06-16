import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/navigation.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flow/widgets/home/home_transaction_cards_scope.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListDateHeader extends StatefulWidget {
  final TimeRange range;
  final List<Transaction> transactions;
  final Widget? action;
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
  bool rangeTitleAlternative = false;

  @override
  Widget build(BuildContext context) {
    final bool onHomeGlass = HomeTransactionCardsScope.enabledIn(context);

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRatesCache, child) {
        final Widget body = _buildBody(context, exchangeRatesCache);

        if (!onHomeGlass) return body;

        final Color accent = context.flowAccent.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: accent.withValues(alpha: 0.55),
                  width: 3.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: body,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, dynamic exchangeRatesCache) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        widget.transactions
            .where((transaction) => !transaction.isTransfer)
            .map((transaction) => transaction.money),
      );

    final bool containsNonPrimary = widget.transactions.any(
      (transaction) => transaction.currency != primaryCurrency,
    );

    final rates = exchangeRatesCache?.get(primaryCurrency);
    final bool showMissingWarning =
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get() &&
        rates == null;

    final SingleCurrencyFlow mergedFlow = flow.merge(primaryCurrency, rates);
    final String exclamation = switch ((
      containsNonPrimary,
      mergedFlow.hasMissingData,
    )) {
      (true, true) => "~",
      (true, false) => "+",
      _ => "",
    };

    // final int count = widget.transactions.renderableCount;
    // final String countLabel = "tabs.home.transactionsCount".t(context, count);
    final bool isPositive = mergedFlow.totalFlow.amount >= 0;
    final Color flowColor = isPositive
        ? context.flowColors.income
        : context.flowColors.expense;

    final TextStyle titleStyle = context.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w800,
      color: scheme.onSurface,
      height: 1.15,
      letterSpacing: -0.15,
    );

    final TextStyle metaStyle = context.textTheme.labelSmall!.copyWith(
      color: GlassPanel.mutedInk(context),
      fontWeight: FontWeight.w500,
      height: 1.25,
      fontSize: 11.5,
    );

    final Widget title = widget.titleOverride ??
        GestureDetector(
          onTap: _handleRangeTextTap,
          onLongPress: _handleRangeTextLongPress,
          child: Text(_getRangeTitle(), style: titleStyle),
        );

        if(widget.pendingGroup){
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title,
              const Spacer(),
              if(widget.action != null) widget.action!,

            ],
          );
        }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
       
          
            
              title,
             const Spacer(),
             MoneyTextBuilder(
              money: mergedFlow.totalFlow,
              builder: (context, formattedSum, originalSum){
                return Text(
                    "$formattedSum$exclamation",
                    style: titleStyle.copyWith(
                        color: showMissingWarning
                    ? scheme.error
                    : flowColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                );
              },
              ),
              
        if (widget.action != null) ...[
          const SizedBox(width: 8.0),
          widget.action!,
        ],
      
    ]);
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
      (DayTimeRange day, false) =>
        day.from.toMoment().calendar(omitHours: true),
      (DayTimeRange day, true) => day.from.toMoment().format("ll"),
      (TimeRange other, _) => other.format(),
    };
  }
}
