import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/reminders/reminders_preferences_theme.dart";
import "package:flow/routes/preferences/reminders/widgets/reminder_time_wheel.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ReminderTimePickerCard extends StatelessWidget {
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const ReminderTimePickerCard({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RemindersPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(RemindersPreferencesTheme.cardRadius),
        border: Border.all(color: RemindersPreferencesTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "preferences.reminders.remindDaily.time".t(context).toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: RemindersPreferencesTheme.sectionLabel(context),
                fontWeight: FontWeight.w700,
                fontSize: 11.0,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "preferences.reminders.time.sectionHint".t(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: RemindersPreferencesTheme.subtitleInk(context),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReminderTimeWheel(
                  value: hour,
                  min: 0,
                  max: 23,
                  onChanged: onHourChanged,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: const BoxDecoration(
                          color: RemindersPreferencesTheme.wheelFadedInk,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: const BoxDecoration(
                          color: RemindersPreferencesTheme.wheelFadedInk,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                ReminderTimeWheel(
                  value: minute,
                  min: 0,
                  max: 59,
                  onChanged: onMinuteChanged,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            DecoratedBox(
              decoration: BoxDecoration(
                color: RemindersPreferencesTheme.infoFill,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Symbols.info_rounded,
                      size: 18.0,
                      color: RemindersPreferencesTheme.primary(context),
                      fill: 0.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "preferences.reminders.remindDaily.habitInfo".t(
                              context,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: RemindersPreferencesTheme.infoText,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "preferences.reminders.remindDaily.expiryWarning".t(
                              context,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: RemindersPreferencesTheme.subtitleInk(context),
                              fontSize: 11.0,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
