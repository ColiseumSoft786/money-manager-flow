import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class SelectCurrencySheetTheme {
  static const Color canvas = Color(0xFFF8F9FB);
  static const Color sheetFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color codeInk(BuildContext context) => primary(context);
  static const Color radioIdleBorder = Color(0xFFD1D5DB);
  static const Color popularChipFill = Color(0xFFEFF6FF);
  static const Color popularChipBorder = Color(0xFFBFDBFE);

  static const double cardRadius = 16.0;
}
