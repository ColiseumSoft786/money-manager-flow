import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/numpad/numpad_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class NumpadPreviewHero extends StatelessWidget {
  const NumpadPreviewHero({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: NumpadPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(NumpadPreferencesTheme.cardRadius),
        border: Border.all(color: NumpadPreferencesTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 20.0),
        child: Column(
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: NumpadPreferencesTheme.infoFill,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Symbols.dialpad_rounded,
                size: 28.0,
                color: NumpadPreferencesTheme.primary(context),
                fill: 0.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              "\$0.00",
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 36.0,
                color: NumpadPreferencesTheme.previewAmount,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "preferences.numpad.preview.hint".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: NumpadPreferencesTheme.subtitleInk,
                fontSize: 14.0,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
