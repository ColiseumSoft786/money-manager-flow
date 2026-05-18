import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with an [Optional]\<bool> indicating whether to filter for transactions
/// that have (or don't have) attachments. `null` means no filter (all
/// transactions).
///
/// Visual redesign matches the "Filter Attachments" Figma mockup
/// (white rounded sheet with drag handle, X-only header, three large option
/// rows with tinted icon plates and a blue check on the selected row,
/// `Reset Filter` + `Apply Filter` footer). Behavior and the
/// `Optional<bool>` return contract are unchanged.
class SelectHasAttachmentSheet extends StatefulWidget {
  final bool? initialSelected;

  const SelectHasAttachmentSheet({super.key, this.initialSelected});

  @override
  State<SelectHasAttachmentSheet> createState() =>
      _SelectHasAttachmentSheetState();
}

class _SelectHasAttachmentSheetState extends State<SelectHasAttachmentSheet> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void didUpdateWidget(covariant SelectHasAttachmentSheet oldWidget) {
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
    // back to material `colorScheme` roles in dark mode.
    final bool light = theme.brightness == Brightness.light;
    final Color sheetBg = light ? Colors.white : theme.colorScheme.surface;
    final Color titleInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color rowIdleFill = light
        ? const Color(0xFFF5F7FA) // slate-50
        : theme.colorScheme.surfaceContainerHigh;
    final Color iconPlateIdleFill = light
        ? const Color(0xFFEEF2F7)
        : theme.colorScheme.surfaceContainerHighest;
    final Color iconPlateIdleInk = light
        ? const Color(0xFF64748B) // slate-500
        : theme.colorScheme.onSurfaceVariant;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color rowSelectedFill = primaryAccent.withValues(alpha: 0.06);
    final Color iconPlateSelectedFill = primaryAccent.withValues(alpha: 0.12);

    final List<_AttachmentOption> options = <_AttachmentOption>[
      _AttachmentOption(
        value: null,
        label: "transactions.query.filter.hasAttachments.allLabel".t(context),
        icon: Symbols.list_alt_rounded,
      ),
      _AttachmentOption(
        value: true,
        label: "transactions.query.filter.hasAttachments#true".t(context),
        icon: Symbols.attach_file_rounded,
      ),
      _AttachmentOption(
        value: false,
        label: "transactions.query.filter.hasAttachments.noneLabel".t(context),
        icon: Symbols.attach_file_off_rounded,
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
                const SizedBox(height: 10.0),
                _Header(
                  title: "transactions.query.filter.hasAttachments.title"
                      .t(context),
                  titleInk: titleInk,
                  chevronInk: chevronInk,
                  onClose: () => context.pop(),
                ),
                const SizedBox(height: 18.0),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
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
                          iconPlateIdleFill: iconPlateIdleFill,
                          iconPlateIdleInk: iconPlateIdleInk,
                          iconPlateSelectedFill: iconPlateSelectedFill,
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
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0,
                    0.0,
                    20.0,
                    20.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _onResetFilter,
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
                          "general.resetFilter".t(context),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: titleInk,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Button(
                        onTap: _onApplyFilter,
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
                          "general.applyFilter".t(context),
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

  void _onApplyFilter() {
    context.pop(Optional<bool>(_selected));
  }

  void _onResetFilter() {
    setState(() => _selected = null);
    context.pop(Optional<bool>(null));
  }
}

class _AttachmentOption {
  final bool? value;
  final String label;
  final IconData icon;

  const _AttachmentOption({
    required this.value,
    required this.label,
    required this.icon,
  });
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

class _OptionRow extends StatelessWidget {
  final _AttachmentOption option;
  final bool selected;
  final Color titleInk;
  final Color rowIdleFill;
  final Color rowSelectedFill;
  final Color iconPlateIdleFill;
  final Color iconPlateIdleInk;
  final Color iconPlateSelectedFill;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  const _OptionRow({
    required this.option,
    required this.selected,
    required this.titleInk,
    required this.rowIdleFill,
    required this.rowSelectedFill,
    required this.iconPlateIdleFill,
    required this.iconPlateIdleInk,
    required this.iconPlateSelectedFill,
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
                  color: selected ? iconPlateSelectedFill : iconPlateIdleFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  option.icon,
                  size: 20.0,
                  color: selected ? accent : iconPlateIdleInk,
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
