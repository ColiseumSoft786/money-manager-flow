import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class DeletedTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onRestore;

  const DeletedTransactionCard({
    super.key,
    required this.transaction,
    required this.onRestore,
  });

  String _resolvedTitle(BuildContext context) {
    if (transaction.title?.isNotEmpty == true) {
      return transaction.title!;
    }
    return transaction.category.target?.name ??
        "transaction.fallbackTitle".t(context);
  }

  String _subtitle(DateTime when) =>
      "${when.toMoment().format("MMM D, YYYY")} • ${when.toMoment().format("HH:mm")}";

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Category? category = transaction.category.target;
    final DateTime when = transaction.transactionDate;
    final Money money = transaction.money;
    final bool isIncome = money.amount > 0;
    final Color amountColor = isIncome
        ? context.flowColors.income
        : context.flowColors.expense;
    final String amountText = money.formatMoney(takeAbsoluteValue: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DeletedTransactionsTheme.cardFill(context),
          borderRadius: BorderRadius.circular(DeletedTransactionsTheme.cardRadius),
          border: Border.all(color: DeletedTransactionsTheme.cardBorder(context)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.04),
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlowIcon(
                category?.icon ??
                    FlowIconData.icon(transaction.type.icon),
                plated: true,
                size: 22.0,
                colorScheme: category?.colorScheme,
                platePadding: const EdgeInsets.all(10.0),
                borderRadius: BorderRadius.circular(999.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resolvedTitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: DeletedTransactionsTheme.titleInk(context),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _subtitle(when),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DeletedTransactionsTheme.subtitleInk(context),
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Material(
                    color: DeletedTransactionsTheme.restoreFill(context),
                    borderRadius: BorderRadius.circular(20.0),
                    child: InkWell(
                      onTap: onRestore,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.history_rounded,
                              size: 16.0,
                              color: DeletedTransactionsTheme.restoreInk,
                              fill: 0.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              "transactions.deleted.restore".t(context),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: DeletedTransactionsTheme.restoreInk,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.0,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
