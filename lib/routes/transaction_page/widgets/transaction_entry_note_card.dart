import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flow/routes/utils/edit_markdown_page.dart";
import "package:flow/widgets/general/markdown_view.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

class TransactionEntryNoteCard extends StatelessWidget {
  final String? value;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool wrapInCard;

  const TransactionEntryNoteCard({
    super.key,
    this.value,
    this.onChanged,
    this.focusNode,
    this.wrapInCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool noContent = value == null || value!.trim().isEmpty;

    final Widget row = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEditor(context),
          borderRadius: BorderRadius.circular(TransactionEntryTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: TransactionEntryTheme.iconPlateSize,
                  height: TransactionEntryTheme.iconPlateSize,
                  decoration: BoxDecoration(
                    color: TransactionEntryTheme.iconPlateFill(context),
                    borderRadius: BorderRadius.circular(
                      TransactionEntryTheme.iconPlateRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child:  Icon(
                    Symbols.notes_rounded,
                    size: 22.0,
                    color: TransactionEntryTheme.iconPlateInk(context),
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "transaction.description".t(context),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TransactionEntryTheme.labelInk,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(
                            SimpleIcons.markdown,
                            size: 13.0,
                            fill: 0,
                            color: TransactionEntryTheme.labelInk,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      if (noContent)
                        Text(
                          "transaction.description.placeholder".t(context),
                          style: TransactionEntryTheme.rowPlaceholderStyle(
                            theme,
                          ).copyWith(height: 1.4),
                        )
                      else
                        MarkdownView(
                          key: ValueKey(value),
                          markdown: value,
                          onChanged: onChanged,
                          focusNode: focusNode,
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: TransactionEntryTheme.chevronInk,
                  fill: 0.0,
                ),
              ],
            ),
          ),
        ),
      );

    return wrapInCard ? TransactionEntryCard(child: row) : row;
  }

  Future<void> _openEditor(BuildContext context) async {
    final String? result = await context.push<String?>(
      "/utils/editmd",
      extra: EditMarkdownPageProps(
        initialValue: value,
        maxLength: Transaction.maxDescriptionLength,
        transactionEntryLayout: true,
      ),
    );

    if (result == null || onChanged == null) return;
    onChanged!(result);
  }
}
