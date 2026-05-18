import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class AccountsTabTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;
  static const Color incomeInk = Color(0xFF2563EB);
  static const Color expenseInk = Color(0xFFE11D48);
  static const Color addCardFill = Color(0xFFF8FAFC);
  static const Color addCardBorder = Color(0xFFCBD5E1);

  static const double cardRadius = 16.0;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
}
