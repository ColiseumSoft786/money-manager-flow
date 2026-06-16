import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transaction_geo/transaction_geo_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class GeoPrivacyCard extends StatelessWidget {
  const GeoPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionGeoPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(
          TransactionGeoPreferencesTheme.cardRadius,
        ),
        border: Border.all(
          color: TransactionGeoPreferencesTheme.cardBorder(context),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.verified_user_rounded,
              size: 22.0,
              color: TransactionGeoPreferencesTheme.subtitleInk(context),
              fill: 0.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                "preferences.transactions.geo.privacyNotice".t(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TransactionGeoPreferencesTheme.subtitleInk(context),
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
