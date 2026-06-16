import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/reminders/reminders_preferences_theme.dart";
import "package:flow/routes/preferences/reminders/widgets/reminder_daily_toggle_card.dart";
import "package:flow/routes/preferences/reminders/widgets/reminder_time_picker_card.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/schdeuled_notification_permission_builder.dart";
import "package:flow/widgets/schdeuled_notification_permission_missing_reminder.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class RemindersPreferencesPage extends StatefulWidget {
  const RemindersPreferencesPage({super.key});

  @override
  State<RemindersPreferencesPage> createState() =>
      _RemindersPreferencesPageState();
}

class _RemindersPreferencesPageState extends State<RemindersPreferencesPage> {
  void _setRemindDailyAt(int hour, int minute) {
    UserPreferencesService().remindDailyAt = Duration(
      hours: hour,
      minutes: minute,
    );
    setState(() {});
  }

  void toggleRemindDaily(bool enabled) {
    if (enabled) {
      final Duration? current = UserPreferencesService().remindDailyAt;
      UserPreferencesService().remindDailyAt =
          current ?? const Duration(hours: 20);
    } else {
      UserPreferencesService().remindDailyAt = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Duration? remindDailyAt = UserPreferencesService().remindDailyAt;
    final bool enabled = remindDailyAt != null;

    final int hour = remindDailyAt?.inHours ?? 20;
    final int minute = (remindDailyAt?.inMinutes ?? 0) % 60;

    final bool showReminderControls =
        flowDebugMode || NotificationsService.schedulingSupported;

    return Scaffold(
      backgroundColor: RemindersPreferencesTheme.canvas(context),
      appBar: AppBar(
        title: Text("preferences.reminders.settingsTitle".t(context)),
      ),
      body: SchdeuledNotificationPermissionBuilder(
        builder: (context, permissions, _) {
          final bool interactive = permissions.hasAllPermissions;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!NotificationsService.schedulingSupported) ...[
                        Frame(
                          child: InfoText(
                            child: Text(
                              "preferences.reminders.unsupportedPlatform".t(
                                context,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      if (NotificationsService.schedulingSupported &&
                          !permissions.hasAllPermissions) ...[
                        SchdeuledNotificationPermissionMissingReminder(
                          permissions: permissions,
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      if (flowDebugMode &&
                          !NotificationsService.schedulingSupported) ...[
                        Frame(
                          child: InfoText(
                            child: Text(
                              "Debug mode - this page was shown even though Flow doesn't support notifications on this platform",
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      if (showReminderControls) ...[
                        ReminderDailyToggleCard(
                          enabled: enabled,
                          interactive: interactive,
                          onChanged: toggleRemindDaily,
                        ),
                        if (interactive && enabled) ...[
                          const SizedBox(height: 12.0),
                          ReminderTimePickerCard(
                            hour: hour,
                            minute: minute,
                            onHourChanged: (int h) =>
                                _setRemindDailyAt(h, minute),
                            onMinuteChanged: (int m) =>
                                _setRemindDailyAt(hour, m),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (showReminderControls)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.0,
                      child: FilledButton(
                        onPressed: () => context.pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: RemindersPreferencesTheme.primary(context),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          "preferences.reminders.saveChanges".t(context),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
