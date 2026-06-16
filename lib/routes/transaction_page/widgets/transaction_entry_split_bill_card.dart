import "package:flow/entity/split_participant.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flow/widgets/sheets/split_bill_participants_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntrySplitBillCard extends StatelessWidget {
  final bool enabled;
  final List<String> participantNames;
  final String payerName;
  final List<SplitParticipant>? existingParticipants;
  final ValueChanged<bool> onEnabledChanged;
  final void Function(List<String> names, String payerName) onParticipantsChanged;
  final void Function(SplitParticipant participant)? onSettle;

  const TransactionEntrySplitBillCard({
    super.key,
    required this.enabled,
    required this.participantNames,
    required this.payerName,
    this.existingParticipants,
    required this.onEnabledChanged,
    required this.onParticipantsChanged,
    this.onSettle,
  });

  String _summary(BuildContext context) {
    if (participantNames.isEmpty) {
      return "splitBill.summary.empty".t(context);
    }
    return "splitBill.summary".t(context, {
      "count": "${participantNames.length}",
      "payer": payerName,
    });
  }

  Future<void> _openParticipantsSheet(BuildContext context) async {
    final SplitBillParticipantsResult? result =
        await showModalBottomSheet<SplitBillParticipantsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => SplitBillParticipantsSheet(
        initialNames: participantNames.isNotEmpty
            ? participantNames
            : [
                "splitBill.defaultPayer".t(context),
                "splitBill.defaultFriend".t(context),
              ],
        initialPayerName: payerName.isNotEmpty
            ? payerName
            : "splitBill.defaultPayer".t(context),
      ),
    );

    if (result == null) return;

    onParticipantsChanged(result.names, result.payerName);
  }

  @override
  Widget build(BuildContext context) {
    return TransactionEntryCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            title: Text(
              "splitBill.title".t(context),
              style: TransactionEntryTheme.rowTitleStyle(
                context,
                Theme.of(context),
              ),
            ),
            subtitle: Text(
              "splitBill.subtitle".t(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TransactionEntryTheme.chevronInk(context),
                  ),
            ),
            secondary: Icon(
              Symbols.groups_rounded,
              color: TransactionEntryTheme.iconPlateInk(context),
              fill: 0.0,
            ),
            value: enabled,
            onChanged: (value) {
              onEnabledChanged(value);
              if (value && participantNames.isEmpty) {
                onParticipantsChanged(
                  [
                    "splitBill.defaultPayer".t(context),
                    "splitBill.defaultFriend".t(context),
                  ],
                  "splitBill.defaultPayer".t(context),
                );
              }
            },
            activeTrackColor: TransactionEntryTheme.primary(context),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
          ),
          if (enabled) ...[
            const Divider(height: 1.0),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              leading: Icon(
                Symbols.people_rounded,
                color: TransactionEntryTheme.iconPlateInk(context),
                fill: 0.0,
              ),
              title: Text(_summary(context)),
              trailing: Icon(
                Symbols.chevron_right_rounded,
                color: TransactionEntryTheme.chevronInk(context),
              ),
              onTap: () => _openParticipantsSheet(context),
            ),
            if (existingParticipants != null)
              ...existingParticipants!
                  .where((p) => !p.isPayer && !p.isFullySettled)
                  .map(
                    (p) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      title: Text(p.displayName),
                      subtitle: Text(
                        "splitBill.owes".t(context, {
                          "amount": p.openBalance.toStringAsFixed(2),
                          "currency": p.currency,
                        }),
                      ),
                      trailing: onSettle == null
                          ? null
                          : TextButton(
                              onPressed: () => onSettle!(p),
                              child: Text("splitBill.settle".t(context)),
                            ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}
