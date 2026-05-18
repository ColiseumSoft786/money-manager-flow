import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/deleted_transactions/deleted_transaction_card.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_day_header.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class DeletedTransactionsListView extends StatelessWidget {
  final List<Transaction> transactions;

  const DeletedTransactionsListView({super.key, required this.transactions});

  static List<({String label, List<Transaction> items})> groupByDay(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> byDay = <DateTime, List<Transaction>>{};

    for (final Transaction transaction in transactions) {
      final DateTime anchor = transaction.deletedDate ?? transaction.transactionDate;
      final DateTime day = DateTime(anchor.year, anchor.month, anchor.day);
      byDay.putIfAbsent(day, () => <Transaction>[]).add(transaction);
    }

    final List<DateTime> days = byDay.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    final DateTime today = DateTime.now();
    final DateTime todayDay = DateTime(today.year, today.month, today.day);
    final DateTime yesterdayDay = todayDay.subtract(const Duration(days: 1));

    return days.map((DateTime day) {
      final String label = switch (day) {
        final DateTime d when d == todayDay =>
          "transactions.deleted.today".t(context),
        final DateTime d when d == yesterdayDay =>
          "transactions.deleted.yesterday".t(context),
        _ => day.toMoment().format("MMMM D, YYYY").toUpperCase(),
      };
      final List<Transaction> items = byDay[day]!
        ..sort(
          (Transaction a, Transaction b) =>
              (b.deletedDate ?? b.transactionDate).compareTo(
                a.deletedDate ?? a.transactionDate,
              ),
        );
      return (label: label, items: items);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<({String label, List<Transaction> items})> groups = groupByDay(
      context,
      transactions,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24.0),
      itemCount: groups.fold<int>(
        0,
        (int sum, ({String label, List<Transaction> items}) g) =>
            sum + 1 + g.items.length,
      ),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final ({String label, List<Transaction> items}) group in groups) {
          if (index == cursor) {
            return DeletedTransactionsDayHeader(label: group.label);
          }
          cursor++;
          for (int i = 0; i < group.items.length; i++) {
            if (index == cursor) {
              final Transaction transaction = group.items[i];
              return DeletedTransactionCard(
                transaction: transaction,
                onRestore: transaction.recoverFromTrashBin,
              );
            }
            cursor++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
