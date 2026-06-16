import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class AccountsTabTheme {
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

  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE5E7EB);

  static Color divider(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : kFlowAccountRowDividerLight;

  static Color incomeInk(BuildContext context) => _isDark(context)
      ? kFlowHomeIncomeMetricAccent
      : const Color(0xFF2563EB);

  static Color expenseInk(BuildContext context) => _isDark(context)
      ? kFlowHomeExpenseMetricAccent
      : const Color(0xFFE11D48);

  static Color addCardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFF8FAFC);

  static Color addCardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFCBD5E1);

  static List<BoxShadow> cardShadow(BuildContext context) => _isDark(context)
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ];
}
