import "package:flow/l10n/extensions.dart";
import "package:flow/routes/home/stats/stats_theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

enum StatsRangeMode { day, week, month, year }

StatsRangeMode? statsRangeModeFrom(TimeRange range) => switch (range) {
  DayTimeRange() => StatsRangeMode.day,
  LocalWeekTimeRange() => StatsRangeMode.week,
  MonthTimeRange() => StatsRangeMode.month,
  YearTimeRange() => StatsRangeMode.year,
  _ => null,
};

TimeRange timeRangeForStatsMode(StatsRangeMode mode) => switch (mode) {
  StatsRangeMode.day => DayTimeRange.fromDateTime(Moment.startOfToday()),
  StatsRangeMode.week => TimeRange.thisLocalWeek(),
  StatsRangeMode.month => TimeRange.thisMonth(),
  StatsRangeMode.year => TimeRange.thisYear(),
};

class StatsRangeModeSegment extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onChanged;

  const StatsRangeModeSegment({
    super.key,
    required this.range,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final StatsRangeMode? selected = statsRangeModeFrom(range);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: StatsTheme.segmentIdleFill,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: StatsRangeMode.values.map((StatsRangeMode mode) {
            final bool isSelected = selected == mode;
            return Expanded(
              child: Material(
                color: isSelected
                    ? StatsTheme.segmentSelectedFill
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onChanged(timeRangeForStatsMode(mode)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _label(context, mode),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13.0,
                        color: isSelected
                            ? StatsTheme.primary(context)
                            : StatsTheme.subtitleInk,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _label(BuildContext context, StatsRangeMode mode) => switch (mode) {
    StatsRangeMode.day => "tabs.stats.range.day".t(context),
    StatsRangeMode.week => "select.timeRange.mode.byWeek".t(context),
    StatsRangeMode.month => "select.timeRange.mode.byMonth".t(context),
    StatsRangeMode.year => "select.timeRange.mode.byYear".t(context),
  };
}
