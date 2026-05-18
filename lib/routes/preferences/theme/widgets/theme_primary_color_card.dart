import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/theme/theme_preferences_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/routes/preferences/theme/widgets/theme_color_grid.dart";
import "package:flutter/material.dart";

class ThemePrimaryColorCard extends StatelessWidget {
  final Map<String, String> groupLabels;
  final String selectedGroup;
  final List<FlowThemeGroup> activeGroups;
  final ValueChanged<String> onGroupSelected;
  final ValueChanged<FlowColorScheme> onSchemeChanged;

  const ThemePrimaryColorCard({
    super.key,
    required this.groupLabels,
    required this.selectedGroup,
    required this.activeGroups,
    required this.onGroupSelected,
    required this.onSchemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemePreferencesTheme.primaryCardFill,
        borderRadius: BorderRadius.circular(ThemePreferencesTheme.cardRadius),
        border: Border.all(color: ThemePreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
        child: Column(
          children: [
            if (groupLabels.length > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: groupLabels.keys.map((String group) {
                    final bool selected = group == selectedGroup;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Material(
                        color: selected
                            ? ThemePreferencesTheme.cardFill
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        child: InkWell(
                          onTap: () => onGroupSelected(group),
                          borderRadius: BorderRadius.circular(20.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              groupLabels[group] ?? group,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.0,
                                    color: selected
                                        ? ThemePreferencesTheme.titleInk
                                        : ThemePreferencesTheme.subtitleInk,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (groupLabels.length > 1) const SizedBox(height: 12.0),
            ThemeColorGrid(
              key: ValueKey(selectedGroup),
              groups: activeGroups,
              playInitialAnimation: true,
              onChanged: onSchemeChanged,
            ),
            const SizedBox(height: 12.0),
            Text(
              "preferences.theme.primaryColor.hint".t(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ThemePreferencesTheme.subtitleInk,
                fontSize: 13.0,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
