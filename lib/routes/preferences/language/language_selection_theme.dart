import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class LanguageSelectionTheme {
  static const Color canvas = Color(0xFFF8F9FB);
  static const Color sheetFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static const Color radioIdleBorder = Color(0xFFD1D5DB);
  static const Color searchFill = Colors.white;

  static const double cardRadius = 16.0;
}
