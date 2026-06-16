import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

abstract final class TransactionEntryFlowPreferencesTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : const Color(0xFFF7F8FA);

  static Color cardFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainerHigh : Colors.white;

  static const Color heroFill = Color(0xFFEFF6FF);
  static const Color heroTitle = Color(0xFF1E3A5F);
  static const Color heroSubtitle = Color(0xFF64748B);
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
  static const Color dragChipFill = Color(0xFFF1F5F9);

  static const double cardRadius = 16.0;
}
