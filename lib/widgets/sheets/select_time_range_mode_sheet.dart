import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

enum TimeRangeMode {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  byMonth("byMonth"),
  byYear("byYear"),
  allTime("allTime"),
  custom("custom");

  final String value;

  const TimeRangeMode(this.value);

  String get translationKey => "select.timeRange.$value";

  /// Only returns one of [TimeRangeMode.thisWeek], [TimeRangeMode.thisMonth],
  /// [TimeRangeMode.thisYear], [TimeRangeMode.allTime] based on the [anchor]
  /// or now.
  static TimeRangeMode? tryInferPresetFromRange(
    TimeRange? range, {
    DateTime? anchor,
  }) {
    if (range == null) {
      return null;
    }

    final DateTime now = anchor ?? DateTime.now();

    if (range == LocalWeekTimeRange(now)) {
      return TimeRangeMode.thisWeek;
    } else if (range == MonthTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisMonth;
    } else if (range == YearTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisYear;
    } else if (range == Moment.minValue.rangeToMax()) {
      return TimeRangeMode.allTime;
    }

    return null;
  }
}

class SelectTimeRangeModeSheet extends StatelessWidget {
  final TimeRangeMode? initialValue;

  const SelectTimeRangeModeSheet({super.key, this.initialValue});

  static const List<TimeRangeMode> _presets = [
    TimeRangeMode.last30Days,
    TimeRangeMode.thisWeek,
    TimeRangeMode.thisMonth,
    TimeRangeMode.thisYear,
    TimeRangeMode.allTime,
  ];

  static const List<TimeRangeMode> _modeRows = [
    TimeRangeMode.byMonth,
    TimeRangeMode.byYear,
    TimeRangeMode.custom,
  ];

  static const Color _sectionLabelLight = Color(0xFF94A3B8);
  static const Color _chipBorderLight = Color(0xFFD7DEE7);
  static const Color _chipIdleInkLight = Color(0xFF0F172A);
  static const Color _dividerLight = Color(0xFFE2E8F0);
  static const Color _rowLeadingLight = Color(0xFF94A3B8);
  static const Color _rowChevronLight = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final Color sectionLabel = light
        ? _sectionLabelLight
        : theme.colorScheme.onSurfaceVariant;
    final Color dividerColor =
        light ? _dividerLight : theme.colorScheme.outlineVariant;
    final Color titleInk = light
        ? kFlowHomeTransactionHeadingInk
        : theme.colorScheme.onSurface;
    final Color primaryAccent =
        light ? kFlowSetupPrimaryCurrencyInfoTitle : theme.colorScheme.primary;

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
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Text(
                      "select.timeRange".t(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        fontSize: 16.0,
                        color: titleInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0,
                        18.0,
                        24.0,
                        20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "select.timeRange.presets".t(context).toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: sectionLabel,
                              fontSize: 12.0,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: [
                              for (final TimeRangeMode mode in _presets)
                                _RangePresetChip(
                                  label: mode.translationKey.t(context),
                                  selected: mode == initialValue,
                                  selectedBg: primaryAccent,
                                  borderColor: light
                                      ? _chipBorderLight
                                      : theme.colorScheme.outlineVariant,
                                  idleInk: light
                                      ? _chipIdleInkLight
                                      : theme.colorScheme.onSurface,
                                  surface:
                                      light ? Colors.white : theme.colorScheme.surface,
                                  onTap: () => context.pop(mode),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22.0),
                          ..._buildRowsWithDividers(
                            context,
                            theme: theme,
                            light: light,
                            dividerColor: dividerColor,
                          ),
                        ],
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

  List<Widget> _buildRowsWithDividers(
    BuildContext context, {
    required ThemeData theme,
    required bool light,
    required Color dividerColor,
  }) {
    final List<Widget> out = [];
    for (int i = 0; i < _modeRows.length; i++) {
      final TimeRangeMode mode = _modeRows[i];
      out.add(
        _RangeModeRow(
          icon: Symbols.calendar_month_rounded,
          label: "select.timeRange.mode.${mode.value}".t(context),
          leadingColor: light
              ? _rowLeadingLight
              : theme.colorScheme.onSurfaceVariant,
          chevronColor: light
              ? _rowChevronLight
              : theme.colorScheme.onSurfaceVariant,
          textColor: light
              ? kFlowHomeTransactionHeadingInk
              : theme.colorScheme.onSurface,
          onTap: () => context.pop(mode),
        ),
      );
      if (i != _modeRows.length - 1) {
        out.add(
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
            child: Divider(height: 1, thickness: 1, color: dividerColor),
          ),
        );
      }
    }
    return out;
  }
}

class _RangePresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedBg;
  final Color borderColor;
  final Color idleInk;
  final Color surface;
  final VoidCallback onTap;

  const _RangePresetChip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.borderColor,
    required this.idleInk,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 18.0,
            vertical: 10.0,
          ),
          decoration: BoxDecoration(
            color: selected ? selectedBg : surface,
            borderRadius: BorderRadius.circular(999.0),
            border: selected
                ? null
                : Border.all(color: borderColor, width: 1.0),
            boxShadow: null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : idleInk,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeModeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color leadingColor;
  final Color chevronColor;
  final Color textColor;
  final VoidCallback onTap;

  const _RangeModeRow({
    required this.icon,
    required this.label,
    required this.leadingColor,
    required this.chevronColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 4.0,
          vertical: 14.0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.0, color: leadingColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Symbols.chevron_left_rounded
                  : Symbols.chevron_right_rounded,
              size: 22.0,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}
