import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:flutter/material.dart";

class TransferSectionHeader extends StatelessWidget {
  final String label;

  const TransferSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 20.0, 2.0, 10.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: TransferPreferencesTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
