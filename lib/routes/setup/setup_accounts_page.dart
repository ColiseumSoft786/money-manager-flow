import "dart:math" as math;

import "package:flow/data/setup/default_accounts.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/setup/accounts/account_preset_card.dart";
import "package:flow/widgets/setup/accounts/add_account_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:local_hero/local_hero.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupAccountsPage extends StatefulWidget {
  const SetupAccountsPage({super.key});

  @override
  State<SetupAccountsPage> createState() => _SetupAccountsPageState();
}

class _SetupAccountsPageState extends State<SetupAccountsPage> {
  QueryBuilder<Account> qb() =>
      ObjectBox().box<Account>().query().order(Account_.createdDate);

  List<Account> presetAccounts = <Account>[];

  bool busy = false;

  @override
  void initState() {
    super.initState();

    UserPreferencesService().valueNotifier.addListener(_updatePresets);
    _updatePresets();
  }

  @override
  void dispose() {
    UserPreferencesService().valueNotifier.removeListener(_updatePresets);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color screenBackground =
        light ? Colors.white : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: light ? Colors.transparent : null,
        title: Text("setup.accounts.setup".t(context)),
      ),
      body: StreamBuilder<List<Account>>(
        stream: qb()
            .watch(triggerImmediately: true)
            .map((event) => event.find()),
        builder: (context, snapshot) {
          final List<Account> currentAccounts =
              _sortAccountsForSetupDisplay(snapshot.data ?? []);
          final List<Account> uniquePresets = presetAccounts
              .where(
                (preset) => !currentAccounts.any(
                  (account) => account.uuid == preset.uuid,
                ),
              )
              .toList();

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "setup.accounts.sectionTitle".t(context),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color:
                                context.popularCurrenciesSectionHeadingColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          "setup.accounts.description".t(context),
                          style: context.textTheme.labelSmall?.copyWith(
                            color:
                                context.popularCurrenciesSectionHeadingColor,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ...currentAccounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AccountPresetCard(
                          key: ValueKey(account.uuid),
                          account: account,
                          onSelect: null,
                          selected: true,
                          preexisting: true,
                          onEditPressed: () {
                            if (account.id > 0) {
                              context.push("/account/${account.id}/edit");
                            }
                          },
                        ),
                      ),
                    ),
                    LocalHeroScope(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: uniquePresets
                            .map(
                              (preset) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: LocalHero(
                                  key: ValueKey(preset.uuid),
                                  tag: preset.uuid,
                                  child: AccountPresetCard(
                                    key: ValueKey(preset.uuid),
                                    account: preset,
                                    onSelect: (selected) =>
                                        select(preset.uuid, selected),
                                    selected: preset.id == 0,
                                    preexisting: false,
                                    onEditPressed: () {
                                      context.push(
                                        "/account/new",
                                        extra: preset,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const AddAccountCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContinueButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Design: 342×68 (clamped to screen), 24px radius, `rgb(37,140,244)` + dual blue shadows.
  Widget _buildContinueButton(BuildContext context) {
    final double maxWidth = MediaQuery.sizeOf(context).width - 32.0;
    final double width = math.min(342.0, maxWidth);

    return Opacity(
      opacity: busy ? 0.55 : 1.0,
      child: SizedBox(
        width: width,
        height: 68.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kFlowSetupAccountsContinueButtonFill,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            boxShadow: kFlowSetupAccountsContinueButtonShadows,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              onTap: busy ? null : save,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "setup.continue".t(context),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      Symbols.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22.0,
                      fill: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadPresets() {}

  void select(String uuid, bool selected) {
    final Account? preset = presetAccounts.firstWhereOrNull(
      (element) => element.uuid == uuid,
    );

    if (preset != null) {
      preset.id = selected ? 0 : -1;
    }

    setState(() {});
  }

  void save() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final List<Account> selectedAccounts = presetAccounts
          .where((element) => element.id == 0)
          .toList();

      for (final e in selectedAccounts.indexed) {
        e.$2.sortOrder = e.$1;
      }

      await ObjectBox().box<Account>().putManyAsync(selectedAccounts);

      presetAccounts.removeWhere(
        (element) =>
            selectedAccounts.indexWhere(
              (selected) => element.uuid == selected.uuid,
            ) !=
            -1,
      );

      if (mounted) {
        await context.push("/setup/categories");
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Preset accounts first in Main → Cash → Savings order, then others.
  static List<Account> _sortAccountsForSetupDisplay(List<Account> accounts) {
    int presetIndex(Account a) {
      final int i = kAccountPresetUuidDisplayOrder.indexOf(a.uuid);
      return i >= 0 ? i : kAccountPresetUuidDisplayOrder.length;
    }

    final List<Account> copy = List<Account>.from(accounts);
    copy.sort((Account a, Account b) {
      final int ia = presetIndex(a);
      final int ib = presetIndex(b);
      if (ia != ib) {
        return ia.compareTo(ib);
      }
      return a.createdDate.compareTo(b.createdDate);
    });
    return copy;
  }

  void _updatePresets() {
    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    presetAccounts = getAccountPresets(primaryCurrency).toList();

    if (mounted) {
      setState(() {});
    }
  }
}
