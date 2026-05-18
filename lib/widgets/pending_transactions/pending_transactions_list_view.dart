import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/pending_transactions/pending_section_header.dart";
import "package:flow/widgets/pending_transactions/pending_summary_card.dart";
import "package:flow/widgets/pending_transactions/pending_transaction_card.dart";
import "package:flutter/material.dart";

class PendingTransactionsListView extends StatelessWidget {
  final List<Transaction> transactions;

  const PendingTransactionsListView({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final List<Transaction> sorted = List<Transaction>.from(transactions)
      ..sort(
        (Transaction a, Transaction b) =>
            a.transactionDate.compareTo(b.transactionDate),
      );

    return ListView(
      padding: const EdgeInsets.only(bottom: 88.0),
      children: [
        PendingSummaryCard(transactions: sorted),
        const SizedBox(height: 8.0),
        PendingSectionHeader(
          label: "transactions.pending.section.upcoming".t(context),
        ),
        ...sorted.map(
          (Transaction transaction) =>
              PendingTransactionCard(transaction: transaction),
        ),
      ],
    );
  }
}
