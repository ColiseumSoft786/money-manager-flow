import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntryPickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool showDivider;

  const TransactionEntryPickerRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.placeholder,
    this.onTap,
    this.leading,
    this.showDivider = true,
  });

  bool get _hasValue => value != null && value!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget iconChild = leading ??
        Icon(
          icon,
          size: 22.0,
          color: TransactionEntryTheme.iconPlateInk(context),
          fill: 0.0,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              TransactionEntryTheme.cardRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 13.0,
              ),
              child: Row(
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
                    child: iconChild,
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TransactionEntryTheme.rowCaptionStyle(
                            context,
                            theme,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          _hasValue ? value! : placeholder,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _hasValue
                              ? TransactionEntryTheme.rowValueStyle(context, theme)
                              : TransactionEntryTheme.rowPlaceholderStyle(
                                  context,
                                  theme,
                                ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Symbols.chevron_right_rounded,
                    size: 22.0,
                    color: TransactionEntryTheme.chevronInk(context),
                    fill: 0.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 74.0,
            endIndent: 16.0,
            color: TransactionEntryTheme.rowDivider(context),
          ),
      ],
    );
  }
}
