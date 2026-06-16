import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class LanguageSelectionTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : const Color(0xFFF8F9FB);
  static Color sheetFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainerHigh : Colors.white;
  static Color titleInk(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurface : kFlowHomeTransactionHeadingInk;
  static Color subtitleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;
  static Color border(BuildContext context) =>
      _isDark(context) ? _scheme(context).outlineVariant : const Color(0xFFE5E7EB);
  static Color divider(BuildContext context) => border(context);

  static Color primary(BuildContext context) =>
      PreferencesUiTheme.primary(context);
  static const Color radioIdleBorder = Color(0xFFD1D5DB);
  static Color searchFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainer : Colors.white;

  static const double cardRadius = 16.0;
}
