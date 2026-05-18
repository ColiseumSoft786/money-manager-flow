import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class EnyPreferencesTheme {
  static const Color canvas = Color(0xFFF8F9FB);
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

  static const Color badgeDisconnectedFill = Color(0xFFFEE2E2);
  static const Color badgeDisconnectedInk = Color(0xFFDC2626);
  static const Color badgeConnectedFill = Color(0xFFDCFCE7);
  static const Color badgeConnectedInk = Color(0xFF16A34A);

  static const Color infoFill = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF475569);

  static const Color danger = Color(0xFFEF4444);

  static const double cardRadius = 16.0;
}
