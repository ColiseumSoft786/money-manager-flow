import "package:flutter/material.dart";

/// Accent palette derived from [ColorScheme.primary] for redesigned UI surfaces.
///
/// Registered on [ThemeData] so icon plates, chips, and CTAs follow the user's
/// chosen theme color.
@immutable
class FlowAccentColors extends ThemeExtension<FlowAccentColors> {
  final Color primary;
  final Color onPrimary;
  final Color iconPlateFill;
  final Color iconPlateInk;
  final Color softFill;
  final Color chipSelectedFill;
  final Color chipSelectedBorder;
  final Color infoPanelFill;
  final Color infoPanelBorder;
  final Color heroGradientStart;
  final Color heroGradientEnd;

  const FlowAccentColors({
    required this.primary,
    required this.onPrimary,
    required this.iconPlateFill,
    required this.iconPlateInk,
    required this.softFill,
    required this.chipSelectedFill,
    required this.chipSelectedBorder,
    required this.infoPanelFill,
    required this.infoPanelBorder,
    required this.heroGradientStart,
    required this.heroGradientEnd,
  });

  factory FlowAccentColors.fromColorScheme(ColorScheme scheme) {
    final Color primary = scheme.primary;
    return FlowAccentColors(
      primary: primary,
      onPrimary: scheme.onPrimary,
      iconPlateFill: primary.withValues(alpha: 0.12),
      iconPlateInk: primary,
      softFill: primary.withValues(alpha: 0.08),
      chipSelectedFill: primary.withValues(alpha: 0.12),
      chipSelectedBorder: primary,
      infoPanelFill: primary.withValues(alpha: 0.10),
      infoPanelBorder: primary.withValues(alpha: 0.30),
      heroGradientStart: primary,
      heroGradientEnd: Color.lerp(primary, const Color(0xFF000000), 0.12) ?? primary,
    );
  }

  @override
  FlowAccentColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? iconPlateFill,
    Color? iconPlateInk,
    Color? softFill,
    Color? chipSelectedFill,
    Color? chipSelectedBorder,
    Color? infoPanelFill,
    Color? infoPanelBorder,
    Color? heroGradientStart,
    Color? heroGradientEnd,
  }) {
    return FlowAccentColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      iconPlateFill: iconPlateFill ?? this.iconPlateFill,
      iconPlateInk: iconPlateInk ?? this.iconPlateInk,
      softFill: softFill ?? this.softFill,
      chipSelectedFill: chipSelectedFill ?? this.chipSelectedFill,
      chipSelectedBorder: chipSelectedBorder ?? this.chipSelectedBorder,
      infoPanelFill: infoPanelFill ?? this.infoPanelFill,
      infoPanelBorder: infoPanelBorder ?? this.infoPanelBorder,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
    );
  }

  @override
  FlowAccentColors lerp(ThemeExtension<FlowAccentColors>? other, double t) {
    if (other is! FlowAccentColors) return this;
    return FlowAccentColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      iconPlateFill: Color.lerp(iconPlateFill, other.iconPlateFill, t)!,
      iconPlateInk: Color.lerp(iconPlateInk, other.iconPlateInk, t)!,
      softFill: Color.lerp(softFill, other.softFill, t)!,
      chipSelectedFill: Color.lerp(chipSelectedFill, other.chipSelectedFill, t)!,
      chipSelectedBorder: Color.lerp(chipSelectedBorder, other.chipSelectedBorder, t)!,
      infoPanelFill: Color.lerp(infoPanelFill, other.infoPanelFill, t)!,
      infoPanelBorder: Color.lerp(infoPanelBorder, other.infoPanelBorder, t)!,
      heroGradientStart: Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
    );
  }
}
