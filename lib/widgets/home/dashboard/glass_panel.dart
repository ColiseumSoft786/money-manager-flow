import "dart:ui";

import "package:flutter/material.dart";

/// Frosted glass — light mode uses mesh-backed blur + translucent gradient fill.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Gradient? gradient;
  final double blurSigma;
  final Color? borderColor;
  final Color? tint;
  final bool blurBehind;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.fillColor,
    this.gradient,
    this.blurSigma = 24.0,
    this.borderColor,
    this.tint,
    this.blurBehind = true,
  });

  static bool _isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static bool _primaryIsLight(Color primary) =>
      ThemeData.estimateBrightnessForColor(primary) == Brightness.light;

  static LinearGradient _lightGlassGradient(
    BuildContext context, {
    Color? tint,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = tint ?? scheme.primary;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.55),
        Color.alphaBlend(accent.withValues(alpha: 0.07), Colors.white.withValues(alpha: 0.28)),
        Colors.white.withValues(alpha: 0.14),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  static Color resolveFill(
    BuildContext context, {
    Color? tint,
    Color? override,
  }) {
    if (override != null) return override;

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool light = _isLight(context);

    if (light) {
      return Colors.white.withValues(alpha: 0.18);
    }

    final Color frost = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.07),
      scheme.surface.withValues(alpha: 0.42),
    );
    if (tint == null) return frost;
    return Color.alphaBlend(tint.withValues(alpha: 0.1), frost);
  }

  static LinearGradient metricGradient(BuildContext context, Color accent) {
    final bool light = _isLight(context);
    if (light) return _lightGlassGradient(context, tint: accent);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.alphaBlend(accent.withValues(alpha: 0.2), scheme.surface.withValues(alpha: 0.5)),
        Color.alphaBlend(accent.withValues(alpha: 0.08), scheme.surface.withValues(alpha: 0.35)),
      ],
    );
  }

  static Color resolveMetricBorder(BuildContext context, Color accent) {
    final bool light = _isLight(context);
    return accent.withValues(alpha: light ? 0.28 : 0.45);
  }

  static Color resolveBorder(BuildContext context) {
    if (_isLight(context)) {
      return Colors.white.withValues(alpha: 0.82);
    }
    return Colors.white.withValues(alpha: 0.12);
  }

  static Color resolveProminentBorder(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (_isLight(context)) {
      return Color.alphaBlend(
        Colors.white.withValues(alpha: 0.88),
        scheme.primary.withValues(alpha: 0.22),
      );
    }
    return scheme.primary.withValues(alpha: 0.35);
  }

  static Color resolveListTileFill(BuildContext context) => resolveFill(context);

  static Color resolveListTileBorder(BuildContext context) => resolveBorder(context);

  static double resolveListTileBlur(BuildContext context) =>
      _isLight(context) ? 30.0 : 28.0;

  static Color accentInk(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color primary = scheme.primary;

    if (!_isLight(context)) return primary;

    if (_primaryIsLight(primary)) {
      return Color.lerp(primary, scheme.onSurface, 0.5)!;
    }
    return primary;
  }

  static Color mutedInk(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return _isLight(context)
        ? scheme.onSurfaceVariant.withValues(alpha: 0.85)
        : scheme.onSurface.withValues(alpha: 0.65);
  }

  static Color heroInk(BuildContext context, Color primary, Color onPrimary) {
    if (_primaryIsLight(primary)) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return onPrimary;
  }

  static double resolveBlur(BuildContext context) =>
      _isLight(context) ? 28.0 : 26.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool light = _isLight(context);
    final double blur = blurSigma > 0 ? blurSigma : resolveBlur(context);

    Widget content = Padding(padding: padding, child: child);

    content = ClipRRect(
      borderRadius: borderRadius,
      child: blurBehind
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
                tileMode: TileMode.clamp,
              ),
              child: _buildGlassSurface(context, content, light: light),
            )
          : _buildGlassSurface(context, content, light: light),
    );

    if (light) {
      content = _buildLightRim(content);
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: scheme.primary.withValues(alpha: 0.1),
          highlightColor: scheme.primary.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildGlassSurface(
    BuildContext context,
    Widget child, {
    required bool light,
  }) {
    if (fillColor != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? resolveBorder(context),
            width: light ? 1.2 : 1.0,
          ),
        ),
        child: child,
      );
    }

    final Gradient? panelGradient = gradient ??
        (light ? _lightGlassGradient(context, tint: tint) : null);

  final Color? panelColor = panelGradient == null
        ? resolveFill(context, tint: tint)
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: panelGradient,
        color: panelColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? resolveBorder(context),
          width: light ? 1.2 : 1.0,
        ),
      ),
      child: child,
    );
  }

  /// Bright top edge + faint inner depth for light glass.
  Widget _buildLightRim(Widget child) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.02),
                  ],
                  stops: const [0.0, 0.18, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
