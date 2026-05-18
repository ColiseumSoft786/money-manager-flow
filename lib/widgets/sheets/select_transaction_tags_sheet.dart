import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/transaction_tag_add_chip.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a [List<TransactionTag>]
class SelectTransactionTagsSheet extends StatefulWidget {
  final List<TransactionTag> tags;
  final List<String>? initialTagUuids;
  final bool? showSearchBar;

  /// Use this to get notified when the selection changes.
  /// This will be called whenever a tag is selected or deselected.
  ///
  /// Last value of this callback will be returned when the sheet is popped.
  final ValueChanged<List<TransactionTag>>? onChanged;

  const SelectTransactionTagsSheet({
    super.key,
    required this.tags,
    this.initialTagUuids,
    this.showSearchBar = true,
    this.onChanged,
  });

  @override
  State<SelectTransactionTagsSheet> createState() =>
      _SelectTransactionTagsSheetState();
}

class _SelectTransactionTagsSheetState extends State<SelectTransactionTagsSheet> {
  late final Set<String> _selectedTagUuids;

  String _query = "";

  @override
  void initState() {
    super.initState();
    _selectedTagUuids = Set.from(widget.initialTagUuids ?? const []);
  }

  @override
  void didUpdateWidget(covariant SelectTransactionTagsSheet oldWidget) {
    if (widget.initialTagUuids != oldWidget.initialTagUuids) {
      _selectedTagUuids.clear();
      _selectedTagUuids.addAll(widget.initialTagUuids ?? const []);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final double maxListHeight = MediaQuery.sizeOf(context).height * 0.42;

    final bool light = theme.brightness == Brightness.light;
    final Color sheetBg = light ? Colors.white : theme.colorScheme.surface;
    final Color titleInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color searchFill =
        light ? const Color(0xFFF8FAFC) : theme.colorScheme.surfaceContainerHigh;
    final Color searchBorder =
        light ? const Color(0xFFE2E8F0) : theme.colorScheme.outlineVariant;
    final Color primaryAccent = kFlowSetupAccountsContinueButtonFill;
    final Color onPrimary = Colors.white;

    final bool showSearchBar =
        widget.showSearchBar ?? widget.tags.length > 8;
    final List<TransactionTag> results = simpleSortByQuery(widget.tags, _query);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: sheetBg,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 10.0),
                _SheetHeader(
                  title: "transaction.tags".t(context),
                  titleInk: titleInk,
                  chevronInk: chevronInk,
                  onClose: () => context.pop(),
                ),
                if (showSearchBar) ...[
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: titleInk,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "general.search".t(context),
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: chevronInk,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: searchFill,
                        prefixIcon: Icon(
                          Symbols.search_rounded,
                          color: chevronInk,
                          fill: 0.0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: searchBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: searchBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(
                            color: primaryAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "transaction.tags.sheetHint".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: chevronInk,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: [
                          if (_query.isEmpty)
                            TransactionTagAddChip(
                              onPressed: createAndAdd,
                              title: "transaction.tags.new".t(context),
                            ),
                          ...results.map(
                            (tag) => TransactionTagChip(
                              tag: tag,
                              selected: _selectedTagUuids.contains(tag.uuid),
                              key: ValueKey(tag.uuid),
                              onPressed: () {
                                if (_selectedTagUuids.contains(tag.uuid)) {
                                  _selectedTagUuids.remove(tag.uuid);
                                } else {
                                  _selectedTagUuids.add(tag.uuid);
                                }
                                notifyChange();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          _selectedTagUuids.clear();
                          notifyChange();
                          context.pop(<TransactionTag>[]);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: titleInk,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 12.0,
                          ),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "transactions.query.clearSelection".t(context),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: titleInk,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Button(
                        onTap: pop,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13.0,
                          horizontal: 22.0,
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                        backgroundColor: primaryAccent,
                        foregroundColor: onPrimary,
                        iconColor: onPrimary,
                        trailing: Icon(
                          Symbols.arrow_forward_rounded,
                          color: onPrimary,
                          size: 18.0,
                        ),
                        child: Text(
                          "general.done".t(context),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: onPrimary,
                          ),
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
    );
  }

  void notifyChange() {
    if (widget.onChanged == null) return;

    final List<TransactionTag> selectedTags = widget.tags
        .where((tag) => _selectedTagUuids.contains(tag.uuid))
        .toList();

    widget.onChanged!(selectedTags);
  }

  void pop() {
    final List<TransactionTag> selectedTags = widget.tags
        .where((tag) => _selectedTagUuids.contains(tag.uuid))
        .toList();

    context.pop(selectedTags);
  }

  void createAndAdd() async {
    final TransactionTag? result = await context.push("/transactionTags/new");

    if (result != null) {
      _selectedTagUuids.add(result.uuid);

      if (mounted) {
        notifyChange();
        setState(() {});
      }
    }
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
