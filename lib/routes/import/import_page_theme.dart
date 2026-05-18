import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class ImportPageTheme {
  static const Color canvas = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;
  static const Color sectionLabel = kFlowHomeTransactionCaptionMuted;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color uploadIconCircle(BuildContext context) => primary(context);

  static const Color uploadFill = kFlowSetupAddCategoryCardFill;
  static const Color uploadDash = kFlowSetupAddCategoryCardDashBorder;

  static const Color cardFill = Colors.white;
  static const Color cardBorder = kFlowHomeTransactionCardBorder;
  static const Color chevronInk = kFlowMonthSelectorChevronInkLight;

  static const Color ivyPlate = Color(0xFFD1FAE5);
  static const Color ivyIcon = Color(0xFF059669);
  static const Color templatePlate = Color(0xFFDBEAFE);
  static Color templateIcon(BuildContext context) => primary(context);

  static const Color privacyFill = Color(0xFFF1F5F9);
  static const Color privacyBorder = Color(0xFFE2E8F0);
  static const Color privacyText = Color(0xFF475569);

  static const double cardRadius = 16.0;
  static const double uploadRadius = 16.0;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: kFlowHomeTransactionCardShadowColor,
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
}
