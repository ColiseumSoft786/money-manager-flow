import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/preferences/transaction_entry_flow/transaction_entry_flow_preferences_theme.dart";
import "package:flow/routes/preferences/transaction_entry_flow/widgets/entry_flow_action_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EntryFlowAddActionsSection extends StatelessWidget {
  final List<TransactionEntryAction> availableActions;
  final ValueChanged<TransactionEntryAction> onAdd;

  const EntryFlowAddActionsSection({
    super.key,
    required this.availableActions,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (availableActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 10.0),
          child: Text(
            "preferences.transactionEntryFlow.actions".t(context).toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: TransactionEntryFlowPreferencesTheme.sectionLabel,
              fontWeight: FontWeight.w700,
              fontSize: 11.0,
              letterSpacing: 1.1,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: TransactionEntryFlowPreferencesTheme.cardFill,
            borderRadius: BorderRadius.circular(
              TransactionEntryFlowPreferencesTheme.cardRadius,
            ),
            border: Border.all(
              color: TransactionEntryFlowPreferencesTheme.cardBorder,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < availableActions.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: TransactionEntryFlowPreferencesTheme.cardBorder,
                  ),
                ListTile(
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: TransactionEntryFlowPreferencesTheme.iconPlateFill(context),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      EntryFlowActionTile.iconFor(availableActions[i]),
                      size: 20.0,
                      color: TransactionEntryFlowPreferencesTheme.primary(context),
                      fill: 0.0,
                    ),
                  ),
                  title: Text(
                    availableActions[i].localizedNameContext(context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                  ),
                  trailing: const Icon(Symbols.add_rounded),
                  onTap: () => onAdd(availableActions[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
