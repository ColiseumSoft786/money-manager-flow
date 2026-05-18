import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class SyncInfoBanner extends StatelessWidget {
  const SyncInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SyncPreferencesTheme.infoFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: SyncPreferencesTheme.infoBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 20.0,
              color: SyncPreferencesTheme.infoIcon,
              fill: 0.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                "preferences.sync.footerNotice".t(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SyncPreferencesTheme.infoText,
                  fontSize: 13.0,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
