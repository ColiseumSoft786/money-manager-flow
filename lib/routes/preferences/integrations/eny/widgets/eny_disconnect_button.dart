import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyDisconnectButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EnyDisconnectButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Symbols.logout_rounded,
          size: 20.0,
          color: EnyPreferencesTheme.danger,
          fill: 0.0,
        ),
        label: Text(
          "integrations.eny.disconnect".t(context),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
            color: EnyPreferencesTheme.danger,
          ),
        ),
      ),
    );
  }
}
