import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flutter/material.dart";

class SyncSectionHeader extends StatelessWidget {
  final String label;

  const SyncSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 24.0, 2.0, 12.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: SyncPreferencesTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
