import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class MoneyFormattingPreferencesTheme {
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

  static const Color previewLabel = Color(0xFF94A3B8);
  static const Color previewWatermark = Color(0xFFE2E8F0);
  static const Color previewHint = Color(0xFF3B82F6);

  static const Color footerFill = Color(0xFFEFF6FF);
  static const Color footerDash = Color(0xFFBFDBFE);
  static const Color footerText = Color(0xFF64748B);

  static const double cardRadius = 16.0;
}
