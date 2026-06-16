import "package:flutter/material.dart";
import "package:loading_indicator/loading_indicator.dart";

/// Indefinite waiting indicator — uses [loading_indicator] for consistent motion.
class Spinner extends StatelessWidget {
  final bool center;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Indicator indicatorType;

  const Spinner({
    super.key,
    this.center = false,
    this.size = 36.0,
    this.strokeWidth = 2.5,
    this.color,
    this.indicatorType = Indicator.lineSpinFadeLoader,
  });

  const Spinner.center({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 2.5,
    this.color,
    this.indicatorType = Indicator.lineSpinFadeLoader,
  }) : center = true;

  /// Compact indicator for buttons, search fields, and app bars.
  const Spinner.inline({
    super.key,
    this.size = 22.0,
    this.strokeWidth = 2.0,
    this.color,
    this.indicatorType = Indicator.ballClipRotate,
  }) : center = false;

  @override
  Widget build(BuildContext context) {
    final Color ink = color ?? Theme.of(context).colorScheme.primary;

    final Widget indicator = SizedBox(
      width: size,
      height: size,
      child: LoadingIndicator(
        indicatorType: indicatorType,
        colors: <Color>[ink, ink.withValues(alpha: 0.45)],
        strokeWidth: strokeWidth,
      ),
    );

    if (center) {
      return Center(child: indicator);
    }

    return indicator;
  }
}
