import "package:flow/data/money.dart";
import "package:flow/data/setup/default_accounts.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Home hero card: lifetime income minus expenses across accounts (excluding
/// transfers, pending, deleted, future), not the sum of stored account balances.
class HomeTotalBalanceCard extends StatefulWidget {
  const HomeTotalBalanceCard({super.key});

  @override
  State<HomeTotalBalanceCard> createState() => _HomeTotalBalanceCardState();
}

class _HomeTotalBalanceCardState extends State<HomeTotalBalanceCard> {
  late Future<Money?> _netFlowsFuture;
  late bool _initiallyAbbreviated;

  QueryBuilder<Account> _mainAccountQuery() => ObjectBox()
      .box<Account>()
      .query(Account_.uuid.equals(kAccountPresetUuidMain));

  @override
  void initState() {
    super.initState();
    LocalPreferences().primaryCurrency.addListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.addListener(_refresh);
    TransactionsService().addListener(_refresh);

    _netFlowsFuture = ObjectBox().getLifetimeFlowsNetGrandTotal();
    _initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();
  }

  @override
  void dispose() {
    LocalPreferences().primaryCurrency.removeListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.removeListener(_refresh);
    TransactionsService().removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Money fallback = ObjectBox().getLifetimeFlowsNetPrimaryCurrencyOnly();

    return StreamBuilder<Account?>(
      stream: _mainAccountQuery()
          .watch(triggerImmediately: true)
          .map((e) => e.findFirst()),
      builder: (context, accountSnap) {
        final String subtitleName =
            accountSnap.data?.name ?? "setup.accounts.preset.main".tr();

        return FutureBuilder<Money?>(
          future: _netFlowsFuture,
          builder: (context, snapshot) {
            final Money total = snapshot.data ?? fallback;

            return Container(
              decoration: BoxDecoration(
                color: context.flowAccent.primary,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(37, 140, 244, 0.35),
                    blurRadius: 16.0,
                    offset: Offset(0.0, 8.0),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 4.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              padding: const EdgeInsetsDirectional.fromSTEB(
                20.0,
                18.0,
                12.0,
                18.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "tabs.home.flowsNetTotal".t(context),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MoneyText(
                          total,
                          initiallyAbbreviated: _initiallyAbbreviated,
                          tapToToggleAbbreviation: true,
                          autoSize: true,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: TransitiveLocalPreferences()
                            .sessionPrivacyMode
                            .valueNotifier,
                        builder: (context, snapshot, _) {
                          final bool hidden = snapshot == true;
                          return IconButton(
                            onPressed: () => TransitiveLocalPreferences()
                                .sessionPrivacyMode
                                .set(!hidden),
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.white,
                              iconSize: 26.0,
                            ),
                            icon: Icon(
                              hidden
                                  ? Symbols.visibility_rounded
                                  : Symbols.visibility_off_rounded,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    children: [
                      Icon(
                        Symbols.account_balance_wallet_rounded,
                        size: 18.0,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          subtitleName,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _refresh() {
    setState(() {
      _netFlowsFuture = ObjectBox().getLifetimeFlowsNetGrandTotal();
    });
  }
}
