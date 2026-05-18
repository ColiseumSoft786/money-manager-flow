import "package:flutter/material.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";

class EnyStatusBadge extends StatelessWidget {
  final bool connected;
  final String label;

  const EnyStatusBadge({
    super.key,
    required this.connected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: connected
            ? EnyPreferencesTheme.badgeConnectedFill
            : EnyPreferencesTheme.badgeDisconnectedFill,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: connected
              ? EnyPreferencesTheme.badgeConnectedInk
              : EnyPreferencesTheme.badgeDisconnectedInk,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
        ),
      ),
    );
  }
}
