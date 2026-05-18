import "package:flow/routes/preferences/reminders/reminders_preferences_theme.dart";
import "package:flutter/material.dart";

class ReminderTimeWheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const ReminderTimeWheel({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<ReminderTimeWheel> createState() => _ReminderTimeWheelState();
}

class _ReminderTimeWheelState extends State<ReminderTimeWheel> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.value - widget.min,
    );
  }

  @override
  void didUpdateWidget(ReminderTimeWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final int target = widget.value - widget.min;
      if (_controller.hasClients && _controller.selectedItem != target) {
        _controller.jumpToItem(target);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(int n) => n.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 76.0,
      height: 148.0,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: 48.0,
        diameterRatio: 1.35,
        perspective: 0.003,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (int index) {
          widget.onChanged(widget.min + index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.max - widget.min + 1,
          builder: (context, index) {
            final int itemValue = widget.min + index;
            final bool selected = itemValue == widget.value;

            return Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64.0,
                height: 44.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? RemindersPreferencesTheme.wheelFill
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  border: selected
                      ? Border.all(color: RemindersPreferencesTheme.wheelBorder)
                      : null,
                ),
                child: Text(
                  _format(itemValue),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: selected ? 26.0 : 18.0,
                    color: selected
                        ? RemindersPreferencesTheme.primary(context)
                        : RemindersPreferencesTheme.wheelFadedInk,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
