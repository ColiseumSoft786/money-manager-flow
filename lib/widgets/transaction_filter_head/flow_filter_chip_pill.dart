import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

/// Stadium-style transaction filter pill (homepage filter row artwork).
///
/// Behaviour is wired by the caller; this widget is visual only.
class FlowFilterChipPill extends StatelessWidget {
  final Widget label;

  /// Usually a colored [Icon]; inherits pill foreground via [IconTheme].
  final Widget? avatar;

  /// When true, uses pale-blue fill / blue foreground (matches “active range” chip).
  final bool selected;

  final VoidCallback onTap;

  const FlowFilterChipPill({
    super.key,
    required this.label,
    this.avatar,
    required this.selected,
    required this.onTap,
  });

  (Color fill, Color foreground) _resolvedColors(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    if (selected) {
      if (dark) {
        return (kFlowFilterPillSelectedFillDark, kFlowFilterPillSelectedFgDark);
      }
      return (kFlowFilterPillSelectedFillLight, kFlowFilterPillSelectedFgLight);
    }
    if (dark) {
      return (
        kFlowFilterPillUnselectedFillDark,
        kFlowFilterPillUnselectedFgDark,
      );
    }
    return (
      kFlowFilterPillUnselectedFillLight,
      kFlowFilterPillUnselectedFgLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color foreground) = _resolvedColors(context);
    final BorderRadius radius = BorderRadius.circular(999.0);

    final TextStyle? baseStyle = Theme.of(context).textTheme.labelLarge;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
          ),
          child: Padding(
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
          ),
        ),
      ),
    );
  }
}
