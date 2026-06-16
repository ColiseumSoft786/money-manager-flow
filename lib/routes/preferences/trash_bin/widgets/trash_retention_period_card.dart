import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/trash_bin/trash_bin_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TrashRetentionPeriodCard extends StatelessWidget {
  final List<Duration> choices;
  final int? selectedDays;
  final ValueChanged<int?> onSelected;

  const TrashRetentionPeriodCard({
    super.key,
    required this.choices,
    required this.selectedDays,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TrashBinPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(TrashBinPreferencesTheme.cardRadius),
        border: Border.all(color: TrashBinPreferencesTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44.0,
                  height: 44.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Symbols.delete_rounded,
                          size: 24.0,
                          color: TrashBinPreferencesTheme.primary(context),
                          fill: 0.0,
                        ),
                      ),
                      Positioned(
                        right: -2.0,
                        bottom: -2.0,
                        child: Container(
                          width: 18.0,
                          height: 18.0,
                          decoration: BoxDecoration(
                            color: TrashBinPreferencesTheme.primary(context),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TrashBinPreferencesTheme.cardFill(context),
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Symbols.schedule_rounded,
                            size: 11.0,
                            color: Colors.white,
                            fill: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "preferences.trashBin.retention.autoDeleteTitle".t(context),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: TrashBinPreferencesTheme.titleInk(context),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        "preferences.trashBin.retention.cardDescription".t(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: TrashBinPreferencesTheme.subtitleInk(context),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 10.0;
                final double chipWidth =
                    (constraints.maxWidth - spacing * 2) / 3;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    ...choices.map((Duration value) {
                      final bool selected = value.inDays == selectedDays;

                      return SizedBox(
                        width: chipWidth,
                        child: _RetentionChip(
                          label: value.toDurationString(
                            format: DurationFormat([DurationUnit.day]),
                            dropPrefixOrSuffix: true,
                          ),
                          selected: selected,
                          onTap: () => onSelected(value.inDays),
                        ),
                      );
                    }),
                    SizedBox(
                      width: chipWidth,
                      child: _RetentionChip(
                        label: "preferences.trashBin.retention.forever".t(context),
                        selected: selectedDays == null,
                        onTap: () => onSelected(null),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RetentionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RetentionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? TrashBinPreferencesTheme.chipSelectedFill
          : TrashBinPreferencesTheme.chipIdleFill,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.0,
              color: selected
                  ? TrashBinPreferencesTheme.chipSelectedInk
                  : TrashBinPreferencesTheme.chipIdleInk,
            ),
          ),
        ),
      ),
    );
  }
}
