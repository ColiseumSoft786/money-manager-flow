import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with an [Optional] of [List] of selected [Category]s.
///
/// Visual redesign matches the "Select categories" Figma mockup
/// (white rounded sheet, drag handle, X-only header, rounded search field,
/// rows with plated icon + name + circular check indicator, full-width Done
/// CTA). Behavior, search, and the `Optional<List<Category>>` return contract
/// are unchanged from the previous implementation.
///
/// Note: the mockup also shows EXPENSE / INCOME / DEBT-LOAN tabs above the
/// list. The current [Category] data model has no transaction-type field, so
/// the tabs are intentionally omitted here. Add a category `kind` (or wire the
/// tabs to a transaction-history heuristic) before bringing them back.
class SelectMultiCategorySheet extends StatefulWidget {
  final List<Category> categories;
  final List<String>? selectedUuids;

  /// Defaults to [true] when there are more than 6 categories.
  final bool? showSearchBar;

  const SelectMultiCategorySheet({
    super.key,
    required this.categories,
    this.selectedUuids,
    this.showSearchBar,
  });

  @override
  State<SelectMultiCategorySheet> createState() =>
      _SelectMultiCategorySheetState();
}

class _SelectMultiCategorySheetState extends State<SelectMultiCategorySheet> {
  String _query = "";

  late final Set<String> selectedUuids;

  @override
  void initState() {
    super.initState();
    selectedUuids = Set.from(widget.selectedUuids ?? (const []));
  }

  @override
  void didUpdateWidget(covariant SelectMultiCategorySheet oldWidget) {
    if (widget.selectedUuids != oldWidget.selectedUuids) {
      selectedUuids.clear();
      selectedUuids.addAll(widget.selectedUuids ?? (const []));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final bool showSearchBar =
        widget.showSearchBar ?? widget.categories.length > 6;

    final List<Category> results =
        simpleSortByQuery(widget.categories, _query);

    // Theme-aware palette: keep the Figma light tokens in light mode, fall
    // back to material `colorScheme` roles in dark mode (matches the pattern
    // used by `TransactionSearchSheet`).
    final bool light = theme.brightness == Brightness.light;
    final Color sheetBg = light ? Colors.white : theme.colorScheme.surface;
    final Color titleInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color subtitleInk = light
        ? kFlowAccountRowBalanceInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color indicatorBorder = light
        ? kFlowAccountRowIndicatorBorderLight
        : theme.colorScheme.outlineVariant;
    final Color rowDivider = light
        ? kFlowAccountRowDividerLight
        : theme.colorScheme.outlineVariant;
    final Color searchFieldFill = light
        ? const Color(0xFFF1F5F9) // slate-100
        : theme.colorScheme.surfaceContainerHighest;
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
                  _Header(
                    title: "transaction.edit.selectCategory.multiple"
                        .t(context),
                    titleInk: titleInk,
                    chevronInk: chevronInk,
                    onClose: () => context.pop(),
                  ),
                  const SizedBox(height: 10.0),
                  Divider(height: 1, thickness: 1, color: rowDivider),
                  const SizedBox(height: 14.0),
                  if (showSearchBar) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20.0,
                      ),
                      child: _SearchField(
                        fillColor: searchFieldFill,
                        hintInk: subtitleInk,
                        hint: "general.search".t(context),
                        onChanged: (value) =>
                            setState(() => _query = value),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (widget.categories.length > 1)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0,
                        0.0,
                        12.0,
                        0.0,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _toggleSelectAll,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _allSelected
                                ? "general.select.clear".t(context)
                                : "general.select.all".t(context),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: primaryAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4.0),
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
                              12.0,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final Category category = results[index];
                              final bool selected =
                                  selectedUuids.contains(category.uuid);
                              return _CategoryRow(
                                key: ValueKey(category.uuid),
                                category: category,
                                selected: selected,
                                titleInk: titleInk,
                                indicatorBorder: indicatorBorder,
                                accent: primaryAccent,
                                onAccent: onPrimary,
                                onTap: () => _toggle(category.uuid),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0,
                      4.0,
                      20.0,
                      20.0,
                    ),
                    child: Button(
                      onTap: pop,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.5,
                        horizontal: 16.0,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                      backgroundColor: primaryAccent,
                      foregroundColor: onPrimary,
                      iconColor: onPrimary,
                      child: Text(
                        "general.done".t(context),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onPrimary,
                        ),
                      ),
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

  bool get _allSelected =>
      widget.categories.isNotEmpty &&
      selectedUuids.length == widget.categories.length;

  void _toggle(String uuid) {
    setState(() {
      if (selectedUuids.contains(uuid)) {
        selectedUuids.remove(uuid);
      } else {
        selectedUuids.add(uuid);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        selectedUuids.clear();
      } else {
        selectedUuids
          ..clear()
          ..addAll(widget.categories.map((category) => category.uuid));
      }
    });
  }

  void pop() {
    final List<Category> selectedCategories = widget.categories
        .where((category) => selectedUuids.contains(category.uuid))
        .toList();

    context.pop(Optional(selectedCategories));
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Color titleInk;
  final Color chevronInk;
  final VoidCallback onClose;

  const _Header({
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
                  contentPadding: const EdgeInsetsDirectional.only(
                    end: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final bool selected;
  final Color titleInk;
  final Color indicatorBorder;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  const _CategoryRow({
    super.key,
    required this.category,
    required this.selected,
    required this.titleInk,
    required this.indicatorBorder,
    required this.accent,
    required this.onAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 12.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlowIcon(category.icon, size: 22.0, plated: true),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: titleInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              _CircleIndicator(
                selected: selected,
                accent: accent,
                onAccent: onAccent,
                idleBorder: indicatorBorder,
              ),
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
