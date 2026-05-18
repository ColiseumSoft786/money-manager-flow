import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/theme/theme_preferences_theme.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/names.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ThemeOtherThemesCard extends StatelessWidget {
  final String currentTheme;
  final ValueChanged<String?> onThemeSelected;

  const ThemeOtherThemesCard({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, FlowColorScheme>> entries =
        standaloneThemes.entries.toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemePreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(ThemePreferencesTheme.cardRadius),
        border: Border.all(color: ThemePreferencesTheme.cardBorder),
      ),
      child: RadioGroup<String>(
        groupValue: currentTheme,
        onChanged: onThemeSelected,
        child: Column(
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1.0,
                  thickness: 1.0,
                  indent: 16.0,
                  endIndent: 16.0,
                  color: ThemePreferencesTheme.divider,
                ),
              _OtherThemeRow(
                themeKey: entries[i].key,
                scheme: entries[i].value,
                title: themeNames[entries[i].value.name] ?? entries[i].value.name,
                subtitle: _subtitleFor(context, entries[i].key),
                onSelect: () => onThemeSelected(entries[i].key),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _subtitleFor(BuildContext context, String key) => switch (key) {
    "palenight" => "preferences.theme.palenight.subtitle".t(context),
    "monochrome" => "preferences.theme.monochrome.subtitle".t(context),
    _ => "",
  };
}

class _OtherThemeRow extends StatelessWidget {
  final String themeKey;
  final FlowColorScheme scheme;
  final String title;
  final String subtitle;
  final VoidCallback onSelect;

  const _OtherThemeRow({
    required this.themeKey,
    required this.scheme,
    required this.title,
    required this.subtitle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ({Color fill, IconData icon, Color iconColor}) iconStyle =
        switch (themeKey) {
          "palenight" => (
            fill: ThemePreferencesTheme.palenightIconFill,
            icon: Symbols.dark_mode_rounded,
            iconColor: Colors.white,
          ),
          "monochrome" => (
            fill: ThemePreferencesTheme.monochromeIconFill,
            icon: Symbols.contrast_rounded,
            iconColor: ThemePreferencesTheme.titleInk,
          ),
          _ => (
            fill: scheme.primary,
            icon: Symbols.palette_rounded,
            iconColor: scheme.onPrimary ?? Colors.white,
          ),
        };

    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: iconStyle.fill,
                borderRadius: BorderRadius.circular(12.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                iconStyle.icon,
                size: 24.0,
                color: iconStyle.iconColor,
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
                      color: ThemePreferencesTheme.titleInk,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ThemePreferencesTheme.subtitleInk,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio<String>(
              value: themeKey,
              activeColor: ThemePreferencesTheme.primary(context),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ThemePreferencesTheme.primary(context);
                }
                return ThemePreferencesTheme.subtitleInk.withValues(alpha: 0.35);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
