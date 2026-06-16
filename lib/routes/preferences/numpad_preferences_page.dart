import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/numpad/numpad_preferences_theme.dart";
import "package:flow/routes/preferences/numpad/widgets/numpad_info_banner.dart";
import "package:flow/routes/preferences/numpad/widgets/numpad_layout_option_card.dart";
import "package:flow/routes/preferences/numpad/widgets/numpad_preview_hero.dart";
import "package:flow/routes/preferences/numpad/widgets/numpad_section_header.dart";
import "package:flutter/material.dart";

class NumpadPreferencesPage extends StatefulWidget {
  const NumpadPreferencesPage({super.key});

  @override
  State<NumpadPreferencesPage> createState() => _NumpadPreferencesPageState();
}

class _NumpadPreferencesPageState extends State<NumpadPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool usePhoneNumpadLayout =
        LocalPreferences().usePhoneNumpadLayout.get();

    return Scaffold(
      backgroundColor: NumpadPreferencesTheme.canvas,
      appBar: AppBar(
        title: Text("preferences.numpad.settingsTitle".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NumpadPreviewHero(),
              NumpadSectionHeader(
                label: "preferences.numpad.layout".t(context),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NumpadLayoutOptionCard(
                      isPhoneLayout: false,
                      selected: !usePhoneNumpadLayout,
                      onTap: () => updateLayoutPreference(false),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: NumpadLayoutOptionCard(
                      isPhoneLayout: true,
                      selected: usePhoneNumpadLayout,
                      onTap: () => updateLayoutPreference(true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const NumpadInfoBanner(),
            ],
          ),
        ),
      ),
    );
  }

  void updateLayoutPreference(bool usePhoneLayout) async {
    await LocalPreferences().usePhoneNumpadLayout.set(usePhoneLayout);

    if (mounted) setState(() {});
  }
}
