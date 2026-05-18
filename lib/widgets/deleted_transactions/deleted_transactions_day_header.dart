import "package:flow/widgets/deleted_transactions/deleted_transactions_theme.dart";
import "package:flutter/material.dart";

class DeletedTransactionsDayHeader extends StatelessWidget {
  final String label;

  const DeletedTransactionsDayHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 10.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: DeletedTransactionsTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 12.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
