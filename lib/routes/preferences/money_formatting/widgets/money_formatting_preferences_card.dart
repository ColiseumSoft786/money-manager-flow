import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_toggle_row.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class MoneyFormattingPreferencesCard extends StatelessWidget {
  final bool preferFullAmounts;
  final bool useCurrencySymbol;
  final ValueChanged<bool> onPreferFullAmountsChanged;
  final ValueChanged<bool> onUseCurrencySymbolChanged;

  const MoneyFormattingPreferencesCard({
    super.key,
    required this.preferFullAmounts,
    required this.useCurrencySymbol,
    required this.onPreferFullAmountsChanged,
    required this.onUseCurrencySymbolChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MoneyFormattingPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(
          MoneyFormattingPreferencesTheme.cardRadius,
        ),
        border: Border.all(color: MoneyFormattingPreferencesTheme.cardBorder),
      ),
      child: Column(
        children: [
          MoneyFormattingToggleRow(
            icon: Symbols.format_list_numbered_rounded,
            title: "preferences.moneyFormatting.preferFull".t(context),
            subtitle: "preferences.moneyFormatting.preferFull.description".t(
              context,
            ),
            value: preferFullAmounts,
            onChanged: onPreferFullAmountsChanged,
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            color: MoneyFormattingPreferencesTheme.divider,
          ),
          MoneyFormattingToggleRow(
            icon: Symbols.currency_exchange_rounded,
            title: "preferences.moneyFormatting.useCurrencySymbol".t(context),
            subtitle:
                "preferences.moneyFormatting.useCurrencySymbol.description".t(
                  context,
                ),
            value: useCurrencySymbol,
            onChanged: onUseCurrencySymbolChanged,
          ),
        ],
      ),
    );
  }
}
