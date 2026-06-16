import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class SyncRetainHistoryCard extends StatelessWidget {
  final int displayValue;
  final List<int?> options;
  final ValueChanged<int?> onChanged;

  const SyncRetainHistoryCard({
    super.key,
    required this.displayValue,
    required this.options,
    required this.onChanged,
  });

  int _nearestSliderIndex(int value, List<int> sliderOptions) {
    if (sliderOptions.isEmpty) return 0;
    int nearest = 0;
    for (int i = 1; i < sliderOptions.length; i++) {
      if ((sliderOptions[i] - value).abs() <
          (sliderOptions[nearest] - value).abs()) {
        nearest = i;
      }
    }
    return nearest;
  }

  bool _isInfinite(int value) => value <= 0;

  String _valueLabel(BuildContext context, int value) {
    if (_isInfinite(value)) {
      return "preferences.sync.iCloud.noOfBackupsToKeep.infiniteBackups".t(
        context,
      );
    }
    return "$value";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<int> sliderOptions = options
        .whereType<int>()
        .where((int v) => v > 0)
        .toList();
    final int? infiniteOption = options.contains(-1) ? -1 : null;

    final int current = displayValue;
    final int resolvedIndex = _isInfinite(current)
        ? 0
        : sliderOptions.contains(current)
        ? sliderOptions.indexOf(current)
        : _nearestSliderIndex(current, sliderOptions);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SyncPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(SyncPreferencesTheme.cardRadius),
        border: Border.all(color: SyncPreferencesTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration:  BoxDecoration(
                    color: SyncPreferencesTheme.iconPlateFill(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.history_rounded,
                    size: 20.0,
                    color: SyncPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    "preferences.sync.iCloud.noOfBackupsToKeep".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: SyncPreferencesTheme.titleInk(context),
                    ),
                  ),
                ),
                Text(
                  _valueLabel(context, current),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.0,
                    color: SyncPreferencesTheme.primary(context),
                  ),
                ),
              ],
            ),
            if (sliderOptions.isNotEmpty) ...[
              const SizedBox(height: 12.0),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: SyncPreferencesTheme.primary(context),
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  thumbColor: SyncPreferencesTheme.primary(context),
                  overlayColor: SyncPreferencesTheme.primary(context).withValues(
                    alpha: 0.12,
                  ),
                  trackHeight: 4.0,
                ),
                child: Slider(
                  value: resolvedIndex.toDouble(),
                  min: 0,
                  max: (sliderOptions.length - 1).toDouble(),
                  divisions: sliderOptions.length > 1
                      ? sliderOptions.length - 1
                      : 1,
                  onChanged: (double index) {
                    onChanged(sliderOptions[index.round()]);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "preferences.sync.retain.minLabel".t(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: SyncPreferencesTheme.sectionLabel(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    "preferences.sync.retain.maxLabel".t(
                      context,
                      sliderOptions.last,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: SyncPreferencesTheme.sectionLabel(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
            if (infiniteOption != null) ...[
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isInfinite(current)
                      ? null
                      : () => onChanged(infiniteOption),
                  style: TextButton.styleFrom(
                    foregroundColor: SyncPreferencesTheme.primary(context),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "preferences.sync.iCloud.noOfBackupsToKeep.infiniteBackups"
                        .t(context),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
