import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class ThemePreferencesTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color primaryCardFill = Color(0xFFF1F5F9);
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static const Color palenightIconFill = Color(0xFF312E81);
  static const Color monochromeIconFill = Color(0xFFE5E7EB);

  static const double cardRadius = 16.0;
}
