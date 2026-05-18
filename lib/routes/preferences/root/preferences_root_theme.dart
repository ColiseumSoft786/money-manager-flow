import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

abstract final class PreferencesRootTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color cardFill = Colors.white;
  static const Color titleInk = kFlowHomeTransactionHeadingInk;
  static const Color subtitleInk = kFlowAccountRowBalanceInkLight;

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = kFlowAccountRowDividerLight;

  static const double cardRadius = 16.0;
  static const double accordionSpacing = 12.0;
}
