import "package:flow/data/budgetProgress.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback? onTap;

  const BudgetCard({
    super.key,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    final Color accentColor = progress.isCritical
        ? colors.error
        : progress.shouldAlert
            ? const Color(0xFFE68A00)
            : colors.primary;

    final List<String> categoryNames =
        progress.budget.categories.map((c) => c.name).toList();
    final String subtitle =
        categoryNames.isEmpty ? "" : categoryNames.join(" & ");

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (progress.budget.categories.isNotEmpty)
                    FlowIcon(
                      progress.budget.categories.first.icon,
                      size: 40.0,
                      plated: true,
                    )
                  else
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.account_balance_wallet_rounded,
                        size: 22.0,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.budget.name,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            subtitle,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Symbols.edit_rounded,
                    size: 20.0,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      MoneyText(
                        progress.spent,
                        displayAbsoluteAmount: true,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        " spent",
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "of ",
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      MoneyText(
                        progress.limit,
                        displayAbsoluteAmount: true,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              _buildStatusText(context, colors, text, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(
    BuildContext context,
    ColorScheme colors,
    TextTheme text,
    Color accentColor,
  ) {
    if (progress.isCritical) {
      return Row(
        children: [
          Icon(Symbols.warning_rounded, size: 16.0, color: accentColor),
          const SizedBox(width: 4.0),
          Text(
            "Over limit",
            style: text.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (progress.shouldAlert) {
      return Row(
        children: [
          Icon(Symbols.warning_rounded, size: 16.0, color: accentColor),
          const SizedBox(width: 4.0),
          Text(
            "Near limit",
            style: text.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          "You have ",
          style: text.bodySmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        MoneyText(
          progress.remaining,
          displayAbsoluteAmount: true,
          style: text.bodySmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          " left",
          style: text.bodySmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
