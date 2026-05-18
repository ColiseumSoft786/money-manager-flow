import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/trash_bin/trash_bin_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TrashEmptyButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const TrashEmptyButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Material(
            color: TrashBinPreferencesTheme.cardFill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
              side: BorderSide(
                color: enabled
                    ? TrashBinPreferencesTheme.danger.withValues(alpha: 0.55)
                    : TrashBinPreferencesTheme.dangerBorder,
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(14.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.delete_forever_rounded,
                      size: 22.0,
                      color: TrashBinPreferencesTheme.danger.withValues(
                        alpha: enabled ? 1.0 : 0.45,
                      ),
                      fill: 0.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      "preferences.trashBin.emptyBin".t(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: TrashBinPreferencesTheme.danger.withValues(
                          alpha: enabled ? 1.0 : 0.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          "preferences.trashBin.emptyBin.irreversible".t(context),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: TrashBinPreferencesTheme.subtitleInk,
            fontWeight: FontWeight.w600,
            fontSize: 10.0,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
