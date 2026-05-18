import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/root/widgets/preferences_root_toggle_row.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class Haptics extends StatefulWidget {
  const Haptics({super.key});

  @override
  State<Haptics> createState() => _HapticsState();
}

class _HapticsState extends State<Haptics> {
  @override
  Widget build(BuildContext context) {
    final bool enableHapticFeedback = LocalPreferences().enableHapticFeedback
        .get();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PreferencesRootToggleRow(
          icon: Symbols.vibration_rounded,
          title: "preferences.hapticFeedback.description".t(context),
          value: enableHapticFeedback,
          onChanged: updateEnableHapticFeedback,
          showDivider: false,
        ),
      ],
    );
  }

  void updateEnableHapticFeedback(bool? newEnableHapticFeedback) async {
    if (newEnableHapticFeedback == null) return;

    await LocalPreferences().enableHapticFeedback.set(newEnableHapticFeedback);

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}
