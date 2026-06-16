import "package:flow/data/transactions_filter/pending_time_range.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flutter/material.dart";

class PendingFilterChips extends StatelessWidget {
  final PendingTimeRange selected;
  final ValueChanged<PendingTimeRange> onSelected;

  static const List<PendingTimeRange> listPagePresets = [
    PendingTimeRange.followHome(),
    PendingTimeRange.duration(Duration(days: 3)),
    PendingTimeRange.thisWeek(),
  ];

  const PendingFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: listPagePresets.map((PendingTimeRange preset) {
          final bool isSelected = preset == selected;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: isSelected
                  ? PendingTransactionsTheme.chipSelectedFill
                  : PendingTransactionsTheme.chipIdleFill(context),
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: () => onSelected(preset),
                borderRadius: BorderRadius.circular(20.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Text(
                    preset.localizedNameContext(
                      context,
                      preset.futureDuration?.inDays,
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                      color: isSelected
                          ? PendingTransactionsTheme.chipSelectedInk
                          : PendingTransactionsTheme.chipIdleInk(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
