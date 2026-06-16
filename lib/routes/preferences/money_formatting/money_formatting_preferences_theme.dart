import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class MoneyFormattingPreferencesTheme {
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
  static Color divider(BuildContext context) => cardBorder(context);

  static const Color previewLabel = Color(0xFF94A3B8);
  static const Color previewWatermark = Color(0xFFE2E8F0);
  static const Color previewHint = Color(0xFF3B82F6);

  static const Color footerFill = Color(0xFFEFF6FF);
  static const Color footerDash = Color(0xFFBFDBFE);
  static const Color footerText = Color(0xFF64748B);

  static const double cardRadius = 16.0;
}
