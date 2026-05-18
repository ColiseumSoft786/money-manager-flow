import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/reminders/reminders_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ReminderDailyToggleCard extends StatelessWidget {
  final bool enabled;
  final bool interactive;
  final ValueChanged<bool>? onChanged;

  const ReminderDailyToggleCard({
    super.key,
    required this.enabled,
    required this.interactive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RemindersPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(RemindersPreferencesTheme.cardRadius),
        border: Border.all(color: RemindersPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration:  BoxDecoration(
                color: RemindersPreferencesTheme.iconPlateFill(context),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Symbols.notifications_rounded,
                size: 24.0,
                color: RemindersPreferencesTheme.primary(context),
                fill: 0.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "preferences.reminders.remindDaily".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: RemindersPreferencesTheme.titleInk,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "preferences.reminders.remindDaily.subtitle".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RemindersPreferencesTheme.subtitleInk,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: interactive ? onChanged : null,
              activeTrackColor: RemindersPreferencesTheme.primary(context),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
