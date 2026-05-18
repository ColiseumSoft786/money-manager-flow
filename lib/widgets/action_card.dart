import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class ActionCard extends StatelessWidget {
  /// Rounded square behind the leading icon (matches onboarding-style mocks).
  static const double _iconChipDimension = 56.0;
  static const double _iconChipRadius = 14.0;
  static const double _iconGlyphSize = 30.0;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final FlowIconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  final BorderRadius borderRadius;

  /// When set, used as the card fill ([Surface.color]). Defaults to theme card
  /// color (often [ColorScheme.secondary]).
  final Color? color;

  /// Passed to [Surface.surfaceTintColor]. Use [Colors.transparent] with a
  /// light [color] to avoid Material 3 blue tint on iOS.
  final Color? surfaceTintColor;

  final Color? shadowColor;
  final double? elevation;

  const ActionCard({
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const .all(Radius.circular(16.0)),
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.color,
    this.surfaceTintColor,
    this.shadowColor,
    this.elevation,
  });

  /// Icon badge fill: pale blue on custom light cards; light chip on default
  /// cards; elevated tone on dark.
  static Color _iconChipFill(ColorScheme scheme, Color? cardColor) {
    if (scheme.brightness == Brightness.light) {
      return cardColor != null ? scheme.secondary : scheme.surface;
    }
    return cardColor != null
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainerHigh;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color iconChipFill = _iconChipFill(scheme, color);

    return SizedBox(
      width: double.infinity,
      child: Surface(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: color,
        surfaceTintColor: surfaceTintColor,
        shadowColor: shadowColor,
        elevation: elevation ?? 0.0,
        builder: (context) => InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (icon != null) ...[
                  SizedBox(
                    width: _iconChipDimension,
                    height: _iconChipDimension,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconChipFill,
                        borderRadius: BorderRadius.circular(_iconChipRadius),
                      ),
                      child: Center(
                        child: FlowIcon(
                          icon!,
                          size: _iconGlyphSize,
                          plated: false,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
                Text(title, style: context.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4.0),
                  Text(subtitle!, style: context.textTheme.bodyMedium),
                ],
                if (trailing != null) ...[
                  const SizedBox(height: 8.0),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
