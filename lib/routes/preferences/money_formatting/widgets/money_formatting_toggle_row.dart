import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class MoneyFormattingToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const MoneyFormattingToggleRow({
    super.key,
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
              color: PreferencesUiTheme.iconPlateFill(context),
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 24.0,
              color: PreferencesUiTheme.primary(context),
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
                    color: MoneyFormattingPreferencesTheme.titleInk(context),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MoneyFormattingPreferencesTheme.subtitleInk(context),
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
            activeTrackColor: PreferencesUiTheme.primary(context),
            inactiveTrackColor:
                MoneyFormattingPreferencesTheme.cardBorder(context),
            thumbColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
