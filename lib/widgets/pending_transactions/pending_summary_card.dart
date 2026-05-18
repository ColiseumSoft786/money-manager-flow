import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flutter/material.dart";

class PendingSummaryCard extends StatelessWidget {
  final List<Transaction> transactions;

  const PendingSummaryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        transactions
            .where((transaction) => !transaction.isTransfer)
            .map((transaction) => transaction.money),
      );

    final SingleCurrencyFlow merged = flow.merge(
      primaryCurrency,
      ExchangeRatesService().getPrimaryCurrencyRates(),
    );
    final Money total = merged.totalFlow;
    final int count = transactions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PendingTransactionsTheme.cardRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PendingTransactionsTheme.summaryGradientStart,
              PendingTransactionsTheme.summaryGradientEnd,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(59, 130, 246, 0.18),
              blurRadius: 20.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20.0,
              top: -20.0,
              child: Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PendingTransactionsTheme.primary(context).withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "transactions.pending.summary.total".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PendingTransactionsTheme.summarySubtitle,
                      fontSize: 13.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  MoneyText(
                    total,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 32.0,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "transactions.pending.summary.remaining".t(context, count),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PendingTransactionsTheme.summarySubtitle,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
