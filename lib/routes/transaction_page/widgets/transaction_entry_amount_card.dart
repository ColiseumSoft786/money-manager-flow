import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class TransactionEntryAmountCard extends StatelessWidget {
  final double amount;
  final String currency;
  final VoidCallback onTap;
  final Widget? titleField;

  const TransactionEntryAmountCard({
    super.key,
    required this.amount,
    required this.currency,
    required this.onTap,
    this.titleField,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Money money = Money(amount, currency);
    final String amountText = money.formattedNoMarker;
    final String symbol =
        NumberFormat.simpleCurrency(name: currency).currencySymbol;
    final bool isZero = amount == 0.0;

    return TransactionEntryCard(
      padding: TransactionEntryTheme.cardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titleField != null) ...[
            Text(
              "transaction.field.title".t(context),
              style: TransactionEntryTheme.sectionLabelStyle(context, theme),
            ),
            const SizedBox(height: 6.0),
            titleField!,
            const SizedBox(height: 20.0),
          ],
          Text(
            "transaction.field.amount".t(context),
            style: TransactionEntryTheme.sectionLabelStyle(context, theme),
          ),
          const SizedBox(height: 8.0),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        symbol.isEmpty ? currency : symbol,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TransactionEntryTheme.amountSymbolInk(context),
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        amountText,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isZero
                              ? TransactionEntryTheme.placeholderInk(context)
                              : TransactionEntryTheme.valueInk(context),
                          fontSize: 44.0,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
