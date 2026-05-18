import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_trend_data.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_preferences_theme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

enum ChangeVisualsGrowthKind { income, expense }

class ChangeVisualsGrowthCard extends StatelessWidget {
  final ChangeVisualsGrowthKind kind;
  final ChangeVisuals changeVisuals;
  final ChangeVisualsTrendData trendData;
  final VoidCallback onToggleArrow;
  final VoidCallback onToggleColor;

  const ChangeVisualsGrowthCard({
    super.key,
    required this.kind,
    required this.changeVisuals,
    required this.trendData,
    required this.onToggleArrow,
    required this.onToggleColor,
  });

  bool get _isIncome => kind == ChangeVisualsGrowthKind.income;

  String _titleKey(BuildContext context) => _isIncome
      ? "preferences.changeVisuals.incomeIncrease".t(context)
      : "preferences.changeVisuals.expenseIncrease".t(context);

  String _badgeKey(BuildContext context) => _isIncome
      ? "preferences.changeVisuals.incomeIncrease.badge".t(context)
      : "preferences.changeVisuals.expenseIncrease.badge".t(context);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double iconSize = IconTheme.of(context).size ?? 24.0;

    final bool upArrow = _isIncome
        ? changeVisuals.incomeIncreaseUpArrow
        : changeVisuals.expenseIncreaseUpArrow;
    final bool primaryColor = _isIncome
        ? changeVisuals.incomeIncreaseGreen
        : changeVisuals.expenseIncreaseRed;

    final Color swatchColor = _isIncome
        ? (primaryColor ? context.flowColors.income : context.flowColors.expense)
        : (primaryColor ? context.flowColors.expense : context.flowColors.income);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChangeVisualsPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(ChangeVisualsPreferencesTheme.cardRadius),
        border: Border.all(color: ChangeVisualsPreferencesTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: ChangeVisualsPreferencesTheme.iconPlateFill(context),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isIncome
                        ? Symbols.trending_up_rounded
                        : Symbols.warning_rounded,
                    size: 24.0,
                    color: ChangeVisualsPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trendData.hasComparison) ...[
                        Text(
                          _badgeKey(context),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ChangeVisualsPreferencesTheme.badgeInk,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                      ],
                      Text(
                        _titleKey(context),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                          color: ChangeVisualsPreferencesTheme.titleInk,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trendData.hasComparison)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Trend.fromMoney(
                        previous: _isIncome
                            ? trendData.incomePrevious
                            : trendData.expensePrevious,
                        current: _isIncome
                            ? trendData.incomeCurrent
                            : trendData.expenseCurrent,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        "preferences.changeVisuals.vsLastMonth".t(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ChangeVisualsPreferencesTheme.subtitleInk,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14.0),
            if (_isIncome) ...[
              const _DecorativeBarChart(),
              const SizedBox(height: 14.0),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                color: ChangeVisualsPreferencesTheme.chartTrack,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _PickerTile(
                        label: "preferences.changeVisuals.arrow".t(context),
                        onTap: onToggleArrow,
                        child: Icon(
                          upArrow
                              ? Symbols.stat_1_rounded
                              : Symbols.stat_minus_1_rounded,
                          size: iconSize,
                          color: ChangeVisualsPreferencesTheme.titleInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _PickerTile(
                        label: "preferences.changeVisuals.color".t(context),
                        onTap: onToggleColor,
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: swatchColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Material(
              color: _isIncome
                  ? ChangeVisualsPreferencesTheme.actionButtonFill(context)
                  : ChangeVisualsPreferencesTheme.actionButtonMutedFill,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "preferences.changeVisuals.clickToChange".t(context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                    color: _isIncome
                        ? ChangeVisualsPreferencesTheme.primary(context)
                        : ChangeVisualsPreferencesTheme.titleInk,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const _PickerTile({
    required this.label,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChangeVisualsPreferencesTheme.cardFill,
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          child: Column(
            children: [
              child,
              const SizedBox(height: 8.0),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ChangeVisualsPreferencesTheme.subtitleInk,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorativeBarChart extends StatelessWidget {
  const _DecorativeBarChart();

  @override
  Widget build(BuildContext context) {
    const List<double> heights = [0.35, 0.5, 0.68, 1.0];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChangeVisualsPreferencesTheme.chartTrack,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
        child: SizedBox(
          height: 72.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < heights.length; i++) ...[
                if (i > 0) const SizedBox(width: 12.0),
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: heights[i],
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: i == heights.length - 1
                            ? ChangeVisualsPreferencesTheme.chartBarActive(context)
                            : ChangeVisualsPreferencesTheme.chartBarMuted,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
