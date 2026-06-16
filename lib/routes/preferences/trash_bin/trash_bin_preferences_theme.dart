import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class TrashBinPreferencesTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : const Color(0xFFF8F9FB);
  static Color cardFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainerHigh : Colors.white;
  static Color titleInk(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurface : kFlowHomeTransactionHeadingInk;
  static Color subtitleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;
  static Color sectionLabel(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static Color iconPlateFill(BuildContext context) =>
      PreferencesUiTheme.iconPlateFill(context);

  static Color cardBorder(BuildContext context) =>
      _isDark(context) ? _scheme(context).outlineVariant : const Color(0xFFE5E7EB);

  static const Color chipSelectedFill = Color(0xFF3B82F6);
  static const Color chipSelectedInk = Colors.white;
  static const Color chipIdleFill = Color(0xFFF1F5F9);
  static const Color chipIdleInk = Color(0xFF334155);

  static const Color infoFill = Color(0xFFE2E8F0);
  static const Color infoText = Color(0xFF64748B);
  static const Color infoWatermark = Color(0xFFCBD5E1);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBorder = Color(0xFFFECACA);

  static const double cardRadius = 16.0;
}
