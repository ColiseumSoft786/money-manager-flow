import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

enum _CategoryTab { expense, income }

/// Pops with [Optional<Category>] when a row or quick action is used.
///
/// Visual layout matches the category-picker mock (white sheet, drag handle,
/// centered title, search, type tabs, quick actions, plated icons, circular
/// indicators). Category list and pop contract are unchanged — tabs are
/// presentational only because [Category] has no expense/income field.
class SelectCategorySheet extends StatefulWidget {
  final int? currentlySelectedCategoryId;

  /// Highlights the matching tab; does not filter categories.
  final TransactionType? transactionType;

  /// Defaults to [true] when there are more than 6 categories.
  final bool? showSearchBar;

  final bool showTrailing;

  const SelectCategorySheet({
    super.key,
    this.currentlySelectedCategoryId,
    this.transactionType,
    this.showSearchBar,
    this.showTrailing = true,
  });

  @override
  State<SelectCategorySheet> createState() => _SelectCategorySheetState();
}

class _SelectCategorySheetState extends State<SelectCategorySheet> {
  String _query = "";
  late _CategoryTab _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = switch (widget.transactionType) {
      TransactionType.income => _CategoryTab.income,
      _ => _CategoryTab.expense,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final List<Category> categories = CategoriesProvider.of(context).categories;
    final bool showSearchBar = widget.showSearchBar ?? categories.length > 6;
    final List<Category> results = simpleSortByQuery(categories, _query);

    const Color sheetBg = Colors.white;
    const Color titleInk = kFlowHomeTransactionHeadingInk;
    const Color subtitleInk = kFlowAccountRowBalanceInkLight;
    const Color chevronInk = kFlowMonthSelectorChevronInkLight;
    const Color indicatorBorder = kFlowAccountRowIndicatorBorderLight;
    const Color rowDivider = kFlowAccountRowDividerLight;
    const Color searchFieldFill = Color(0xFFF1F5F9);
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: sheetBg,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0),
                  Center(
                    child: Container(
                      width: 36.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: titleInk.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _SheetHeader(
                    title: "transaction.edit.selectCategory".t(context),
                    titleInk: titleInk,
                    chevronInk: chevronInk,
                    onClose: () => context.pop(),
                  ),
                  const SizedBox(height: 10.0),
                  Divider(height: 1, thickness: 1, color: rowDivider),
                  const SizedBox(height: 14.0),
                  if (showSearchBar)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20.0,
                      ),
                      child: _SearchField(
                        fillColor: searchFieldFill,
                        hintInk: subtitleInk,
                        hint: "category.search.placeholder".t(context),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  if (showSearchBar) const SizedBox(height: 12.0),
                  _CategoryTabBar(
                    activeTab: _activeTab,
                    accent: primaryAccent,
                    inactiveInk: subtitleInk,
                    onTabChanged: (tab) => setState(() => _activeTab = tab),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionChip(
                            label: "category.skip".t(context),
                            icon: Symbols.block_rounded,
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF475569),
                            onTap: () =>
                                context.pop(const Optional<Category>(null)),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: _QuickActionChip(
                            label: "category.new".t(context),
                            icon: Symbols.add_circle_rounded,
                            backgroundColor: const Color(0xFFEFF6FF),
                            foregroundColor: primaryAccent,
                            onTap: () => context.push("/category/new"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Flexible(
                    child: results.isEmpty
                        ? _EmptyState(
                            message: "transaction.edit.selectCategory"
                                .t(context),
                            ink: subtitleInk,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              4.0,
                              16.0,
                              20.0,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final Category category = results[index];
                              final bool selected =
                                  widget.currentlySelectedCategoryId ==
                                  category.id;
                              return _CategoryPickerRow(
                                key: ValueKey(category.uuid),
                                category: category,
                                selected: selected,
                                titleInk: titleInk,
                                indicatorBorder: indicatorBorder,
                                accent: primaryAccent,
                                onAccent: onPrimary,
                                showTrailing: widget.showTrailing,
                                onTap: () =>
                                    context.pop(Optional(category)),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final Color titleInk;
  final Color chevronInk;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.title,
    required this.titleInk,
    required this.chevronInk,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
              onPressed: onClose,
              icon: Icon(Symbols.close_rounded, color: chevronInk),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
                letterSpacing: -0.1,
                color: titleInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final Color fillColor;
  final Color hintInk;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.fillColor,
    required this.hintInk,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 46.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44.0,
              child: Center(
                child: Icon(
                  Symbols.search_rounded,
                  color: hintInk,
                  size: 20.0,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium,
                cursorHeight: 18.0,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: hintInk,
                  ),
                  contentPadding: const EdgeInsetsDirectional.only(end: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  final _CategoryTab activeTab;
  final Color accent;
  final Color inactiveInk;
  final ValueChanged<_CategoryTab> onTabChanged;

  const _CategoryTabBar({
    required this.activeTab,
    required this.accent,
    required this.inactiveInk,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          for (final _CategoryTab tab in _CategoryTab.values)
            Expanded(
              child: _CategoryTabItem(
                label: switch (tab) {
                  _CategoryTab.expense =>
                    TransactionType.expense.localizedNameContext(context),
                  _CategoryTab.income =>
                    TransactionType.income.localizedNameContext(context),
                },
                selected: activeTab == tab,
                accent: accent,
                inactiveInk: inactiveInk,
                onTap: () => onTabChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final Color inactiveInk;
  final VoidCallback onTap;

  const _CategoryTabItem({
    required this.label,
    required this.selected,
    required this.accent,
    required this.inactiveInk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12.0,
                letterSpacing: 0.6,
                color: selected ? accent : inactiveInk,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 2.0,
            width: double.infinity,
            color: selected ? accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.0, color: foregroundColor, fill: 0.0),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerRow extends StatelessWidget {
  final Category category;
  final bool selected;
  final Color titleInk;
  final Color indicatorBorder;
  final Color accent;
  final Color onAccent;
  final bool showTrailing;
  final VoidCallback onTap;

  const _CategoryPickerRow({
    super.key,
    required this.category,
    required this.selected,
    required this.titleInk,
    required this.indicatorBorder,
    required this.accent,
    required this.onAccent,
    required this.showTrailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(14.0);

    return Material(
      color: selected ? kFlowAccountRowSelectedFillLight : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected
            ? const BorderSide(color: kFlowAccountRowSelectedBorderLight)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 12.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlowIcon(
                category.icon,
                size: 22.0,
                plated: true,
                colorScheme: category.colorScheme,
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: titleInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                  ),
                ),
              ),
              if (showTrailing) ...[
                const SizedBox(width: 12.0),
                _CircleIndicator(
                  selected: selected,
                  accent: accent,
                  onAccent: onAccent,
                  idleBorder: indicatorBorder,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIndicator extends StatelessWidget {
  final bool selected;
  final Color accent;
  final Color onAccent;
  final Color idleBorder;

  const _CircleIndicator({
    required this.selected,
    required this.accent,
    required this.onAccent,
    required this.idleBorder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? accent : Colors.transparent,
        border: selected ? null : Border.all(color: idleBorder, width: 1.5),
      ),
      child: selected
          ? Center(
              child: Icon(Symbols.check_rounded, color: onAccent, size: 16.0),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final Color ink;

  const _EmptyState({required this.message, required this.ink});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink),
        ),
      ),
    );
  }
}
