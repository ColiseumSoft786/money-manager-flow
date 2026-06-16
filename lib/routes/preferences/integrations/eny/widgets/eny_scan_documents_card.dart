import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flutter/material.dart";

class EnyScanDocumentsCard extends StatelessWidget {
  final bool createTransactionsPerItem;
  final bool markAsPending;
  final ValueChanged<bool> onCreatePerItemChanged;
  final ValueChanged<bool> onMarkPendingChanged;

  const EnyScanDocumentsCard({
    super.key,
    required this.createTransactionsPerItem,
    required this.markAsPending,
    required this.onCreatePerItemChanged,
    required this.onMarkPendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EnyPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(EnyPreferencesTheme.cardRadius),
        border: Border.all(color: EnyPreferencesTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 14.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "preferences.scan".t(context),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
                color: EnyPreferencesTheme.titleInk(context),
              ),
            ),
            const SizedBox(height: 4.0),
            _ScanToggleRow(
              title: "preferences.scan.createTransactionsPerItemInScans".t(
                context,
              ),
              subtitle:
                  "preferences.scan.createTransactionsPerItemInScans.description"
                      .t(context),
              value: createTransactionsPerItem,
              onChanged: onCreatePerItemChanged,
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: EnyPreferencesTheme.divider(context),
            ),
            _ScanToggleRow(
              title: "preferences.scan.markPendingThreshold".t(context),
              subtitle: "preferences.scan.markPendingThreshold.subtitle".t(
                context,
              ),
              value: markAsPending,
              onChanged: onMarkPendingChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ScanToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: EnyPreferencesTheme.titleInk(context),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: EnyPreferencesTheme.subtitleInk(context),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: EnyPreferencesTheme.primary(context),
            inactiveTrackColor: EnyPreferencesTheme.cardBorder(context),
            thumbColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
