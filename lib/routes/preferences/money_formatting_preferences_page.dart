import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_customization_card.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_footer_notice.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_preferences_card.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_preview_card.dart";
import "package:flow/routes/preferences/money_formatting/widgets/money_formatting_section_header.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/sheets/select_currency_icu_pattern.dart";
import "package:flutter/material.dart";

class MoneyFormattingPreferencesPage extends StatefulWidget {
  const MoneyFormattingPreferencesPage({super.key});

  @override
  State<MoneyFormattingPreferencesPage> createState() =>
      _MoneyFormattingPreferencesPageState();
}

class _MoneyFormattingPreferencesPageState
    extends State<MoneyFormattingPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool preferFullAmounts = LocalPreferences().preferFullAmounts.get();
    final bool useCurrencySymbol = LocalPreferences().useCurrencySymbol.get();

    return Scaffold(
      backgroundColor: MoneyFormattingPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: MoneyFormattingPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "preferences.moneyFormatting".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: MoneyFormattingPreferencesTheme.titleInk,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: kFlowAccountRowDividerLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MoneyFormattingPreviewCard(preferFullAmounts: preferFullAmounts),
              MoneyFormattingSectionHeader(
                label: "preferences.moneyFormatting.section.preferences".t(
                  context,
                ),
              ),
              MoneyFormattingPreferencesCard(
                preferFullAmounts: preferFullAmounts,
                useCurrencySymbol: useCurrencySymbol,
                onPreferFullAmountsChanged: updatePreferFullAmounts,
                onUseCurrencySymbolChanged: updateUseCurrencySymbol,
              ),
              MoneyFormattingSectionHeader(
                label: "preferences.moneyFormatting.section.customization".t(
                  context,
                ),
              ),
              MoneyFormattingCustomizationCard(
                onTap: updateCustomICUCurrencyFormatter,
              ),
              const SizedBox(height: 20.0),
              const MoneyFormattingFooterNotice(),
            ],
          ),
        ),
      ),
    );
  }

  void updatePreferFullAmounts(bool newPreferFullAmounts) async {
    await LocalPreferences().preferFullAmounts.set(newPreferFullAmounts);

    if (mounted) setState(() {});
  }

  void updateUseCurrencySymbol(bool newUseCurrencySymbol) async {
    await LocalPreferences().useCurrencySymbol.set(newUseCurrencySymbol);

    if (mounted) setState(() {});
  }

  void updateCustomICUCurrencyFormatter() async {
    final Optional<String?>? result = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectCurrencyIcuPattern(),
      isScrollControlled: true,
    );

    if (result == null) return;

    UserPreferencesService().icuCurrencyFormattingPattern = result.value;

    if (mounted) setState(() {});
  }
}
