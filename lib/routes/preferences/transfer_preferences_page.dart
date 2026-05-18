import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_accounting_card.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_hero_illustration.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_info_banner.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_layout_options_card.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_section_header.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class TransferPreferencesPage extends StatefulWidget {
  const TransferPreferencesPage({super.key});

  @override
  State<TransferPreferencesPage> createState() =>
      _TransferPreferencesPageState();
}

class _TransferPreferencesPageState extends State<TransferPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool excludeTransferFromFlow =
        UserPreferencesService().excludeTransfersFromFlow;
    final bool combineTransferTransactions =
        UserPreferencesService().combineTransfers;

    return Scaffold(
      backgroundColor: TransferPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: TransferPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "preferences.transfer.settingsTitle".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: TransferPreferencesTheme.titleInk,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              "general.save".t(context),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: TransferPreferencesTheme.primary(context),
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TransferHeroIllustration(),
              const SizedBox(height: 16.0),
              Text(
                "preferences.transfer.heroDescription".t(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TransferPreferencesTheme.subtitleInk,
                  fontSize: 14.0,
                  height: 1.45,
                ),
              ),
              TransferSectionHeader(
                label: "preferences.transfer.section.layout".t(context),
              ),
              TransferLayoutOptionsCard(
                combineSelected: combineTransferTransactions,
                onCombine: () => updateCombineTransferTransactions(true),
                onSeparate: () => updateCombineTransferTransactions(false),
              ),
              TransferSectionHeader(
                label: "preferences.transfer.section.accounting".t(context),
              ),
              TransferAccountingCard(
                excludeFromTotals: excludeTransferFromFlow,
                onChanged: (bool value) => updateExcludeTransferFromFlow(value),
              ),
              const SizedBox(height: 20.0),
              const TransferInfoBanner(),
            ],
          ),
        ),
      ),
    );
  }

  void updateExcludeTransferFromFlow(bool? excludeFromFlow) {
    if (excludeFromFlow == null) return;

    UserPreferencesService().excludeTransfersFromFlow = excludeFromFlow;

    if (mounted) setState(() {});
  }

  void updateCombineTransferTransactions(bool? combine) {
    if (combine == null) return;

    UserPreferencesService().combineTransfers = combine;

    if (mounted) setState(() {});
  }
}
