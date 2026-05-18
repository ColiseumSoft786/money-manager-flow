import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/list_tile_appearance/list_tile_appearance_theme.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/flow_themes.dart";
import "package:flow/widgets/home/home_transaction_cards_scope.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flow/widgets/transaction_list_tile_theme.dart";
import "package:flutter/material.dart";

class ListTilePreviewSection extends StatefulWidget {
  const ListTilePreviewSection({super.key});

  @override
  State<ListTilePreviewSection> createState() => _ListTilePreviewSectionState();
}

class _ListTilePreviewSectionState extends State<ListTilePreviewSection> {
  @override
  void initState() {
    super.initState();
    TransactionsService().addListener(_onTransactionsChanged);
  }

  @override
  void dispose() {
    TransactionsService().removeListener(_onTransactionsChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Transaction> _previewTransactions() {
    return TransactionsService()
        .findManySync(TransactionFilter.empty)
        .where((Transaction transaction) => !transaction.isTransfer)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Transaction> transactions = _previewTransactions();
    final bool relaxed =
        UserPreferencesService().transactionListTileRelaxedDensity;

    if (transactions.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: ListTileAppearanceTheme.cardFill,
          borderRadius: BorderRadius.circular(ListTileAppearanceTheme.cardRadius),
          border: Border.all(color: ListTileAppearanceTheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Text(
            "tabs.home.noTransactions".t(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ListTileAppearanceTheme.subtitleInk,
              fontSize: 13.0,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return HomeTransactionCardsScope(
      enabled: true,
      child: FlowThemes(
        child: TransactionListTileTheme(
          data:
              (TransactionListTileTheme.maybeOf(context)?.data ??
                      TransactionListTileThemeData.fallback)
                  .merge(
            TransactionListTileThemeData(
              showCategory: true,
              padding: EdgeInsetsDirectional.fromSTEB(
                18.0,
                relaxed ? 16.0 : 14.0,
                18.0,
                relaxed ? 16.0 : 14.0,
              ),
              spacing: 14.0,
              titleSpacing: 8.0,
            ),
          ),
          child: Column(
            children: [
              for (int index = 0; index < transactions.length; index++) ...[
                if (index > 0) const SizedBox(height: 8.0),
                IgnorePointer(
                  child: TransactionListTile(
                    transaction: transactions[index],
                    recoverFromTrashFn: null,
                    moveToTrashFn: null,
                    combineTransfers: false,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
