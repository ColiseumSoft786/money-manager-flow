import "package:flow/l10n/extensions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

enum ExportRangeTab { thisMonth, lastMonth, custom }

class ExportRangeCard extends StatelessWidget {
  final ExportRangeTab tab;
  final ValueChanged<ExportRangeTab> onTabChanged;
  final DateTime displayMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDayTap;

  const ExportRangeCard({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.displayMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDayTap,
  });

  String _rangeLabel(BuildContext context) {
    if (rangeStart == null) {
      return "sync.export.range.notSelected".t(context);
    }
    final DateTime end = rangeEnd ?? rangeStart!;
    if (rangeStart!.year == end.year &&
        rangeStart!.month == end.month &&
        rangeStart!.day == end.day) {
      return rangeStart!.toMoment().format("MMM D, YYYY");
    }
    return "${rangeStart!.toMoment().format("MMM D")} – ${end.toMoment().format("MMM D, YYYY")}";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExportOptionsTheme.cardFill,
        borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
        border: Border.all(color: ExportOptionsTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RangeTabs(tab: tab, onTabChanged: onTabChanged),
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: ExportOptionsTheme.rangeSummaryFill,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.date_range_rounded,
                    size: 20.0,
                    color: ExportOptionsTheme.primary(context),
                    fill: 0.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "sync.export.range.selected".t(context),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ExportOptionsTheme.sectionLabel,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            fontSize: 10.0,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          _rangeLabel(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: ExportOptionsTheme.titleInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            _MonthNavigator(
              displayMonth: displayMonth,
              onPrevious: onPreviousMonth,
              onNext: onNextMonth,
            ),
            const SizedBox(height: 8.0),
            _ExportMonthCalendar(
              month: displayMonth,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
              onDayTap: onDayTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  final ExportRangeTab tab;
  final ValueChanged<ExportRangeTab> onTabChanged;

  const _RangeTabs({required this.tab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final ExportRangeTab value in ExportRangeTab.values) ...[
          if (value != ExportRangeTab.values.first) const SizedBox(width: 8.0),
          Expanded(
            child: _RangeTabChip(
              label: switch (value) {
                ExportRangeTab.thisMonth =>
                  "sync.export.range.thisMonth".t(context),
                ExportRangeTab.lastMonth =>
                  "sync.export.range.lastMonth".t(context),
                ExportRangeTab.custom => "sync.export.range.custom".t(context),
              },
              selected: tab == value,
              onTap: () => onTabChanged(value),
            ),
          ),
        ],
      ],
    );
  }
}

class _RangeTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ExportOptionsTheme.tabSelectedFill
          : ExportOptionsTheme.tabIdleFill,
      borderRadius: BorderRadius.circular(999.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12.0,
              color: selected
                  ? ExportOptionsTheme.tabSelectedInk
                  : ExportOptionsTheme.tabIdleInk,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final DateTime displayMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.displayMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        _NavButton(icon: Symbols.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Text(
            displayMonth.toMoment().format("MMMM YYYY"),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: ExportOptionsTheme.titleInk,
            ),
          ),
        ),
        _NavButton(icon: Symbols.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ExportOptionsTheme.tabIdleFill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36.0,
          height: 36.0,
          child: Icon(icon, size: 22.0, color: ExportOptionsTheme.titleInk),
        ),
      ),
    );
  }
}

class _ExportMonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDayTap;

  const _ExportMonthCalendar({
    required this.month,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDayTap,
  });

  static const List<String> _weekdays = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int year = month.year;
    final int monthIndex = month.month;
    final int firstWeekday = DateTime(year, monthIndex, 1).weekday;
    final int startColumn = firstWeekday % 7;
    final int daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    final int totalCells = startColumn + daysInMonth;
    final int numRows = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _weekdays[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: i == 0
                          ? ExportOptionsTheme.calendarSundayInk
                          : ExportOptionsTheme.calendarWeekdayInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6.0),
        for (int row = 0; row < numRows; row++) ...[
          if (row > 0) const SizedBox(height: 4.0),
          SizedBox(
            height: 40.0,
            child: Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: _dayAtColumn(row, col, startColumn, daysInMonth),
                      column: col,
                      year: year,
                      monthIndex: monthIndex,
                      rangeStart: rangeStart,
                      rangeEnd: rangeEnd,
                      onDayTap: onDayTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  int? _dayAtColumn(int row, int col, int startColumn, int daysInMonth) {
    final int day = row * 7 + col - startColumn + 1;
    if (day < 1 || day > daysInMonth) return null;
    return day;
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final int column;
  final int year;
  final int monthIndex;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDayTap;

  const _DayCell({
    required this.day,
    required this.column,
    required this.year,
    required this.monthIndex,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox.shrink();

    final DateTime date = DateTime(year, monthIndex, day!);
    final DateTime? start = rangeStart == null
        ? null
        : DateTime(rangeStart!.year, rangeStart!.month, rangeStart!.day);
    final DateTime? end = rangeEnd == null
        ? null
        : DateTime(rangeEnd!.year, rangeEnd!.month, rangeEnd!.day);

    final bool hasStart = start != null;
    final bool hasEnd = end != null;
    final bool isStart = hasStart && date.isAtSameMomentAs(start!);
    final bool isEnd = hasEnd && date.isAtSameMomentAs(end!);
    final bool inRange =
        hasStart &&
        hasEnd &&
        date.isAfter(start!) &&
        date.isBefore(end!);
    final bool single = hasStart && hasEnd && start!.isAtSameMomentAs(end!);
    final bool selected = isStart || isEnd || inRange;

    final bool leftFill = !single && (inRange || isEnd);
    final bool rightFill = !single && (inRange || isStart);

    return GestureDetector(
      onTap: () => onDayTap(date),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (leftFill)
            Positioned(
              left: 0,
              right: column == 6 ? 0 : null,
              width: column == 6 ? null : double.infinity,
              top: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ExportOptionsTheme.calendarPillFill,
                  borderRadius: BorderRadius.horizontal(
                    left: column == 0 ? const Radius.circular(20.0) : Radius.zero,
                  ),
                ),
              ),
            ),
          if (rightFill)
            Positioned(
              right: 0,
              left: column == 0 ? 0 : null,
              width: column == 0 ? null : double.infinity,
              top: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ExportOptionsTheme.calendarPillFill,
                  borderRadius: BorderRadius.horizontal(
                    right: column == 6 ? const Radius.circular(20.0) : Radius.zero,
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34.0,
            height: 34.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isStart || isEnd)
                  ? ExportOptionsTheme.calendarAccent(context)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$day",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.0,
                color: (isStart || isEnd)
                    ? Colors.white
                    : ExportOptionsTheme.titleInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
