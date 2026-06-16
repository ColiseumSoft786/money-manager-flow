import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class TransactionEntryTypeSegment extends StatelessWidget {
  final TransactionType current;
  final bool canEdit;
  final ValueChanged<TransactionType> onChange;

  const TransactionEntryTypeSegment({
    super.key,
    required this.current,
    required this.onChange,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!canEdit) {
      return Align(
        alignment: Alignment.center,
        child: Text(
          current.localizedNameContext(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: TransactionEntryTheme.valueInk(context),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionEntryTheme.segmentTrack(context),
        borderRadius: BorderRadius.circular(TransactionEntryTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            for (final TransactionType type in TransactionType.values)
              Expanded(
                child: _TypeSegmentOption(
                  label: type.localizedNameContext(context),
                  selected: current == type,
                  selectedColor: type.color(context),
                  onTap: () {
                    if (type == current) return;
                    if (LocalPreferences().enableHapticFeedback.get()) {
                      HapticFeedback.selectionClick();
                    }
                    onChange(type);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeSegmentOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeSegmentOption({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TransactionEntryTheme.cardFill(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      elevation: selected ? 0.5 : 0.0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: selected
                    ? selectedColor
                    : TransactionEntryTheme.placeholderInk(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
