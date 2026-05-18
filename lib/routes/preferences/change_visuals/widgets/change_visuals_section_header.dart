import "package:flow/routes/preferences/change_visuals/change_visuals_preferences_theme.dart";
import "package:flutter/material.dart";

class ChangeVisualsSectionHeader extends StatelessWidget {
  final String label;
  final bool first;

  const ChangeVisualsSectionHeader({
    super.key,
    required this.label,
    this.first = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.0, first ? 4.0 : 20.0, 2.0, 10.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ChangeVisualsPreferencesTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
