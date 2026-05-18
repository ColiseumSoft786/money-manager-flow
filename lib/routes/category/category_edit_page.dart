import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/category.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/main.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account/account_delete_styled_button.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/sheets/select_color_scheme_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_char_flow_icon_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_icon_flow_icon_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_image_flow_icon_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Fallback accent picker plate when category has no theme yet.
const Color _kCategoryAccentPlateBgNeutral = Color(0xFFF3F4F6);
const Color _kCategoryAccentPlateFgNeutral = Color(0xFF6B7280);

class CategoryEditPage extends StatefulWidget {
  final int categoryId;

  bool get isNewCategory => categoryId == 0;

  const CategoryEditPage.create({super.key}) : categoryId = 0;
  const CategoryEditPage({super.key, required this.categoryId});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _nameTextController;

  late FlowIconData? _iconData;

  late final Category? _currentlyEditing;

  String? _colorSchemeName;

  String get iconCodeOrError =>
      _iconData?.toString() ??
      FlowIconData.icon(Symbols.category_rounded).toString();

  dynamic error;

  @override
  void initState() {
    super.initState();

    _currentlyEditing = widget.isNewCategory
        ? null
        : ObjectBox().box<Category>().get(widget.categoryId);

    if (!widget.isNewCategory && _currentlyEditing == null) {
      error = "Category with id ${widget.categoryId} was not found";
    } else {
      _nameTextController = TextEditingController(
        text: _currentlyEditing?.name,
      );
      _iconData = _currentlyEditing?.icon;
      _colorSchemeName = _currentlyEditing?.colorSchemeName;
    }
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  String _titleText(BuildContext context) {
    if (widget.isNewCategory) {
      return "category.new".t(context);
    }
    return _currentlyEditing?.name ?? "category.new".t(context);
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);
    final FlowColorScheme? activeScheme = getThemeStrict(_colorSchemeName);

    // Pure-white canvas + light ink tokens — matches [TransactionTagPage].
    const Color screenBackground = Colors.white;
    const Color titleInk = kFlowHomeTransactionHeadingInk;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        title: Text(
          _titleText(context),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: titleInk,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                Center(
                  child: FlowIcon(
                    _iconData ?? FlowIconData.icon(Symbols.category_rounded),
                    size: 80.0,
                    plated: true,
                    colorScheme: activeScheme,
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _nameTextController,
                    maxLength: Category.maxNameLength,
                    validator: validateNameField,
                    decoration: InputDecoration(
                      label: Text("category.name".t(context)),
                      focusColor: context.colorScheme.secondary,
                      counter: const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: contentPadding,
                  child: _buildIconSourceSection(context, activeScheme, true),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: contentPadding,
                  child: _buildThemeColorSection(context, activeScheme, true),
                ),
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 36.0),
                  Padding(
                    padding: contentPadding,
                    child: AccountDeleteStyledButton(
                      onTap: _deleteCategory,
                      label: Text("category.delete".t(context)),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: context.textTheme.titleSmall?.copyWith(
          color: kFlowPopularCurrenciesSectionHeading,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _categoryEditInsetCard(
    BuildContext context,
    bool light,
    Widget child,
  ) {
    final Color cardBg =
        light ? Colors.white : context.colorScheme.surfaceContainerHighest;
    final Color borderColor = light
        ? const Color(0xFFE5E7EB)
        : context.colorScheme.outlineVariant.withValues(alpha: 0.45);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: child,
      ),
    );
  }

  Widget _buildIconSourceSection(
    BuildContext context,
    FlowColorScheme? activeScheme,
    bool light,
  ) {
    final Color dividerColor = light
        ? const Color(0xFFF0F0EE)
        : context.colorScheme.outlineVariant.withValues(alpha: 0.35);

    final Color symbolPlateBg = activeScheme != null
        ? Color.alphaBlend(
            activeScheme.primary.withValues(alpha: light ? 0.14 : 0.22),
            light ? Colors.white : context.colorScheme.surface,
          )
        : _kCategoryAccentPlateBgNeutral;
    final Color symbolPlateFg =
        activeScheme?.primary ?? _kCategoryAccentPlateFgNeutral;

    final Color altPlateBg =
        light ? const Color(0xFFF5F4F2) : context.colorScheme.surfaceContainerHigh;
    final Color altPlateFg =
        light ? const Color(0xFF57534E) : context.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(context, "flowIcon.change".t(context)),
        const SizedBox(height: 8.0),
        _categoryEditInsetCard(
          context,
          light,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconSourceTile(
                  context,
                  light: light,
                  icon: Symbols.interests_rounded,
                  plateBg: symbolPlateBg,
                  plateFg: symbolPlateFg,
                  title: "flowIcon.type.icon".t(context),
                  subtitle: "flowIcon.type.icon.search".t(context),
                  onTap: _pickMaterialIcon,
                  dividerColor: dividerColor,
                  showDividerBelow: true,
                ),
                _buildIconSourceTile(
                  context,
                  light: light,
                  icon: Symbols.glyphs_rounded,
                  plateBg: altPlateBg,
                  plateFg: altPlateFg,
                  title: "flowIcon.type.character".t(context),
                  subtitle: "flowIcon.type.character.description".t(context),
                  onTap: _pickEmojiIcon,
                  dividerColor: dividerColor,
                  showDividerBelow: true,
                ),
                _buildIconSourceTile(
                  context,
                  light: light,
                  icon: Symbols.image_rounded,
                  plateBg: altPlateBg,
                  plateFg: altPlateFg,
                  title: "flowIcon.type.image".t(context),
                  subtitle: "flowIcon.type.image.description".t(context),
                  onTap: _pickImageIcon,
                  dividerColor: dividerColor,
                  showDividerBelow: false,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconSourceTile(
    BuildContext context, {
    required bool light,
    required IconData icon,
    required Color plateBg,
    required Color plateFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color dividerColor,
    required bool showDividerBelow,
  }) {
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : context.colorScheme.onSurface;

    final Widget row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: plateBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22.0, color: plateFg, fill: 0.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: kFlowPopularCurrenciesSectionHeading,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                size: 20.0,
                color: kFlowPopularCurrenciesSectionHeading.withValues(
                  alpha: 0.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!showDividerBelow) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(
          height: 1.0,
          thickness: 1.0,
          indent: 72.0,
          color: dividerColor,
        ),
      ],
    );
  }

  Widget _buildThemeColorSection(
    BuildContext context,
    FlowColorScheme? activeScheme,
    bool light,
  ) {
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : context.colorScheme.onSurface;

    final Color plateBg = activeScheme != null
        ? Color.alphaBlend(
            activeScheme.primary.withValues(alpha: light ? 0.14 : 0.22),
            light ? Colors.white : context.colorScheme.surface,
          )
        : _kCategoryAccentPlateBgNeutral;
    final Color plateFg =
        activeScheme?.primary ?? _kCategoryAccentPlateFgNeutral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(context, "account.themeColor".t(context)),
        const SizedBox(height: 8.0),
        _categoryEditInsetCard(
          context,
          light,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectColorScheme,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 14.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: plateBg,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Symbols.palette_rounded,
                        size: 22.0,
                        color: plateFg,
                        fill: 0.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                          height: 1.25,
                        ),
                        child: _buildThemeColorValue(context, activeScheme),
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right_rounded,
                      size: 20.0,
                      color: kFlowPopularCurrenciesSectionHeading.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeColorValue(
    BuildContext context,
    FlowColorScheme? scheme,
  ) {
    if (scheme == null) {
      return Text("select.color.none".t(context));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11.0,
          height: 11.0,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Flexible(
          child: Text(
            scheme.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  Future<void> update({required String formattedName}) async {
    final Category? editing = _currentlyEditing;
    if (editing == null) return;

    editing.name = formattedName;
    editing.iconCode = iconCodeOrError;
    editing.colorSchemeName = _colorSchemeName;

    ObjectBox().box<Category>().put(editing, mode: PutMode.update);

    context.pop();
  }

  Future<void> save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String trimmed = _nameTextController.text.trim();

    if (_currentlyEditing != null) {
      return update(formattedName: trimmed);
    }

    final Category category = Category(
      name: trimmed,
      iconCode: iconCodeOrError,
      colorSchemeName: _colorSchemeName,
    );

    unawaited(
      ObjectBox().box<Category>().putAsync(category, mode: PutMode.insert),
    );

    context.showToast(text: "category.new.success".t(context));

    context.pop();
  }

  bool hasChanged() {
    final Category? editing = _currentlyEditing;
    if (editing != null) {
      return editing.name != _nameTextController.text.trim() ||
          editing.iconCode != iconCodeOrError ||
          editing.colorSchemeName != _colorSchemeName;
    }

    return _nameTextController.text.trim().isNotEmpty ||
        _iconData != null ||
        _colorSchemeName != null;
  }

  String? validateNameField(String? value) {
    final requiredValidationError = validateRequiredField(value);
    if (requiredValidationError != null) {
      return requiredValidationError.t(context);
    }

    final String trimmed = value!.trim();

    final Query<Category> otherCategoriesWithSameNameQuery = ObjectBox()
        .box<Category>()
        .query(
          Category_.name
              .equals(trimmed)
              .and(Category_.id.notEquals(_currentlyEditing?.id ?? 0)),
        )
        .build();

    final bool isNameUnique = otherCategoriesWithSameNameQuery.count() == 0;

    otherCategoriesWithSameNameQuery.close();

    if (!isNameUnique) {
      return "error.input.duplicate.accountName".t(context, trimmed);
    }

    return null;
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
    setState(() {});
  }

  Future<void> _pickMaterialIcon() async {
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          SelectIconFlowIconSheet(initialValue: _iconData),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  Future<void> _pickEmojiIcon() async {
    const double pickerIconSize = 88.0;
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectCharFlowIconSheet(
        iconSize: pickerIconSize,
        initialValue: _iconData,
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  Future<void> _pickImageIcon() async {
    const double pickerIconSize = 88.0;
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectImageFlowIconSheet(
        iconSize: pickerIconSize,
        initialValue: _iconData,
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }

    if (mounted) setState(() {});
  }

  Future<void> _deleteCategory() async {
    final Category? cat = _currentlyEditing;
    if (cat == null) return;

    final TransactionFilter filter = TransactionFilter(
      categories: StringMultiFilter.whitelist([cat.uuid]),
    );

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, cat.name),
      child: Text("category.delete.description".t(context, txnCount)),
    );

    if (confirmation == true) {
      ObjectBox().box<Category>().remove(cat.id);

      if (mounted) {
        context.pop();
        GoRouter.of(context).popUntil((route) {
          return route.path != "/category/:id";
        });
      }
    }
  }
}
