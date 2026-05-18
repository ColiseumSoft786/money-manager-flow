import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flutter/material.dart";

class EnySectionHeader extends StatelessWidget {
  final String label;

  const EnySectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 10.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: EnyPreferencesTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
