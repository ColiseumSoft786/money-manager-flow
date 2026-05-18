import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/utils/optional.dart";
import "package:flow/routes/home/accounts/accounts_tab_theme.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account_card.dart";
import "package:flow/widgets/account_card_skeleton.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/accounts/accounts_hero_balance.dart";
import "package:flow/widgets/home/accounts/accounts_search_field.dart";
import "package:flow/widgets/home/home/account/no_accounts.dart";
import "package:flow/widgets/home/privacy_toggler.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountsTab extends StatefulWidget {
  /// When false (user switched to another bottom tab), reorder mode is cleared.
  final bool isActive;

  const AccountsTab({super.key, this.isActive = true});

  @override
  State<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab>
    with AutomaticKeepAliveClientMixin {
  bool _reordering = false;

  final TextEditingController _searchController = TextEditingController();

  String get _searchQuery => _searchController.text.trim();

  String? primaryAccountUuid;

  @override
  void initState() {
    super.initState();

    _updatePrimaryAccountUuid();
    UserPreferencesService().valueNotifier.addListener(
      _updatePrimaryAccountUuid,
    );
  }

  @override
  void dispose() {
    UserPreferencesService().valueNotifier.removeListener(
      _updatePrimaryAccountUuid,
    );
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AccountsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive && _reordering) {
      setState(() => _reordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final AccountsProvider accountsProvider = AccountsProvider.of(context);
    final List<Account> activeAccounts = accountsProvider.activeAccounts;
    final List<Account> archivedSorted = accountsProvider.allAccounts.inactives
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final bool ready = accountsProvider.ready;

    if (!ready) {
      return const ColoredBox(
        color: AccountsTabTheme.canvas,
        child: Spinner.center(),
      );
    }

    if (activeAccounts.isEmpty && archivedSorted.isEmpty) {
      return const ColoredBox(
        color: AccountsTabTheme.canvas,
        child: SafeArea(child: NoAccounts()),
      );
    }

    final int accountCountForSearchBar =
        activeAccounts.length + archivedSorted.length;

    return ColoredBox(
      color: AccountsTabTheme.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              child: _buildHeader(
                context,
                hasSearchBar: accountCountForSearchBar > 4,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: UserPreferencesService().valueNotifier,
            builder: (context, userPreferences, child) {
              final bool excludeTransfersInTotal =
                  userPreferences.excludeTransfersFromFlow;

              final bool hasQuery = !_reordering && _searchQuery.isNotEmpty;

              final List<Account> displayedActive = hasQuery
                  ? simpleSortByQuery(activeAccounts, _searchQuery)
                  : activeAccounts;

              final List<Account> displayedArchived = hasQuery
                  ? simpleSortByQuery(archivedSorted, _searchQuery)
                  : archivedSorted;

              return Expanded(
                child: _reordering
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          96.0,
                        ),
                        itemBuilder: (context, index) => Padding(
                          key: ValueKey(activeAccounts[index].uuid),
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AccountCard(
                            account: activeAccounts[index],
                            useCupertinoContextMenu: false,
                            style: AccountCardStyle.accountsTab,
                            primary:
                                activeAccounts[index].uuid == primaryAccountUuid,
                            excludeTransfersInTotal:
                                excludeTransfersInTotal == true,
                          ),
                        ),
                        proxyDecorator: proxyDecorator,
                        itemCount: activeAccounts.length,
                        onReorder: (oldIndex, newIndex) =>
                            onReorder(activeAccounts, oldIndex, newIndex),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          96.0,
                        ),
                        children: [
                          if (displayedActive.isNotEmpty)
                            Text(
                              "accounts".t(context).toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AccountsTabTheme.sectionLabel,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    fontSize: 11.0,
                                  ),
                            ),
                          if (displayedActive.isNotEmpty)
                            const SizedBox(height: 8.0),
                          ...displayedActive.map(
                            (account) => Padding(
                              key: ValueKey("account-card-${account.uuid}"),
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AccountCard(
                                account: account,
                                useCupertinoContextMenu: Platform.isIOS,
                                style: AccountCardStyle.accountsTab,
                                primary: account.uuid == primaryAccountUuid,
                                excludeTransfersInTotal:
                                    excludeTransfersInTotal == true,
                                onTapOverride: Optional(() async {
                                  await context.push("/account/${account.id}");
                                  setState(() {});
                                }),
                              ),
                            ),
                          ),
                          if (!_reordering && displayedArchived.isNotEmpty) ...[
                            const SizedBox(height: 8.0),
                            Text(
                              "account.archived".t(context).toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AccountsTabTheme.sectionLabel,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    fontSize: 11.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            ...displayedArchived.map(
                              (account) => Padding(
                                key: ValueKey(
                                  "account-card-archived-${account.uuid}",
                                ),
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: AccountCard(
                                  account: account,
                                  useCupertinoContextMenu: Platform.isIOS,
                                  style: AccountCardStyle.accountsTab,
                                  primary: account.uuid == primaryAccountUuid,
                                  excludeTransfersInTotal:
                                      excludeTransfersInTotal == true,
                                  onTapOverride: Optional(() async {
                                    await context.push("/account/${account.id}");
                                    setState(() {});
                                  }),
                                ),
                              ),
                            ),
                          ],
                          AccountCardSkeleton(
                            onTap: () => context.push("/account/new"),
                            style: AccountCardSkeletonStyle.accountsTab,
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {bool hasSearchBar = false}) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "tabs.accounts".t(context),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26.0,
                      color: AccountsTabTheme.titleInk,
                    ),
                  ),
                  if (_reordering && !isDesktop())
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "tabs.accounts.reorder.guide".t(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AccountsTabTheme.subtitleInk,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Material(
              color: AccountsTabTheme.cardFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: AccountsTabTheme.cardBorder),
              ),
              child: IconButton(
                onPressed: toggleReorderMode,
                tooltip: _reordering
                    ? "general.done".t(context)
                    : "tabs.accounts.reorder".t(context),
                icon: Icon(
                  _reordering ? Symbols.check_rounded : Symbols.reorder_rounded,
                  color: _reordering
                      ? AccountsTabTheme.primary(context)
                      : AccountsTabTheme.titleInk,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Material(
              color: AccountsTabTheme.cardFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: AccountsTabTheme.cardBorder),
              ),
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: PrivacyToggler(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (!_reordering) const AccountsHeroBalance(),
        if (hasSearchBar) ...[
          const SizedBox(height: 12.0),
          AccountsSearchField(
            controller: _searchController,
            hintText: "general.search".t(context),
            enabled: !_reordering,
            onClear: _searchQuery.isNotEmpty
                ? () => setState(() => _searchController.clear())
                : null,
          ),
        ],
      ],
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(elevation: 0, color: Colors.transparent, child: child);
      },
      child: child,
    );
  }

  void toggleReorderMode() {
    setState(() {
      _reordering = !_reordering;
    });
  }

  void onReorder(List<Account> currentAccounts, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final removed = currentAccounts.removeAt(oldIndex);
    currentAccounts.insert(newIndex, removed);

    ObjectBox().updateAccountOrderList(accounts: currentAccounts);
  }

  void _updatePrimaryAccountUuid() {
    try {
      primaryAccountUuid = UserPreferencesService().primaryAccountUuid;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      //
    }
  }

  @override
  bool get wantKeepAlive => true;
}
