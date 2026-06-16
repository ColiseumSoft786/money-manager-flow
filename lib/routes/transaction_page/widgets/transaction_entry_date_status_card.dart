import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntryDateStatusCard extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onEditDate;
  final bool isPending;
  final bool pendingEnabled;
  final ValueChanged<bool> onPendingChanged;

  const TransactionEntryDateStatusCard({
    super.key,
    required this.dateLabel,
    required this.onEditDate,
    required this.isPending,
    required this.pendingEnabled,
    required this.onPendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TransactionEntryCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditDate,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(TransactionEntryTheme.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: TransactionEntryTheme.iconPlateSize,
                      height: TransactionEntryTheme.iconPlateSize,
                      decoration: BoxDecoration(
                        color: TransactionEntryTheme.iconPlateFill(context),
                        borderRadius: BorderRadius.circular(
                          TransactionEntryTheme.iconPlateRadius,
                        ),
                      ),
                      alignment: Alignment.center,
                      child:  Icon(
                        Symbols.calendar_month_rounded,
                        size: 22.0,
                        color: TransactionEntryTheme.iconPlateInk(context),
                        fill: 0.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "transaction.date".t(context),
                            style: TransactionEntryTheme.rowCaptionStyle(
                              context,
                              theme,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            dateLabel,
                            style: TransactionEntryTheme.rowValueStyle(
                              context,
                              theme,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Symbols.edit_rounded,
                      size: 20.0,
                      color: TransactionEntryTheme.chevronInk(context),
                      fill: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            color: TransactionEntryTheme.rowDivider(context),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            title: Text(
              "transaction.pending".t(context),
              style: TransactionEntryTheme.rowTitleStyle(context, theme),
            ),
            secondary: Icon(
              Symbols.schedule_rounded,
              color: TransactionEntryTheme.iconPlateInk(context),
              fill: 0.0,
            ),
            value: isPending,
            onChanged: pendingEnabled ? onPendingChanged : null,
            activeTrackColor: TransactionEntryTheme.primary(context),
            inactiveTrackColor: TransactionEntryTheme.segmentTrack(context),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
