import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class StatsTheme {
  static const double cardRadius = 16.0;

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

  static Color sectionLabel(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;

  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE5E7EB);

  static Color divider(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : kFlowAccountRowDividerLight;

  static Color incomeFill(BuildContext context) => _isDark(context)
      ? kFlowHomeIncomeMetricFillDark
      : const Color(0xFFEFF6FF);

  static Color incomeInk(BuildContext context) => _isDark(context)
      ? kFlowHomeIncomeMetricAccent
      : const Color(0xFF2563EB);

  static Color expenseFill(BuildContext context) => _isDark(context)
      ? kFlowHomeExpenseMetricFillDark
      : const Color(0xFFFFF1F2);

  static Color expenseInk(BuildContext context) => _isDark(context)
      ? kFlowHomeExpenseMetricAccent
      : const Color(0xFFE11D48);

  static Color chartBarMuted(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHighest
      : const Color(0xFFE5E7EB);

  static Color chartTooltipFill(BuildContext context) => _isDark(context)
      ? _scheme(context).inverseSurface
      : const Color(0xFF1E293B);

  static Color segmentIdleFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFE5E7EB);

  static Color segmentSelectedFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;
}
