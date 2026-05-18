import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";


class SelectMultiAccountSheet extends StatefulWidget {
  final List<Account> accounts;
  final List<String>? selectedUuids;

  final String? titleOverride;

  /// Defaults to [true] when there are more than 6 accounts.
  final bool? showSearchBar;

  const SelectMultiAccountSheet({
    super.key,
    required this.accounts,
    this.titleOverride,
    this.selectedUuids,
    this.showSearchBar,
  });

  @override
  State<SelectMultiAccountSheet> createState() =>
      _SelectMultiAccountSheetState();
}

class _SelectMultiAccountSheetState extends State<SelectMultiAccountSheet> {
  String _query = "";

  late Set<String> selectedUuids;

  @override
  void initState() {
    super.initState();
    selectedUuids = Set.from(widget.selectedUuids ?? (const []));
  }

  @override
  void didUpdateWidget(SelectMultiAccountSheet oldWidget) {
    if (widget.selectedUuids != oldWidget.selectedUuids) {
      selectedUuids = Set.from(widget.selectedUuids ?? (const []));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final bool showSearchBar =
        widget.showSearchBar ?? widget.accounts.length > 6;

    final List<Account> results = simpleSortByQuery(widget.accounts, _query);

    // Theme-aware palette: keep the Figma light-mode tokens when the app is in
    // light mode, and fall back to the material `colorScheme` roles when it's
    // in dark mode. This mirrors the pattern used in `TransactionSearchSheet`.
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
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color rowSelectedFill = light
        ? kFlowAccountRowSelectedFillLight
        : theme.colorScheme.primary.withValues(alpha: 0.10);
    final Color rowSelectedBorder = light
        ? kFlowAccountRowSelectedBorderLight
        : theme.colorScheme.primary;
    final Color indicatorBorder = light
        ? kFlowAccountRowIndicatorBorderLight
        : theme.colorScheme.outlineVariant;
    final Color rowDivider = light
        ? kFlowAccountRowDividerLight
        : theme.colorScheme.outlineVariant;

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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _Header(
                    title: widget.titleOverride ??
                        "transaction.edit.selectAccount".t(context),
                    titleInk: titleInk,
                    chevronInk: chevronInk,
                    onClose: () => context.pop(),
                  ),
                  const SizedBox(height: 10.0),
                  Divider(height: 1, thickness: 1, color: rowDivider),
                  if (showSearchBar) ...[
                    const SizedBox(height: 12.0),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20.0,
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "general.search".t(context),
                          prefixIcon: const Icon(Symbols.search_rounded),
                        ),
                      ),
                    ),
                  ],
                  if (widget.accounts.length > 1)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0,
                        4.0,
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
                            message:
                                "transaction.edit.selectAccount.noPossibleChoice"
                                    .t(context),
                            ink: subtitleInk,
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              6.0,
                              16.0,
                              12.0,
                            ),
                            itemCount: results.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8.0),
                            itemBuilder: (context, index) {
                              final Account account = results[index];
                              final bool selected =
                                  selectedUuids.contains(account.uuid);
                              return _AccountRow(
                                key: ValueKey(account.uuid),
                                account: account,
                                selected: selected,
                                titleInk: titleInk,
                                subtitleInk: subtitleInk,
                                selectedFill: rowSelectedFill,
                                selectedBorder: rowSelectedBorder,
                                indicatorBorder: indicatorBorder,
                                accent: primaryAccent,
                                onAccent: onPrimary,
                                onTap: () =>
                                    _toggle(account.uuid, !selected),
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
      widget.accounts.isNotEmpty &&
      selectedUuids.length == widget.accounts.length;

  void _toggle(String uuid, bool selected) {
    if (selectedUuids.contains(uuid)) {
      selectedUuids.remove(uuid);
    } else {
      selectedUuids.add(uuid);
    }
    setState(() {});
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        selectedUuids.clear();
      } else {
        selectedUuids
          ..clear()
          ..addAll(widget.accounts.map((account) => account.uuid));
      }
    });
  }

  void pop() {
    final List<Account> selectedAccounts = widget.accounts
        .where((account) => selectedUuids.contains(account.uuid))
        .toList();

    context.pop(Optional(selectedAccounts));
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
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0,
                  letterSpacing: -0.1,
                  color: titleInk,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
              onPressed: onClose,
              icon: Icon(Symbols.close_rounded, color: chevronInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final Account account;
  final bool selected;
  final Color titleInk;
  final Color subtitleInk;
  final Color selectedFill;
  final Color selectedBorder;
  final Color indicatorBorder;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  const _AccountRow({
    super.key,
    required this.account,
    required this.selected,
    required this.titleInk,
    required this.subtitleInk,
    required this.selectedFill,
    required this.selectedBorder,
    required this.indicatorBorder,
    required this.accent,
    required this.onAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(16.0);

    return Material(
      color: selected ? selectedFill : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected
            ? BorderSide(color: selectedBorder, width: 1.0)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 14.0, 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlowIcon(account.icon, size: 22.0, plated: true),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: titleInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleInk,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      child: MoneyText(
                        account.balance,
                        initiallyAbbreviated: false,
                        autoSize: true,
                        overrideObscure: false,
                      ),
                    ),
                  ],
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
