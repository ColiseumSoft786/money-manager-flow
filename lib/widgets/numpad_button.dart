import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";

/// Visual role for a numpad key (digits vs operators vs confirm).
enum NumpadKeyStyle { digit, utility, accent }

class NumpadButton extends StatelessWidget {
  /// When set, treated as [NumpadKeyStyle.accent].
  final Color? backgroundColor;

  final NumpadKeyStyle? style;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  final int crossAxisCellCount;
  final int mainAxisCellCount;

  final double borderRadiusSize;

  /// Ideally an [Icon] or [Text] widget with single character text.
  final Widget child;

  const NumpadButton({
    super.key,
    required this.child,
    this.backgroundColor,
    this.style,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.borderRadiusSize = 14.0,
    this.crossAxisCellCount = 1,
    this.mainAxisCellCount = 1,
  });

  NumpadKeyStyle get _resolvedStyle {
    if (style != null) return style!;
    if (backgroundColor != null) return NumpadKeyStyle.accent;
    if (child is Icon) return NumpadKeyStyle.utility;
    return NumpadKeyStyle.digit;
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;
    final NumpadKeyStyle keyStyle = _resolvedStyle;
    final BorderRadius borderRadius = BorderRadius.circular(borderRadiusSize);

    final Color fill = _fillColor(context, light, scheme, keyStyle);
    final Color border = _borderColor(context, light, scheme, keyStyle);
    final List<BoxShadow> shadows = _shadows(context, light, keyStyle);

    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap == null ? null : onTapHandler,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: scheme.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: borderRadius,
              border: Border.all(color: border, width: 1.0),
              boxShadow: shadows,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Color _fillColor(
    BuildContext context,
    bool light,
    ColorScheme scheme,
    NumpadKeyStyle keyStyle,
  ) {
    if (backgroundColor != null) return backgroundColor!;

    return switch (keyStyle) {
      NumpadKeyStyle.accent => scheme.primary,
      NumpadKeyStyle.utility => light
          ? scheme.surfaceContainerHighest
          : scheme.surfaceContainerHigh,
      NumpadKeyStyle.digit => light ? scheme.surface : scheme.surfaceContainer,
    };
  }

  Color _borderColor(
    BuildContext context,
    bool light,
    ColorScheme scheme,
    NumpadKeyStyle keyStyle,
  ) {
    if (backgroundColor != null) {
      return backgroundColor!.withValues(alpha: 0.85);
    }

    return switch (keyStyle) {
      NumpadKeyStyle.accent => scheme.primary.withValues(alpha: 0.5),
      NumpadKeyStyle.utility => light
          ? const Color(0xFFE2E8F0)
          : scheme.outlineVariant.withValues(alpha: 0.55),
      NumpadKeyStyle.digit => light
          ? const Color(0xFFE8ECF1)
          : scheme.outlineVariant.withValues(alpha: 0.4),
    };

    
  }

  List<BoxShadow> _shadows(
    BuildContext context,
    bool light,
    NumpadKeyStyle keyStyle,
  ) {
    if (!light || keyStyle == NumpadKeyStyle.utility) {
      return const [];
    }

    final double alpha = keyStyle == NumpadKeyStyle.accent ? 0.14 : 0.05;
    final double blur = keyStyle == NumpadKeyStyle.accent ? 8.0 : 4.0;
    final double offsetY = keyStyle == NumpadKeyStyle.accent ? 3.0 : 2.0;

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: blur,
        offset: Offset(0, offsetY),
      ),
    ];
  }
  

 

  void onTapHandler() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    onTap?.call();
  }
}
