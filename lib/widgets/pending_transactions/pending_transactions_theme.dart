import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class PendingTransactionsTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) => _isDark(context)
      ? _scheme(context).surface
      : const Color(0xFFF8F9FB);

  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;

  static Color titleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowHomeTransactionHeadingInk;

  static Color subtitleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;

  static Color sectionLabel(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color primaryButtonFill(BuildContext context) => primary(context);
  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE5E7EB);

  static const Color chipSelectedFill = Color(0xFF3B82F6);
  static const Color chipSelectedInk = Colors.white;
  static Color chipIdleFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFF1F5F9);
  static Color chipIdleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : const Color(0xFF334155);

  static Color summaryGradientStart(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHighest
      : const Color(0xFF0F172A);
  static Color summaryGradientEnd(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : const Color(0xFF1E293B);
  static Color summarySubtitle(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : const Color(0xFF94A3B8);

  static const Color incomeAmount = Color(0xFF3B82F6);
  static Color expenseAmount(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : const Color(0xFF0F172A);

  static Color secondaryButtonFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFF1F5F9);
  static Color secondaryButtonInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : const Color(0xFF334155);

  static Color infoText(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : const Color(0xFF475569);

  static Color infoBannerFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFEFF6FF);

  static Color infoBannerBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFDBEAFE);

  static Color switchInactiveTrack(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHighest
      : const Color(0xFFE5E7EB);

  static const double cardRadius = 16.0;
}
