import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_dashboard_card.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_disconnect_button.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_info_footer.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_scan_documents_card.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_section_header.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_status_card.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

class EnyPreferencesPage extends StatefulWidget {
  const EnyPreferencesPage({super.key});

  @override
  State<EnyPreferencesPage> createState() => _EnyPreferencesPageState();
}

class _EnyPreferencesPageState extends State<EnyPreferencesPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      EnyService().checkCredits().catchError((_) {
        return null;
      });
    });
  }

  void _openDashboard() {
    openUrl(enyDashboardLink);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnyPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: EnyPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "Eny",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: EnyPreferencesTheme.titleInk,
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
      body: ValueListenableBuilder(
        valueListenable: EnyService().apiKey,
        builder: (context, apiKey, child) {
          final bool connected = EnyService().isConnected;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnySectionHeader(
                    label: "integrations.eny.privacyNotice".t(context),
                  ),
                  Text(
                    "integrations.eny.privacyNotice.preferencesDescription".t(
                      context,
                      {"appName": "appName".t(context)},
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EnyPreferencesTheme.subtitleInk,
                      fontSize: 14.0,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  EnyDashboardCard(onTap: _openDashboard),
                  const SizedBox(height: 16.0),
                  ValueListenableBuilder(
                    valueListenable: EnyService().remainingCredits,
                    builder: (context, remainingCredits, child) {
                      return EnyStatusCard(
                        connected: connected,
                        email: EnyService().email,
                        creditsBusy: _busy,
                        remainingCredits: remainingCredits,
                        onConnect: _openDashboard,
                        onRefreshCredits: connected ? _refreshCredits : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ValueListenableBuilder(
                    valueListenable: UserPreferencesService().valueNotifier,
                    builder: (context, userPreferences, child) {
                      final bool createTransactionsPerItemInScans =
                          userPreferences.createTransactionsPerItemInScans;
                      final int? scansPendingThresholdInHours =
                          userPreferences.scansPendingThresholdInHours;

                      return EnyScanDocumentsCard(
                        createTransactionsPerItem:
                            createTransactionsPerItemInScans,
                        markAsPending: scansPendingThresholdInHours == 0,
                        onCreatePerItemChanged: (bool newValue) {
                          UserPreferencesService()
                                  .createTransactionsPerItemInScans =
                              newValue;
                        },
                        onMarkPendingChanged: (bool newValue) {
                          UserPreferencesService().scansPendingThresholdInHours =
                              newValue ? 0 : 6;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const EnyInfoFooter(),
                  if (connected) ...[
                    const SizedBox(height: 8.0),
                    EnyDisconnectButton(onPressed: _disconnectEny),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshCredits() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      await EnyService().checkCredits();
    } finally {
      _busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _disconnectEny() async {
    final bool? confirmed = await context.showConfirmationSheet(
      title: "integrations.eny.disconnect".t(context),
      isDeletionConfirmation: true,
      mainActionLabelOverride: "general.confirm".t(context),
    );

    if (confirmed != true) {
      return;
    }

    await EnyService().disconnect();
    if (mounted) {
      setState(() {});
    }
  }
}
