import "package:flow/entity/transaction.dart";
import "package:flow/theme/flow_accent_colors.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_custom_colors.dart";
import "package:flow/theme/pie_theme_extension.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:pie_menu/pie_menu.dart";

extension ThemeAccessor on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  FlowCustomColors get flowColors =>
      Theme.of(this).extension<FlowCustomColors>()!;
  FlowAccentColors get flowAccent =>
      Theme.of(this).extension<FlowAccentColors>() ??
      FlowAccentColors.fromColorScheme(colorScheme);
  PieTheme get pieTheme =>
      Theme.of(this).extension<PieThemeExtension>()!.pieTheme;

  /// FOSS setup globe outer ring — [ColorScheme.tertiaryFixed] (see `kFlowFossGlobeRingLight` / `kFlowFossGlobeRingDark` in `flow_color_scheme.dart`).
  Color get fossGlobeRing => colorScheme.tertiaryFixed;

  /// FOSS setup globe inner backdrop — [ColorScheme.tertiaryFixedDim].
  Color get fossGlobeInnerBackdrop => colorScheme.tertiaryFixedDim;

  /// FOSS globe Lottie bottom glow (solid; apply alpha in the widget).
  Color get fossGlobeGlowCyan => kFlowFossGlobeGlowCyan;

  Color get fossGlobeGlowCyanBright => kFlowFossGlobeGlowCyanBright;

  /// Privacy setup hero: pale outer ring (light: [ColorScheme.secondary], dark: elevated surface).
  Color get privacySetupHeroHalo => colorScheme.brightness == Brightness.light
      ? colorScheme.secondary
      : colorScheme.surfaceContainerHigh;

  /// Foreground for the lock icon on the income-colored badge.
  Color get privacySetupLockOnIncomeBadge {
    final Color badge = flowColors.income;
    return ThemeData.estimateBrightnessForColor(badge) == Brightness.dark
        ? colorScheme.surface
        : colorScheme.onSurface;
  }

  /// [ColorScheme.primary] radial halo for the privacy setup hero (center → edge).
  List<Color> get privacySetupHeroRadialPrimaryGradient => [
        colorScheme.primary.withAlpha(kFlowPrivacyHeroRadialCenterAlpha),
        colorScheme.primary.withAlpha(kFlowPrivacyHeroRadialEdgeAlpha),
      ];

  /// Outer glow under the privacy hero circle (primary + shared alpha).
  Color get privacySetupHeroPrimaryGlow =>
      colorScheme.primary.withAlpha(kFlowPrivacyHeroGlowAlpha);

  /// Soft shadow under the income badge on the privacy slide.
  Color get privacySetupBadgeShadow =>
      colorScheme.shadow.withAlpha(kFlowPrivacyBadgeShadowAlpha);

  /// Elevation shadow for setup slides’ rounded surface cards.
  Color get setupSlideCardShadowColor =>
      colorScheme.shadow.withAlpha(kFlowSetupCardShadowAlpha);

  /// Primary-currency setup info card fill ([kFlowSetupPrimaryCurrencyInfoPanelFill] in light).
  Color get setupPrimaryCurrencyInfoPanelFill =>
      colorScheme.brightness == Brightness.light
          ? kFlowSetupPrimaryCurrencyInfoPanelFill
          : colorScheme.surfaceContainerHigh;

  /// Border for [setupPrimaryCurrencyInfoPanelFill] panel.
  Color get setupPrimaryCurrencyInfoPanelBorder => flowAccent.infoPanelBorder;

  /// Secondary body line on the primary-currency info card.
  Color get setupPrimaryCurrencyInfoPanelBody =>
      colorScheme.onSurfaceVariant;

  /// Accent title on primary-currency / info cards — follows theme primary.
  Color get setupPrimaryCurrencyInfoTitleColor => flowAccent.primary;

  /// Section heading above the popular-currency list ([kFlowPopularCurrenciesSectionHeading] in light).
  Color get popularCurrenciesSectionHeadingColor =>
      colorScheme.brightness == Brightness.light
          ? kFlowPopularCurrenciesSectionHeading
          : colorScheme.onSurfaceVariant;

  /// Popular currency tile border (light grey in light mode).
  Color get popularCurrencyCardBorderColor =>
      colorScheme.brightness == Brightness.light
          ? kFlowPopularCurrencyCardBorder
          : colorScheme.outlineVariant;

  /// Leading symbol circle on popular currency tiles.
  Color get popularCurrencySymbolPlateColor =>
      colorScheme.brightness == Brightness.light
          ? kFlowPopularCurrencySymbolPlate
          : colorScheme.surfaceContainerHighest;

  /// Currency code line on popular currency tiles (slate-500 in light).
  Color get popularCurrencyTileCodeColor =>
      colorScheme.brightness == Brightness.light
          ? kFlowPopularCurrenciesSectionHeading
          : colorScheme.onSurfaceVariant;

  /// Popular currency card fill (pure white in light).
  Color get popularCurrencyTileCardFill =>
      colorScheme.brightness == Brightness.light
          ? Colors.white
          : colorScheme.surfaceContainerHigh;
}

extension TextStyleHelper on TextStyle {
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle semi(BuildContext context) =>
      copyWith(color: context.flowColors.semi);
}

extension TransactionTypeWidgetData on TransactionType {
  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Symbols.stat_minus_2_rounded;
      case TransactionType.expense:
        return Symbols.stat_2_rounded;
      case TransactionType.transfer:
        return Symbols.compare_arrows_rounded;
    }
  }

  Color color(BuildContext context) => switch (this) {
    TransactionType.income => context.flowColors.income,
    TransactionType.expense => context.flowColors.expense,
    TransactionType.transfer => context.colorScheme.onSurface,
  };

  Color actionColor(BuildContext context) => switch (this) {
    TransactionType.income => context.colorScheme.onError,
    TransactionType.expense => context.colorScheme.onError,
    TransactionType.transfer => context.colorScheme.onSecondary,
  };

  Color actionBackgroundColor(BuildContext context) => switch (this) {
    TransactionType.income => context.flowColors.income,
    TransactionType.expense => context.flowColors.expense,
    TransactionType.transfer => context.colorScheme.secondary,
  };
}
