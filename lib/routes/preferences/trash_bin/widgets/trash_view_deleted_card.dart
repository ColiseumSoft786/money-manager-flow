import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/trash_bin/trash_bin_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TrashViewDeletedCard extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const TrashViewDeletedCard({
    super.key,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TrashBinPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(TrashBinPreferencesTheme.cardRadius),
        border: Border.all(color: TrashBinPreferencesTheme.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TrashBinPreferencesTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: TrashBinPreferencesTheme.iconPlateFill(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.delete_outline_rounded,
                    size: 24.0,
                    color: TrashBinPreferencesTheme.subtitleInk,
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "preferences.trashBin.seeItems".t(context),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: TrashBinPreferencesTheme.titleInk,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        "preferences.trashBin.seeItems.subtitle".t(
                          context,
                          {"count": itemCount},
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: TrashBinPreferencesTheme.subtitleInk,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: TrashBinPreferencesTheme.subtitleInk.withValues(
                    alpha: 0.6,
                  ),
                  fill: 0.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
