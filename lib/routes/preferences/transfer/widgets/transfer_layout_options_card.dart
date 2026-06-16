import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:flow/routes/preferences/transfer/widgets/transfer_option_radio.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransferLayoutOptionsCard extends StatelessWidget {
  final bool combineSelected;
  final VoidCallback onCombine;
  final VoidCallback onSeparate;

  const TransferLayoutOptionsCard({
    super.key,
    required this.combineSelected,
    required this.onCombine,
    required this.onSeparate,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransferPreferencesTheme.cardFill(context),
        borderRadius: BorderRadius.circular(TransferPreferencesTheme.cardRadius),
        border: Border.all(color: TransferPreferencesTheme.cardBorder(context)),
      ),
      child: Column(
        children: [
          _LayoutOptionRow(
            icon: Symbols.layers_rounded,
            iconColor: TransferPreferencesTheme.primary(context),
            title: "preferences.transfer.combineTransferTransaction.combine"
                .t(context),
            subtitle: "preferences.transfer.combine.subtitle".t(context),
            selected: combineSelected,
            onTap: onCombine,
          ),
          Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            color: TransferPreferencesTheme.divider(context),
          ),
          _LayoutOptionRow(
            icon: Symbols.view_agenda_rounded,
            iconColor: TransferPreferencesTheme.heroMutedIcon,
            title: "preferences.transfer.combineTransferTransaction.separate"
                .t(context),
            subtitle: "preferences.transfer.separate.subtitle".t(context),
            selected: !combineSelected,
            onTap: onSeparate,
          ),
        ],
      ),
    );
  }
}

class _LayoutOptionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LayoutOptionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: selected
          ? TransferPreferencesTheme.infoFill.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: TransferPreferencesTheme.iconPlateFill(context),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 24.0, color: iconColor, fill: 0.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: TransferPreferencesTheme.titleInk(context),
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TransferPreferencesTheme.subtitleInk(context),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TransferOptionRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
