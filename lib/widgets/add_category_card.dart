import "package:dashed_border/dashed_border.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Setup categories — dashed outline card prompting custom category creation.
class AddCategoryCard extends StatelessWidget {
  final VoidCallback? onTapOverride;

  const AddCategoryCard({super.key, this.onTapOverride});

  static final BorderRadius borderRadius =
      BorderRadius.circular(14.0);

  void _navigate(BuildContext context) {
    final VoidCallback action =
        onTapOverride ?? (() => context.push("/category/new"));
    action();
  }
  

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color fill = light
        ? kFlowSetupAddCategoryCardFill
        : context.colorScheme.surfaceContainerHighest;
    final Color dashColor = light
        ? kFlowSetupAddCategoryCardDashBorder
        : context.colorScheme.primary.withValues(alpha: 0.55);
    final Color plateBg = light
        ? kFlowSetupAddCategoryIconPlateFill
        : context.colorScheme.primary.withValues(alpha: 0.22);
    final Color iconFg = light
        ? kFlowSetupPrimaryCurrencyInfoTitle
        : context.colorScheme.primary;
    final Color titleColor = light
        ? kFlowAccountEditTitleColor
        : context.colorScheme.onSurface;
    final Color subtitleColor =
        context.colorScheme.onSurface.withValues(alpha: light ? 0.62 : 0.65);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: borderRadius,
          border: DashedBorder(
            color: dashColor,
            width: 1.5,
            borderRadius: borderRadius,
            dashLength: 5.0,
            dashGap: 4.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: plateBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Symbols.add_rounded,
                size: 28.0,
                color: iconFg,
                fill: 0.0,
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              "category.new".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              "setup.categories.addCardSubtitle".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22.0),
            Button(
              fullWidth: true,
              borderRadius: BorderRadius.circular(12.0),
              backgroundColor: light
                  ? kFlowSetupAccountsContinueButtonFill
                  : context.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: light ? 3.0 : 2.0,
              shadowColor: (light
                      ? kFlowSetupAccountsContinueButtonFill
                      : context.colorScheme.primary)
                  .withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              onTap: () => _navigate(context),
              child: Text(
                "setup.categories.addNewButton".t(context),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
