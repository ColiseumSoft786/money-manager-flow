import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with an [Optional]\<bool> indicating whether to filter for transactions
/// by pending status. `null` means no filter (all transactions),
/// `true` means show pending only, `false` means show non-pending only.
///
/// Visual redesign matches the "Pending status" Figma mockup
/// (white rounded sheet with drag handle, centered title, three option rows
/// each with its own colored icon plate, right-aligned `Done →` button).
/// Behavior and the `Optional<bool>` return contract are unchanged.
class SelectIsPendingSheet extends StatefulWidget {
  final bool? initialSelected;

  const SelectIsPendingSheet({super.key, this.initialSelected});

  @override
  State<SelectIsPendingSheet> createState() => _SelectIsPendingSheetState();
}

class _SelectIsPendingSheetState extends State<SelectIsPendingSheet> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void didUpdateWidget(covariant SelectIsPendingSheet oldWidget) {
    if (widget.initialSelected != oldWidget.initialSelected) {
      _selected = widget.initialSelected;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    // Theme-aware palette: keep the Figma light tokens in light mode, fall
    // back to material `colorScheme` roles in dark mode. Status colors
    // (amber pending, green not-pending) keep their saturated ink in both
    // modes; on dark surfaces the icon plate becomes a low-alpha tint of
    // that ink so the colored identity reads without a bright pastel slab.
    final bool light = theme.brightness == Brightness.light;
    final Color sheetBg = light ? Colors.white : theme.colorScheme.surface;
    final Color titleInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color rowIdleFill = light
        ? const Color(0xFFF5F7FA) // slate-50
        : theme.colorScheme.surfaceContainerHigh;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color rowSelectedFill = primaryAccent.withValues(alpha: 0.06);

    // Per-option ink colors stay constant; plate fill switches between a
    // hardcoded pastel (light mode) and a translucent tint of the ink
    // (dark mode).
    const Color allInk = Color(0xFF64748B); // slate-500
    const Color pendingInk = Color(0xFFD97706); // amber-600
    const Color notPendingInk = Color(0xFF16A34A); // green-600
    final Color allPlate = light
        ? const Color(0xFFEEF2F7)
        : allInk.withValues(alpha: 0.18);
    final Color pendingPlate = light
        ? const Color(0xFFFFF3D6)
        : pendingInk.withValues(alpha: 0.18);
    final Color notPendingPlate = light
        ? const Color(0xFFD9F5E5)
        : notPendingInk.withValues(alpha: 0.18);
    final Color allInkResolved =
        light ? allInk : theme.colorScheme.onSurfaceVariant;

    final List<_PendingOption> options = <_PendingOption>[
      _PendingOption(
        value: null,
        label: "transactions.query.filter.isPending.all".t(context),
        icon: Symbols.menu_rounded,
        plateFill: allPlate,
        plateInk: allInkResolved,
      ),
      _PendingOption(
        value: true,
        label: "transactions.query.filter.isPending#true".t(context),
        icon: Symbols.schedule_rounded,
        plateFill: pendingPlate,
        plateInk: pendingInk,
      ),
      _PendingOption(
        value: false,
        label: "transactions.query.filter.isPending#false".t(context),
        icon: Symbols.verified_rounded,
        plateFill: notPendingPlate,
        plateInk: notPendingInk,
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
                    "transactions.query.filter.isPending".t(context),
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
                      for (int i = 0; i < options.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12.0),
                        _OptionRow(
                          option: options[i],
                          selected: _selected == options[i].value,
                          titleInk: titleInk,
                          rowIdleFill: rowIdleFill,
                          rowSelectedFill: rowSelectedFill,
                          accent: primaryAccent,
                          onAccent: onPrimary,
                          onTap: () => setState(() {
                            _selected = options[i].value;
                          }),
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
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Button(
                      onTap: _onDone,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                        horizontal: 26.0,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDone() {
    context.pop(Optional<bool>(_selected));
  }
}

class _PendingOption {
  final bool? value;
  final String label;
  final IconData icon;
  final Color plateFill;
  final Color plateInk;

  const _PendingOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.plateFill,
    required this.plateInk,
  });
}

class _OptionRow extends StatelessWidget {
  final _PendingOption option;
  final bool selected;
  final Color titleInk;
  final Color rowIdleFill;
  final Color rowSelectedFill;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  const _OptionRow({
    required this.option,
    required this.selected,
    required this.titleInk,
    required this.rowIdleFill,
    required this.rowSelectedFill,
    required this.accent,
    required this.onAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(16.0);

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
                  color: option.plateFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  option.icon,
                  size: 20.0,
                  color: option.plateInk,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  option.label,
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
              if (selected)
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                  child: Center(
                    child: Icon(
                      Symbols.check_rounded,
                      color: onAccent,
                      size: 15.0,
                    ),
                  ),
                )
              else
                const SizedBox(width: 22.0, height: 22.0),
            ],
          ),
        ),
      ),
    );
  }
}
