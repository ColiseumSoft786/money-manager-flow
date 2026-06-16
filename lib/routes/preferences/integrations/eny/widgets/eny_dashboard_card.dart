import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyDashboardCard extends StatelessWidget {
  final VoidCallback onTap;

  const EnyDashboardCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EnyPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(EnyPreferencesTheme.cardRadius),
        border: Border.all(color: EnyPreferencesTheme.cardBorder(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EnyPreferencesTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: EnyPreferencesTheme.iconPlateFill(context),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.dashboard_rounded,
                    size: 24.0,
                    color: EnyPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    "integrations.eny.dashboard".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: EnyPreferencesTheme.titleInk(context),
                    ),
                  ),
                ),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: EnyPreferencesTheme.subtitleInk(context).withValues(
                    alpha: 0.6,
                  ),
                  fill: 0.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
