import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/deleted_transactions/deleted_transactions_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class DeletedTransactionsInfoBanner extends StatelessWidget {
  const DeletedTransactionsInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DeletedTransactionsTheme.infoFill,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: DeletedTransactionsTheme.infoBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.0,
                height: 28.0,
                decoration: const BoxDecoration(
                  color: DeletedTransactionsTheme.infoIconFill,
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
                  "transactions.deleted.infoBanner".t(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DeletedTransactionsTheme.infoText,
                    fontSize: 13.0,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
