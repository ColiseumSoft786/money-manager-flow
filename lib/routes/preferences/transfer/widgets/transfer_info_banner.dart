import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransferInfoBanner extends StatelessWidget {
  const TransferInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransferPreferencesTheme.infoFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: TransferPreferencesTheme.infoBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.info_rounded,
              size: 20.0,
              color: TransferPreferencesTheme.primary(context),
              fill: 0.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "preferences.transfer.footerNotice".t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TransferPreferencesTheme.infoText,
                      fontSize: 13.0,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "preferences.transfer.combineTransferTransaction.combineSupportDisclaimer"
                        .t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TransferPreferencesTheme.subtitleInk(context),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
