import "package:dashed_border/dashed_border.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class Button extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget child;

  final Widget? leading;
  final Widget? trailing;

  final EdgeInsets padding;
  final BorderRadius borderRadius;

  final Color? backgroundColor;

  /// When set, used for label (and icons if [iconColor] is null) instead of
  /// [ColorScheme.onSurface]. Use with [backgroundColor] for filled buttons.
  final Color? foregroundColor;

  /// Overrides icon color for [leading] / [trailing]. Defaults to
  /// [foregroundColor] when that is non-null.
  final Color? iconColor;

  /// When true with [leading]/[trailing], content is centered in a full-width
  /// bar (e.g. primary CTA pills).
  final bool fullWidth;

  final double elevation;

  final Color? shadowColor;

  final Color? surfaceTintColor;

  /// When true, renders a dashed outline instead of a filled [Surface] card.
  final bool dashedBorder;

  /// Stroke color for [dashedBorder]. Defaults to [ColorScheme.outline].
  final Color? dashedBorderColor;

  const Button({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.fullWidth = false,
    this.elevation = 0.0,
    this.shadowColor,
    this.surfaceTintColor,
    this.dashedBorder = false,
    this.dashedBorderColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.borderRadius = const .all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    late final EdgeInsets padding;

    if (trailing != null || leading != null) {
      final Widget rowWidget = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [?leading, this.child, ?trailing],
      );
      child = fullWidth
          ? SizedBox(width: double.infinity, child: Center(child: rowWidget))
          : rowWidget;
      padding = this.padding.copyWith(
        left: (this.padding.left - (leading != null ? 4.0 : 0.0)).clamp(
          0.0,
          double.infinity,
        ),
        right: (this.padding.right - (trailing != null ? 4.0 : 0.0)).clamp(
          0.0,
          double.infinity,
        ),
      );
    } else {
      child = fullWidth
          ? SizedBox(
              width: double.infinity,
              child: Center(child: this.child),
            )
          : this.child;
      padding = this.padding;
    }

    final bool disabled = onTap == null && onLongPress == null;
    final Color resolvedForeground = disabled
        ? context.colorScheme.onSurface.withAlpha(0x99)
        : (foregroundColor ?? context.colorScheme.onSurface);

    final TextStyle? mergedLabelStyle = context.textTheme.labelLarge?.copyWith(
      color: resolvedForeground,
      fontWeight: dashedBorder
          ? FontWeight.w500
          : (foregroundColor != null ? FontWeight.w600 : FontWeight.w500),
    );

    if (dashedBorder) {
      final Color dashColor =
          dashedBorderColor ?? context.colorScheme.outline;
      final Widget dashed = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          onLongPress: disabled ? null : onLongPress,
          borderRadius: borderRadius,
          child: Container(
            width: fullWidth ? double.infinity : null,
            padding: padding,
            decoration: BoxDecoration(
              color: disabled
                  ? context.colorScheme.onSurface.withAlpha(0x12)
                  : backgroundColor,
              borderRadius: borderRadius,
              border: DashedBorder(
                color: disabled ? dashColor.withAlpha(0x66) : dashColor,
                width: 1.0,
                borderRadius: borderRadius,
                dashLength: 5.0,
                dashGap: 4.0,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: mergedLabelStyle,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: iconColor ?? resolvedForeground,
                  size: 22.0,
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
      return fullWidth ? SizedBox(width: double.infinity, child: dashed) : dashed;
    }

    final Widget surface = Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      color: disabled
          ? context.colorScheme.onSurface.withAlpha(0x61)
          : backgroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      iconColor: iconColor ?? foregroundColor,
      builder: (context) => InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: mergedLabelStyle,
            child: child,
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: surface) : surface;
  }
}
