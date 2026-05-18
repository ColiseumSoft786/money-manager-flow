import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/preferences/transaction_entry_flow/transaction_entry_flow_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EntryFlowActionTile extends StatelessWidget {
  final TransactionEntryAction action;
  final int stepNumber;
  final int listIndex;
  final VoidCallback onDelete;

  const EntryFlowActionTile({
    super.key,
    required this.action,
    required this.stepNumber,
    required this.listIndex,
    required this.onDelete,
  });

  static IconData iconFor(TransactionEntryAction action) {
    return switch (action) {
      TransactionEntryAction.selectAccount ||
      TransactionEntryAction.selectPrimaryAccount =>
        Symbols.account_balance_wallet_rounded,
      TransactionEntryAction.selectCategoryOrTransferAccount =>
        Symbols.category_rounded,
      TransactionEntryAction.inputAmount => Symbols.payments_rounded,
      TransactionEntryAction.inputTitle => Symbols.title_rounded,
      TransactionEntryAction.selectTags => Symbols.sell_rounded,
      TransactionEntryAction.attachFiles => Symbols.attach_file_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? lastItemHint = action == TransactionEntryAction.inputTitle
        ? "preferences.transactionEntryFlow.actions.lastItem".t(context)
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionEntryFlowPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(
          TransactionEntryFlowPreferencesTheme.cardRadius,
        ),
        border: Border.all(color: TransactionEntryFlowPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 10.0, 8.0, 10.0),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: listIndex,
              child: SizedBox(
                width: 40.0,
                height: 44.0,
                child: Icon(
                  Symbols.drag_indicator_rounded,
                  size: 22.0,
                  color: TransactionEntryFlowPreferencesTheme.subtitleInk
                      .withValues(alpha: 0.55),
                  fill: 0.0,
                ),
              ),
            ),
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: TransactionEntryFlowPreferencesTheme.iconPlateFill(context),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                iconFor(action),
                size: 20.0,
                color: TransactionEntryFlowPreferencesTheme.primary(context),
                fill: 0.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.localizedNameContext(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: TransactionEntryFlowPreferencesTheme.titleInk,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    lastItemHint ??
                        "preferences.transactionEntryFlow.step".t(
                          context,
                          {"index": stepNumber},
                        ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TransactionEntryFlowPreferencesTheme.subtitleInk,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Symbols.delete_rounded,
                color: TransactionEntryFlowPreferencesTheme.subtitleInk
                    .withValues(alpha: 0.65),
                fill: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
