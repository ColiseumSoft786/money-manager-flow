import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class ChangeVisualsPreferencesTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static Color iconPlateFill(BuildContext context) =>
      PreferencesUiTheme.iconPlateFill(context);
  static Color chartBarActive(BuildContext context) => primary(context);
  static Color actionButtonFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color chartTrack = Color(0xFFF1F5F9);
  static const Color chartBarMuted = Color(0xFFBFDBFE);
  static const Color actionButtonMutedFill = Color(0xFFF8FAFC);
  static const Color badgeInk = Color(0xFF3B82F6);

  static const double cardRadius = 16.0;
}
