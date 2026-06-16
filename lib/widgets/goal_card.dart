import "package:flow/data/goalProgress.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class GoalCard extends StatelessWidget {
  final GoalProgress progress;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = progress.fraction >= 1.0;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final Color accentColor = completed ? colors.primary : colors.primary;

    return Surface(
      color: Theme.of(context).cardColor,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      builder: (context) => InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRing(context, colors),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.goal.name,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          progress.goal.accountUuid != null
                              ? "Savings Account"
                              : "Goal",
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBadge(context, completed, colors, text),
                ],
              ),
              const SizedBox(height: 16.0),
              if (!completed) ...[
                Text(
                  "SAVED",
                  style: text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          MoneyText(
                            progress.saved,
                            displayAbsoluteAmount: true,
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            " / ",
                            style: text.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          MoneyText(
                            progress.target,
                            displayAbsoluteAmount: true,
                            style: text.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${progress.percent.round()}%",
                      style: text.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: MoneyText(
                        progress.target,
                        displayAbsoluteAmount: true,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Symbols.check_circle_rounded,
                      color: accentColor,
                      size: 28.0,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10.0),
              Container(
                height: 10.0,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress.fraction.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              if (!completed && progress.suggestedMonthlySave != null)
                Row(
                  children: [
                    Icon(
                      Symbols.schedule_rounded,
                      size: 14.0,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      "~\$${progress.suggestedMonthlySave!.toStringAsFixed(0)}/mo needed to reach goal",
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              if (completed)
                Text(
                  "TARGET ACHIEVED",
                  style: text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRing(BuildContext context, ColorScheme colors) {
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.fraction.clamp(0.0, 1.0),
            strokeWidth: 3.0,
            backgroundColor: colors.surfaceContainerHighest,
            color: colors.primary,
          ),
          Center(
            child: FlowIcon(progress.goal.icon, size: 22.0),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    bool completed,
    ColorScheme colors,
    TextTheme text,
  ) {
    final String label = completed ? "COMPLETED" : "ACTIVE";
    final Color badgeColor = completed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE68A00);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
