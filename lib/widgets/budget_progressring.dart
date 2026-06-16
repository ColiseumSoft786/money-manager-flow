
import "package:flow/data/budgetProgress.dart";
import "package:flutter/material.dart";

class BudgetProgressRing extends StatelessWidget {
  final BudgetProgress progress;
  final double size;

  const BudgetProgressRing({
    super.key,
    required this.progress,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color = progress.isCritical
        ? scheme.error
        : progress.shouldAlert
        ? scheme.tertiary
        : scheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.fraction.clamp(0, 1),
            strokeWidth: 4,
            backgroundColor: scheme.surfaceContainerHighest,
            color: color,
          ),
          Center(
            child: Text(
              "${progress.percent.round()}%",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}