import "package:flow/l10n/extensions.dart";
import "package:flow/routes/import/import_page_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ImportPrivacyBanner extends StatelessWidget {
  const ImportPrivacyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ImportPageTheme.privacyFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: ImportPageTheme.privacyBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28.0,
              height: 28.0,
              decoration:  BoxDecoration(
                color: ImportPageTheme.primary(context),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Symbols.info_rounded,
                size: 18.0,
                color: Colors.white,
                fill: 0.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                "sync.import.privacyNotice".t(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ImportPageTheme.privacyText,
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
