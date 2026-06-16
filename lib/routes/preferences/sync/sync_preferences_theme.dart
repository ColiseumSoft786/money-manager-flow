import "package:flow/routes/preferences/preferences_ui_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class SyncPreferencesTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : Colors.white;

  static Color titleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowHomeTransactionHeadingInk;

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

  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;
  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE5E7EB);

  static Color chipSelectedFill(BuildContext context) =>
      context.flowAccent.chipSelectedFill;
  static Color chipSelectedBorder(BuildContext context) => primary(context);
  static const Color chipSelectedInk = kFlowFilterPillSelectedFgLight;
  static Color chipIdleFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainer : Colors.white;
  static Color chipIdleBorder(BuildContext context) => cardBorder(context);
  static Color chipIdleInk(BuildContext context) => titleInk(context);
  static Color chipRecommendedInk(BuildContext context) =>
      subtitleInk(context);

  static const Color infoFill = Color(0xFFECFDF5);
  static const Color infoBorder = Color(0xFFD1FAE5);
  static const Color infoIcon = Color(0xFF059669);
  static const Color infoText = Color(0xFF065F46);

  static const double cardRadius = 16.0;
}
