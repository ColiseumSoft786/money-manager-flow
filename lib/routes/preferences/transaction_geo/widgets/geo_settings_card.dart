import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transaction_geo/transaction_geo_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class GeoSettingsCard extends StatelessWidget {
  final bool enableGeo;
  final bool autoAttach;
  final bool showAutoAttach;
  final ValueChanged<bool> onEnableGeoChanged;
  final ValueChanged<bool> onAutoAttachChanged;

  const GeoSettingsCard({
    super.key,
    required this.enableGeo,
    required this.autoAttach,
    required this.showAutoAttach,
    required this.onEnableGeoChanged,
    required this.onAutoAttachChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionGeoPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(
          TransactionGeoPreferencesTheme.cardRadius,
        ),
        border: Border.all(
          color: TransactionGeoPreferencesTheme.cardBorder(context),
        ),
      ),
      child: Column(
        children: [
          _GeoToggleRow(
            icon: Symbols.location_on_rounded,
            title: "preferences.transactions.geo.enable.title".t(context),
            subtitle: "preferences.transactions.geo.enable.subtitle".t(context),
            value: enableGeo,
            onChanged: onEnableGeoChanged,
          ),
          if (showAutoAttach) ...[
            Divider(
              height: 1.0,
              thickness: 1.0,
              indent: 16.0,
              endIndent: 16.0,
              color: TransactionGeoPreferencesTheme.divider(context),
            ),
            _GeoToggleRow(
              icon: Symbols.near_me_rounded,
              title: "preferences.transactions.geo.auto.enable".t(context),
              subtitle: "preferences.transactions.geo.auto.subtitle".t(context),
              value: autoAttach,
              onChanged: onAutoAttachChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _GeoToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GeoToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: TransactionGeoPreferencesTheme.iconPlateFill(context),
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 24.0,
              color: TransactionGeoPreferencesTheme.primary(context),
              fill: 0.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    color: TransactionGeoPreferencesTheme.titleInk(context),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TransactionGeoPreferencesTheme.subtitleInk(context),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: TransactionGeoPreferencesTheme.primary(context),
            inactiveTrackColor: TransactionGeoPreferencesTheme.cardBorder(context),
            thumbColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
