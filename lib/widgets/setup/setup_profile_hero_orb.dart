import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Neutral person ornament on [SetupProfilePage] — no blue ring or blue-tinted shadow.
///
/// Tint tokens: `flow_color_scheme.dart`.
class SetupProfileHeroOrb extends StatelessWidget {
  final double diameter;

  const SetupProfileHeroOrb({
    super.key,
    this.diameter = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;

    final Color orbFill =
        light ? kFlowPopularCurrencySymbolPlate : scheme.surfaceContainerHigh;
    final Color ringColor =
        light ? kFlowSetupAccountCardBorder : scheme.outlineVariant;
    final Color iconColor =
        light ? kFlowPopularCurrenciesSectionHeading : scheme.onSurfaceVariant;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orbFill,
        border: Border.all(color: ringColor, width: light ? 1.0 : 1.0),
        boxShadow: light
            ? const [
                BoxShadow(
                  color: kFlowSetupAccountCardShadow,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Symbols.person_rounded,
        size: diameter * 0.38,
        color: iconColor,
        fill: 0.0,
      ),
    );
  }
}
