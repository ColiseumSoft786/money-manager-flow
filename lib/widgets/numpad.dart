import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";

export "numpad_button.dart";

/// Digits and icons scale to this fraction of each key cell.
const _contentSizeFactor = 0.44;

class Numpad extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  final EdgeInsets padding;

  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// If not specified, uses [MediaQuery.of(context).size.width]
  final double? width;

  /// Wrap keys in a soft rounded panel (amount entry sheets).
  final bool showPanel;

  const Numpad({
    super.key,
    required this.children,
    this.width,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.crossAxisCount = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.showPanel = true,
  });

  @override
  Widget build(BuildContext context) {
    final double layoutWidth = width ?? MediaQuery.of(context).size.width;
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;

    final double totalHorizontalPadding =
        padding.left +
        padding.right +
        (crossAxisCount * (crossAxisSpacing - 1));

    final double itemSize = (layoutWidth - totalHorizontalPadding) / crossAxisCount;
    final double itemContentSize = itemSize * _contentSizeFactor;

    final Widget grid = Directionality(
      textDirection: TextDirection.ltr,
      child: IconTheme.merge(
        data: IconThemeData(
          color: scheme.onSurface,
          size: itemContentSize,
          weight: 500.0,
          fill: 0.0,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: itemContentSize,
            color: scheme.onSurface,
            height: 1.0,
            letterSpacing: -0.5,
          ),
          child: StaggeredGrid.count(
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            crossAxisCount: crossAxisCount,
            children: children,
          ),
        ),
      ),
    );

    if (!showPanel) {
      return Padding(padding: padding, child: grid);
    }

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: light
              ? scheme.surfaceContainerLow.withValues(alpha: 0.65)
              : scheme.surfaceContainerLow.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: light
                ? const Color(0xFFE8ECF1)
                : scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: grid,
        ),
      ),
    );
  }
}
