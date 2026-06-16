import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/select_recurrence.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

class TransactionEntryRecurringCard extends StatelessWidget {
  final Recurrence? recurrence;
  final bool isNewTransaction;
  final ValueChanged<Recurrence?> onRecurrenceChanged;
  final VoidCallback onSetupRecurring;
  final TimeRange? startBounds;

  const TransactionEntryRecurringCard({
    super.key,
    required this.recurrence,
    required this.isNewTransaction,
    required this.onRecurrenceChanged,
    required this.onSetupRecurring,
    this.startBounds,
  });

  bool get _isRecurring => recurrence != null;

  @override
  Widget build(BuildContext context) {
    if (_isRecurring) {
      return TransactionEntryCard(
        padding: const EdgeInsets.all(12.0),
        child: SelectRecurrence(
          initialValue: recurrence,
          onChanged: onRecurrenceChanged,
          startBounds: startBounds,
        ),
      );
    }

    return TransactionEntryCard(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        title: Text(
          "transaction.recurring.setup".t(context),
          style: TransactionEntryTheme.rowTitleStyle(
            context,
            Theme.of(context),
          ),
        ),
        secondary:  Icon(
          Symbols.repeat_rounded,
          color: TransactionEntryTheme.iconPlateInk(context),
          fill: 0.0,
        ),
        value: _isRecurring,
        onChanged: (enabled) {
          if (enabled) {
            onSetupRecurring();
          } else {
            onRecurrenceChanged(null);
          }
        },
        activeTrackColor: TransactionEntryTheme.primary(context),
        inactiveTrackColor: TransactionEntryTheme.segmentTrack(context),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
