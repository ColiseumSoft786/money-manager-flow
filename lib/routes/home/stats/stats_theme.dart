import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class StatsTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static const Color incomeFill = Color(0xFFEFF6FF);
  static const Color incomeInk = Color(0xFF2563EB);
  static const Color expenseFill = Color(0xFFFFF1F2);
  static const Color expenseInk = Color(0xFFE11D48);

  static const Color chartBarMuted = Color(0xFFE5E7EB);
  static const Color chartTooltipFill = Color(0xFF1E293B);

  static const Color segmentIdleFill = Color(0xFFE5E7EB);
  static const Color segmentSelectedFill = Colors.white;

  static const double cardRadius = 16.0;
}
