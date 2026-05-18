import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class ButtonOrderPreferencesTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static const Color infoFill = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF475569);

  static const double cardRadius = 16.0;
}
