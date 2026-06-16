import "package:flow/theme/flow_color_scheme.dart" show
    kFlowAccountRowBalanceInkLight,
    kFlowFilterPillSelectedFillLight,
    kFlowFilterPillSelectedFgLight,
    kFlowFilterPillUnselectedFillLight,
    kFlowFilterPillUnselectedFgLight,
    kFlowDateRangePillFillLight,
    kFlowDateRangeSelectedCardFillLight,
    kFlowDateRangeSundayInkLight,
    kFlowDateRangeWeekdayInkLight,
    kFlowHomeHistoryCanvasLight,
    kFlowHomeTransactionCaptionMuted,
    kFlowHomeTransactionCardBorder,
    kFlowHomeTransactionHeadingInk;
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class ExportOptionsTheme {
  /// Page backdrop behind elevated white cards.
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : kFlowHomeHistoryCanvasLight;
  static Color titleInk(BuildContext context) =>
      _isDark(context) ? _scheme(context).onSurface : kFlowHomeTransactionHeadingInk;
  static Color sectionLabel(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowHomeTransactionCaptionMuted;
  static Color mutedInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowAccountRowBalanceInkLight;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;
  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : kFlowHomeTransactionCardBorder;

  static Color tabSelectedFill(BuildContext context) => _isDark(context)
      ? primary(context)
      : kFlowFilterPillSelectedFillLight;
  static Color tabSelectedInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onPrimary
      : kFlowFilterPillSelectedFgLight;
  static Color tabIdleFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : kFlowFilterPillUnselectedFillLight;
  static Color tabIdleInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowFilterPillUnselectedFgLight;

  static Color rangeSummaryFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : kFlowDateRangeSelectedCardFillLight;
  static Color calendarAccent(BuildContext context) => primary(context);
  static Color calendarPillFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : kFlowDateRangePillFillLight;
  static Color calendarSundayInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowDateRangeSundayInkLight;
  static Color calendarWeekdayInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowDateRangeWeekdayInkLight;

  static const Color csvAccent = Color(0xFF059669);
  static const Color csvPlate = Color(0xFFD1FAE5);
  static const Color zipAccent = Color(0xFF7C3AED);
  static const Color zipPlate = Color(0xFFEDE9FE);
  static const Color pdfAccent = Color(0xFFDC2626);
  static const Color pdfPlate = Color(0xFFFEE2E2);

  static const double cardRadius = 18.0;
}
