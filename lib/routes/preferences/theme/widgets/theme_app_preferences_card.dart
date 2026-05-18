import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/theme/theme_preferences_theme.dart";
import "package:flutter/material.dart";

class ThemeAppPreferencesCard extends StatelessWidget {
  final bool themeChangesAppIcon;
  final ValueChanged<bool> onChanged;

  const ThemeAppPreferencesCard({
    super.key,
    required this.themeChangesAppIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemePreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(ThemePreferencesTheme.cardRadius),
        border: Border.all(color: ThemePreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "preferences.theme.themeChangesAppIcon".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: ThemePreferencesTheme.titleInk,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    "preferences.theme.themeChangesAppIcon.subtitle".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ThemePreferencesTheme.subtitleInk,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: themeChangesAppIcon,
              onChanged: onChanged,
              activeTrackColor: ThemePreferencesTheme.primary(context),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
