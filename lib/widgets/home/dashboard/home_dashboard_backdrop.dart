import "dart:ui";

import "package:flutter/material.dart";

/// Home scroll canvas — soft mesh in light mode so glass panels have depth to blur.
class HomeDashboardBackdrop extends StatelessWidget {
  final Widget child;

  const HomeDashboardBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool light = scheme.brightness == Brightness.light;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _baseGradient(scheme, light),
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        if (light) ..._lightMesh(scheme),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: light ? 360.0 : 240.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.secondary.withValues(alpha: light ? 0.42 : 0.09),
                  scheme.primary.withValues(alpha: light ? 0.08 : 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  static List<Color> _baseGradient(ColorScheme scheme, bool light) {
    if (light) {
      return [
        Color.lerp(scheme.surface, scheme.secondary, 0.38)!,
        Color.lerp(scheme.surface, scheme.primary, 0.1)!,
        Color.lerp(scheme.surface, scheme.outlineVariant, 0.16)!,
      ];
    }

    final Color base = scheme.surface;
    return [
      Color.lerp(base, scheme.primary, 0.05)!,
      base,
      base,
    ];
  }

  static List<Widget> _lightMesh(ColorScheme scheme) {
    return [
      _meshOrb(
        top: 40,
        left: -50,
        size: 220,
        color: scheme.primary,
        alpha: 0.22,
      ),
      _meshOrb(
        top: 180,
        right: -70,
        size: 260,
        color: scheme.secondary,
        alpha: 0.38,
      ),
      _meshOrb(
        top: 420,
        left: 40,
        size: 180,
        color: scheme.primary,
        alpha: 0.14,
      ),
      _meshOrb(
        top: 640,
        right: -20,
        size: 200,
        color: scheme.tertiary,
        alpha: 0.18,
      ),
      _meshOrb(
        top: 900,
        left: -30,
        size: 240,
        color: scheme.secondary,
        alpha: 0.2,
      ),
    ];
  }

  static Widget _meshOrb({
    required double top,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48, tileMode: TileMode.decal),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: alpha),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
