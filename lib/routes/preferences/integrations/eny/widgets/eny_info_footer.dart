import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyInfoFooter extends StatelessWidget {
  const EnyInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EnyPreferencesTheme.infoFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: EnyPreferencesTheme.infoBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 20.0,
              color: EnyPreferencesTheme.primary(context),
              fill: 0.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                "integrations.eny.footerNotice".t(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EnyPreferencesTheme.infoText,
                  fontSize: 13.0,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
