import "package:flow/data/transaction_filter.dart";
import "package:flutter/material.dart";

/// Renders a row of transaction filter pills ([TransactionFilterChip], etc.).
class TransactionFilterHead extends StatelessWidget {
  final TransactionFilter value;

  /// Usually List of [TransactionFilterChip]s
  final List<Widget> filterChips;

  final EdgeInsets? padding;

  const TransactionFilterHead({
    super.key,
    required this.filterChips,
    this.value = TransactionFilter.empty,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    for (final chip in filterChips) {
      children.add(chip);
      children.add(const SizedBox(width: 8.0));
    }

    if (children.isNotEmpty && children.last is SizedBox) {
      children.removeLast();
    }

    final EdgeInsets basePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16.0);

    return SingleChildScrollView(
      padding: basePadding.copyWith(
        top: basePadding.top + 8.0,
        bottom: basePadding.bottom + 10.0,
      ),
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}
