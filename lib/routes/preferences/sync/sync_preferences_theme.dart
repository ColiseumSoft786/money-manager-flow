import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class SyncPreferencesTheme {
  static const Color canvas = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static Color iconPlateFill(BuildContext context) =>
      PreferencesUiTheme.iconPlateFill(context);

  static const Color cardFill = Colors.white;
  static const Color cardBorder = Color(0xFFE5E7EB);

  static Color chipSelectedFill(BuildContext context) =>
      context.flowAccent.chipSelectedFill;
  static Color chipSelectedBorder(BuildContext context) => primary(context);
  static const Color chipSelectedInk = kFlowFilterPillSelectedFgLight;
  static const Color chipIdleFill = Colors.white;
  static const Color chipIdleBorder = cardBorder;
  static const Color chipIdleInk = titleInk;
  static const Color chipRecommendedInk = subtitleInk;

  static const Color infoFill = Color(0xFFECFDF5);
  static const Color infoBorder = Color(0xFFD1FAE5);
  static const Color infoIcon = Color(0xFF059669);
  static const Color infoText = Color(0xFF065F46);

  static const double cardRadius = 16.0;
}
