import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class TransactionGeoPreferencesTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : const Color(0xFFF4F7F9);
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
  static Color divider(BuildContext context) => cardBorder(context);

  static const Color mapParkFill = Color(0xFFD8E8D4);
  static const Color mapRoadFill = Color(0xFFE8ECF0);
  static const Color mapBlockFill = Color(0xFFCFD8DC);
  static const Color mapPin = Color(0xFF0F766E);

  static const double cardRadius = 16.0;
  static const double mapRadius = 16.0;
}
