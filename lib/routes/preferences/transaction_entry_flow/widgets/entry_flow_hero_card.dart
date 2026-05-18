import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transaction_entry_flow/transaction_entry_flow_preferences_theme.dart";
import "package:flutter/material.dart";

class EntryFlowHeroCard extends StatelessWidget {
  const EntryFlowHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TransactionEntryFlowPreferencesTheme.heroFill,
        borderRadius: BorderRadius.circular(
          TransactionEntryFlowPreferencesTheme.cardRadius,
        ),
        border: Border.all(color: TransactionEntryFlowPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Block(width: 52.0, height: 36.0, color: const Color(0xFFD4A574)),
                Transform.translate(
                  offset: const Offset(-12.0, 8.0),
                  child: _Block(
                    width: 48.0,
                    height: 32.0,
                    color: const Color(0xFFE8D5B5),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-8.0, -6.0),
                  child: _Block(
                    width: 44.0,
                    height: 28.0,
                    color: const Color(0xFFF5E6D3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Text(
              "preferences.transactionEntryFlow.heroTitle".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
                color: TransactionEntryFlowPreferencesTheme.heroTitle,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "preferences.transactionEntryFlow.description".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: TransactionEntryFlowPreferencesTheme.heroSubtitle,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _Block({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 4.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
    );
  }
}
