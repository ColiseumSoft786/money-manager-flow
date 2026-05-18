import "package:dashed_border/dashed_border.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/money_formatting/money_formatting_preferences_theme.dart";
import "package:flutter/material.dart";

class MoneyFormattingFooterNotice extends StatelessWidget {
  const MoneyFormattingFooterNotice({super.key});

  static final BorderRadius _radius = BorderRadius.circular(12.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: MoneyFormattingPreferencesTheme.footerFill,
        borderRadius: _radius,
        border: DashedBorder(
          color: MoneyFormattingPreferencesTheme.footerDash,
          width: 1.5,
          borderRadius: _radius,
          dashLength: 6.0,
          dashGap: 5.0,
        ),
      ),
      child: Text(
        "preferences.moneyFormatting.footerNotice".t(context),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: MoneyFormattingPreferencesTheme.footerText,
          fontSize: 13.0,
          height: 1.45,
        ),
      ),
    );
  }
}
