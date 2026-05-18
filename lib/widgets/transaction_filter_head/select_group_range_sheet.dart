import "package:flow/data/transaction_filter.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// Pops with the chosen [TransactionGroupRange].
///
/// Visual redesign matches the "Group By" Figma mockup
/// (white rounded sheet with drag handle, centered title, 2-row x 3-column
/// chip grid with the selected chip outlined in the app's primary accent,
/// full-width `Done` CTA). Behavior and the `TransactionGroupRange` pop
/// payload are unchanged.
class SelectGroupRangeSheet extends StatefulWidget {
  final TransactionGroupRange? selected;

  const SelectGroupRangeSheet({super.key, this.selected});

  @override
  State<SelectGroupRangeSheet> createState() => _SelectGroupRangeSheetState();
}

class _SelectGroupRangeSheetState extends State<SelectGroupRangeSheet> {
  late TransactionGroupRange _selected;

  @override
  void initState() {
    _selected = widget.selected ?? TransactionGroupRange.day;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    // Theme-aware palette: keep the Figma light tokens in light mode, fall
    // back to material `colorScheme` roles in dark mode.
    final bool light = theme.brightness == Brightness.light;
    final Color sheetBg = light ? Colors.white : theme.colorScheme.surface;
    final Color titleInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color chipIdleFill = light
        ? const Color(0xFFF5F7FA) // slate-50
        : theme.colorScheme.surfaceContainerHigh;
    final Color chipIdleInk = light
        ? const Color(0xFF475569) // slate-600
        : theme.colorScheme.onSurfaceVariant;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color chipSelectedFill = primaryAccent.withValues(alpha: 0.08);

    // Lay the 6 enum values out in a fixed 2x3 grid (Hour | Day | Week /
    // Month | Year | All time) to match the mockup. The enum declaration
    // order already matches this layout, so we can chunk `values` into
    // 3-wide rows without re-ordering.
    final List<TransactionGroupRange> values = TransactionGroupRange.values;
    const int columns = 3;
    final List<List<TransactionGroupRange>> rows = <List<TransactionGroupRange>>[
      for (int i = 0; i < values.length; i += columns)
        values.sublist(
          i,
          i + columns > values.length ? values.length : i + columns,
        ),
    ];

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
                const SizedBox(height: 14.0),
                Center(
                  child: Text(
                    "transactions.query.filter.groupBy".t(context),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17.0,
                      letterSpacing: -0.1,
                      color: titleInk,
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int r = 0; r < rows.length; r++) ...[
                        if (r > 0) const SizedBox(height: 12.0),
                        Row(
                          children: [
                            for (int c = 0; c < columns; c++) ...[
                              if (c > 0) const SizedBox(width: 12.0),
                              Expanded(
                                child: c < rows[r].length
                                    ? _GroupChip(
                                        label: rows[r][c]
                                            .localizedNameContext(context),
                                        selected: _selected == rows[r][c],
                                        idleFill: chipIdleFill,
                                        idleInk: chipIdleInk,
                                        selectedFill: chipSelectedFill,
                                        accent: primaryAccent,
                                        onTap: () => _select(rows[r][c]),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
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

  void _select(TransactionGroupRange value) {
    if (!mounted) return;
    setState(() => _selected = value);
  }

  void _onDone() {
    context.pop(_selected);
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color idleFill;
  final Color idleInk;
  final Color selectedFill;
  final Color accent;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.selected,
    required this.idleFill,
    required this.idleInk,
    required this.selectedFill,
    required this.accent,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedFill : idleFill,
            borderRadius: radius,
            border: Border.all(
              color: selected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? accent : idleInk,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
