import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class ImportPageTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) =>
      _isDark(context) ? _scheme(context).surface : Colors.white;

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
  static Color uploadIconCircle(BuildContext context) => primary(context);

  static const Color uploadFill = kFlowSetupAddCategoryCardFill;
  static const Color uploadDash = kFlowSetupAddCategoryCardDashBorder;
  static Color uploadFillResolved(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : uploadFill;
  static Color uploadDashResolved(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : uploadDash;

  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;
  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : kFlowHomeTransactionCardBorder;
  static Color chevronInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowMonthSelectorChevronInkLight;

  static const Color ivyPlate = Color(0xFFD1FAE5);
  static const Color ivyIcon = Color(0xFF059669);
  static const Color templatePlate = Color(0xFFDBEAFE);
  static Color templateIcon(BuildContext context) => primary(context);

  static Color privacyFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFF1F5F9);
  static Color privacyBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE2E8F0);
  static Color privacyText(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : const Color(0xFF475569);

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
