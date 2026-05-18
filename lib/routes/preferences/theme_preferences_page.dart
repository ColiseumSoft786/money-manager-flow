import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/theme/theme_preferences_theme.dart";
import "package:flow/routes/preferences/theme/widgets/theme_app_preferences_card.dart";
import "package:flow/routes/preferences/theme/widgets/theme_other_themes_card.dart";
import "package:flow/routes/preferences/theme/widgets/theme_primary_color_card.dart";
import "package:flow/routes/preferences/theme/widgets/theme_section_header.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/utils/extensions.dart";
import "package:flutter/material.dart";

class ThemePreferencesPage extends StatefulWidget {
  const ThemePreferencesPage({super.key});

  @override
  State<ThemePreferencesPage> createState() => _ThemePreferencesPageState();
}

class _ThemePreferencesPageState extends State<ThemePreferencesPage> {
  bool busy = false;
  bool appIconBusy = false;

  String selectedGroup = groups.keys.first;

  @override
  void initState() {
    super.initState();

    final String currentTheme = UserPreferencesService().themeName;

    selectedGroup =
        groups.entries
            .firstWhereOrNull(
              (entry) => entry.value.any(
                (group) => group.schemes.any((s) => s.name == currentTheme),
              ),
            )
            ?.key ??
        groups.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserPreferencesService().valueNotifier,
      builder: (context, _, __) {
        final String currentTheme = UserPreferencesService().themeName;
        final bool themeChangesAppIcon =
            UserPreferencesService().themeChangesAppIcon;
        final List<FlowThemeGroup> activeGroups = groups[selectedGroup]!;

        return Scaffold(
          backgroundColor: ThemePreferencesTheme.canvas,
          appBar: AppBar(
            backgroundColor: ThemePreferencesTheme.cardFill,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: Text(
              "preferences.theme.settingsTitle".t(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
                color: ThemePreferencesTheme.titleInk,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                height: 1.0,
                thickness: 1.0,
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ThemeSectionHeader(
                    first: true,
                    label: "preferences.theme.section.primaryColor".t(context),
                  ),
                  ThemePrimaryColorCard(
                    groupLabels: {for (final String key in groups.keys) key: key},
                    selectedGroup: selectedGroup,
                    activeGroups: activeGroups,
                    onGroupSelected: (String group) {
                      setState(() {
                        selectedGroup = group;
                      });
                    },
                    onSchemeChanged: (FlowColorScheme scheme) {
                      UserPreferencesService().themeName = scheme.name;
                      if (UserPreferencesService().themeChangesAppIcon) {
                        trySetAppIcon(scheme.iconName);
                      }
                      setState(() {});
                    },
                  ),
                  ThemeSectionHeader(
                    label: "preferences.theme.other".t(context),
                  ),
                  ThemeOtherThemesCard(
                    currentTheme: currentTheme,
                    onThemeSelected: handleChange,
                  ),
                  if (Platform.isIOS) ...[
                    ThemeSectionHeader(
                      label: "preferences.theme.section.appPreferences".t(
                        context,
                      ),
                    ),
                    ThemeAppPreferencesCard(
                      themeChangesAppIcon: themeChangesAppIcon,
                      onChanged: changeThemeChangesAppIcon,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void changeThemeChangesAppIcon(bool newValue) async {
    if (appIconBusy) return;

    try {
      appIconBusy = true;
      UserPreferencesService().themeChangesAppIcon = newValue;
      trySetAppIcon(
        newValue
            ? allThemes[UserPreferencesService().themeName]?.iconName
            : null,
      );
    } finally {
      appIconBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void handleChange(String? name) async {
    if (name == null) return;
    if (busy) return;

    try {
      busy = true;
      UserPreferencesService().themeName = name;
      if (UserPreferencesService().themeChangesAppIcon) {
        trySetAppIcon(allThemes[name]?.iconName);
      }

      final String? groupKey = groups.entries
          .firstWhereOrNull(
            (entry) => entry.value.any(
              (group) => group.schemes.any((s) => s.name == name),
            ),
          )
          ?.key;
      if (groupKey != null && groupKey != selectedGroup) {
        selectedGroup = groupKey;
      }
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
