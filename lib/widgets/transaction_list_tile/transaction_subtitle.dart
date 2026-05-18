import "package:flutter/material.dart";

class TransactionSubtitle extends StatelessWidget {
  final List<InlineSpan> components;

  /// When non-null (e.g. home elevated cards), tints subtitle “caption” text.
  final Color? foregroundColor;

  const TransactionSubtitle({
    super.key,
    required this.components,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    const TextSpan divider = TextSpan(text: " • ");

    final List<InlineSpan> orderedComponents = [
      for (int i = 0; i < components.length; i++) ...[
        if (i != 0) divider,
        components[i],
      ],
    ];

    final TextStyle? labelSmall = Theme.of(context).textTheme.labelSmall;

    final TextStyle? mergedStyle =
        foregroundColor != null ? labelSmall?.copyWith(
            color: foregroundColor,
            height: 1.35,
          ) : labelSmall;

    return RichText(
      text: TextSpan(
        children: textDirection == TextDirection.ltr
            ? orderedComponents
            : orderedComponents.reversed.toList(),
        style: mergedStyle,
      ),
    );
  }
}
