import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flutter/material.dart";

class TransactionEntryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hero;

  const TransactionEntryCard({
    super.key,
    required this.child,
    this.padding,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: TransactionEntryTheme.cardDecoration(context, hero: hero),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

/// Uppercase section label above a card (e.g. ATTACHMENTS).
class TransactionEntrySectionLabel extends StatelessWidget {
  final String text;

  const TransactionEntrySectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        text.toUpperCase(),
        style: TransactionEntryTheme.sectionLabelStyle(
          context,
          Theme.of(context),
        ),
      ),
    );
  }
}
