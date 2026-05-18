import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a list of selected [TransactionType]s.
///
/// Visual redesign matches the "Transaction Type" Figma mockup
/// (white rounded sheet with drag handle, left-aligned title + X close,
/// three rows with title + description + colored icon plate + radio
/// indicator, full-width `Done ✓` CTA). Behavior and the
/// `List<TransactionType>` pop payload are unchanged.
class SelectMultiTransactionTypeSheet extends StatefulWidget {
  final Iterable<TransactionType>? currentlySelected;

  const SelectMultiTransactionTypeSheet({super.key, this.currentlySelected});

  @override
  State<SelectMultiTransactionTypeSheet> createState() =>
      _SelectMultiTransactionTypeSheetState();
}

class _SelectMultiTransactionTypeSheetState
    extends State<SelectMultiTransactionTypeSheet> {
  late Set<TransactionType> _selectedTypes;

  /// Display order matches the Figma mockup (Expense → Income → Transfer).
  /// The enum's `values` order is `transfer, income, expense`, which is the
  /// reverse of what the design calls for, so we list it explicitly.
  static const List<TransactionType> _displayOrder = <TransactionType>[
    TransactionType.expense,
    TransactionType.income,
    TransactionType.transfer,
  ];

  @override
  void initState() {
    super.initState();
    _selectedTypes = widget.currentlySelected?.toSet() ?? <TransactionType>{};
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    // Theme-aware palette: keep the Figma light tokens in light mode, fall
    // back to material `colorScheme` roles in dark mode. Per-type plate
    // colors (red/green/blue) are still resolved inside `_OptionRow` so
    // each type keeps its identity in both themes.
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
    final Color rowIdleFill = light
        ? const Color(0xFFF5F7FA) // slate-50
        : theme.colorScheme.surfaceContainerHigh;
    final Color indicatorIdleBorder = light
        ? const Color(0xFFCBD5E1) // slate-300
        : theme.colorScheme.outlineVariant;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color rowSelectedFill = primaryAccent.withValues(alpha: 0.06);

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
                const SizedBox(height: 12.0),
                _Header(
                  title: "enum.TransactionType".t(context),
                  titleInk: titleInk,
                  chevronInk: chevronInk,
                  onClose: () => context.pop(),
                ),
                const SizedBox(height: 14.0),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _displayOrder.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12.0),
                        _OptionRow(
                          type: _displayOrder[i],
                          selected: _selectedTypes.contains(_displayOrder[i]),
                          titleInk: titleInk,
                          subtitleInk: subtitleInk,
                          rowIdleFill: rowIdleFill,
                          rowSelectedFill: rowSelectedFill,
                          indicatorIdleBorder: indicatorIdleBorder,
                          accent: primaryAccent,
                          onTap: () => _toggle(_displayOrder[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22.0),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0,
                    0.0,
                    20.0,
                    20.0,
                  ),
                  child: Button(
                    onTap: _onDone,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.5,
                      horizontal: 16.0,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                    backgroundColor: primaryAccent,
                    foregroundColor: onPrimary,
                    iconColor: onPrimary,
                    trailing: Icon(
                      Symbols.check_circle_rounded,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(TransactionType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _onDone() {
    context.pop(_selectedTypes.toList());
  }
}

/// Static visual metadata for each [TransactionType] row.
///
/// Kept as plain `const` values rather than reading from the theme so that
/// each type retains its signature color (red expense, green income, blue
/// transfer) regardless of which app accent color is currently active.
class _TypeVisual {
  final IconData icon;
  final Color plateFill;
  final Color plateInk;
  final String descriptionKey;

  const _TypeVisual({
    required this.icon,
    required this.plateFill,
    required this.plateInk,
    required this.descriptionKey,
  });

  static _TypeVisual of(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return const _TypeVisual(
          icon: Symbols.account_balance_wallet_rounded,
          plateFill: Color(0xFFFEE2E2), // red-100
          plateInk: Color(0xFFDC2626), // red-600
          descriptionKey: "enum.TransactionType@expense.description",
        );
      case TransactionType.income:
        return const _TypeVisual(
          icon: Symbols.account_balance_wallet_rounded,
          plateFill: Color(0xFFD9F5E5), // green-100
          plateInk: Color(0xFF16A34A), // green-600
          descriptionKey: "enum.TransactionType@income.description",
        );
      case TransactionType.transfer:
        return const _TypeVisual(
          icon: Symbols.swap_horiz_rounded,
          plateFill: Color(0xFFDBEAFE), // blue-100
          plateInk: Color(0xFF2563EB), // blue-600
          descriptionKey: "enum.TransactionType@transfer.description",
        );
    }
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
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 8.0, 0.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                letterSpacing: -0.1,
                color: titleInk,
              ),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
            onPressed: onClose,
            icon: Icon(Symbols.close_rounded, color: chevronInk),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final TransactionType type;
  final bool selected;
  final Color titleInk;
  final Color subtitleInk;
  final Color rowIdleFill;
  final Color rowSelectedFill;
  final Color indicatorIdleBorder;
  final Color accent;
  final VoidCallback onTap;

  const _OptionRow({
    required this.type,
    required this.selected,
    required this.titleInk,
    required this.subtitleInk,
    required this.rowIdleFill,
    required this.rowSelectedFill,
    required this.indicatorIdleBorder,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _TypeVisual visual = _TypeVisual.of(type);
    final BorderRadius radius = BorderRadius.circular(16.0);

    // Keep the saturated ink (red/green/blue 600) in both themes, but in
    // dark mode swap the pastel plate fill for a low-alpha tint of the ink
    // so it doesn't shout against a dark surface.
    final bool light = theme.brightness == Brightness.light;
    final Color plateFill =
        light ? visual.plateFill : visual.plateInk.withValues(alpha: 0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12.0, 14.0, 14.0, 14.0),
          decoration: BoxDecoration(
            color: selected ? rowSelectedFill : rowIdleFill,
            borderRadius: radius,
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: plateFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  visual.icon,
                  size: 20.0,
                  color: visual.plateInk,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.localizedNameContext(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: titleInk,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      visual.descriptionKey.t(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleInk,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              _RadioDot(
                selected: selected,
                accent: accent,
                idleBorder: indicatorIdleBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  final Color accent;
  final Color idleBorder;

  const _RadioDot({
    required this.selected,
    required this.accent,
    required this.idleBorder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : idleBorder,
          width: selected ? 2.0 : 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
