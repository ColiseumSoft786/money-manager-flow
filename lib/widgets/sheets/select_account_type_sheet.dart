import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Order shown in the account-type picker (matches design: checking → savings → loan → card → …).
const List<AccountType> kAccountTypeSheetDisplayOrder = [
  AccountType.debit,
  AccountType.savings,
  AccountType.loan,
  AccountType.creditLine,
  AccountType.asset,
  AccountType.other,
];

class _TypeVisual {
  final Color plateBg;
  final Color plateFg;
  final IconData icon;

  const _TypeVisual({
    required this.plateBg,
    required this.plateFg,
    required this.icon,
  });
}

_TypeVisual _visualFor(AccountType type, bool light) {
  if (!light) {
    return _TypeVisual(
      plateBg: const Color(0xFF334155),
      plateFg: const Color(0xFF94A3B8),
      icon: _iconFor(type),
    );
  }
  return switch (type) {
    AccountType.debit => const _TypeVisual(
      plateBg: Color(0xFFDBEAFE),
      plateFg: Color(0xFF2563EB),
      icon: Symbols.account_balance_wallet_rounded,
    ),
    AccountType.savings => const _TypeVisual(
      plateBg: Color(0xFFFCE7F3),
      plateFg: Color(0xFFDB2777),
      icon: Symbols.savings_rounded,
    ),
    AccountType.loan => const _TypeVisual(
      plateBg: Color(0xFFFFEDD5),
      plateFg: Color(0xFFEA580C),
      icon: Symbols.handshake_rounded,
    ),
    AccountType.creditLine => const _TypeVisual(
      plateBg: Color(0xFFD1FAE5),
      plateFg: Color(0xFF059669),
      icon: Symbols.credit_card_rounded,
    ),
    AccountType.asset => const _TypeVisual(
      plateBg: Color(0xFFE9D5FF),
      plateFg: Color(0xFF7C3AED),
      icon: Symbols.inventory_2_rounded,
    ),
    AccountType.other => const _TypeVisual(
      plateBg: Color(0xFFF1F5F9),
      plateFg: Color(0xFF64748B),
      icon: Symbols.category_rounded,
    ),
  };
}

IconData _iconFor(AccountType type) => switch (type) {
  AccountType.debit => Symbols.account_balance_wallet_rounded,
  AccountType.savings => Symbols.savings_rounded,
  AccountType.loan => Symbols.handshake_rounded,
  AccountType.creditLine => Symbols.credit_card_rounded,
  AccountType.asset => Symbols.inventory_2_rounded,
  AccountType.other => Symbols.category_rounded,
};

String _subtitleKey(AccountType type) =>
    "account.type.sheetSubtitle.${type.localizationEnumValue}";

class SelectAccountTypeSheet extends StatelessWidget {
  final AccountType? currentlySelected;

  const SelectAccountTypeSheet({super.key, this.currentlySelected});

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;

    final Color cardFill =
        light ? kFlowAccountEditFieldFill : scheme.surfaceContainerHighest;
    final Color cardBorder =
        light ? kFlowPopularCurrencyCardBorder : scheme.outlineVariant;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : scheme.onSurface;
    const Color subtitleColor = kFlowPopularCurrenciesSectionHeading;

    return ModalSheet.scrollable(
      title: Text(
        "account.type".t(context),
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: titleColor,
          height: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < kAccountTypeSheetDisplayOrder.length; i++) ...[
              if (i > 0) const SizedBox(height: 12.0),
              _AccountTypeOptionCard(
                type: kAccountTypeSheetDisplayOrder[i],
                groupValue: currentlySelected,
                cardFill: cardFill,
                cardBorder: cardBorder,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                visual: _visualFor(kAccountTypeSheetDisplayOrder[i], light),
                onSelect: (AccountType value) => context.pop<AccountType>(value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountTypeOptionCard extends StatelessWidget {
  final AccountType type;
  final AccountType? groupValue;
  final Color cardFill;
  final Color cardBorder;
  final Color titleColor;
  final Color subtitleColor;
  final _TypeVisual visual;
  final ValueChanged<AccountType> onSelect;

  const _AccountTypeOptionCard({
    required this.type,
    required this.groupValue,
    required this.cardFill,
    required this.cardBorder,
    required this.titleColor,
    required this.subtitleColor,
    required this.visual,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => onSelect(type),
        child: Ink(
          decoration: BoxDecoration(
            color: cardFill,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: cardBorder, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: visual.plateBg,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    visual.icon,
                    size: 22.0,
                    color: visual.plateFg,
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.localizedNameContext(context),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        _subtitleKey(type).t(context),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<AccountType>(
                  value: type,
                  groupValue: groupValue,
                  onChanged: (AccountType? v) {
                    if (v != null) {
                      onSelect(v);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
