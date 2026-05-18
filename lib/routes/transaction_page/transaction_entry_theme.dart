import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

/// Light entry form tokens (transaction add/edit).
abstract final class TransactionEntryTheme {
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color appBarFill = Colors.white;
  static const Color canvasLight = canvas;
  static const Color cardFillLight = Colors.white;
  static const Color segmentTrack = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;
  static Color iconPlateInk(BuildContext context) =>
      context.flowAccent.iconPlateInk;
  static Color amountSymbolInk(BuildContext context) =>
      context.flowAccent.iconPlateInk;
  static Color saveActionFill(BuildContext context) => context.flowAccent.primary;
  static const Color rowDivider = Color(0xFFF1F5F9);

  static const double cardRadius = 16.0;
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 22.0,
  );
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    20.0,
    8.0,
    20.0,
    32.0,
  );

  /// Amount hero card — soft sky tint (Figma-style).
  static const Color amountHeroTop = Color(0xFFF0F9FF);
  static const Color amountHeroBottom = Color(0xFFFFFFFF);
  static const Color amountHeroBorder = Color(0xFFBFDBFE);

  static const Color labelInk = kFlowHomeTransactionCaptionMuted;
  static const Color valueInk = kFlowHomeTransactionHeadingInk;
  static const Color placeholderInk = Color(0xFF94A3B8);
  static const Color chevronInk = kFlowMonthSelectorChevronInkLight;
  static const Color attachmentTileFill = Color(0xFFEFF6FF);
  static const Color attachmentDashedBorder = Color(0xFFCBD5E1);

  static const double iconPlateSize = 44.0;
  static const double iconPlateRadius = 12.0;

  static TextStyle sectionLabelStyle(ThemeData theme) =>
      theme.textTheme.labelSmall?.copyWith(
        color: labelInk,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        fontSize: 11.0,
      ) ??
      const TextStyle(
        color: labelInk,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        fontSize: 11.0,
      );

  /// Picker / switch row caption (e.g. Transaction date, Pending).
  static TextStyle rowCaptionStyle(ThemeData theme) => theme.textTheme.labelSmall
          ?.copyWith(
            color: labelInk,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ) ??
      const TextStyle(
        color: labelInk,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      );

  /// Primary line on compact entry rows (Add files, Pending, …).
  static TextStyle rowTitleStyle(ThemeData theme) => theme.textTheme.titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
            color: valueInk,
          ) ??
      const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        color: valueInk,
      );

  static TextStyle rowValueStyle(ThemeData theme) => theme.textTheme.titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.0,
            color: valueInk,
            height: 1.25,
          ) ??
      const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
        color: valueInk,
        height: 1.25,
      );

  static TextStyle rowPlaceholderStyle(ThemeData theme) =>
      rowValueStyle(theme).copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 13.0,
        color: placeholderInk,
      );

  static BoxDecoration cardDecoration({bool hero = false}) => BoxDecoration(
    color: hero ? null : cardFillLight,
    gradient: hero
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [amountHeroTop, amountHeroBottom],
          )
        : null,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: hero ? amountHeroBorder : cardBorder,
      width: 1.0,
    ),
    // Border only — shadows on a long scroll form add GPU cost on every frame.
    boxShadow: const [],
  );
}
