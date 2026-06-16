import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class SyncIntervalGrid extends StatelessWidget {
  final List<int?> options;
  final int? selectedHours;
  final ValueChanged<int?> onSelected;

  const SyncIntervalGrid({
    super.key,
    required this.options,
    required this.selectedHours,
    required this.onSelected,
  });

  String _label(BuildContext context, int? hours) {
    if (hours == null) {
      return "preferences.sync.autoBackup.disabled".t(context);
    }
    return Duration(hours: hours).toDurationString(
      dropPrefixOrSuffix: true,
      format: hours >= 24 ? DurationFormat.dh : DurationFormat.hm,
    );
  }

  bool _isRecommended(int? hours) => hours == 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 10.0;
        final double tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: options.map((int? hours) {
            final bool selected = hours == selectedHours;
            final bool recommended = _isRecommended(hours);

            return SizedBox(
              width: tileWidth,
              child: Material(
                color: selected
                    ? SyncPreferencesTheme.chipSelectedFill(context)
                    : SyncPreferencesTheme.chipIdleFill(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  side: BorderSide(
                    color: selected
                        ? SyncPreferencesTheme.chipSelectedBorder(context)
                        : SyncPreferencesTheme.chipIdleBorder(context),
                    width: selected ? 2.0 : 1.0,
                  ),
                ),
                child: InkWell(
                  onTap: () => onSelected(hours),
                  borderRadius: BorderRadius.circular(14.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _label(context, hours),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                                color: selected
                                    ? SyncPreferencesTheme.chipSelectedInk
                                    : SyncPreferencesTheme.chipIdleInk(context),
                              ),
                        ),
                        if (recommended) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            "preferences.sync.interval.recommended".t(context),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: SyncPreferencesTheme.chipRecommendedInk(context),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9.0,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
