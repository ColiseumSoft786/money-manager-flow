import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transactions_filter/group_range.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/utils/flow_haptics.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text_builder.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flow/widgets/home/home_transaction_cards_scope.dart";
import "package:flow/widgets/general/money_text.dart";
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
    final effectiveTheme = TransactionListTileTheme.maybeOf(context)?.data.merge(theme) ?? theme ?? TransactionListTileThemeData.fallback;
    final showPendingConfirmation = confirmFn != null && transaction.confirmable();
    
    if ((combineTransfers || showPendingConfirmation) && transaction.isTransfer && !transaction.amount.isNegative) {
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

    final listTile = _ModernTransactionCard(
      transaction: transaction,
      resolvedTitle: resolvedTitle,
      effectiveTheme: effectiveTheme,
      combineTransfers: combineTransfers,
      groupRange: groupRange,
      overrideObscure: overrideObscure,
      onTap: () => context.push("/transaction/${transaction.id}"),
      child: _buildCardContent(context, effectiveTheme, resolvedTitle),
    );

    final startActions = _buildStartActions(context);
    final endActions = _buildEndActions(context, showPendingConfirmation);

    if (startActions.isEmpty && endActions.isEmpty) {
      return listTile;
    }

    return DirectionalSlidable(
      key: dismissibleKey,
      groupTag: "transaction_list_tile",
      startActions: startActions,
      endActions: endActions,
      child: listTile,
    );
  }

  Widget _buildCardContent(
  BuildContext context,
  TransactionListTileThemeData effectiveTheme,
  String resolvedTitle,
) {
  final theme = Theme.of(context);
  final isExpense = transaction.type == TransactionType.expense;
  final timeString = _getTimeString();
  final categoryText = transaction.category.target?.name;
  final accountText = _getAccountName(context);

  return Padding(
    padding: effectiveTheme.paddingOrDefault,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        _ModernIcon(transaction: transaction, effectiveTheme: effectiveTheme),
        SizedBox(width: effectiveTheme.spacingOrDefault),
        
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
             
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      resolvedTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                 
                  MoneyTextBuilder(
                    money: transaction.money,
                    displayAbsoluteAmount: true,
                    overrideObscure: overrideObscure,
                    builder: (context, text, money) {
                      return Text(
                        isExpense ? "-$text" : "+$text",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: isExpense 
                              ? context.flowColors.expense 
                              : context.flowColors.income,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
            
              if (categoryText != null && categoryText.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        categoryText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                     
                     timeString,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 2),
             
              Text(
               
               accountText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  String _getTimeString() {
    final DateTime now = Moment.now().startOfNextMinute();
    final bool isPending = transaction.isPending == true ||
        transaction.transactionDate.isFutureAnchored(now);

    if (isPending) {
      return transaction.transactionDate.toMoment().calendar();
    }

    return switch (groupRange) {
      TransactionGroupRange.hour || TransactionGroupRange.day =>
        transaction.transactionDate.toMoment().LT,
      _ => transaction.transactionDate.toMoment().lll,
    };
  }

  String _getAccountName(BuildContext context) {
    final transfer =
        transaction.isTransfer ? transaction.extensions.transfer : null;

    if (transaction.isTransfer && combineTransfers && transfer != null) {
      return "${AccountsProvider.of(context).getName(transfer.fromAccountUuid)} → ${AccountsProvider.of(context).getName(transfer.toAccountUuid)}";
    }

    return AccountsProvider.of(context).getName(transaction.accountUuid) ??
        transaction.account.target?.name ??
        "";
  }

  List<SlidableAction> _buildStartActions(BuildContext context) {
    final actions = <SlidableAction>[];
    
    if (transaction.isDeleted != true) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticLight();
          context.push("/transaction/${transaction.id}");
        },
        icon: Symbols.edit_rounded,
        backgroundColor: context.colorScheme.secondaryContainer,
        foregroundColor: context.colorScheme.onSecondaryContainer,
      ));
    }
    
    if (duplicateFn != null && transaction.isDeleted != true) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticLight();
          duplicateFn!();
        },
        icon: Symbols.content_copy_rounded,
        backgroundColor: context.colorScheme.tertiaryContainer,
        foregroundColor: context.colorScheme.onTertiaryContainer,
      ));
    }
    
    return actions;
  }

  List<SlidableAction> _buildEndActions(BuildContext context, bool showPendingConfirmation) {
    final actions = <SlidableAction>[];
    final showConfirmButton = confirmFn != null && transaction.confirmable();
    final showHoldButton = confirmFn != null && transaction.holdable();
    
    if (showConfirmButton) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticMedium();
          confirmFn!();
        },
        icon: Symbols.check_rounded,
        backgroundColor: context.flowColors.income,
        foregroundColor: Colors.white,
      ));
    }
    
    if (showHoldButton) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticMedium();
          confirmFn!(false);
        },
        icon: Symbols.cancel_rounded,
        backgroundColor: context.flowColors.expense,
        foregroundColor: Colors.white,
      ));
    }
    
    if (moveToTrashFn != null && !showHoldButton && transaction.isDeleted != true) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticMedium();
          moveToTrashFn!();
        },
        icon: Symbols.delete_forever_rounded,
        backgroundColor: context.colorScheme.errorContainer,
        foregroundColor: context.colorScheme.onErrorContainer,
      ));
    }
    
    if (recoverFromTrashFn != null && !showHoldButton && transaction.isDeleted == true) {
      actions.add(SlidableAction(
        onPressed: (_) {
          flowHapticLight();
          recoverFromTrashFn!();
        },
        icon: Symbols.restore_page_rounded,
        backgroundColor: context.flowColors.income,
        foregroundColor: Colors.white,
      ));
    }
    
    return actions;
  }
}

// Modern icon widget
class _ModernIcon extends StatelessWidget {
  final Transaction transaction;
  final TransactionListTileThemeData effectiveTheme;

  const _ModernIcon({required this.transaction, required this.effectiveTheme});

  @override
  Widget build(BuildContext context) {
    late final FlowIconData iconData;
    FlowColorScheme? colorScheme;

    if (transaction.isTransfer) {
      iconData = FlowIconData.icon(Symbols.sync_alt_rounded);
    } else if (effectiveTheme.useAccountIconForLeadingOrDefault) {
      iconData =
          AccountsProvider.of(context).get(transaction.accountUuid)?.icon ??
          transaction.account.target?.icon ??
          FlowIconData.icon(Symbols.circle_rounded);
    } else if (transaction.category.target != null) {
      final Category category = transaction.category.target!;
      iconData = category.icon;
      colorScheme = category.colorScheme;
    } else {
      iconData = FlowIconData.icon(Symbols.circle_rounded);
    }

    final Category? category = transaction.category.target;
    final bool isPending =
        transaction.isPending == true ||
        transaction.transactionDate.isFutureAnchored(
          Moment.now().startOfNextMinute(),
        );

    return Opacity(
      opacity: isPending ? 0.65 : 1.0,
      child: FlowIcon(
        iconData,
        plated: true,
        size: 20.0,
        fill: category != null ? 1.0 : 0.0,
        color: colorScheme?.primary,
        plateColor: colorScheme?.secondary,
        platePadding: const EdgeInsets.all(8.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}

// Modern meta row with chips
class _ModernMetaRow extends StatelessWidget {
  final Transaction transaction;
  final bool combineTransfers;
  final TransactionGroupRange? groupRange;

  const _ModernMetaRow({
    required this.transaction,
    required this.combineTransfers,
    required this.groupRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context);
    final transfer = transaction.isTransfer ? transaction.extensions.transfer : null;
    
    String accountText;
    if (transaction.isTransfer && combineTransfers && transfer != null) {
      accountText = "${AccountsProvider.of(context).getName(transfer.fromAccountUuid)} → ${AccountsProvider.of(context).getName(transfer.toAccountUuid)}";
    } else {
      accountText = AccountsProvider.of(context).getName(transaction.accountUuid) ?? transaction.account.target?.name ?? "";
    }
    
    final categoryText = transaction.category.target?.name;
    final timeText = _getTimeString();
    
    
    final List<String> parts = <String>[];
    if (accountText.isNotEmpty) parts.add(accountText);
    if (categoryText != null && categoryText.isNotEmpty) parts.add(categoryText);
    parts.add(timeText);

    return Text(
      parts.join(" · "),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: GlassPanel.mutedInk(context),
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  String _getTimeString() {
    final now = Moment.now().startOfNextMinute();
    final isPending = transaction.isPending == true || transaction.transactionDate.isFutureAnchored(now);
    
    if (isPending) return transaction.transactionDate.toMoment().calendar();
    
    return switch (groupRange) {
      TransactionGroupRange.hour || TransactionGroupRange.day => transaction.transactionDate.toMoment().LT,
      _ => transaction.transactionDate.toMoment().lll,
    };
  }
}

// Modern amount display
class _ModernAmount extends StatelessWidget {
  final Transaction transaction;
  final bool combineTransfers;
  final bool? overrideObscure;

  const _ModernAmount({
    required this.transaction,
    required this.combineTransfers,
    required this.overrideObscure,
  });

  @override
  Widget build(BuildContext context) {
    final flowColors = context.flowColors;
    final isPositive = transaction.type == TransactionType.income;
    final Color color =
        isPositive ? flowColors.income : flowColors.expense;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        MoneyTextBuilder(
          money: transaction.money,
          displayAbsoluteAmount: transaction.isTransfer && combineTransfers,
          overrideObscure: overrideObscure,
          builder: (context, text, money) {
            String displayText = text;
            if (isPositive && !displayText.trimLeft().startsWith("+")) {
              displayText = "+$displayText";
            }
            return Text(
              displayText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: color,
              ),
            );
          },
        ),
        if (combineTransfers && 
            transaction.extensions.transfer?.conversionRate != null &&
            transaction.extensions.transfer?.conversionRate != 1.0)
          MoneyText(
            Money(
              transaction.money.amount * transaction.extensions.transfer!.conversionRate!,
              AccountsProvider.of(context)
                  .get(transaction.extensions.transfer!.toAccountUuid)!
                  .currency,
            ),
            displayAbsoluteAmount: true,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            overrideObscure: overrideObscure,
          ),
      ],
    );
  }
}

// Modern transaction card wrapper
class _ModernTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String resolvedTitle;
  final TransactionListTileThemeData effectiveTheme;
  final bool combineTransfers;
  final TransactionGroupRange? groupRange;
  final bool? overrideObscure;
  final VoidCallback onTap;
  final Widget child;

  const _ModernTransactionCard({
    required this.transaction,
    required this.resolvedTitle,
    required this.effectiveTheme,
    required this.combineTransfers,
    required this.groupRange,
    required this.overrideObscure,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isOnGlass = HomeTransactionCardsScope.enabledIn(context);
    
    if (isOnGlass) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
        child: GlassPanel(
          borderRadius: BorderRadius.circular(16),
          blurBehind: true,
          blurSigma: GlassPanel.resolveListTileBlur(context),
          borderColor: GlassPanel.resolveListTileBorder(context),
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: child,
        ),
      );
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: child,
        ),
      ),
    );
  }
}