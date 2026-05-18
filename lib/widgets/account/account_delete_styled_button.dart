import "dart:math" as math;

import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Figma-style delete control: max width [kFlowAccountEditNameFieldMaxWidth], height 56,
/// rose fill / border, centered outlined trash + label.
class AccountDeleteStyledButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget label;

  const AccountDeleteStyledButton({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final ColorScheme scheme = context.colorScheme;

    final Color fill = light
        ? kFlowAccountDeleteCardFill
        : scheme.errorContainer.withAlpha(0x66);
    final Color borderColor = light
        ? kFlowAccountDeleteCardBorder
        : scheme.error.withAlpha(0x55);
    final double borderWidth = light
        ? kFlowAccountDeleteCardBorderWidth
        : 1.0;
    final Color fg = light
        ? kFlowAccountDeleteCardForeground
        : scheme.error;

    final double maxWidth = math.min(
      kFlowAccountEditNameFieldMaxWidth,
      MediaQuery.sizeOf(context).width - 40.0,
    );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          height: kFlowAccountEditNameFieldHeight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.delete_outline_rounded,
                        size: 22.0,
                        color: fg,
                        fill: 0.0,
                      ),
                      const SizedBox(width: 8.0),
                      DefaultTextStyle(
                        style: context.textTheme.titleMedium!.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        child: label,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
