import "package:flow/data/money.dart";
import "package:flow/data/setup/default_accounts.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/flow_accent_colors.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class HomeTotalBalanceCard extends StatefulWidget {
  const HomeTotalBalanceCard({super.key});

  @override
  State<HomeTotalBalanceCard> createState() => _HomeTotalBalanceCardState();
}

typedef _LifetimeFlowsSnapshot = ({Money? current, Money? previousAtMonthStart});

class _HomeTotalBalanceCardState extends State<HomeTotalBalanceCard>
    with SingleTickerProviderStateMixin {
  late Future<_LifetimeFlowsSnapshot> _netFlowsFuture;
  late bool _initiallyAbbreviated;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  QueryBuilder<Account> _mainAccountQuery() => ObjectBox()
      .box<Account>()
      .query(Account_.uuid.equals(kAccountPresetUuidMain));

  @override
  void initState() {
    super.initState();
    LocalPreferences().primaryCurrency.addListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.addListener(_refresh);
    TransactionsService().addListener(_refresh);

    _netFlowsFuture = _loadLifetimeFlows();
    _initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    LocalPreferences().primaryCurrency.removeListener(_refresh);
    ExchangeRatesService().exchangeRatesCache.removeListener(_refresh);
    TransactionsService().removeListener(_refresh);
    _floatController.dispose();
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

        return FutureBuilder<_LifetimeFlowsSnapshot>(
          future: _netFlowsFuture,
          builder: (context, snapshot) {
            final DateTime monthStart = Moment.startOfToday().startOfMonth();
            final Money total = snapshot.data?.current ??
                fallback;
            final Money previousAtMonthStart =
                snapshot.data?.previousAtMonthStart ??
                ObjectBox().getLifetimeFlowsNetPrimaryCurrencyOnly(
                  until: monthStart,
                );
            final double? percentageChange = _monthToDateChangePercent(
              current: total,
              previousAtMonthStart: previousAtMonthStart,
            );
            final bool isPositive = (percentageChange ?? 0) >= 0;
            
            final FlowAccentColors accent = context.flowAccent;
            final ColorScheme scheme = Theme.of(context).colorScheme;
            final TextTheme textTheme = Theme.of(context).textTheme;
            final bool light = scheme.brightness == Brightness.light;
            final Color primary = accent.primary;

            final Color titleInk = GlassPanel.mutedInk(context);
            final Color amountInk = scheme.onSurface;
            final Color accentInk = light ? primary : GlassPanel.accentInk(context);

            return AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: GlassPanel(
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    blurBehind: true,
                    tint: light ? primary : null,
                    borderColor: GlassPanel.resolveProminentBorder(context),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "tabs.home.flowsNetTotal".t(context).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: titleInk,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Amount row with percentage chip
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // Main amount
                            MoneyText(
                              total,
                              initiallyAbbreviated: _initiallyAbbreviated,
                              tapToToggleAbbreviation: true,
                              autoSize: true,
                              maxLines: 1,
                              style: textTheme.headlineMedium?.copyWith(
                                color: amountInk,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                                letterSpacing: -0.5,
                                fontSize: 36,
                              ),
                            ),
                            if (percentageChange != null) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPositive
                                      ? context.flowColors.income.withValues(alpha: 0.12)
                                      : context.flowColors.expense.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPositive
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 12,
                                      color: isPositive
                                          ? context.flowColors.income
                                          : context.flowColors.expense,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${isPositive ? "+" : ""}${percentageChange.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isPositive
                                            ? context.flowColors.income
                                            : context.flowColors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Account chip - "Main account" style
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withValues(
                              alpha: light ? 0.05 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: scheme.onSurface.withValues(
                                alpha: light ? 0.08 : 0.12,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.account_balance_wallet_rounded,
                                size: 14,
                                color: accentInk,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                subtitleName,
                                style: textTheme.labelMedium?.copyWith(
                                  color: titleInk,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<_LifetimeFlowsSnapshot> _loadLifetimeFlows() async {
    final DateTime monthStart = Moment.startOfToday().startOfMonth();
    final List<Money?> results = await Future.wait<Money?>([
      ObjectBox().getLifetimeFlowsNetGrandTotal(),
      ObjectBox().getLifetimeFlowsNetGrandTotal(until: monthStart),
    ]);

    return (
      current: results[0],
      previousAtMonthStart: results[1],
    );
  }

  double? _monthToDateChangePercent({
    required Money current,
    required Money previousAtMonthStart,
  }) {
    final double base = previousAtMonthStart.amount.abs();
    if (base == 0) return null;

    return ((current.amount - previousAtMonthStart.amount) / base) * 100;
  }

  void _refresh() {
    setState(() {
      _netFlowsFuture = _loadLifetimeFlows();
    });
  }
}