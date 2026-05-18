import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/home/accounts/accounts_tab_theme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Same data as [TotalBalance], accounts-tab presentation.
class AccountsHeroBalance extends StatefulWidget {
  const AccountsHeroBalance({super.key});

  @override
  State<AccountsHeroBalance> createState() => _AccountsHeroBalanceState();
}

class _AccountsHeroBalanceState extends State<AccountsHeroBalance> {
  bool initiallyAbbreviated = true;

  late Future<Money?> _getGrandTotalFuture;

  @override
  void initState() {
    super.initState();
    LocalPreferences().primaryCurrency.addListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.addListener(_refresh);
    TransactionsService().addListener(_refresh);

    _getGrandTotalFuture = ObjectBox().getGrandTotal();
    initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();
  }

  @override
  void dispose() {
    LocalPreferences().primaryCurrency.removeListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.removeListener(_refresh);
    TransactionsService().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _getGrandTotalFuture = ObjectBox().getGrandTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Money primaryCurrencyTotalBalance = ObjectBox()
        .getPrimaryCurrencyGrandTotal();

    return FutureBuilder<Money?>(
      future: _getGrandTotalFuture,
      builder: (context, snapshot) {
        final Money value = snapshot.hasData
            ? snapshot.data!
            : primaryCurrencyTotalBalance;

        final accent = context.flowAccent;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.heroGradientStart,
                accent.heroGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(AccountsTabTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: accent.primary.withValues(alpha: 0.2),
                blurRadius: 16.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Symbols.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        "tabs.home.totalBalance".t(context).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                MoneyText(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 32.0,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  initiallyAbbreviated: initiallyAbbreviated,
                  tapToToggleAbbreviation: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
