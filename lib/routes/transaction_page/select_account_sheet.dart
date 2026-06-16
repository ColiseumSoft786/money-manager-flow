import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [Account] when a row is tapped.
///
/// Visual layout matches the "Select an account" picker mock (white rounded
/// sheet, drag handle, title + close, account rows with icon / balance /
/// circular indicator). Search, empty state, and pop contract are unchanged.
class SelectAccountSheet extends StatefulWidget {
  final List<Account> accounts;
  final int? currentlySelectedAccountId;

  final String? titleOverride;

  final bool showBalance;

  final bool showTrailing;

  /// Defaults to [true] when there are more than 6 accounts.
  final bool? showSearchBar;

  const SelectAccountSheet({
    super.key,
    required this.accounts,
    this.currentlySelectedAccountId,
    this.titleOverride,
    this.showSearchBar,
    this.showBalance = false,
    this.showTrailing = true,
  });

  @override
  State<SelectAccountSheet> createState() => _SelectAccountSheetState();
}

class _SelectAccountSheetState extends State<SelectAccountSheet> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final bool showSearchBar =
        widget.showSearchBar ?? widget.accounts.length > 6;

    final List<Account> results = simpleSortByQuery(widget.accounts, _query);

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
        : theme.colorScheme.primary.withValues(alpha: 0.12);
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
                  _SheetHeader(
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
                  const SizedBox(height: 6.0),
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
                              20.0,
                            ),
                            itemCount: results.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8.0),
                            itemBuilder: (context, index) {
                              final Account account = results[index];
                              final bool selected =
                                  widget.currentlySelectedAccountId ==
                                  account.id;
                              return _AccountPickerRow(
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
                                showBalance: widget.showBalance,
                                showTrailing: widget.showTrailing,
                                onTap: () => context.pop(account),
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

class _AccountPickerRow extends StatelessWidget {
  final Account account;
  final bool selected;
  final Color titleInk;
  final Color subtitleInk;
  final Color selectedFill;
  final Color selectedBorder;
  final Color indicatorBorder;
  final Color accent;
  final Color onAccent;
  final bool showBalance;
  final bool showTrailing;
  final VoidCallback onTap;

  const _AccountPickerRow({
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
    required this.showBalance,
    required this.showTrailing,
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
                    if (showBalance) ...[
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
                  ],
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
