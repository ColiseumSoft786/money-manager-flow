import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class PendingTransactionCard extends StatelessWidget {
  final Transaction transaction;

  const PendingTransactionCard({super.key, required this.transaction});

  String _resolvedTitle(BuildContext context) {
    if (transaction.title?.isNotEmpty == true) {
      return transaction.title!;
    }
    return transaction.category.target?.name ??
        "transaction.fallbackTitle".t(context);
  }

  String _subtitle(BuildContext context) {
    final Category? category = transaction.category.target;
    final String categoryName = category?.name ?? "";
    final String timing = _timingLabel(context);

    if (categoryName.isEmpty) return timing;
    return "$categoryName • $timing";
  }

  String _timingLabel(BuildContext context) {
    if (transaction.extensions.recurring != null) {
      return "transactions.pending.timing.recurring".t(context);
    }

    final DateTime now = DateTime.now();
    final DateTime date = transaction.transactionDate;
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime txDay = DateTime(date.year, date.month, date.day);

    if (txDay.isAfter(today)) {
      final int days = txDay.difference(today).inDays;
      if (days == 1) {
        return "transactions.pending.timing.expectedTomorrow".t(context);
      }
      return "transactions.pending.timing.dueInDays".t(context, {"n": days});
    }

    return "transaction.pending".t(context);
  }

  void _onConfirm(BuildContext context) {
    final bool updateTransactionDate = LocalPreferences()
        .pendingTransactions
        .updateDateUponConfirmation
        .get();
    transaction.confirm(true, updateTransactionDate);
  }

  void _onPostpone(BuildContext context) {
    final bool updateTransactionDate = LocalPreferences()
        .pendingTransactions
        .updateDateUponConfirmation
        .get();
    transaction.confirm(false, updateTransactionDate);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Category? category = transaction.category.target;
    final Money money = transaction.money;
    final bool isIncome = money.amount > 0;
    final bool holdable = transaction.holdable();
    final String amountText = money.formatMoney(takeAbsoluteValue: false);
    final Color amountColor = isIncome
        ? PendingTransactionsTheme.incomeAmount
        : PendingTransactionsTheme.expenseAmount(context);

    final String primaryLabel = holdable
        ? "transactions.pending.payNow".t(context)
        : "general.confirm".t(context);
    final String secondaryLabel = holdable
        ? "transactions.pending.postpone".t(context)
        : "general.edit".t(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PendingTransactionsTheme.cardFill(context),
          borderRadius: BorderRadius.circular(PendingTransactionsTheme.cardRadius),
          border: Border.all(color: PendingTransactionsTheme.cardBorder(context)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
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
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: PendingTransactionsTheme.titleInk(context),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _subtitle(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PendingTransactionsTheme.subtitleInk(context),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountText,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onConfirm(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: PendingTransactionsTheme.primaryButtonFill(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        primaryLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (holdable) {
                          _onPostpone(context);
                        } else {
                          context.push("/transaction/${transaction.id}");
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            PendingTransactionsTheme.secondaryButtonFill(context),
                        foregroundColor:
                            PendingTransactionsTheme.secondaryButtonInk(context),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        secondaryLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          color: PendingTransactionsTheme.secondaryButtonInk(context),
                        ),
                      ),
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
