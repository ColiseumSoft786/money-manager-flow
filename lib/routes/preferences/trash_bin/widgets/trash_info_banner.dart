import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/trash_bin/trash_bin_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TrashInfoBanner extends StatelessWidget {
  const TrashInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(TrashBinPreferencesTheme.cardRadius),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 28.0),
            color: TrashBinPreferencesTheme.infoFill,
            child: Text(
              "preferences.trashBin.infoBanner".t(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TrashBinPreferencesTheme.infoText,
                fontSize: 14.0,
                height: 1.45,
              ),
            ),
          ),
          Positioned(
            right: 12.0,
            bottom: -8.0,
            child: Icon(
              Symbols.delete_rounded,
              size: 88.0,
              color: TrashBinPreferencesTheme.infoWatermark.withValues(
                alpha: 0.45,
              ),
              fill: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
