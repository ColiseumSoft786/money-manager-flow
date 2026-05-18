import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Bottom sheet that lets the user pick a custom [DateTimeRange] using a
/// continuously-scrolling month-by-month calendar (Figma redesign that
/// replaces the stock [showDateRangePicker]).
///
/// Returns:
///   * a [DateTimeRange] when the user taps **Save** with at least one date,
///   * `null` when the user dismisses or taps **Save** with no selection.
class SelectCustomDateRangeSheet extends StatefulWidget {
  final DateTimeRange? initialValue;

  const SelectCustomDateRangeSheet({super.key, this.initialValue});

  @override
  State<SelectCustomDateRangeSheet> createState() =>
      _SelectCustomDateRangeSheetState();
}

class _SelectCustomDateRangeSheetState
    extends State<SelectCustomDateRangeSheet> {
  DateTime? _start;
  DateTime? _end;

  /// First day (1st) of the month that the calendar opens centered on.
  late final DateTime _anchorMonth;

  /// Sentinel key used by [CustomScrollView.center] so the scroll view starts
  /// already centered on [_anchorMonth] while still allowing the user to
  /// scroll into past months.
  final Key _futureSliverKey = const ValueKey<String>("date_range_future");

  /// Number of months before and after the anchor that are scrollable.
  static const int _monthsBefore = 36;
  static const int _monthsAfter = 36;

  @override
  void initState() {
    super.initState();
    _start = _normalize(widget.initialValue?.start);
    _end = _normalize(widget.initialValue?.end);

    final DateTime focus = _start ?? DateTime.now();
    _anchorMonth = DateTime(focus.year, focus.month, 1);
  }

  static DateTime? _normalize(DateTime? d) =>
      d == null ? null : DateTime(d.year, d.month, d.day);

  DateTime _monthAt(int offset) =>
      DateTime(_anchorMonth.year, _anchorMonth.month + offset, 1);

  void _onDayTap(DateTime date) {
    setState(() {
      if (_start == null) {
        _start = date;
        _end = null;
      } else if (_end == null) {
        if (date.isBefore(_start!)) {
          _start = date;
        } else if (date.isAtSameMomentAs(_start!)) {
          _end = date;
        } else {
          _end = date;
        }
      } else {
        _start = date;
        _end = null;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _start = null;
      _end = null;
    });
  }

  void _save() {
    if (_start == null) {
      context.pop(null);
      return;
    }
    final DateTime endValue = _end ?? _start!;
    context.pop(DateTimeRange(start: _start!, end: endValue));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.92;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final Color titleInk = light
        ? kFlowHomeTransactionHeadingInk
        : theme.colorScheme.onSurface;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color cardFill = light
        ? kFlowDateRangeSelectedCardFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color cardLabelInk = light
        ? kFlowPopularCurrenciesSectionHeading
        : theme.colorScheme.onSurfaceVariant;
    final Color pillFill = light
        ? kFlowDateRangePillFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color sundayInk = light
        ? kFlowDateRangeSundayInkLight
        : theme.colorScheme.error;
    final Color weekdayInk = light
        ? kFlowDateRangeWeekdayInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color dayInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;

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
                  const SizedBox(height: 12.0),
                  _Header(
                    titleInk: titleInk,
                    chevronInk: chevronInk,
                    saveInk: primaryAccent,
                    onClose: () => context.pop(null),
                    onSave: _save,
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20.0,
                    ),
                    child: _SelectedRangeCard(
                      start: _start,
                      end: _end,
                      cardFill: cardFill,
                      labelInk: cardLabelInk,
                      valueInk: titleInk,
                      accent: primaryAccent,
                      onPrimary: onPrimary,
                      onEditTap: _clearSelection,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20.0,
                    ),
                    child: _WeekdayHeader(
                      sundayInk: sundayInk,
                      weekdayInk: weekdayInk,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Flexible(
                    child: CustomScrollView(
                      center: _futureSliverKey,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final int offset = -(index + 1);
                              return _MonthBlock(
                                month: _monthAt(offset),
                                start: _start,
                                end: _end,
                                accent: primaryAccent,
                                onAccent: onPrimary,
                                pillFill: pillFill,
                                dayInk: dayInk,
                                titleInk: titleInk,
                                onDayTap: _onDayTap,
                              );
                            },
                            childCount: _monthsBefore,
                          ),
                        ),
                        SliverList(
                          key: _futureSliverKey,
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _MonthBlock(
                                month: _monthAt(index),
                                start: _start,
                                end: _end,
                                accent: primaryAccent,
                                onAccent: onPrimary,
                                pillFill: pillFill,
                                dayInk: dayInk,
                                titleInk: titleInk,
                                onDayTap: _onDayTap,
                              );
                            },
                            childCount: _monthsAfter + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color titleInk;
  final Color chevronInk;
  final Color saveInk;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const _Header({
    required this.titleInk,
    required this.chevronInk,
    required this.saveInk,
    required this.onClose,
    required this.onSave,
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
              icon: Icon(
                Symbols.close_rounded,
                color: chevronInk,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56.0),
            child: Text(
              "select.timeRange".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
                letterSpacing: -0.1,
                color: titleInk,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onSave,
              style: TextButton.styleFrom(
                foregroundColor: saveInk,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "general.save".t(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: saveInk,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRangeCard extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final Color cardFill;
  final Color labelInk;
  final Color valueInk;
  final Color accent;
  final Color onPrimary;
  final VoidCallback onEditTap;

  const _SelectedRangeCard({
    required this.start,
    required this.end,
    required this.cardFill,
    required this.labelInk,
    required this.valueInk,
    required this.accent,
    required this.onPrimary,
    required this.onEditTap,
  });

  String _formatDate(DateTime d) =>
      "${d.format(payload: "MMM")} ${d.day}, ${d.year}";

  String _label(BuildContext context) {
    if (start == null) {
      return "select.timeRange.mode.custom".t(context);
    }
    if (end == null || start == end) {
      return _formatDate(start!);
    }
    return "${_formatDate(start!)} - ${_formatDate(end!)}";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "select.timeRange.selectedRange".t(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelInk,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    fontSize: 11.0,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  _label(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: valueInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Material(
            color: accent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onEditTap,
              child: SizedBox(
                width: 32.0,
                height: 32.0,
                child: Center(
                  child: Icon(
                    Symbols.edit_rounded,
                    color: onPrimary,
                    size: 16.0,
                    fill: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  static const List<String> _labels = ["S", "M", "T", "W", "T", "F", "S"];

  final Color sundayInk;
  final Color weekdayInk;

  const _WeekdayHeader({required this.sundayInk, required this.weekdayInk});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                _labels[i],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: i == 0 ? sundayInk : weekdayInk,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthBlock extends StatelessWidget {
  final DateTime month;
  final DateTime? start;
  final DateTime? end;
  final Color accent;
  final Color onAccent;
  final Color pillFill;
  final Color dayInk;
  final Color titleInk;
  final ValueChanged<DateTime> onDayTap;

  const _MonthBlock({
    required this.month,
    required this.start,
    required this.end,
    required this.accent,
    required this.onAccent,
    required this.pillFill,
    required this.dayInk,
    required this.titleInk,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int year = month.year;
    final int monthIndex = month.month;

    final int firstWeekday = DateTime(year, monthIndex, 1).weekday; // 1..7
    final int startColumn = firstWeekday % 7; // Sun=0
    final int daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    final int totalCells = startColumn + daysInMonth;
    final int numRows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18.0),
          Center(
            child: Text(
              "${month.format(payload: "MMMM")} ${month.year}",
              style: theme.textTheme.titleMedium?.copyWith(
                color: titleInk,
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          for (int row = 0; row < numRows; row++) ...[
            if (row != 0) const SizedBox(height: 6.0),
            _CalendarRow(
              year: year,
              monthIndex: monthIndex,
              daysInMonth: daysInMonth,
              startColumn: startColumn,
              row: row,
              start: start,
              end: end,
              accent: accent,
              onAccent: onAccent,
              pillFill: pillFill,
              dayInk: dayInk,
              onDayTap: onDayTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarRow extends StatelessWidget {
  final int year;
  final int monthIndex;
  final int daysInMonth;
  final int startColumn;
  final int row;
  final DateTime? start;
  final DateTime? end;
  final Color accent;
  final Color onAccent;
  final Color pillFill;
  final Color dayInk;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarRow({
    required this.year,
    required this.monthIndex,
    required this.daysInMonth,
    required this.startColumn,
    required this.row,
    required this.start,
    required this.end,
    required this.accent,
    required this.onAccent,
    required this.pillFill,
    required this.dayInk,
    required this.onDayTap,
  });

  int? _dayAtColumn(int column) {
    final int day = row * 7 + column - startColumn + 1;
    if (day < 1 || day > daysInMonth) return null;
    return day;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 44.0,
      child: Row(
        children: [
          for (int col = 0; col < 7; col++)
            Expanded(
              child: _DayCell(
                day: _dayAtColumn(col),
                column: col,
                year: year,
                monthIndex: monthIndex,
                start: start,
                end: end,
                accent: accent,
                onAccent: onAccent,
                pillFill: pillFill,
                dayInk: dayInk,
                textTheme: theme.textTheme,
                onDayTap: onDayTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final int column;
  final int year;
  final int monthIndex;
  final DateTime? start;
  final DateTime? end;
  final Color accent;
  final Color onAccent;
  final Color pillFill;
  final Color dayInk;
  final TextTheme textTheme;
  final ValueChanged<DateTime> onDayTap;

  const _DayCell({
    required this.day,
    required this.column,
    required this.year,
    required this.monthIndex,
    required this.start,
    required this.end,
    required this.accent,
    required this.onAccent,
    required this.pillFill,
    required this.dayInk,
    required this.textTheme,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox.shrink();

    final DateTime date = DateTime(year, monthIndex, day!);
    final bool hasStart = start != null;
    final bool hasEnd = end != null;
    final bool isStart = hasStart && date.isAtSameMomentAs(start!);
    final bool isEnd = hasEnd && date.isAtSameMomentAs(end!);
    final bool inRangeStrict = hasStart &&
        hasEnd &&
        date.isAfter(start!) &&
        date.isBefore(end!);

    final bool singleSelection =
        hasStart && hasEnd && start!.isAtSameMomentAs(end!);

    final bool leftHalfFill =
        !singleSelection && (inRangeStrict || (isEnd && hasStart));
    final bool rightHalfFill =
        !singleSelection && (inRangeStrict || (isStart && hasEnd));

    final bool roundLeft = leftHalfFill && column == 0;
    final bool roundRight = rightHalfFill && column == 6;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onDayTap(date),
      child: SizedBox(
        height: 44.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36.0,
                      child: leftHalfFill
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: pillFill,
                                borderRadius: BorderRadiusDirectional.only(
                                  topStart:
                                      Radius.circular(roundLeft ? 100.0 : 0.0),
                                  bottomStart:
                                      Radius.circular(roundLeft ? 100.0 : 0.0),
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 36.0,
                      child: rightHalfFill
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: pillFill,
                                borderRadius: BorderRadiusDirectional.only(
                                  topEnd:
                                      Radius.circular(roundRight ? 100.0 : 0.0),
                                  bottomEnd:
                                      Radius.circular(roundRight ? 100.0 : 0.0),
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
            if (isStart || isEnd)
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
                child: Center(
                  child: Text(
                    day!.toString(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: onAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              )
            else
              Text(
                day!.toString(),
                style: textTheme.bodyMedium?.copyWith(
                  color: dayInk,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
