import "dart:async";

import "package:flow/data/transactions_filter/pending_time_range.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flow/widgets/schdeuled_notification_permission_builder.dart";
import "package:flow/widgets/schdeuled_notification_permission_missing_reminder.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class PendingTransactionPreferencesPage extends StatefulWidget {
  const PendingTransactionPreferencesPage({super.key});

  @override
  State<PendingTransactionPreferencesPage> createState() =>
      _PendingTransactionPreferencesPageState();
}

class _PendingTransactionPreferencesPageState
    extends State<PendingTransactionPreferencesPage> {
  @override
  void dispose() {
    unawaited(TransactionsService().synchronizeNotifications());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PendingTimeRange pendingTransactionsHomeTimeframe =
        UserPreferencesService().homePendingTransactionsTimeRange;
    final bool pendingTransactionsRequireConfrimation = LocalPreferences()
        .pendingTransactions
        .requireConfrimation
        .get();
    final bool pendingTransactionsUpdateDateUponConfirmation =
        LocalPreferences().pendingTransactions.updateDateUponConfirmation.get();
    final bool notify = LocalPreferences().pendingTransactions.notify.get();
    final int? earlyReminderInSeconds = LocalPreferences()
        .pendingTransactions
        .earlyReminderInSeconds
        .get();

    return SchdeuledNotificationPermissionBuilder(
      builder: (context, permissions, _) {
        return Scaffold(
          backgroundColor: PendingTransactionsTheme.canvas,
          appBar: AppBar(
            backgroundColor: PendingTransactionsTheme.cardFill,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: Text(
              "preferences.transactions.pending".t(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
                color: PendingTransactionsTheme.titleInk,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                height: 1.0,
                thickness: 1.0,
                color: kFlowAccountRowDividerLight,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InfoBanner(
                    text:
                        "preferences.transactions.pending.requireConfirmation.description"
                            .t(context),
                  ),
                  _SectionHeader(
                    label: "preferences.transactions.pending.homeTimeframe".t(
                      context,
                    ),
                  ),
                  _RetentionChipCard(
                    choices: PendingTimeRange.presets,
                    selected: pendingTransactionsHomeTimeframe,
                    onSelected: updatePendingTransactionsHomeTimeframe,
                  ),
                  _SectionHeader(
                    label: "preferences.transactions.pending.requireConfirmation"
                        .t(context),
                  ),
                  _ToggleCard(
                    title:
                        "preferences.transactions.pending.requireConfirmation"
                            .t(context),
                    value: pendingTransactionsRequireConfrimation,
                    onChanged: updatePendingTransactionsRequireConfrimation,
                  ),
                  if (pendingTransactionsRequireConfrimation) ...[
                    _ToggleCard(
                      title:
                          "preferences.transactions.pending.updateDateUponConfirmation"
                              .t(context),
                      subtitle:
                          "preferences.transactions.pending.updateDateUponConfirmation.description"
                              .t(context),
                      value: pendingTransactionsUpdateDateUponConfirmation,
                      onChanged: updatePendingTransactionsConfirmationDate,
                    ),
                    if (permissions.hasAllPermissions)
                      _ToggleCard(
                        title: "preferences.transactions.pending.notify".t(
                          context,
                        ),
                        value:
                            permissions.hasNotificationPermission && notify,
                        enabled: permissions.hasNotificationPermission,
                        onChanged: updateNotify,
                      )
                    else
                      SchdeuledNotificationPermissionMissingReminder(
                        permissions: permissions,
                      ),
                    if (!NotificationsService.schedulingSupported) ...[
                      const SizedBox(height: 8.0),
                      _InfoBanner(
                        text:
                            "preferences.transactions.pending.notify.schedulingUnsupported"
                                .t(context),
                      ),
                    ],
                    if (NotificationsService.schedulingSupported &&
                        notify &&
                        permissions.hasNotificationPermission) ...[
                      _SectionHeader(
                        label:
                            "preferences.transactions.pending.notify.earlyReminder"
                                .t(context),
                      ),
                      _EarlyReminderChipCard(
                        selectedDurationSeconds: earlyReminderInSeconds,
                        onDurationSelected: updateEarlyReminderInSeconds,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void updatePendingTransactionsHomeTimeframe(PendingTimeRange newValue) {
    UserPreferencesService().homePendingTransactionsTimeRange = newValue;

    if (mounted) setState(() {});
  }

  void updateEarlyReminderInSeconds(Duration? duration) async {
    final int? value = duration?.inSeconds;

    if (value == null) {
      await LocalPreferences().pendingTransactions.earlyReminderInSeconds
          .remove();
    } else {
      await LocalPreferences().pendingTransactions.earlyReminderInSeconds.set(
        value,
      );
    }

    if (mounted) setState(() {});
  }

  void updatePendingTransactionsRequireConfrimation(
    bool? requirePendingTransactionConfrimation,
  ) async {
    if (requirePendingTransactionConfrimation == null) return;

    await LocalPreferences().pendingTransactions.requireConfrimation.set(
      requirePendingTransactionConfrimation,
    );

    if (mounted) setState(() {});
  }

  void updatePendingTransactionsConfirmationDate(bool? newValue) async {
    if (newValue == null) return;

    await LocalPreferences().pendingTransactions.updateDateUponConfirmation.set(
      newValue,
    );

    if (mounted) setState(() {});
  }

  void updateNotify(bool? newValue) async {
    if (newValue == null) return;

    await LocalPreferences().pendingTransactions.notify.set(newValue);

    if (mounted) setState(() {});
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 20.0, 2.0, 10.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: PendingTransactionsTheme.sectionLabel,
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 20.0,
              color: PendingTransactionsTheme.primary(context),
              fill: 0.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PendingTransactionsTheme.infoText,
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

class _ToggleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PendingTransactionsTheme.cardFill,
          borderRadius: BorderRadius.circular(PendingTransactionsTheme.cardRadius),
          border: Border.all(color: PendingTransactionsTheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: PendingTransactionsTheme.titleInk,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PendingTransactionsTheme.subtitleInk,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeTrackColor: PendingTransactionsTheme.primary(context),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetentionChipCard extends StatelessWidget {
  final List<PendingTimeRange> choices;
  final PendingTimeRange selected;
  final ValueChanged<PendingTimeRange> onSelected;

  const _RetentionChipCard({
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _ChipCardShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 10.0;
          final double chipWidth = (constraints.maxWidth - spacing * 2) / 3;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: choices.map((PendingTimeRange value) {
              return SizedBox(
                width: chipWidth,
                child: _Chip(
                  label: value.localizedNameContext(
                    context,
                    value.futureDuration?.inDays,
                  ),
                  selected: value == selected,
                  onTap: () => onSelected(value),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _EarlyReminderChipCard extends StatelessWidget {
  final int? selectedDurationSeconds;
  final ValueChanged<Duration?> onDurationSelected;

  static const List<Duration?> _choices = [
    null,
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 3),
    Duration(days: 7),
  ];

  const _EarlyReminderChipCard({
    required this.selectedDurationSeconds,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _ChipCardShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 10.0;
          final double chipWidth = (constraints.maxWidth - spacing * 2) / 3;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: _choices.map((Duration? value) {
              final bool isSelected =
                  (value?.inSeconds ?? 0) == (selectedDurationSeconds ?? 0);

              return SizedBox(
                width: chipWidth,
                child: _Chip(
                  label:
                      value?.toDurationString(dropPrefixOrSuffix: true) ??
                      "preferences.transactions.pending.notify.earlyReminder.none"
                          .t(context),
                  selected: isSelected,
                  onTap: () => onDurationSelected(value),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ChipCardShell extends StatelessWidget {
  final Widget child;

  const _ChipCardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PendingTransactionsTheme.cardFill,
        borderRadius: BorderRadius.circular(PendingTransactionsTheme.cardRadius),
        border: Border.all(color: PendingTransactionsTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: child,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PendingTransactionsTheme.chipSelectedFill
          : PendingTransactionsTheme.chipIdleFill,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
              color: selected
                  ? PendingTransactionsTheme.chipSelectedInk
                  : PendingTransactionsTheme.chipIdleInk,
            ),
          ),
        ),
      ),
    );
  }
}
