import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class PendingTransactionsTheme {
  static const Color canvas = Color(0xFFF8F9FB);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color primaryButtonFill(BuildContext context) => primary(context);
  static const Color cardBorder = Color(0xFFE5E7EB);

  static const Color chipSelectedFill = Color(0xFF3B82F6);
  static const Color chipSelectedInk = Colors.white;
  static const Color chipIdleFill = Color(0xFFF1F5F9);
  static const Color chipIdleInk = Color(0xFF334155);

  static const Color summaryGradientStart = Color(0xFF0F172A);
  static const Color summaryGradientEnd = Color(0xFF1E293B);
  static const Color summarySubtitle = Color(0xFF94A3B8);

  static const Color incomeAmount = Color(0xFF3B82F6);
  static const Color expenseAmount = Color(0xFF0F172A);

  static const Color secondaryButtonFill = Color(0xFFF1F5F9);
  static const Color secondaryButtonInk = Color(0xFF334155);

  static const Color infoText = Color(0xFF475569);

  static const double cardRadius = 16.0;
}
