import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class MoneyFormattingPreviewCard extends StatelessWidget {
  final bool preferFullAmounts;

  const MoneyFormattingPreviewCard({
    super.key,
    required this.preferFullAmounts,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: MoneyFormattingPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(
          MoneyFormattingPreferencesTheme.cardRadius,
        ),
        border: Border.all(
          color: MoneyFormattingPreferencesTheme.cardBorder(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  "preferences.moneyFormatting.preview.label".t(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MoneyFormattingPreferencesTheme.previewLabel,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.0,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Icon(
                  Symbols.payments_rounded,
                  size: 28.0,
                  color: MoneyFormattingPreferencesTheme.previewWatermark,
                  fill: 0.0,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            MoneyText(
              Money(12345678.90, UserPreferencesService().primaryCurrency),
              initiallyAbbreviated: !preferFullAmounts,
              tapToToggleAbbreviation: false,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 36.0,
                color: MoneyFormattingPreferencesTheme.titleInk(context),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14.0),
            Row(
              children: [
                Icon(
                  Symbols.info_rounded,
                  size: 18.0,
                  color: MoneyFormattingPreferencesTheme.previewHint,
                  fill: 0.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    "preferences.moneyFormatting.preview.hint".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MoneyFormattingPreferencesTheme.previewHint,
                      fontSize: 13.0,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
