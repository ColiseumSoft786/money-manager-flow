import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class SelectCurrencySheetTheme {
  static bool _light(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static Color canvas(BuildContext context) => _light(context)
      ? const Color(0xFFF8F9FB)
      : Theme.of(context).colorScheme.surface;

  static Color sheetFill(BuildContext context) => _light(context)
      ? Colors.white
      : Theme.of(context).colorScheme.surfaceContainerHigh;

  static Color titleInk(BuildContext context) => _light(context)
      ? kFlowHomeTransactionHeadingInk
      : Theme.of(context).colorScheme.onSurface;

  static Color subtitleInk(BuildContext context) => _light(context)
      ? kFlowAccountRowBalanceInkLight
      : Theme.of(context).colorScheme.onSurfaceVariant;

  static Color border(BuildContext context) => _light(context)
      ? const Color(0xFFE5E7EB)
      : Theme.of(context).colorScheme.outlineVariant;

  static Color divider(BuildContext context) => _light(context)
      ? kFlowAccountRowDividerLight
      : Theme.of(context).colorScheme.outlineVariant;

  static Color primary(BuildContext context) => context.flowAccent.primary;

  static Color codeInk(BuildContext context) => primary(context);

  static Color radioIdleBorder(BuildContext context) => _light(context)
      ? const Color(0xFFD1D5DB)
      : Theme.of(context).colorScheme.outlineVariant;

  static Color popularChipFill(BuildContext context) => _light(context)
      ? const Color(0xFFEFF6FF)
      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.14);

  static Color popularChipBorder(BuildContext context) => _light(context)
      ? const Color(0xFFBFDBFE)
      : Theme.of(context).colorScheme.primary;

  static Color rowSelectedFill(BuildContext context) => _light(context)
      ? const Color(0xFFEFF6FF)
      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);

  static const double cardRadius = 16.0;
}
