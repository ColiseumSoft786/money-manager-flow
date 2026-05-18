import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/home/home_transaction_cards_scope.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/transaction_list_tile/transaction_subtitle.dart";
import "package:flow/widgets/transaction_list_tile_theme.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListTile extends StatelessWidget {
  final TransactionListTileThemeData? theme;

  final Transaction transaction;

  final VoidCallback? recoverFromTrashFn;
  final VoidCallback? moveToTrashFn;
  final VoidCallback? duplicateFn;
  final Function([bool confirm])? confirmFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  final bool? overrideObscure;

  /// Determines what date/time to show. i.e.:
  ///
  /// * [TransactionGroupRange.hour] - Hour and minute
  /// * [TransactionGroupRange.day] - Hour and minute
  /// * [TransactionGroupRange.week] - Calendar date with hour and minute
  /// * [TransactionGroupRange.month] - Calendar date with hour and minute
  /// * [TransactionGroupRange.year] - Calendar date with hour and minute
  ///
  /// Defaults to [TransactionGroupRange.day]
  final TransactionGroupRange? groupRange;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.recoverFromTrashFn,
    required this.moveToTrashFn,
    required this.combineTransfers,
    this.groupRange = TransactionGroupRange.day,
    this.confirmFn,
    this.duplicateFn,
    this.dismissibleKey,
    this.overrideObscure,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionListTileThemeData effectiveTheme =
        TransactionListTileTheme.maybeOf(context)?.data.merge(theme) ??
        theme ??
        TransactionListTileThemeData.fallback;

    final bool cardChrome = HomeTransactionCardsScope.enabledIn(context);

    final bool showPendingConfirmation =
        confirmFn != null && transaction.confirmable();

    final bool showDuplicateButton =
        transaction.isDeleted != true && duplicateFn != null;
    final bool showHoldButton = confirmFn != null && transaction.holdable();
    final bool showConfirmButton =
        confirmFn != null && transaction.confirmable();

    if ((combineTransfers || showPendingConfirmation) &&
        transaction.isTransfer &&
        !transaction.amount.isNegative) {
      return Container();
    }

    final String resolvedTitle = switch (transaction.title) {
      String title when title.isNotEmpty => title,
      _ =>
        ((effectiveTheme.useCategoryNameForUntitledTransactionsOrDefault
                ? transaction.category.target?.name
                : null) ??
            "transaction.fallbackTitle".t(context)),
    };

    final Transfer? transfer = transaction.isTransfer
        ? transaction.extensions.transfer
        : null;

    final List<InlineSpan> subtitleComponents = [
      TextSpan(
        text: (transaction.isTransfer && combineTransfers)
            ? "${AccountsProvider.of(context).getName(transfer!.fromAccountUuid)} → ${AccountsProvider.of(context).getName(transfer.toAccountUuid)}"
            : (AccountsProvider.of(context).getName(transaction.accountUuid) ??
                  transaction.account.target?.name),
      ),
      if (effectiveTheme.showCategoryOrDefault &&
          transaction.category.target != null)
        TextSpan(text: transaction.category.target!.name),
      if (effectiveTheme.showExternalSourceOrDefault)
        if (transaction.externalProviderName
            case String externalProviderName) ...[
          TextSpan(
            children: [
              if (externalProviderName == "Siri")
                WidgetSpan(
                  child: Padding(
                    padding: .only(right: 4.0),
                    child: Image.asset("assets/images/siri.png", height: 12.0),
                  ),
                  alignment: .middle,
                ),
              if (externalProviderName == "Eny")
                WidgetSpan(
                  child: Padding(
                    padding: .only(right: 4.0),
                    child: Image.network(enyLogoUrl, height: 12.0),
                  ),
                  alignment: .middle,
                ),
              TextSpan(text: externalProviderName),
            ],
          ),
        ],
      TextSpan(text: dateString),
      if (transaction.transactionDate.isFuture)
        TextSpan(
          text: transaction.isPending == true
              ? "transaction.pending".t(context)
              : "transaction.pending.preapproved".t(context),
        ),
    ];

    final WidgetSpan? titleLeadingIconSpan = transaction.isRecurring
        ? titleIconSpan(context, Symbols.repeat_rounded)
        : (transaction.transactionDate.isFutureAnchored(
                Moment.now().startOfNextMinute(),
              )
              ? titleIconSpan(
                  context,
                  Symbols.search_activity_rounded,
                  color: transaction.isPending == true
                      ? context.colorScheme.onSurface.withAlpha(0xc0)
                      : context.flowColors.income,
                )
              : null);

    final Widget inner = Padding(
      padding: effectiveTheme.paddingOrDefault,
      child: Column(
        children: [
          Row(
                crossAxisAlignment: cardChrome
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                spacing: effectiveTheme.spacingOrDefault,
                children: [
                  buildLeading(context, effectiveTheme, cardChrome),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: effectiveTheme.titleSpacingOrDefault,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              if (titleLeadingIconSpan != null) ...[
                                titleLeadingIconSpan,
                                TextSpan(text: " "),
                              ],
                              TextSpan(text: resolvedTitle),
                            ],
                            style: cardChrome
                                ? context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? kFlowHomeTransactionHeadingInk
                                        : context.colorScheme.onSurface,
                                  )
                                : context.textTheme.bodyMedium,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cardChrome)
                          _buildHomeStackedMeta(
                            context,
                            effectiveTheme,
                            combineTransfers,
                            resolvedTitle,
                          )
                        else
                          TransactionSubtitle(
                            components: subtitleComponents,
                            foregroundColor: null,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: effectiveTheme.titleSpacingOrDefault,
                    children: [
                      MoneyTextBuilder(
                        money: transaction.money,
                        displayAbsoluteAmount:
                            transaction.isTransfer && combineTransfers,
                        overrideObscure: overrideObscure,
                        builder: (context, text, money) {
                          String displayText = text;
                          if (cardChrome &&
                              !transaction.isTransfer &&
                              money != null &&
                              money.amount > 0 &&
                              !displayText.trimLeft().startsWith("+")) {
                            displayText = "+$displayText";
                          }
                          return Text(
                            displayText,
                            style: cardChrome
                                ? context.textTheme.titleSmall?.copyWith(
                                    color: transaction.type.color(context),
                                    fontWeight: FontWeight.w700,
                                  )
                                : context.textTheme.bodyLarge?.copyWith(
                                    color: transaction.type.color(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                          );
                        },
                      ),
                      if (combineTransfers &&
                          AccountsProvider.of(context).ready &&
                          transaction.extensions.transfer?.conversionRate !=
                              null &&
                          transaction.extensions.transfer?.conversionRate !=
                              1.0)
                        MoneyText(
                          Money(
                            transaction.money.amount *
                                transaction
                                    .extensions
                                    .transfer!
                                    .conversionRate!,
                            AccountsProvider.of(context)
                                .get(
                                  transaction
                                      .extensions
                                      .transfer!
                                      .toAccountUuid,
                                )!
                                .currency,
                          ),
                          displayAbsoluteAmount: true,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(
                              0x80,
                            ),
                          ),
                          overrideObscure: overrideObscure,
                        ),
                    ],
                  ),
                ],
              ),
              if (showPendingConfirmation) ...[
                SizedBox(height: effectiveTheme.spacingOrDefault),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => confirmFn!(),
                      label: Text("general.confirm".t(context)),
                      icon: Icon(Symbols.check_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
        ],
      ),
    );

    final BorderRadius cardRadius = BorderRadius.circular(18.0);

    final Widget listTile = cardChrome
        ? Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 6.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : context.colorScheme.surfaceContainerHigh,
                borderRadius: cardRadius,
                border: Border.all(
                  width: 1.0,
                  color: Theme.of(context).brightness == Brightness.light
                      ? kFlowHomeTransactionCardBorder
                      : context.colorScheme.outline.withValues(alpha: 0.22),
                ),
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? const [
                        BoxShadow(
                          offset: Offset(0.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          color: kFlowHomeTransactionCardShadowColor,
                        ),
                      ]
                    : const [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push("/transaction/${transaction.id}"),
                  borderRadius: cardRadius,
                  child: inner,
                ),
              ),
            ),
          )
        : Material(
            type: MaterialType.card,
            color: kTransparent,
            child: InkWell(
              onTap: () => context.push("/transaction/${transaction.id}"),
              child: inner,
            ),
          );

    final List<SlidableAction> startActions = [
      if (showDuplicateButton)
        SlidableAction(
          onPressed: (context) => duplicateFn!(),
          icon: Symbols.content_copy_rounded,
          backgroundColor: context.flowColors.semi,
        ),
    ];

    final List<SlidableAction> endActions = [
      if (showConfirmButton)
        SlidableAction(
          onPressed: (context) => confirmFn!(),
          icon: Symbols.check_rounded,
          backgroundColor: context.colorScheme.primary,
        ),
      if (showHoldButton)
        SlidableAction(
          onPressed: (context) => confirmFn!(false),
          icon: Symbols.cancel_rounded,
          backgroundColor: context.flowColors.expense,
        ),
      if (moveToTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted != true)
        SlidableAction(
          onPressed: (context) => moveToTrashFn!(),
          icon: Symbols.delete_forever_rounded,
          backgroundColor: context.flowColors.expense,
        ),
      if (recoverFromTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted == true)
        SlidableAction(
          onPressed: (context) => recoverFromTrashFn!(),
          icon: Symbols.restore_page_rounded,
          backgroundColor: context.flowColors.income,
        ),
    ];

    return DirectionalSlidable(
      key: dismissibleKey,
      groupTag: "transaction_list_tile",
      startActions: startActions,
      endActions: endActions,
      child: listTile,
    );
  }

  /// Home elevated cards: account, category, time on separate lines (no • run-on).
  Widget _buildHomeStackedMeta(
    BuildContext context,
    TransactionListTileThemeData effectiveTheme,
    bool combineTransfers,
    String resolvedTitle,
  ) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color captionColor = light
        ? kFlowHomeTransactionCaptionMuted
        : context.colorScheme.onSurfaceVariant;

    final TextStyle lineStyle = context.textTheme.bodySmall!.copyWith(
      color: captionColor,
      height: 1.45,
      fontWeight: FontWeight.w500,
    );

    final List<Widget> lines = <Widget>[];

    void pushLine(Widget line) {
      if (lines.isNotEmpty) {
        lines.add(const SizedBox(height: 4.0));
      }
      lines.add(line);
    }

    final Transfer? xfer =
        transaction.isTransfer ? transaction.extensions.transfer : null;

    final String accountLabel =
        (transaction.isTransfer && combineTransfers && xfer != null)
        ? "${AccountsProvider.of(context).getName(xfer.fromAccountUuid) ?? ""} → ${AccountsProvider.of(context).getName(xfer.toAccountUuid) ?? ""}"
        : (AccountsProvider.of(context).getName(transaction.accountUuid) ??
              transaction.account.target?.name ??
              "");

    if (accountLabel.isNotEmpty) {
      pushLine(
        Text(
          accountLabel,
          style: lineStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (effectiveTheme.showCategoryOrDefault &&
        transaction.category.target != null) {
      final String cat = transaction.category.target!.name;
      if (cat.toLowerCase() != resolvedTitle.trim().toLowerCase()) {
        pushLine(
          Text(
            cat,
            style: lineStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
    }

    if (effectiveTheme.showExternalSourceOrDefault &&
        transaction.externalProviderName != null) {
      final String externalProviderName = transaction.externalProviderName!;
      pushLine(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (externalProviderName == "Siri")
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6.0),
                child: Image.asset("assets/images/siri.png", height: 12.0),
              ),
            if (externalProviderName == "Eny")
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6.0),
                child: Image.network(enyLogoUrl, height: 12.0),
              ),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                externalProviderName,
                style: lineStyle.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final String pendingPiece = transaction.transactionDate.isFuture
        ? " · ${transaction.isPending == true ? "transaction.pending".t(context) : "transaction.pending.preapproved".t(context)}"
        : "";

    pushLine(
      Text(
        "${dateString}$pendingPiece",
        style: lineStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines,
    );
  }

  FlowIcon buildLeading(
    BuildContext context,
    TransactionListTileThemeData theme,
    bool cardChrome,
  ) {
    late final FlowIconData iconData;
    FlowColorScheme? colorScheme;

    if (transaction.isTransfer) {
      iconData = FlowIconData.icon(Symbols.sync_alt_rounded);
    } else if (theme.useAccountIconForLeadingOrDefault) {
      iconData =
          AccountsProvider.of(context).get(transaction.accountUuid)?.icon ??
          transaction.account.target?.icon ??
          FlowIconData.icon(Symbols.circle_rounded);
    } else if (transaction.category.target != null) {
      iconData = transaction.category.target!.icon;
      colorScheme = transaction.category.target!.colorScheme;
    } else {
      iconData = FlowIconData.icon(Symbols.circle_rounded);
    }

    return FlowIcon(
      iconData,
      plated: true,
      fill: transaction.category.target != null ? 1.0 : 0.0,
      color: colorScheme?.primary,
      plateColor: colorScheme?.secondary,
      platePadding:
          cardChrome ? const EdgeInsets.all(12.0) : const EdgeInsets.all(8.0),
      borderRadius: cardChrome
          ? BorderRadius.circular(8.0)
          : const BorderRadius.all(Radius.circular(16.0)),
    );
  }

  String get dateString {
    final DateTime now = Moment.now().startOfNextMinute();

    final bool pending =
        transaction.isPending == true ||
        transaction.transactionDate.isFutureAnchored(now);

    if (pending) return transaction.transactionDate.toMoment().calendar();

    return switch (groupRange) {
      TransactionGroupRange.hour ||
      TransactionGroupRange.day => transaction.transactionDate.toMoment().LT,
      _ => transaction.transactionDate.toMoment().lll,
    };
  }

  WidgetSpan titleIconSpan(
    BuildContext context,
    IconData icon, {
    Color? color,
  }) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Icon(
      icon,
      size: context.textTheme.bodyMedium!.fontSize!,
      fill: 0.0,
      color: color,
    ),
  );
}
