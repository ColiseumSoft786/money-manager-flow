import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class PreferencesRootTheme {
  static const double cardRadius = 16.0;
  static const double accordionSpacing = 12.0;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) => _isDark(context)
      ? _scheme(context).surface
      : const Color(0xFFF7F8FA);

  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;

  static Color titleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowHomeTransactionHeadingInk;

  static Color subtitleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;

  static Color primary(BuildContext context) => context.flowAccent.primary;

  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE5E7EB);

  static Color divider(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : kFlowAccountRowDividerLight;

  static Color switchInactiveTrack(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHighest
      : const Color(0xFFE5E7EB);
}
