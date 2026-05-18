import "package:flow/theme/flow_color_scheme.dart" show
    kFlowAccountRowBalanceInkLight,
    kFlowHomeTransactionHeadingInk,
    kFlowSetupPrimaryCurrencyInfoTitle;
import "package:flutter/material.dart";

abstract final class DeletedTransactionsTheme {
  static const Color canvas = Colors.white;
  static const Color infoFill = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color infoIconFill = kFlowSetupPrimaryCurrencyInfoTitle;
  static const Color infoText = Color(0xFF475569);
  static const Color sectionLabel = Color(0xFF64748B);
  static const Color cardFill = Colors.white;
  static const Color cardBorder = Color(0xFFF1F5F9);
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color restoreFill = Color(0xFFEFF6FF);
  static const Color restoreInk = kFlowSetupPrimaryCurrencyInfoTitle;
  static const double cardRadius = 16.0;
}
