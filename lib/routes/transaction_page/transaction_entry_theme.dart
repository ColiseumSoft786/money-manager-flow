import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

/// Light entry form tokens (transaction add/edit).
abstract final class TransactionEntryTheme {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color canvas(BuildContext context) => _isDark(context)
      ? _scheme(context).surface
      : const Color(0xFFF7F8FA);

  static Color appBarFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surface
      : Colors.white;

  static Color cardFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : Colors.white;

  static Color segmentTrack(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFF1F5F9);

  static Color cardBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFE2E8F0);

  static Color primary(BuildContext context) => context.flowAccent.primary;
  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;
  static Color iconPlateInk(BuildContext context) =>
      context.flowAccent.iconPlateInk;
  static Color amountSymbolInk(BuildContext context) =>
      context.flowAccent.iconPlateInk;
  static Color saveActionFill(BuildContext context) => context.flowAccent.primary;
  static Color rowDivider(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFF1F5F9);

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
  static Color amountHeroTop(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHigh
      : const Color(0xFFF0F9FF);

  static Color amountHeroBottom(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainer
      : const Color(0xFFFFFFFF);

  static Color amountHeroBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFBFDBFE);

  static Color labelInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowHomeTransactionCaptionMuted;

  static Color valueInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurface
      : kFlowHomeTransactionHeadingInk;

  static Color placeholderInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant.withValues(alpha: 0.75)
      : const Color(0xFF94A3B8);

  static Color chevronInk(BuildContext context) => _isDark(context)
      ? _scheme(context).onSurfaceVariant
      : kFlowMonthSelectorChevronInkLight;

  static Color attachmentTileFill(BuildContext context) => _isDark(context)
      ? _scheme(context).surfaceContainerHighest
      : const Color(0xFFEFF6FF);

  static Color attachmentDashedBorder(BuildContext context) => _isDark(context)
      ? _scheme(context).outlineVariant
      : const Color(0xFFCBD5E1);

  static const double iconPlateSize = 44.0;
  static const double iconPlateRadius = 12.0;

  static TextStyle sectionLabelStyle(BuildContext context, ThemeData theme) =>
      theme.textTheme.labelSmall?.copyWith(
        color: labelInk(context),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        fontSize: 11.0,
      ) ??
      const TextStyle(
        // Fallback color is handled by theme; keep a sane default.
        color: kFlowHomeTransactionCaptionMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        fontSize: 11.0,
      );

  /// Picker / switch row caption (e.g. Transaction date, Pending).
  static TextStyle rowCaptionStyle(BuildContext context, ThemeData theme) =>
      theme.textTheme.labelSmall
          ?.copyWith(
            color: labelInk(context),
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ) ??
      const TextStyle(
        color: kFlowHomeTransactionCaptionMuted,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      );

  /// Primary line on compact entry rows (Add files, Pending, …).
  static TextStyle rowTitleStyle(BuildContext context, ThemeData theme) =>
      theme.textTheme.titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
            color: valueInk(context),
          ) ??
      const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        color: kFlowHomeTransactionHeadingInk,
      );

  static TextStyle rowValueStyle(BuildContext context, ThemeData theme) =>
      theme.textTheme.titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.0,
            color: valueInk(context),
            height: 1.25,
          ) ??
      const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
        color: kFlowHomeTransactionHeadingInk,
        height: 1.25,
      );

  static TextStyle rowPlaceholderStyle(BuildContext context, ThemeData theme) =>
      rowValueStyle(context, theme).copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 13.0,
        color: placeholderInk(context),
      );

  static BoxDecoration cardDecoration(BuildContext context, {bool hero = false}) =>
      BoxDecoration(
    color: hero ? null : cardFill(context),
    gradient: hero
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [amountHeroTop(context), amountHeroBottom(context)],
          )
        : null,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: hero ? amountHeroBorder(context) : cardBorder(context),
      width: 1.0,
    ),
    // Border only — shadows on a long scroll form add GPU cost on every frame.
    boxShadow: const [],
  );
}
