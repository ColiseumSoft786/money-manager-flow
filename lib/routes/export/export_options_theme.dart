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
  static const Color canvas = kFlowHomeHistoryCanvasLight;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;
  static const Color mutedInk = kFlowAccountRowBalanceInkLight;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static const Color cardFill = Colors.white;
  static const Color cardBorder = kFlowHomeTransactionCardBorder;

  static const Color tabSelectedFill = kFlowFilterPillSelectedFillLight;
  static const Color tabSelectedInk = kFlowFilterPillSelectedFgLight;
  static const Color tabIdleFill = kFlowFilterPillUnselectedFillLight;
  static const Color tabIdleInk = kFlowFilterPillUnselectedFgLight;

  static const Color rangeSummaryFill = kFlowDateRangeSelectedCardFillLight;
  static Color calendarAccent(BuildContext context) => primary(context);
  static const Color calendarPillFill = kFlowDateRangePillFillLight;
  static const Color calendarSundayInk = kFlowDateRangeSundayInkLight;
  static const Color calendarWeekdayInk = kFlowDateRangeWeekdayInkLight;

  static const Color csvAccent = Color(0xFF059669);
  static const Color csvPlate = Color(0xFFD1FAE5);
  static const Color zipAccent = Color(0xFF7C3AED);
  static const Color zipPlate = Color(0xFFEDE9FE);
  static const Color pdfAccent = Color(0xFFDC2626);
  static const Color pdfPlate = Color(0xFFFEE2E2);

  static const double cardRadius = 18.0;
}
