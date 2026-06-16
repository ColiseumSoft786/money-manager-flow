import "package:flow/l10n/extensions.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flow/widgets/home/stats/stats_range_mode_segment.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Stats screen header: back, date navigation, calendar, period segment.
class StatsTabHeader extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onRangeChanged;
  final VoidCallback? onBack;

  const StatsTabHeader({
    super.key,
    required this.range,
    required this.onRangeChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool pageable = range is PageableRange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Symbols.arrow_back_rounded,
                color: StatsTheme.titleInk(context),
                size: 22.0,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(40.0, 40.0),
                padding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pageable)
                      IconButton(
                        onPressed: () =>
                            onRangeChanged((range as PageableRange).last),
                        icon:  Icon(
                          Symbols.chevron_left_rounded,
                          color: StatsTheme.primary(context),
                          size: 22.0,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36.0,
                          minHeight: 36.0,
                        ),
                      )
                    else
                      const SizedBox(width: 36.0),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _openRangePicker(context),
                        child: Text(
                          _centerLabel(context, range),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 17.0,
                            color: StatsTheme.titleInk(context),
                          ),
                        ),
                      ),
                    ),
                    if (pageable)
                      IconButton(
                        onPressed: () =>
                            onRangeChanged((range as PageableRange).next),
                        icon:  Icon(
                          Symbols.chevron_right_rounded,
                          color: StatsTheme.primary(context),
                          size: 22.0,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36.0,
                          minHeight: 36.0,
                        ),
                      )
                    else
                      const SizedBox(width: 36.0),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _openRangePicker(context),
              icon:  Icon(
                Symbols.calendar_month_rounded,
                color: StatsTheme.primary(context),
                size: 22.0,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(40.0, 40.0),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        StatsRangeModeSegment(
          range: range,
          onChanged: onRangeChanged,
        ),
      ],
    );
  }

  static String _centerLabel(BuildContext context, TimeRange range) =>
      switch (range) {
        MonthTimeRange month => month.from.format(
          payload: month.from.isAtSameYearAs(DateTime.now())
              ? "MMMM"
              : "MMMM YYYY",
        ),
        YearTimeRange year => year.year.toString(),
        LocalWeekTimeRange week =>
          "${week.from.toMoment().format("D MMM")} – ${week.to.toMoment().format("D MMM")}",
        DayTimeRange day => day.from.toMoment().format("D MMM YYYY"),
        _ =>
          (range.from <= Moment.minValue && range.to >= Moment.maxValue)
              ? "select.timeRange.allTime".t(context)
              : "${range.from.toMoment().format("D MMM")} – ${range.to.toMoment().format("D MMM YYYY")}",
      };

  Future<void> _openRangePicker(BuildContext context) async {
    if (range is MonthTimeRange) {
      final DateTime? picked = await showMonthPickerSheet(
        context,
        initialDate: range.from,
      );
      if (picked != null) {
        onRangeChanged(MonthTimeRange.fromDateTime(picked));
      }
      return;
    }

    if (range is YearTimeRange) {
      final DateTime? picked = await showYearPickerSheet(
        context,
        initialDate: range.from,
      );
      if (picked != null) {
        onRangeChanged(YearTimeRange.fromDateTime(picked));
      }
      return;
    }

    final TimeRange? picked = await showTimeRangePickerSheet(
      context,
      initialValue: range,
    );
    if (picked != null) {
      onRangeChanged(picked);
    }
  }
}
