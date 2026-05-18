import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/root/widgets/preferences_root_toggle_row.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PreferencesRootToggleRow(
          icon: Symbols.password_rounded,
          title: "preferences.privacy.maskAtStartup".t(context),
          value: UserPreferencesService().privacyModeUponLaunch,
          onChanged: updatePrivacyMode,
        ),
        PreferencesRootToggleRow(
          icon: Symbols.earthquake_rounded,
          title: "preferences.privacy.maskAtShake".t(context),
          value: UserPreferencesService().privacyModeUponShaking,
          onChanged: updatePrivacyModeUponShaking,
          showDivider: false,
        ),
      ],
    );
  }

  void updatePrivacyMode(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponLaunch = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }

  void updatePrivacyModeUponShaking(bool? newPrivacyMode) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().privacyModeUponShaking = newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
