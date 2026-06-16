import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class SyncCloudCard extends StatelessWidget {
  final bool enabled;
  final String? lastSyncedLabel;
  final ValueChanged<bool> onChanged;

  const SyncCloudCard({
    super.key,
    required this.enabled,
    required this.onChanged,
    this.lastSyncedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SyncPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(SyncPreferencesTheme.cardRadius),
        border: Border.all(color: SyncPreferencesTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: SyncPreferencesTheme.iconPlateFill(context),
                borderRadius: BorderRadius.circular(12.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                Symbols.cloud_sync_rounded,
                size: 24.0,
                color: SyncPreferencesTheme.primary(context),
                fill: 0.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "preferences.sync.iCloud".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: SyncPreferencesTheme.titleInk(context),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    lastSyncedLabel ??
                        "preferences.sync.iCloud.subtitle".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SyncPreferencesTheme.subtitleInk(context),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeTrackColor: SyncPreferencesTheme.primary(context),
              inactiveTrackColor:
                  SyncPreferencesTheme.cardBorder(context),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return Theme.of(context).colorScheme.surface;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
