import "dart:math" as math;
import "dart:math";

import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ModalSheet extends StatelessWidget {
  final Widget? title;

  final Widget? child;

  final Widget? leading;
  final Widget? trailing;

  final double leadingSpacing;
  final double trailingSpacing;

  /// Only used when [scrollable] is true — max height of the sheet panel.
  final double topMargin;
  final double titleSpacing;

  final bool scrollable;

  /// If [scrollableContentMaxHeight] is less than [this], [this] will be used instead of max height.
  ///
  /// Scroll content height: `math.max(scrollableContentMaxHeight, minScrollableContentHeight)`
  ///
  /// Defaults to `64.0`
  final double minScrollableContentHeight;
  final double scrollableContentMaxHeight;

  const ModalSheet({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 16.0,
    this.trailingSpacing = 8.0,
  }) : scrollable = false,
       scrollableContentMaxHeight = 0,
       minScrollableContentHeight = 0;

  /// [scrollableContentMaxHeight] defaults to 50% of the screen height.
  ///
  /// Setting [scrollableContentMaxHeight] to `0.0` will result in the default behaviour.
  const ModalSheet.scrollable({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.minScrollableContentHeight = 64.0,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 16.0,
    this.trailingSpacing = 8.0,
    this.scrollableContentMaxHeight = 0.0,
  }) : scrollable = true;

  @override
  Widget build(BuildContext context) {
    final Widget? titleWidget = this.title == null
        ? null
        : DefaultTextStyle(
            style: (scrollable
                    ? context.textTheme.headlineSmall!
                    : context.textTheme.titleMedium!)
                .copyWith(fontWeight: FontWeight.w600)!,
            textAlign: TextAlign.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: scrollable ? 24.0 : 16.0),
              child: this.title!,
            ),
          );

    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final Widget panel = Material(
      color: context.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (scrollable)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 30.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.25),
                  borderRadius: .circular(24.0),
                ),
              )
            else
              const SizedBox(height: 6.0),
            if (titleWidget != null) ...[
              SizedBox(height: scrollable ? titleSpacing : 4.0),
              titleWidget,
            ],
            if (titleWidget != null && (leading != null || child != null))
              SizedBox(height: scrollable ? titleSpacing : 6.0),
            if (leading != null) ...[
              leading!,
              SizedBox(height: leadingSpacing),
            ],
            if (child != null)
              scrollable
                  ? Flexible(child: Builder(builder: buildScrollableContent))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: child,
                    ),
            if (trailing != null) ...[
              SizedBox(height: trailingSpacing),
              trailing!,
            ],
            if (!scrollable) const SizedBox(height: 4.0),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: scrollable
          ? Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(
                  Size(
                    MediaQuery.sizeOf(context).width,
                    MediaQuery.sizeOf(context).height - topMargin,
                  ),
                ),
                child: panel,
              ),
            )
          : panel,
    );
  }

  Widget buildScrollableContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxScrollableContentHeight = math.max(
          (MediaQuery.sizeOf(context).height -
              64.0 -
              MediaQuery.viewInsetsOf(context).bottom),
          scrollableContentMaxHeight,
        );

        return AnimatedContainer(
          constraints: BoxConstraints.loose(
            Size(
              double.infinity,
              min(
                    max(minScrollableContentHeight, maxScrollableContentHeight),
                    constraints.maxHeight,
                  ) -
                  64.0,
            ),
          ),
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: child,
          ),
        );
      },
    );
  }
}
