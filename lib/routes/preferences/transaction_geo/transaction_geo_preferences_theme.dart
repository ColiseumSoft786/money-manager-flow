import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class TransactionGeoPreferencesTheme {
  static const Color canvas = Color(0xFFF4F7F9);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static Color iconPlateFill(BuildContext context) =>
      PreferencesUiTheme.iconPlateFill(context);

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static const Color mapParkFill = Color(0xFFD8E8D4);
  static const Color mapRoadFill = Color(0xFFE8ECF0);
  static const Color mapBlockFill = Color(0xFFCFD8DC);
  static const Color mapPin = Color(0xFF0F766E);

  static const double cardRadius = 16.0;
  static const double mapRadius = 16.0;
}
