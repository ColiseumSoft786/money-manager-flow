import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class MoneyFormattingCustomizationCard extends StatelessWidget {
  final VoidCallback onTap;

  const MoneyFormattingCustomizationCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MoneyFormattingPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(
          MoneyFormattingPreferencesTheme.cardRadius,
        ),
        border: Border.all(color: MoneyFormattingPreferencesTheme.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            MoneyFormattingPreferencesTheme.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: MoneyFormattingPreferencesTheme.iconPlateFill(context),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.edit_note_rounded,
                    size: 24.0,
                    color: MoneyFormattingPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "preferences.moneyFormatting.setICUPattern".t(context),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: MoneyFormattingPreferencesTheme.titleInk,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        "preferences.moneyFormatting.setICUPattern.description"
                            .t(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MoneyFormattingPreferencesTheme.subtitleInk,
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
                  color: MoneyFormattingPreferencesTheme.subtitleInk.withValues(
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
