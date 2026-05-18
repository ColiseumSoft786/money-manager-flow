import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transaction_entry_flow/transaction_entry_flow_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EntryFlowSettingsCard extends StatelessWidget {
  final bool skipSelectedFields;
  final bool abandonUponActionCancelled;
  final ValueChanged<bool> onSkipSelectedFieldsChanged;
  final ValueChanged<bool> onAbandonUponActionCancelledChanged;

  const EntryFlowSettingsCard({
    super.key,
    required this.skipSelectedFields,
    required this.abandonUponActionCancelled,
    required this.onSkipSelectedFieldsChanged,
    required this.onAbandonUponActionCancelledChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionEntryFlowPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(
          TransactionEntryFlowPreferencesTheme.cardRadius,
        ),
        border: Border.all(color: TransactionEntryFlowPreferencesTheme.cardBorder),
      ),
      child: Column(
        children: [
          _SettingsToggleRow(
            icon: Symbols.keyboard_double_arrow_right_rounded,
            title: "preferences.transactionEntryFlow.skipSelectedFields".t(
              context,
            ),
            value: skipSelectedFields,
            onChanged: onSkipSelectedFieldsChanged,
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            color: TransactionEntryFlowPreferencesTheme.cardBorder,
          ),
          _SettingsToggleRow(
            icon: Symbols.stop_circle_rounded,
            title: "preferences.transactionEntryFlow.abandonUponCancelForm".t(
              context,
            ),
            value: abandonUponActionCancelled,
            onChanged: onAbandonUponActionCancelledChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: TransactionEntryFlowPreferencesTheme.iconPlateFill(context),
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20.0,
              color: TransactionEntryFlowPreferencesTheme.primary(context),
              fill: 0.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                color: TransactionEntryFlowPreferencesTheme.titleInk,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: TransactionEntryFlowPreferencesTheme.primary(context),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }
}
