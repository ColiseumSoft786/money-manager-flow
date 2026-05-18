import "package:flow/data/flow_button_type.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/preferences/button_order/button_order_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ButtonOrderReorderTile extends StatelessWidget {
  final FlowButtonType type;
  final int index;

  const ButtonOrderReorderTile({
    super.key,
    required this.type,
    required this.index,
  });

  String _subtitleKey(FlowButtonType type) =>
      "preferences.transactionButtonOrder.buttonSubtitle@${type.name}";

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconBackground = type.actionBackgroundColor(context);
    final Color iconColor = type.actionColor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ButtonOrderPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(ButtonOrderPreferencesTheme.cardRadius),
        border: Border.all(color: ButtonOrderPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 8.0, 12.0),
        child: Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: iconBackground.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                type.icon,
                size: 24.0,
                color: iconColor,
                weight: 800.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.localizedNameContext(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: ButtonOrderPreferencesTheme.titleInk,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    _subtitleKey(type).t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ButtonOrderPreferencesTheme.subtitleInk,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: SizedBox(
                width: 44.0,
                height: 44.0,
                child: Icon(
                  Symbols.drag_indicator_rounded,
                  size: 22.0,
                  color: ButtonOrderPreferencesTheme.subtitleInk.withValues(
                    alpha: 0.55,
                  ),
                  fill: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
