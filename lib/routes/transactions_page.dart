import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/pending_time_range.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_info_banner.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_list_view.dart";
import "package:flow/widgets/grouped_transactions_list_view.dart";
import "package:flow/widgets/pending_transactions/pending_filter_chips.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_list_view.dart";
import "package:flow/widgets/pending_transactions/pending_transactions_theme.dart";
import "package:flow/widgets/pending_transactions/pending_summary_card.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flow/widgets/transactions_empty_state.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Controls how loaded rows are grouped before display.
enum TransactionsPageScope {
  /// Posted and pending rows are split like the home tab.
  all,

  /// Only pending / scheduled rows (see [TransactionsPage.pending]).
  pending,

  /// Trash bin rows (see [TransactionsPage.deleted]).
  deleted,
}

/// Generic transactions page that can be used to display list of transactions
///
/// This view does not respect [UserPreferences.combineTransfers] since it may
/// be used to show transactions of specific account, and there will be
/// scenarios where the other half of the transfer transaction is wouldn't be
/// shown.
class TransactionsPage extends StatefulWidget {
  final QueryBuilder<Transaction> Function(TimeRange range) queryFn;
  final TimeRange? initialRange;
  final String? title;

  /// When set, shown as the empty-state body copy under the title.
  final String? emptyDescriptionKey;

  /// When true, shows the primary **Add Transaction** CTA in the empty state.
  final bool showEmptyAddButton;

  final TransactionsPageScope scope;

  const TransactionsPage({
    super.key,
    required this.queryFn,
    this.initialRange,
    this.title,
    this.emptyDescriptionKey,
    this.showEmptyAddButton = false,
    this.scope = TransactionsPageScope.all,
  });

  factory TransactionsPage.account({
    Key? key,
    required int accountId,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange? range) {
      Condition<Transaction> condition = Transaction_.account.equals(accountId);

      if (range != null) {
        condition = condition.and(
          Transaction_.transactionDate.betweenDate(range.from, range.to),
        );
      }

      return ObjectBox()
          .box<Transaction>()
          .query(condition)
          .order(Transaction_.transactionDate, flags: Order.descending);
    }

    return TransactionsPage(queryFn: queryBuilder, key: key, title: title);
  }

  factory TransactionsPage.all({Key? key, String? title, Widget? header}) {
    QueryBuilder<Transaction> queryBuilder(TimeRange range) =>
        TransactionFilter(
          sortBy: TransactionSortField.transactionDate,
          sortDescending: true,
          range: TransactionFilterTimeRange.fromTimeRange(range),
        ).queryBuilder();

    return TransactionsPage(
      queryFn: queryBuilder,
      key: key,
      title: title,
      emptyDescriptionKey: "transactions.query.noResult.description",
    );
  }

  factory TransactionsPage.pending({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange range) =>
        TransactionsService().pendingTransactionsQb(
          anchor: anchor,
          range: range,
        );

    return TransactionsPage(
      queryFn: queryBuilder,
      key: key,
      title: title,
      scope: TransactionsPageScope.pending,
      emptyDescriptionKey: "transactions.query.noResult.description.pending",
      showEmptyAddButton: true,
    );
  }

  factory TransactionsPage.deleted({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    QueryBuilder<Transaction> queryBuilder(TimeRange range) =>
        TransactionsService().deletedTransactionsQb();

    return TransactionsPage(
      queryFn: queryBuilder,
      key: key,
      title: title,
      scope: TransactionsPageScope.deleted,
    );
  }

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static TimeRange get defaultTimeRange => TimeRange.thisMonth();

  late TimeRange _timeRange;
  late PendingTimeRange _pendingListRange;

  late final bool showExchangeRatesMissingWarning;

  @override
  void initState() {
    super.initState();
    _timeRange = widget.initialRange ?? defaultTimeRange;
    _pendingListRange = const PendingTimeRange.followHome();
    showExchangeRatesMissingWarning =
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get() &&
        ExchangeRatesService().getPrimaryCurrencyRates() == null;
  }

  TimeRange _queryTimeRange() {
    if (widget.scope != TransactionsPageScope.pending) {
      return _timeRange;
    }

    if (_pendingListRange == const PendingTimeRange.followHome()) {
      return UserPreferencesService().homePendingTransactionsTimeRange.range(
        homeTimeRange: TimeRange.thisMonth(),
      );
    }

    return _pendingListRange.range(homeTimeRange: TimeRange.thisMonth());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeletedScope = widget.scope == TransactionsPageScope.deleted;
    final bool isPendingScope = widget.scope == TransactionsPageScope.pending;
    final Color screenBackground = isPendingScope
        ? PendingTransactionsTheme.canvas(context)
        : isDeletedScope
            ? DeletedTransactionsTheme.canvas(context)
            : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: isPendingScope
            ? PendingTransactionsTheme.cardFill(context)
            : screenBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: widget.title == null
            ? null
            : Text(
                widget.title!,
                style: (isDeletedScope || isPendingScope)
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.0,
                        color: isPendingScope
                            ? PendingTransactionsTheme.titleInk(context)
                            : DeletedTransactionsTheme.titleInk(context),
                      )
                    : null,
              ),
        bottom: (isDeletedScope || isPendingScope)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: isPendingScope
                      ? PendingTransactionsTheme.cardBorder(context)
                      : DeletedTransactionsTheme.cardBorder(context),
                ),
              )
            : null,
      ),
      floatingActionButton: isPendingScope
          ? FloatingActionButton(
              onPressed: () => context.push("/transaction/new?isPending=true"),
              backgroundColor: PendingTransactionsTheme.primary(context),
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Symbols.add_rounded, fill: 0.0),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (showExchangeRatesMissingWarning) RatesMissingErrorBox(),
            if (isPendingScope) ...[
              const SizedBox(height: 8.0),
              PendingFilterChips(
                selected: _pendingListRange,
                onSelected: (PendingTimeRange value) {
                  setState(() {
                    _pendingListRange = value;
                  });
                },
              ),
              const SizedBox(height: 12.0),
            ],
            if (!isDeletedScope && !isPendingScope)
              ColoredBox(
                color: screenBackground,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Frame(
                    child: TimeRangeSelector(
                      backgroundColor: screenBackground,
                      initialValue: _timeRange,
                      onChanged: (newRange) {
                        setState(() {
                          _timeRange = newRange;
                        });
                      },
                    ),
                  ),
                ),
              ),
            if (isDeletedScope) const DeletedTransactionsInfoBanner(),
            Expanded(
              child: StreamBuilder<List<Transaction>>(
                stream: widget
                    .queryFn(_queryTimeRange())
                    .watch(triggerImmediately: true)
                    .map((event) => event.find()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Spinner.center();
                  }

                  final List<Transaction> items = snapshot.requireData;

                  if (items.isEmpty) {
                    if (isPendingScope) {
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        children: [
                          PendingSummaryCard(transactions: const []),
                          TransactionsEmptyState(
                            description: widget.emptyDescriptionKey?.t(context),
                            onAddTransaction: widget.showEmptyAddButton
                                ? () => context.push(
                                    "/transaction/new?isPending=true",
                                  )
                                : null,
                          ),
                        ],
                      );
                    }

                    return TransactionsEmptyState(
                      description: widget.emptyDescriptionKey?.t(context),
                      onAddTransaction: widget.showEmptyAddButton
                          ? () => context.push(
                              widget.scope == TransactionsPageScope.pending
                                  ? "/transaction/new?isPending=true"
                                  : "/transaction/new",
                            )
                          : null,
                    );
                  }

                  if (isDeletedScope) {
                    return DeletedTransactionsListView(
                      transactions: items,
                    );
                  }

                  if (isPendingScope) {
                    return PendingTransactionsListView(transactions: items);
                  }

                  final (
                    Map<TimeRange, List<Transaction>> transactions,
                    Map<TimeRange, List<Transaction>> pendingTransactions,
                  ) = _groupTransactions(items);

                  final int totalTransactionsCount =
                      transactions.values.fold<int>(
                        0,
                        (previousValue, element) =>
                            previousValue + element.length,
                      ) +
                      pendingTransactions.values.fold<int>(
                        0,
                        (previousValue, element) =>
                            previousValue + element.length,
                      );

                  return GroupedTransactionsListView(
                    transactions: transactions,
                    pendingTransactions: pendingTransactions,
                    headerBuilder: (pendingGroup, range, transactions) =>
                        TransactionListDateHeader(
                          pendingGroup: pendingGroup,
                          range: range,
                          transactions: transactions,
                        ),
                    pendingDivider: WavyDivider(),
                    mainHeader: Frame(
                      child: Text(
                        "transactions.count".t(context, totalTransactionsCount),
                        style: context.textTheme.bodyMedium?.semi(context),
                      ),
                    ),
                    mainHeaderPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  (
    Map<TimeRange, List<Transaction>> transactions,
    Map<TimeRange, List<Transaction>> pendingTransactions,
  )
  _groupTransactions(List<Transaction> items) {
    if (widget.scope == TransactionsPageScope.pending) {
      return (const {}, items.groupByDate());
    }

    final DateTime now = DateTime.now().startOfNextMinute();

    return (
      items
          .where(
            (transaction) =>
                !transaction.transactionDate.isAfter(now) &&
                transaction.isPending != true,
          )
          .groupByDate(),
      items
          .where(
            (transaction) =>
                transaction.transactionDate.isAfter(now) ||
                transaction.isPending == true,
          )
          .groupByDate(),
    );
  }
}
