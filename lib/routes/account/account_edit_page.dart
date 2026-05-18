import "dart:async";
import "dart:developer";
import "dart:math" as math;

import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/routes/transaction_page/input_amount_sheet.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/sync/export.dart";
import "package:flow/main.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account/update_balance_options_sheet.dart";
import "package:flow/widgets/account/account_delete_styled_button.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/sheets/select_account_type_sheet.dart";
import "package:flow/widgets/sheets/select_color_scheme_sheet.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountEditPage extends StatefulWidget {
  /// Account Object ID
  final int accountId;

  /// When [isNewAccount], seeds the form (e.g. a setup preset passed via `/account/new` [extra]).
  final Account? createTemplate;

  bool get isNewAccount => accountId == 0;

  AccountEditPage({
    super.key,
    required this.accountId,
    this.createTemplate,
  }) : assert(createTemplate == null || accountId == 0);

  factory AccountEditPage.create({Key? key, Account? template}) =>
      AccountEditPage(key: key, accountId: 0, createTemplate: template);

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  /// Wallet art always shown in the hero; account’s real icon is chosen via [selectIcon].
  static const String _walletHeroLineArtAsset = "assets/images/walletIcon.png";

  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  final FocusNode _editNameFocusNode = FocusNode();

  late String _currency;
  late FlowIconData? _iconData;
  late bool _excludeFromTotalBalance;

  AccountType _accountType = AccountType.debit;

  double _creditLimit = 0.0;

  late double _balance;

  
  DateTime? _updateBalanceAt;

  String? _colorSchemeName;

  late Account? _currentlyEditing;

  bool _editingName = false;
  bool _archived = false;

  /// True while confirmed account deletion runs (export + DB). Blocks save to avoid races.
  bool _accountDeleteInProgress = false;

  String get iconCodeOrError =>
      _iconData?.toString() ??
      FlowIconData.icon(Symbols.wallet_rounded).toString();

  int? balanceUpdateTransactionId;

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNewAccount
        ? null
        : ObjectBox().box<Account>().get(widget.accountId);

    if (!widget.isNewAccount && _currentlyEditing == null) {
      error = "Account with id ${widget.accountId} was not found";
    } else {
      final Account? seed = _currentlyEditing ?? widget.createTemplate;
      _nameTextController = TextEditingController(
        text: seed?.name,
      );
      _balance = seed?.balance.amount ?? 0.0;
      _creditLimit = seed?.creditLimit ?? 0.0;
      _currency =
          seed?.currency ?? UserPreferencesService().primaryCurrency;
      _iconData = seed?.icon;
      _excludeFromTotalBalance =
          seed?.excludeFromTotalBalance ?? false;
      _archived = seed?.archived ?? false;
      _accountType = seed?.accountType ?? _accountType;
      _colorSchemeName = seed?.colorSchemeName;
    }

    _editNameFocusNode.addListener(() {
      if (!_editNameFocusNode.hasFocus) {
        toggleEditName(false);
      }
    });
  }

  @override
  void dispose() {
    _editNameFocusNode.dispose();
    _nameTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme? activeScheme = getThemeStrict(_colorSchemeName);
    final bool light = Theme.of(context).brightness == Brightness.light;

    final Color titleColor = light
        ? kFlowAccountEditTitleColor
        : context.colorScheme.onSurface;

    final Color screenBackground =
        light ? Colors.white : context.colorScheme.surface;

    final String titleText = widget.isNewAccount
        ? "account.new".t(context)
        : "account.edit".t(context);

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: light ? Colors.transparent : null,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 40.0,
        leading: _accountDeleteInProgress
            ? Center(
                child: IconButton(
                  onPressed: null,
                  icon: Icon(
                    Symbols.close_rounded,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.38),
                    fill: 0.0,
                  ),
                ),
              )
            : FormCloseButton(
                canPop: () => !hasChanged(),
              ),
        title: Text(
          titleText,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        actions: [
          if (_accountDeleteInProgress)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => save(),
              icon: Icon(
                Symbols.check_rounded,
                color: context.colorScheme.primary,
                fill: 0.0,
              ),
              tooltip: "general.save".t(context),
            ),
        ],
      ),
      body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 32.0),
                child: SafeArea(
                  top: false,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                _buildHeroIcon(context, activeScheme),
                const SizedBox(height: 20.0),
                _buildCurrentBalance(context),
                const SizedBox(height: 28.0),
                _buildSectionLabel(
                  context,
                  "account.name".t(context).toUpperCase(),
                  
                ),
                const SizedBox(height: 10.0),
                _buildNameField(context),
                const SizedBox(height: 20.0),
                _AccountSettingRow(
                  plateBg: kFlowAccountEditCurrencyPlateBg,
                  plateFg: kFlowAccountEditCurrencyPlateFg,
                  icon: Symbols.payments_rounded,
                  label: "currency".t(context),
                  value: _currency,
                  onTap: widget.isNewAccount ? selectCurrency : null,
                  showChevron: widget.isNewAccount,
                ),
                const SizedBox(height: 12.0),
                _AccountSettingRow(
                  plateBg: kFlowAccountEditTypePlateBg,
                  plateFg: kFlowAccountEditTypePlateFg,
                  icon: Symbols.category_rounded,
                  label: "account.type".t(context),
                  value: _accountType.localizedNameContext(context),
                  onTap: selectAccountType,
                ),
                if (_accountType.showCreditLimit) ...[
                  const SizedBox(height: 12.0),
                  _AccountSettingRow(
                    plateBg: kFlowAccountEditTypePlateBg,
                    plateFg: kFlowAccountEditTypePlateFg,
                    icon: Symbols.credit_card_rounded,
                    label: "account.creditLimit".t(context),
                    valueWidget: MoneyText(
                      Money(_creditLimit, _currency),
                      style: _settingValueStyle(context),
                    ),
                    onTap: inputCreditLimit,
                  ),
                ],
                const SizedBox(height: 12.0),
                _AccountSettingRow(
                  plateBg: kFlowAccountEditColorPlateBg,
                  plateFg: kFlowAccountEditColorPlateFg,
                  icon: Symbols.palette_rounded,
                  label: "account.themeColor".t(context),
                  valueWidget: _buildThemeColorValue(context, activeScheme),
                  onTap: _selectColorScheme,
                ),
                const SizedBox(height: 20.0),
                _AccountToggleRow(
                  plateBg: kFlowPopularCurrencySymbolPlate,
                  plateFg: kFlowAccountEditExcludePlateFg,
                  icon: Symbols.visibility_off_rounded,
                  title: "account.excludeFromTotalBalance".t(context),
                  subtitle:
                      "account.excludeFromTotalBalance.shortDescription".t(
                        context,
                      ),
                  value: _excludeFromTotalBalance,
                  onChanged: updateBalanceExclusion,
                  titleUsesLabelSmall: true,
                  useExcludeBalanceCardStyle: true,
                ),
                // if (!_archived && _currentlyEditing?.uuid != null) ...[
                //   const SizedBox(height: 12.0),
                //   ValueListenableBuilder(
                //     valueListenable: UserPreferencesService().valueNotifier,
                //     builder: (context, value, _) {
                //       final bool isPrimary =
                //           value.primaryAccountUuid == _currentlyEditing?.uuid;

                //       if (isPrimary) {
                //         return Column(
                //           crossAxisAlignment: CrossAxisAlignment.stretch,
                //           children: [
                //             _AccountSettingRow(
                //               plateBg: kFlowAccountEditColorPlateBg,
                //               plateFg: kFlowAccountEditColorPlateFg,
                //               icon: Symbols.star_rounded,
                //               label: "account.primaryAccount".t(context),
                //               value: "",
                //               showChevron: false,
                //             ),
                //             const SizedBox(height: 8.0),
                //             Frame(
                //               child: InfoText(
                //                 child: Text(
                //                   "account.primaryAccount.changeDescription"
                //                       .t(context),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         );
                //       }

                //       return _AccountToggleRow(
                //         plateBg: kFlowAccountEditColorPlateBg,
                //         plateFg: kFlowAccountEditColorPlateFg,
                //         icon: Symbols.star_rounded,
                //         title: "account.primaryAccount.notPrimary".t(context),
                //         subtitle:
                //             "account.primaryAccount.description".t(context),
                //         value: false,
                //         onChanged: (_) => setAsPrimaryAccount(),
                //       );
                //     },
                //   ),
                // ],
                if (!widget.isNewAccount) ...[
                  const SizedBox(height: 24.0),
                  const WavyDivider(),
                  const SizedBox(height: 16.0),
                  _AccountToggleRow(
                    plateBg: kFlowPopularCurrencySymbolPlate,
                    plateFg: kFlowAccountEditExcludePlateFg,
                    icon: Symbols.block_rounded,
                    title: "account.archive".t(context),
                    subtitle: "account.archive.description".t(context),
                    value: _archived,
                    onChanged: updateArchived,
                  ),
                ],
                if (_currentlyEditing != null && _archived) ...[
                  const SizedBox(height: 32.0),
                  AccountDeleteStyledButton(
                    onTap: _deleteAccount,
                    label: Text("account.delete".t(context)),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ],
            ),
          ),
        ),
      ),
              if (_accountDeleteInProgress)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: const Color.fromRGBO(15, 23, 42, 0.35),
                      child: Center(
                        child: Material(
                          color: context.colorScheme.surface,
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(16.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                              vertical: 24.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 36.0,
                                  height: 36.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.0,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  "account.delete.inProgress".t(context),
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildHeroIcon(BuildContext context, FlowColorScheme? scheme) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    const double outerSide = 140.0;
    final double innerDiameter =
        outerSide * kFlowAccountEditHeroInnerCircleScale;

    final Color outerFill = light
        ? kFlowAccountEditHeroFill
        : context.colorScheme.surfaceContainerHighest;
    final Color innerFill =
        scheme?.primary ?? kFlowAccountEditHeroInnerBlue;

    final double glyphSize = innerDiameter * 0.46;

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: selectIcon,
        child: Container(
          width: outerSide,
          height: outerSide,
          decoration: BoxDecoration(
            color: outerFill,
            borderRadius: BorderRadius.circular(24.0),
          ),
          alignment: Alignment.center,
          child: Container(
            width: innerDiameter,
            height: innerDiameter,
            decoration: BoxDecoration(
              color: innerFill,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _buildHeroWalletAsset(glyphSize),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroWalletAsset(double size) {
    return Image.asset(
      _walletHeroLineArtAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }

  Widget _buildCurrentBalance(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: updateBalance,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "account.currentBalance".t(context).toUpperCase(),
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: kFlowPopularCurrenciesSectionHeading,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
             
            const SizedBox(height: 8.0),
            Text(
              Money(_balance, _currency).formatMoney(),
              textAlign: TextAlign.center,
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: light
                    ? kFlowAccountEditTitleColor
                    : context.colorScheme.onSurface,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.edit_rounded,
                  size: 16.0,
                  color: context.colorScheme.primary,
                  fill: 0.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  "account.updateBalance".t(context),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: kFlowPopularCurrenciesSectionHeading,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final double maxWidth = math.min(
      kFlowAccountEditNameFieldMaxWidth,
      MediaQuery.sizeOf(context).width - 40.0,
    );

    final Color fill = light
        ? kFlowAccountEditFieldFill
        : context.colorScheme.surfaceContainerHighest;
    final Color borderColor = light
        ? kFlowAccountEditNameFieldBorder
        : context.colorScheme.outlineVariant;

    final OutlineInputBorder shape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: borderColor, width: 1.0),
    );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          height: kFlowAccountEditNameFieldHeight,
          child: TextFormField(
            controller: _nameTextController,
            focusNode: _editNameFocusNode,
            maxLength: Account.maxNameLength,
            textAlignVertical: TextAlignVertical.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: light
                  ? kFlowAccountEditTitleColor
                  : context.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              counter: const SizedBox.shrink(),
              hintText: "account.name".t(context),
              hintStyle: context.textTheme.titleMedium?.copyWith(
                color: kFlowPopularCurrenciesSectionHeading,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              filled: true,
              fillColor: fill,
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(16.0, 17.0, 16.0, 17.0),
              border: shape,
              enabledBorder: shape,
              disabledBorder: shape,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: context.colorScheme.primary,
                  width: 1.0,
                ),
              ),
            ),
            onTap: () => toggleEditName(true),
            onFieldSubmitted: (_) => toggleEditName(false),
            validator: validateNameField,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeColorValue(
    BuildContext context,
    FlowColorScheme? scheme,
  ) {
    if (scheme == null) {
      return Text(
        "select.color.none".t(context),
        style: _settingValueStyle(context),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(scheme.name, style: _settingValueStyle(context)),
      ],
    );
  }

  TextStyle? _settingValueStyle(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    return context.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: light
          ? kFlowAccountEditTitleColor
          : context.colorScheme.onSurface,
    );
  }

  Future<void> _selectColorScheme() async {
    final FlowColorScheme theme = getTheme(
      UserPreferencesService().themeNameRaw,
      preferDark: Flow.of(context).useDarkTheme,
    );

    final FlowThemeGroup group = getGroupByTheme(theme.name);

    final Optional<FlowColorScheme>? result =
        await showModalBottomSheet<Optional<FlowColorScheme>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SelectColorSchemeSheet(
            group: group,
            initialScheme: _colorSchemeName,
          ),
        );

    if (result == null) return;

    setState(() {
      _colorSchemeName = result.value?.name;
    });
  }

  void inputCreditLimit() async {
    final double? result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => InputAmountSheet(
        initialAmount: _creditLimit.abs(),
        currency: _currency,
        title: "account.creditLimit".t(context),
        allowNegative: false,
        lockSign: true,
      ),
      isScrollControlled: true,
    );

    if (result == null) return;

    _creditLimit = result.abs();

    if (mounted) {
      setState(() {});
    }
  }

  void updateType(AccountType newType) async {
    if (newType.preferExcludeFromBalance) {
      updateBalanceExclusion(true);
    }

    _accountType = newType;

    setState(() {});
  }

  void updateBalance() async {
    final Optional<DateTime>? updateAtResult =
        await showModalBottomSheet<Optional<DateTime>>(
          context: context,
          builder: (context) => UpdateBalanceOptionsSheet(),
          isScrollControlled: true,
        );

    if (updateAtResult == null || !mounted) {
      _updateBalanceAt = null;
      return;
    }

    _updateBalanceAt = updateAtResult.value;

    final result = await showModalBottomSheet<double>(
      context: context,
      builder: (context) =>
          InputAmountSheet(initialAmount: _balance, currency: _currency),
      isScrollControlled: true,
    );

    if (result == null || result == _balance) return;
    if (!mounted) return;

    _balance = result;

    if (_currentlyEditing == null) {
      setState(() {});
      return;
    }

    balanceUpdateTransactionId = _currentlyEditing!.updateBalanceAndSave(
      _balance,
      title: "account.updateBalance.transactionTitle".t(context),
      transactionDate: _updateBalanceAt,
      existingTransactionId: balanceUpdateTransactionId,
    );

    _refetch();
  }

  void updateBalanceExclusion(bool? value) {
    if (value != null) {
      setState(() {
        _excludeFromTotalBalance = value;
      });
    }
  }

  void updateArchived(bool? value) {
    if (value != null) {
      setState(() {
        _archived = value;
      });
    }
  }

  void selectCurrency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => const SelectCurrencySheet(),
      isScrollControlled: true,
    );

    setState(() {
      _currency = result ?? _currency;
    });
  }

  void selectAccountType() async {
    final result = await showModalBottomSheet<AccountType>(
      context: context,
      builder: (context) =>
          SelectAccountTypeSheet(currentlySelected: _accountType),
      isScrollControlled: true,
    );

    if (result != null) {
      updateType(result);
    }
  }

  void update({required String formattedName}) async {
    if (_currentlyEditing == null) return;

    final Account? persisted =
        ObjectBox().box<Account>().get(_currentlyEditing!.id);
    if (persisted == null) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    _currentlyEditing!.name = formattedName;
    _currentlyEditing!.currency = _currency;

    _currentlyEditing!.creditLimit = _creditLimit;
    _currentlyEditing!.accountType = _accountType;

    _currentlyEditing!.colorSchemeName = _colorSchemeName;
    _currentlyEditing!.iconCode = iconCodeOrError;
    _currentlyEditing!.excludeFromTotalBalance = _excludeFromTotalBalance;
    _currentlyEditing!.archived = _archived;

    try {
      ObjectBox()
          .box<Account>()
          .put(_currentlyEditing!, mode: PutMode.update);
    } catch (e, st) {
      log(
        "[AccountEditPage] Failed to save account ${_currentlyEditing!.id}: $e\n$st",
      );
      if (mounted) {
        context.pop();
      }
      return;
    }

    TransactionsService().notifyDataChanged();

    if (_archived) {
      try {
        UserPreferencesService().ensurePrimaryAccountAvailability();
      } catch (e) {
        //
      }
    }

    if (mounted) {
      context.pop();
    }
  }

  void save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_accountDeleteInProgress) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      final Account? persisted =
          ObjectBox().box<Account>().get(_currentlyEditing!.id);
      if (persisted == null) {
        if (mounted) {
          context.pop();
        }
        return;
      }
      return update(formattedName: trimmed);
    }

    final int sortOrder = ObjectBox().box<Account>().count();

    final account = Account(
      name: trimmed,
      currency: _currency,
      archived: _archived,
      excludeFromTotalBalance: _excludeFromTotalBalance,
      colorSchemeName: _colorSchemeName,
      iconCode: iconCodeOrError,
      sortOrder: sortOrder,
      type: _accountType.value,
      creditLimit: _creditLimit,
    );

    if (_balance.abs() != 0) {
      unawaited(
        ObjectBox()
            .box<Account>()
            .putAndGetAsync(account, mode: PutMode.insert)
            .then((value) {
              value.updateBalanceAndSave(
                _balance,
                title: "account.updateBalance.transactionTitle".tr(),
                transactionDate: _updateBalanceAt,
              );
              ObjectBox().box<Account>().putAsync(value);
              TransactionsService().notifyDataChanged();
            }),
      );
    } else {
      unawaited(
        ObjectBox()
            .box<Account>()
            .putAsync(account, mode: PutMode.insert)
            .then((_) => TransactionsService().notifyDataChanged()),
      );
    }

    context.pop();
  }

  bool hasChanged() {
    if (_currentlyEditing != null) {
      return _currentlyEditing!.name != _nameTextController.text.trim() ||
          _currentlyEditing!.iconCode != iconCodeOrError ||
          _currentlyEditing!.colorSchemeName != _colorSchemeName ||
          _currentlyEditing!.archived != _archived ||
          _currentlyEditing!.currency != _currency ||
          (_currentlyEditing!.creditLimit ?? 0) != _creditLimit ||
          _currentlyEditing!.accountType != _accountType ||
          _currentlyEditing!.excludeFromTotalBalance !=
              _excludeFromTotalBalance ||
          _balance != _currentlyEditing!.balance.amount ||
          _updateBalanceAt != null;
    }

    return _nameTextController.text.trim().isNotEmpty ||
        _iconData != null ||
        _colorSchemeName != null ||
        _currency != UserPreferencesService().primaryCurrency ||
        _balance != 0.0 ||
        _creditLimit != 0.0 ||
        _accountType != AccountType.debit ||
        _excludeFromTotalBalance ||
        _archived ||
        _updateBalanceAt != null;
  }

  void _refetch() {
    if (_currentlyEditing == null) return;

    _currentlyEditing = ObjectBox().box<Account>().get(_currentlyEditing!.id);

    if (mounted) setState(() {});
  }

  void toggleEditName([bool? force]) {
    setState(() {
      _editingName = force ?? !_editingName;
    });

    if (_editingName) {
      _editNameFocusNode.requestFocus();
    }
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final Query<Account> sameNameQuery = ObjectBox()
        .box<Account>()
        .query(
          Account_.name
              .equals(trimmed)
              .and(Account_.id.notEquals(_currentlyEditing?.id ?? 0)),
        )
        .build();

    final bool isNameUnique = sameNameQuery.count() == 0;

    sameNameQuery.close();

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
  }

  Future<void> setAsPrimaryAccount() async {
    if (_currentlyEditing?.uuid == null) return;

    final bool? confirmation = await context.showConfirmationSheet(
      title: "account.primaryAccount.set".t(context),
      child: Text("account.primaryAccount.description".t(context)),
    );

    if (confirmation != true) return;

    UserPreferencesService().primaryAccountUuid = _currentlyEditing!.uuid;
  }

  Future<void> selectIcon() async {
    final result = await showModalBottomSheet<FlowIconData>(
      context: context,
      builder: (context) => SelectFlowIconSheet(current: _iconData),
      isScrollControlled: true,
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  void _deleteAccount() async {
    if (_currentlyEditing == null) return;

    final TransactionFilter filter = TransactionFilter(
      accounts: StringMultiFilter.whitelist([_currentlyEditing!.uuid]),
    );

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.name),
      child: Text("account.delete.description".t(context, txnCount)),
    );

    if (!mounted) return;

    if (confirmation != true) {
      return;
    }

    setState(() {
      _accountDeleteInProgress = true;
    });

    bool accountRemoved = false;
    try {
      await export(
        showShareDialog: false,
        subfolder: "anti-blunder",
        type: BackupEntryType.preAccountDeletion,
      );

      if (!mounted) return;

      try {
        await TransactionsService().deleteMany(filter);
      } catch (e) {
        log(
          "[Account Page] Failed to remove associated transactions for account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e",
        );
      }

      try {
        await ObjectBox().box<Account>().removeAsync(_currentlyEditing!.id);
        accountRemoved = true;
      } catch (e) {
        log(
          "[Account Page] Failed to delete account ${_currentlyEditing!.name} (${_currentlyEditing!.uuid}) due to:\n$e",
        );
      }

      TransactionsService().notifyDataChanged();
    } finally {
      if (mounted) {
        setState(() {
          _accountDeleteInProgress = false;
        });
      }
    }

    try {
      UserPreferencesService().ensurePrimaryAccountAvailability();
    } catch (e) {
      //
    }

    if (!mounted || !accountRemoved) {
      return;
    }

    context.pop();
    GoRouter.of(context).popUntil((route) {
      return route.path != "/account/:id";
    });
  }
}

/// One row in the redesigned [AccountEditPage] settings list.
///
/// Renders a soft-grey rounded card with a tinted icon plate (24×24 icon in a
/// 40×40 rounded square), a small label above a bold value, and a trailing
/// chevron when [onTap] is interactive.
class _AccountSettingRow extends StatelessWidget {
  final Color plateBg;
  final Color plateFg;
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
  final bool showChevron;

  const _AccountSettingRow({
    required this.plateBg,
    required this.plateFg,
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.onTap,
    this.showChevron = true,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;
    final Color rowFill =
        light ? kFlowAccountEditRowFill : scheme.surfaceContainerHighest;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : scheme.onSurface;

    return Material(
      color: rowFill,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: plateBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22.0, color: plateFg, fill: 0.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: kFlowPopularCurrenciesSectionHeading,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    DefaultTextStyle.merge(
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      child: valueWidget ?? Text(value ?? ""),
                    ),
                  ],
                ),
              ),
              if (showChevron && onTap != null)
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: kFlowPopularCurrenciesSectionHeading,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle row used for "Exclude from balance" / "Deactivate" in the
/// redesigned [AccountEditPage].
class _AccountToggleRow extends StatelessWidget {
  final Color plateBg;
  final Color plateFg;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// When true, [title] uses [TextTheme.labelSmall] instead of [TextTheme.titleSmall].
  final bool titleUsesLabelSmall;

  /// Figma card: max width [kFlowAccountEditNameFieldMaxWidth], height [kFlowAccountEditExcludeCardHeight], `16` padding, `12` radius, fill [kFlowAccountEditFieldFill], border [kFlowPopularCurrencySymbolPlate].
  final bool useExcludeBalanceCardStyle;

  const _AccountToggleRow({
    required this.plateBg,
    required this.plateFg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.titleUsesLabelSmall = false,
    this.useExcludeBalanceCardStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useExcludeBalanceCardStyle) {
      return _buildExcludeBalanceCard(context);
    }
    return _buildStandardToggleRow(context);
  }

  Widget _buildExcludeBalanceCard(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : scheme.onSurface;

    final double maxWidth = math.min(
      kFlowAccountEditNameFieldMaxWidth,
      MediaQuery.sizeOf(context).width - 40.0,
    );

    final Color fill =
        light ? kFlowAccountEditFieldFill : scheme.surfaceContainerHighest;
    final Color borderColor =
        light ? kFlowPopularCurrencySymbolPlate : scheme.outlineVariant;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minHeight: kFlowAccountEditExcludeCardHeight,
        ),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => onChanged(!value),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: plateBg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              icon,
                              size: 22.0,
                              color: plateFg,
                              fill: 0.0,
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: (titleUsesLabelSmall
                                          ? context.textTheme.labelSmall
                                          : context.textTheme.titleSmall)
                                      ?.copyWith(
                                    fontWeight: titleUsesLabelSmall
                                        ? FontWeight.w600
                                        : FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  subtitle,
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(
                                    color: kFlowPopularCurrenciesSectionHeading,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Switch(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardToggleRow(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;
    final Color rowFill =
        light ? kFlowAccountEditRowFill : scheme.surfaceContainerHighest;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : scheme.onSurface;

    return Material(
      color: rowFill,
      borderRadius: BorderRadius.circular(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () => onChanged(!value),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: plateBg,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 22.0, color: plateFg, fill: 0.0),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: (titleUsesLabelSmall
                                    ? context.textTheme.labelSmall
                                    : context.textTheme.titleSmall)
                                ?.copyWith(
                              fontWeight: titleUsesLabelSmall
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: kFlowPopularCurrenciesSectionHeading,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 10.0,
              top: 12.0,
              bottom: 12.0,
            ),
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
