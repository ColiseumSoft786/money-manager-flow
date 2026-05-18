import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class MonthSelectorSheet extends StatefulWidget {
  final DateTime? initialDate;

  const MonthSelectorSheet({super.key, this.initialDate});

  @override
  State<MonthSelectorSheet> createState() => _MonthSelectorSheetState();
}

class _MonthSelectorSheetState extends State<MonthSelectorSheet> {
  late int year;
  late int month;

  @override
  void initState() {
    super.initState();

    final DateTime current = widget.initialDate ?? DateTime.now();
    year = current.year;
    month = current.month;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final Color titleInk = light
        ? kFlowHomeTransactionHeadingInk
        : theme.colorScheme.onSurface;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color yearPillFill = light
        ? kFlowMonthSelectorYearPillFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color chipBorder = light
        ? kFlowMonthSelectorChipBorderLight
        : theme.colorScheme.outlineVariant;
    final Color chipIdleInk = light
        ? kFlowMonthSelectorChipInkLight
        : theme.colorScheme.onSurface;
    final Color chipSurface =
        light ? Colors.white : theme.colorScheme.surface;
    final Color nowFill = light
        ? kFlowMonthSelectorNowFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color nowInk =
        light ? kFlowMonthSelectorNowInkLight : theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: light ? Colors.white : theme.colorScheme.surface,
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
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).cancelButtonLabel,
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Symbols.close_rounded,
                              fill: light ? 0.0 : 1.0,
                              color: chevronInk,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48.0,
                          ),
                          child: Text(
                            "select.time.select.month".t(context),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              letterSpacing: -0.1,
                              color: titleInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      6.0,
                      24.0,
                      18.0,
                    ),
                    child: _YearSelectorRow(
                      year: year,
                      pillFill: yearPillFill,
                      pillInk: primaryAccent,
                      chevronInk: chevronInk,
                      onPrev: () => setState(() => year -= 1),
                      onNext: () => setState(() => year += 1),
                      onTapYear: _pickYear,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      18.0,
                      0.0,
                      18.0,
                      18.0,
                    ),
                    child: _MonthsGrid(
                      currentYear: year,
                      currentMonth: month,
                      selectedBg: primaryAccent,
                      selectedInk: onPrimary,
                      idleBorder: chipBorder,
                      idleInk: chipIdleInk,
                      surface: chipSurface,
                      onTap: (int newMonth) =>
                          setState(() => month = newMonth),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      4.0,
                      24.0,
                      20.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 36,
                          child: Button(
                            onTap: _setNow,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 14.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: nowFill,
                            foregroundColor: nowInk,
                            child: Text(
                              "select.time.now".t(context),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          flex: 62,
                          child: Button(
                            onTap: _confirm,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 16.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: primaryAccent,
                            foregroundColor: onPrimary,
                            iconColor: onPrimary,
                            elevation: light ? 2.2 : 0.0,
                            shadowColor: Colors.black.withValues(
                              alpha: light ? 0.18 : 0,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickYear() async {
    final DateTime? value = await showYearPickerSheet(
      context,
      initialDate: DateTime(year),
    );
    if (value == null || !mounted) return;
    setState(() => year = value.year);
  }

  void _setNow() {
    final DateTime now = DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
    });
  }

  void _confirm() {
    context.pop(DateTime(year, month));
  }
}

class _YearSelectorRow extends StatelessWidget {
  final int year;
  final Color pillFill;
  final Color pillInk;
  final Color chevronInk;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTapYear;

  const _YearSelectorRow({
    required this.year,
    required this.pillFill,
    required this.pillInk,
    required this.chevronInk,
    required this.onPrev,
    required this.onNext,
    required this.onTapYear,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          splashRadius: 22.0,
          icon: Icon(
            Symbols.chevron_left_rounded,
            color: chevronInk,
            size: 22.0,
          ),
        ),
        const SizedBox(width: 8.0),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapYear,
            borderRadius: BorderRadius.circular(12.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minWidth: 84.0),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 18.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: pillFill,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                year.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: pillInk,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        IconButton(
          onPressed: onNext,
          splashRadius: 22.0,
          icon: Icon(
            Symbols.chevron_right_rounded,
            color: chevronInk,
            size: 22.0,
          ),
        ),
      ],
    );
  }
}

class _MonthsGrid extends StatelessWidget {
  final int currentYear;
  final int currentMonth;
  final Color selectedBg;
  final Color selectedInk;
  final Color idleBorder;
  final Color idleInk;
  final Color surface;
  final ValueChanged<int> onTap;

  const _MonthsGrid({
    required this.currentYear,
    required this.currentMonth,
    required this.selectedBg,
    required this.selectedInk,
    required this.idleBorder,
    required this.idleInk,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final int row in const [1, 4, 7, 10]) ...[
          if (row != 1) const SizedBox(height: 12.0),
          Row(
            children: [
              for (int i = row; i < row + 3; i++) ...[
                if (i != row) const SizedBox(width: 12.0),
                Expanded(
                  child: _MonthChip(
                    label: DateTime(
                      currentYear,
                      i,
                    ).format(payload: "MMM"),
                    selected: i == currentMonth,
                    selectedBg: selectedBg,
                    selectedInk: selectedInk,
                    idleBorder: idleBorder,
                    idleInk: idleInk,
                    surface: surface,
                    onTap: () => onTap(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedInk;
  final Color idleBorder;
  final Color idleInk;
  final Color surface;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedInk,
    required this.idleBorder,
    required this.idleInk,
    required this.surface,
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 48.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedBg : surface,
            borderRadius: radius,
            border: selected
                ? null
                : Border.all(color: idleBorder, width: 1.0),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? selectedInk : idleInk,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
