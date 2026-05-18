import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// Shared header for [SetupProfilePage] and [SetupProfilePhotoPage].
/// Colors come from `flow_color_scheme.dart` (+ theme); no literals here.
class SetupProfileStepHeader extends StatelessWidget {
  final int step;
  final int total;
  final String headline;
  final String description;

  const SetupProfileStepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.headline,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color primary = context.colorScheme.primary;
    final ColorScheme scheme = context.colorScheme;

    final Color chipBg = light
        ? Color.alphaBlend(primary.withValues(alpha: 0.12), Colors.white)
        : primary.withValues(alpha: 0.18);
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : scheme.onSurface;

    final Color trackColor = light
        ? kFlowSetupProfileProgressTrackLight
        : scheme.outlineVariant.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(999.0),
          ),
          child: Text(
            "setup.profile.stepOf".t(
              context,
              {"index": "$step", "total": "$total"},
            ),
            style: context.textTheme.labelLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 14.0),
        Row(
          children: [
            for (int i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 8.0),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: SizedBox(
                    height: 5.0,
                    child: LinearProgressIndicator(
                      value: i < step ? 1.0 : 0.0,
                      backgroundColor: trackColor,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20.0),
        Text(
          headline,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: titleColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: kFlowPopularCurrenciesSectionHeading,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
