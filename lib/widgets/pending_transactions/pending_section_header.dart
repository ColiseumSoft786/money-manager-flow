import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flutter/material.dart";

class PendingSectionHeader extends StatelessWidget {
  final String label;

  const PendingSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 10.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: PendingTransactionsTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
