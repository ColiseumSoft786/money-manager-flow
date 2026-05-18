import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/routes/home/accounts/accounts_tab_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

enum AccountCardStyle { classic, accountsTab }

class AccountCard extends StatelessWidget {
  final Account account;

  final Optional<VoidCallback>? onTapOverride;

  final bool useCupertinoContextMenu;

  final bool excludeTransfersInTotal;

  final bool primary;

  final BorderRadius borderRadius;
  final AccountCardStyle style;

  const AccountCard({
    super.key,
    required this.account,
    required this.useCupertinoContextMenu,
    this.onTapOverride,
    this.primary = false,
    this.borderRadius = const .all(Radius.circular(24.0)),
    required this.excludeTransfersInTotal,
    this.style = AccountCardStyle.classic,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final Iterable<Transaction> transactions = account
        .transactions
        .nonPending
        .nonDeleted
        .where((x) => x.transactionDate.isAtSameMonthAs(now));

    final MultiCurrencyFlow flow = MultiCurrencyFlow()
      ..addAll(
        (excludeTransfersInTotal ? transactions.nonTransfers : transactions)
            .map((transaction) => transaction.money),
      );

    final Widget child = style == AccountCardStyle.accountsTab
        ? _buildAccountsTabCard(context, flow)
        : _buildClassicCard(context, flow);

    if (!useCupertinoContextMenu) {
      return child;
    }

    return CupertinoContextMenu.builder(
      builder: (context, animation) {
        return Padding(
          padding: const EdgeInsets.all(16.0) * animation.value,
          child: child,
        );
      },
      actions: [
        // TODO Why is it still open? Do I really have to pop, then push?
        CupertinoContextMenuAction(
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.push("/account/${account.id}/edit");
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.edit_rounded,
          child: Text("account.edit".t(context)),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.push(
                "/account/${account.id}/transactions?title=${"account.transactions.title".t(context, account.name)}",
              );
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.list_rounded,
          child: Text("account.transactions".t(context)),
        ),
      ],
    );
  }

  Widget _buildClassicCard(BuildContext context, MultiCurrencyFlow flow) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: onTapOverride == null
            ? () => context.push("/account/${account.id}")
            : onTapOverride!.value,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  FlowIcon(
                    account.icon,
                    size: 60.0,
                    colorScheme: account.colorScheme,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            if (primary)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Symbols.star_rounded,
                                    size:
                                        context.textTheme.titleSmall?.fontSize,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ),
                            TextSpan(
                              text:
                                  account.name +
                                  (account.archived
                                      ? " (${"account.archived".t(context)})"
                                      : ""),
                            ),
                          ],
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                      MoneyText(
                        account.balance,
                        style: context.textTheme.displaySmall,
                      ),
                    ],
                  ),
                ],
              ),
              if (!account.archived) ...[
                const SizedBox(height: 16.0),
                Text(
                  "account.thisMonth".t(context),
                  style: context.textTheme.bodyLarge,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        TransactionType.income.localizedNameContext(context),
                        style: context.textTheme.labelSmall?.semi(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        TransactionType.expense.localizedNameContext(context),
                        style: context.textTheme.labelSmall?.semi(context),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: MoneyText(
                        flow.getIncomeByCurrency(account.currency),
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: MoneyText(
                        flow.getExpenseByCurrency(account.currency),
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsTabCard(BuildContext context, MultiCurrencyFlow flow) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(AccountsTabTheme.cardRadius);
    final Color accent =
        account.colorScheme?.primary ?? AccountsTabTheme.primary(context);

    return Opacity(
      opacity: account.archived ? 0.72 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapOverride == null
              ? () => context.push("/account/${account.id}")
              : onTapOverride!.value,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: AccountsTabTheme.cardFill,
              borderRadius: radius,
              border: Border.all(
                color: primary
                    ? AccountsTabTheme.primary(context).withValues(alpha: 0.35)
                    : AccountsTabTheme.cardBorder,
                width: primary ? 1.5 : 1.0,
              ),
              boxShadow: AccountsTabTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        alignment: Alignment.center,
                        child: FlowIcon(
                          account.icon,
                          size: 28.0,
                          colorScheme: account.colorScheme,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (primary) ...[
                                   Icon(
                                    Symbols.star_rounded,
                                    size: 16.0,
                                    color: AccountsTabTheme.primary(context),
                                  ),
                                  const SizedBox(width: 4.0),
                                ],
                                Expanded(
                                  child: Text(
                                    account.name +
                                        (account.archived
                                            ? " (${"account.archived".t(context)})"
                                            : ""),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.0,
                                      color: AccountsTabTheme.titleInk,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            MoneyText(
                              account.balance,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20.0,
                                color: AccountsTabTheme.titleInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const LeChevron(),
                    ],
                  ),
                  if (!account.archived) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: AccountsTabTheme.divider,
                      ),
                    ),
                    Text(
                      "account.thisMonth".t(context).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AccountsTabTheme.sectionLabel,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: _MonthMetric(
                            label: TransactionType.income.localizedNameContext(
                              context,
                            ),
                            money: flow.getIncomeByCurrency(account.currency),
                            ink: AccountsTabTheme.incomeInk,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: _MonthMetric(
                            label: TransactionType.expense.localizedNameContext(
                              context,
                            ),
                            money: flow.getExpenseByCurrency(account.currency),
                            ink: AccountsTabTheme.expenseInk,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthMetric extends StatelessWidget {
  final String label;
  final Money money;
  final Color ink;

  const _MonthMetric({
    required this.label,
    required this.money,
    required this.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w600,
              fontSize: 11.0,
            ),
          ),
          const SizedBox(height: 4.0),
          MoneyText(
            money,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              color: AccountsTabTheme.titleInk,
            ),
          ),
        ],
      ),
    );
  }
}
