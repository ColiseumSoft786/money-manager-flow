import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flutter/material.dart";

/// Individual frosted glass filter pill (Search, This month, etc.).
class FlowFilterChipPill extends StatelessWidget {
  final Widget label;

  /// Usually a colored [Icon]; inherits pill foreground via [IconTheme].
  final Widget? avatar;

  /// When true, uses primary-tinted glass.
  final bool selected;

  final VoidCallback onTap;

  const FlowFilterChipPill({
    super.key,
    required this.label,
    this.avatar,
    required this.selected,
    required this.onTap,
  });

  Color _foreground(BuildContext context) {
    if (selected) return GlassPanel.accentInk(context);

    return GlassPanel.mutedInk(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color foreground = _foreground(context);
    final TextStyle? baseStyle = Theme.of(context).textTheme.labelLarge;

    return GlassPanel(
      borderRadius: const BorderRadius.all(Radius.circular(999.0)),
      blurSigma: 14.0,
      onTap: onTap,
      tint: selected
          ? scheme.primary.withValues(
              alpha: scheme.brightness == Brightness.light ? 0.16 : 0.1,
            )
          : null,
      borderColor: selected
          ? GlassPanel.accentInk(context).withValues(alpha: 0.38)
          : (scheme.brightness == Brightness.light
              ? scheme.outlineVariant.withValues(alpha: 0.45)
              : null),
      padding: const EdgeInsetsDirectional.only(
        start: 14.0,
        end: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: 18.0),
        child: DefaultTextStyle.merge(
          style:
              baseStyle?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ) ??
              TextStyle(
                color: foreground,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: 6.0),
              ],
              label,
            ],
          ),
        ),
      ),
    );
  }
}
