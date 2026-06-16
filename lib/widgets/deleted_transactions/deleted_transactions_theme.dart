import "package:flow/theme/flow_color_scheme.dart" show
    kFlowAccountRowBalanceInkLight,
    kFlowHomeTransactionHeadingInk,
    kFlowSetupPrimaryCurrencyInfoTitle;
import "package:flutter/material.dart";

abstract final class DeletedTransactionsTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : Colors.white;

  static Color infoFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainer : const Color(0xFFEFF6FF);

  static Color infoBorder(BuildContext context) =>
      _isDark(context) ? _scheme(context).outlineVariant : const Color(0xFFBFDBFE);

  static const Color infoIconFill = kFlowSetupPrimaryCurrencyInfoTitle;

  static Color infoText(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurfaceVariant : const Color(0xFF475569);

  static Color sectionLabel(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurfaceVariant : const Color(0xFF64748B);

  static Color cardFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainerHigh : Colors.white;

  static Color cardBorder(BuildContext context) =>
      _isDark(context) ? _scheme(context).outlineVariant : const Color(0xFFF1F5F9);

  static Color titleInk(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurface : kFlowHomeTransactionHeadingInk;

  static Color subtitleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;

  static Color restoreFill(BuildContext context) =>
      _isDark(context) ? _scheme(context).surfaceContainer : const Color(0xFFEFF6FF);

  static const Color restoreInk = kFlowSetupPrimaryCurrencyInfoTitle;
  static const double cardRadius = 16.0;
}
