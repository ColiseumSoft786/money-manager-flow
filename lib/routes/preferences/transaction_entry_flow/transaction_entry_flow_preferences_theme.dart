import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class TransactionEntryFlowPreferencesTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color heroFill = Color(0xFFEFF6FF);
  static const Color heroTitle = Color(0xFF1E3A5F);
  static const Color heroSubtitle = Color(0xFF64748B);
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static Color iconPlateFill(BuildContext context) =>
      PreferencesUiTheme.iconPlateFill(context);

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color dragChipFill = Color(0xFFF1F5F9);

  static const double cardRadius = 16.0;
}
