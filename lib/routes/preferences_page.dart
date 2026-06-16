import "dart:io";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/language_selection_sheet.dart";
import "package:flow/routes/preferences/root/preferences_root_theme.dart";
import "package:flow/routes/preferences/root/widgets/preferences_root_accordion_section.dart";
import "package:flow/routes/preferences/root/widgets/preferences_root_nav_row.dart";
import "package:flow/routes/preferences/sections/haptics.dart";
import "package:flow/routes/preferences/sections/lock_app.dart";
import "package:flow/routes/preferences/root/widgets/preferences_root_toggle_row.dart";
import "package:flow/routes/preferences/sections/privacy.dart";
import "package:flow/services/Firebase_auth_service.dart";
import "package:flow/services/file_attachment.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/names.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/animated_eny_logo.dart";
import "package:flow/widgets/general/flow_deletion_alert_dialog.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:permission_handler/permission_handler.dart";

final Logger _log = Logger("PreferencesPage");

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => PreferencesPageState();

  static PreferencesPageState of(BuildContext context) {
    return context.findAncestorStateOfType<PreferencesPageState>()!;
  }
}

class PreferencesPageState extends State<PreferencesPage> {
  bool _currencyBusy = false;
  bool _languageBusy = false;

  bool _showLockApp = false;

  @override
  void initState() {
    super.initState();

    LocalAuthService.initialize()
        .then((_) {
          _showLockApp = LocalAuthService.available;

          if (mounted) {
            setState(() {});
          }
        })
        .catchError((_) {
          _log.warning("Failed to initialize local auth service");
        });
  }

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme currentTheme = getTheme(
      UserPreferencesService().themeName,
    );

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo = LocalPreferences()
        .autoAttachTransactionGeo
        .get();
    final bool pendingTransactionsRequireConfrimation = LocalPreferences()
        .pendingTransactions
        .requireConfrimation
        .get();

    final String currentPrimaryCurrency =
        UserPreferencesService().primaryCurrency;

    final String geoSubtitle = enableGeo
        ? (autoAttachTransactionGeo
              ? "preferences.transactions.geo.auto.enabled".t(context)
              : "general.enabled".t(context))
        : "general.disabled".t(context);

    return Scaffold(
      backgroundColor: PreferencesRootTheme.canvas(context),
      appBar: AppBar(
        backgroundColor: PreferencesRootTheme.cardFill(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "preferences".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: PreferencesRootTheme.titleInk(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: PreferencesRootTheme.cardBorder(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
          children: [
            ValueListenableBuilder<int>(
              valueListenable: FirebaseAuthService().authRevision,
              builder: (context, _, __) {
                final List<Widget> generalRows = [
                  if (FirebaseAuthService().isSignedIn)
                    PreferencesRootNavRow(
                      leading: const PreferencesRootSymbolIcon(
                        Symbols.person_rounded,
                      ),
                      title: "auth.account.signOut".t(context),
                      subtitle: "auth.account.signOutSubtitle".t(context),
                      onTap: () async {
                        await FirebaseAuthService().signOut();
                        if (!context.mounted) return;
                        context.go("/");
                      },
                    ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.sync_rounded,
                    ),
                    title: "preferences.sync".t(context),
                    onTap: () => _pushAndRefreshAfter("/preferences/sync"),
                  ),
                  if (flowDebugMode ||
                      NotificationsService.schedulingSupported)
                    PreferencesRootNavRow(
                      leading: const PreferencesRootSymbolIcon(
                        Symbols.notifications_rounded,
                      ),
                      title: "preferences.reminders".t(context),
                      onTap: () =>
                          _pushAndRefreshAfter("/preferences/reminders"),
                    ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.language_rounded,
                    ),
                    title: "preferences.language".t(context),
                    subtitle: FlowLocalizations.of(context).locale.endonym,
                    onTap: _updateLanguage,
                  ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.universal_currency_alt_rounded,
                    ),
                    title: "preferences.primaryCurrency".t(context),
                    subtitle: currentPrimaryCurrency,
                    onTap: _updatePrimaryCurrency,
                  ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.sync_alt_rounded,
                    ),
                    title: "preferences.transfer".t(context),
                    subtitle: "preferences.transfer.description".t(context),
                    onTap: () => _pushAndRefreshAfter("/preferences/transfer"),
                  ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.delete_rounded,
                    ),
                    title: "preferences.trashBin".t(context),
                    onTap: () => _pushAndRefreshAfter("/preferences/trashBin"),
                  ),
                  PreferencesRootNavRow(
                    leading: const PreferencesRootSymbolIcon(
                      Symbols.numbers_rounded,
                    ),
                    title: "preferences.moneyFormatting".t(context),
                    onTap: () =>
                        _pushAndRefreshAfter("/preferences/moneyFormatting"),
                    showDivider: false,
                  ),
                ];

                return PreferencesRootAccordionSection(
                  title: "preferences.general".t(context),
                  icon: Symbols.tune_rounded,
                  isInitiallyExpanded: true,
                  itemCount: generalRows.length,
                  tallRows: true,
                  children: generalRows,
                );
              },
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.integrations".t(context),
              icon: Symbols.extension_rounded,
              children: [
                PreferencesRootNavRow(
                  leading: const PreferencesRootIconPlate(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: AnimatedEnyLogo(),
                    ),
                  ),
                  title: "Eny",
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/integrations/eny"),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.transactions".t(context),
              icon: Symbols.receipt_long_rounded,
              itemCount: 7,
              tallRows: true,
              children: [
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.search_activity_rounded,
                  ),
                  title: "preferences.transactions.pending".t(context),
                  subtitle: pendingTransactionsRequireConfrimation
                      ? "general.enabled".t(context)
                      : "general.disabled".t(context),
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/pendingTransactions"),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.location_pin_rounded,
                  ),
                  title: "preferences.transactions.geo".t(context),
                  subtitle: geoSubtitle,
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/transactionGeo"),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(Symbols.list_rounded),
                  title: "preferences.transactions.listTile".t(context),
                  onTap: () => _pushAndRefreshAfter(
                    "/preferences/transactionListItemAppearance",
                  ),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.automation_rounded,
                  ),
                  title: "preferences.transactionEntryFlow".t(context),
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/transactionEntryFlow"),
                  showDivider: true,
                ),
                _TaxModeToggleRow(
                  onChanged: () => setState(() {}),
                ),
                _SubscriptionManagerToggleRow(
                  onChanged: () => setState(() {}),
                ),
                _ReceiptScanToggleRow(
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.appearance".t(context),
              icon: Symbols.palette_rounded,
              itemCount: 4,
              tallRows: true,
              children: [
                PreferencesRootNavRow(
                  leading: PreferencesRootIconPlate(
                    child: Icon(
                      currentTheme.isDark
                          ? Symbols.dark_mode_rounded
                          : Symbols.light_mode_rounded,
                      size: 24.0,
                      color: PreferencesRootTheme.primary(context),
                      fill: 0.0,
                    ),
                  ),
                  title: "preferences.theme".t(context),
                  subtitle: themeNames[currentTheme.name] ?? currentTheme.name,
                  onTap: _openTheme,
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(Symbols.dialpad_rounded),
                  title: "preferences.numpad".t(context),
                  subtitle: LocalPreferences().usePhoneNumpadLayout.get()
                      ? "preferences.numpad.layout.modern".t(context)
                      : "preferences.numpad.layout.classic".t(context),
                  onTap: () => _pushAndRefreshAfter("/preferences/numpad"),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.action_key_rounded,
                  ),
                  title: "preferences.transactionButtonOrder".t(context),
                  subtitle: "preferences.transactionButtonOrder.description"
                      .t(context),
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/transactionButtonOrder"),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.dashboard_customize_rounded,
                  ),
                  title: "home.dashboard.customize".t(context),
                  subtitle: "home.dashboard.customize.preferencesSubtitle"
                      .t(context),
                  onTap: () =>
                      _pushAndRefreshAfter("/preferences/homeDashboard"),
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(Symbols.moving_rounded),
                  title: "preferences.changeVisuals".t(context),
                  onTap: () => _pushAndRefreshAfter("/preferences/changeVisuals"),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.privacy".t(context),
              icon: Symbols.shield_rounded,
              contentHeight: _showLockApp ? 320.0 : 180.0,
              children: [
                const Privacy(),
                if (_showLockApp) const LockApp(),
              ],
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.hapticFeedback".t(context),
              icon: Symbols.vibration_rounded,
              itemCount: 1,
              children: const [Haptics()],
            ),
            const SizedBox(height: PreferencesRootTheme.accordionSpacing),
            PreferencesRootAccordionSection(
              title: "preferences.feedback".t(context),
              icon: Symbols.feedback_rounded,
              children: [
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.cleaning_services_rounded,
                  ),
                  title: "fileAttachment.cleanupHangingFiles".t(context),
                  onTap: _deleteHangingFiles,
                ),
                PreferencesRootNavRow(
                  leading: const PreferencesRootSymbolIcon(
                    Symbols.bug_report_rounded,
                  ),
                  title: "preferences.feedback.debugLogs".t(context),
                  onTap: () => context.push("/_debug/logs"),
                  showDivider: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateLanguage() async {
    if (Platform.isIOS) {
      await LocalPreferences().localeOverride.remove().catchError((
        e,
        stackTrace,
      ) {
        _log.warning("Failed to remove locale override", e, stackTrace);
      });
      try {
        await openAppSettings();
        return;
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to open system app settings on iOS",
          e,
          stackTrace,
        );
      }
    }

    if (_languageBusy || !mounted) return;

    setState(() {
      _languageBusy = true;
    });

    try {
      Locale current =
          LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLocales.first;

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        backgroundColor: Colors.transparent,
        elevation: 0,
        builder: (context) => LanguageSelectionSheet(currentLocale: current),
        isScrollControlled: true,
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }

  void _updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      final String current = UserPreferencesService().primaryCurrency;

      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        elevation: 0,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
        isScrollControlled: true,
      );

      if (selected != null) {
        UserPreferencesService().primaryCurrency = selected;
      }
    } finally {
      _currencyBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pushAndRefreshAfter(String path) async {
    await context.push(path);

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void _openTheme() async {
    await context.push("/preferences/theme");

    final bool themeChangesAppIcon =
        UserPreferencesService().themeChangesAppIcon;

    trySetAppIcon(
      themeChangesAppIcon
          ? allThemes[UserPreferencesService().themeName]?.iconName
          : null,
    );

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void _deleteHangingFiles() async {
    final bool? confirmation = await FlowDeletionAlertDialog.show(
      context,
      title: "fileAttachment.cleanupHangingFiles".t(context),
      message: "fileAttachment.cleanupHangingFiles.description".t(context),
    );

    if (confirmation != true || !mounted) return;

    try {
      final int deleted = await FileAttachmentService().deleteAllOrphans();

      if (mounted) {
        context.showToast(text: "fileAttachment.delete.success".t(context));
      }

      _log.info("Deleted $deleted hanging files");
    } catch (e, stackTrace) {
      _log.warning("Failed to delete hanging files", e, stackTrace);

      if (mounted) {
        context.showErrorToast(error: "error.sync.fileNotFound".t(context));
      }
    }
  }

  void reload() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }
}

class _TaxModeToggleRow extends StatefulWidget {
  final VoidCallback onChanged;

  const _TaxModeToggleRow({required this.onChanged});

  @override
  State<_TaxModeToggleRow> createState() => _TaxModeToggleRowState();
}

class _TaxModeToggleRowState extends State<_TaxModeToggleRow> {
  @override
  Widget build(BuildContext context) {
    final bool enabled = LocalPreferences().enableTaxMode.get();

    return PreferencesRootToggleRow(
      icon: Symbols.receipt_long_rounded,
      title: "Tax Mode",
      subtitle: "Track deductible business expenses",
      value: enabled,
      onChanged: (value) {
        LocalPreferences().enableTaxMode.set(value);
        setState(() {});
        widget.onChanged();
      },
    );
  }
}

class _SubscriptionManagerToggleRow extends StatefulWidget {
  final VoidCallback onChanged;

  const _SubscriptionManagerToggleRow({required this.onChanged});

  @override
  State<_SubscriptionManagerToggleRow> createState() =>
      _SubscriptionManagerToggleRowState();
}

class _SubscriptionManagerToggleRowState
    extends State<_SubscriptionManagerToggleRow> {
  static String _label(BuildContext context, String key, String fallback) {
    final String value = key.t(context);
    return value.isEmpty || value == key ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled =
        LocalPreferences().enableSubscriptionManager.get();

    return PreferencesRootToggleRow(
      icon: Symbols.subscriptions_rounded,
      title: _label(
        context,
        "preferences.subscriptionManager",
        "Subscription Manager",
      ),
      subtitle: _label(
        context,
        "preferences.subscriptionManager.description",
        "Track recurring subscriptions, cancel deadlines, and unused services",
      ),
      value: enabled,
      onChanged: (value) {
        LocalPreferences().enableSubscriptionManager.set(value);
        setState(() {});
        widget.onChanged();
      },
    );
  }
}

class _ReceiptScanToggleRow extends StatefulWidget {
  final VoidCallback onChanged;

  const _ReceiptScanToggleRow({required this.onChanged});

  @override
  State<_ReceiptScanToggleRow> createState() => _ReceiptScanToggleRowState();
}

class _ReceiptScanToggleRowState extends State<_ReceiptScanToggleRow> {
  static String _label(BuildContext context, String key, String fallback) {
    final String value = key.t(context);
    return value.isEmpty || value == key ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = LocalPreferences().enableReceiptScan.get();

    return PreferencesRootToggleRow(
      icon: Symbols.document_scanner_rounded,
      title: _label(
        context,
        "preferences.receiptScan",
        "Smart receipt scan",
      ),
      subtitle: _label(
        context,
        "preferences.receiptScan.description",
        "Read receipts on your phone and pre-fill the transaction form",
      ),
      value: enabled,
      onChanged: (value) {
        LocalPreferences().enableReceiptScan.set(value);
        setState(() {});
        widget.onChanged();
      },
      showDivider: false,
    );
  }
}
