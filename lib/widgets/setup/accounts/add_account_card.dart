import "package:dashed_border/dashed_border.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// “Add new account” — pill, dashed light-gray border, soft shadow, centered
/// primary-blue outlined plus + label (see setup accounts design).
class AddAccountCard extends StatelessWidget {
  /// Fully rounded pill (large radius).
  static final BorderRadius pillRadius = BorderRadius.circular(999.0);

  const AddAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final bool light = scheme.brightness == Brightness.light;

    final Color cardFill =
        light ? const Color.fromRGBO(255, 255, 255, 1.0) : scheme.surfaceContainerHigh;
    final Color primary = scheme.primary;

    final List<BoxShadow> shadows = light
        ? const [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 0,
              color: kFlowSetupAccountCardShadow,
            ),
          ]
        : [
            BoxShadow(
              color: scheme.shadow.withAlpha(0x22),
              blurRadius: 12.0,
              offset: const Offset(0.0, 2.0),
            ),
          ];

    final Color dashColor = light
        ? const Color(0xFFCBD5E1)
        : scheme.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => context.push("/account/new"),
          borderRadius: pillRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: cardFill,
              borderRadius: pillRadius,
              border: DashedBorder(
                color: dashColor,
                width: 1.0,
                borderRadius: pillRadius,
                dashLength: 4.0,
                dashGap: 3.5,
              ),
              boxShadow: shadows,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlinedPlusIcon(color: primary),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      "setup.accounts.addAccount".t(context),
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plus inside a circular stroke (primary), matching the reference.
class _OutlinedPlusIcon extends StatelessWidget {
  const _OutlinedPlusIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.0,
      height: 28.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Icon(
            Symbols.add_rounded,
            size: 18.0,
            color: color,
            fill: 0.0,
          ),
        ),
      ),
    );
  }
}
