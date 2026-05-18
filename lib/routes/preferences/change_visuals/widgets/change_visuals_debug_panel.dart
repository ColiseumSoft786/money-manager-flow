import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_preferences_theme.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_trend_data.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";

/// Debug section: live month-over-month previews and serialized prefs.
class ChangeVisualsDebugPanel extends StatelessWidget {
  final String serializedVisuals;
  final ChangeVisualsTrendData trendData;

  const ChangeVisualsDebugPanel({
    super.key,
    required this.serializedVisuals,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trendData.hasComparison) ...[
          Row(
            children: [
              Expanded(
                child: _LiveTrendCard(
                  label: "preferences.changeVisuals.incomeIncrease".t(context),
                  child: Trend.fromMoney(
                    previous: trendData.incomePrevious,
                    current: trendData.incomeCurrent,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _LiveTrendCard(
                  label: "preferences.changeVisuals.expenseIncrease".t(context),
                  child: Trend.fromMoney(
                    previous: trendData.expensePrevious,
                    current: trendData.expenseCurrent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
        ] else
          DecoratedBox(
            decoration: BoxDecoration(
              color: ChangeVisualsPreferencesTheme.chartTrack,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: ChangeVisualsPreferencesTheme.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "preferences.changeVisuals.noComparisonData".t(context),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ChangeVisualsPreferencesTheme.subtitleInk,
                  fontSize: 13.0,
                  height: 1.4,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12.0),
        DecoratedBox(
          decoration: BoxDecoration(
            color: ChangeVisualsPreferencesTheme.chartTrack,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: ChangeVisualsPreferencesTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              serializedVisuals,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: "monospace",
                color: ChangeVisualsPreferencesTheme.subtitleInk,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveTrendCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _LiveTrendCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChangeVisualsPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(ChangeVisualsPreferencesTheme.cardRadius),
        border: Border.all(color: ChangeVisualsPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ChangeVisualsPreferencesTheme.subtitleInk,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12.0),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: ChangeVisualsPreferencesTheme.titleInk,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
