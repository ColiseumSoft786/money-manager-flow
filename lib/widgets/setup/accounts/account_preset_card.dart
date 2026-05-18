import "package:flow/data/setup/default_accounts.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountPresetCard extends StatelessWidget {
  final Function(bool)? onSelect;
  final bool selected;

  final bool preexisting;

  final Account account;

  final BorderRadius borderRadius;

  /// Pencil — opens edit flow; does not toggle preset selection ([IconButton] absorbs tap).
  final VoidCallback onEditPressed;

  const AccountPresetCard({
    super.key,
    required this.account,
    required this.onSelect,
    required this.selected,
    required this.preexisting,
    required this.onEditPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final bool light = scheme.brightness == Brightness.light;

    final Color cardFill =
        light ? const Color.fromRGBO(255, 255, 255, 1.0) : scheme.surfaceContainerHigh;
    final Color borderColor =
        light ? kFlowSetupAccountCardBorder : scheme.outlineVariant;

    final _PlateColors plate = _plateColors(context, account.uuid);

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
              color: scheme.shadow.withAlpha(selected ? 0x33 : 0x22),
              blurRadius: 12.0,
              offset: const Offset(0.0, 2.0),
            ),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect == null ? null : () => onSelect!(!selected),
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: cardFill,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: shadows,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: plate.background,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: FlowIcon(
                        account.icon,
                        size: 24.0,
                        color: plate.foreground,
                        fill: 1.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: light
                                ? const Color(0xFF0F172A)
                                : scheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _subtitle(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: light
                                ? kFlowPopularCurrenciesSectionHeading
                                : context.popularCurrenciesSectionHeadingColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 13.0,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onEditPressed,
                  icon: DecoratedBox(
                    decoration: BoxDecoration(
                      color: light
                          ? kFlowPopularCurrencySymbolPlate
                          : scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Symbols.edit_rounded,
                        size: 20.0,
                        color: light
                            ? kFlowPopularCurrenciesSectionHeading
                            : scheme.onSurfaceVariant,
                        fill: 0.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    switch (account.uuid) {
      case kAccountPresetUuidMain:
        return "setup.accounts.preset.mainSubtitle".t(context);
      case kAccountPresetUuidCash:
        return "setup.accounts.preset.cashSubtitle".t(context);
      case kAccountPresetUuidSavings:
        return "setup.accounts.preset.savingsSubtitle".t(context);
      default:
        return account.balance.formatMoney();
    }
  }
}

class _PlateColors {
  const _PlateColors({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}

/// Light mode uses fixed tints (bank / cash / savings); dark mode follows theme.
_PlateColors _plateColors(BuildContext context, String uuid) {
  final ColorScheme scheme = context.colorScheme;
  final bool light = scheme.brightness == Brightness.light;

  if (light) {
    switch (uuid) {
      case kAccountPresetUuidMain:
        return const _PlateColors(
          foreground: Color(0xFF2563EB),
          background: Color(0xFFEFF6FF),
        );
      case kAccountPresetUuidCash:
        return const _PlateColors(
          foreground: Color(0xFFEA580C),
          background: Color(0xFFFFF7ED),
        );
      case kAccountPresetUuidSavings:
        return const _PlateColors(
          foreground: Color(0xFF16A34A),
          background: Color(0xFFF0FDF4),
        );
      default:
        break;
    }
  }

  final Color primary = scheme.primary;
  final Color income = context.flowColors.income;
  final Color expense = context.flowColors.expense;

  switch (uuid) {
    case kAccountPresetUuidMain:
      return _PlateColors(
        foreground: primary,
        background: primary.withAlpha(0x26),
      );
    case kAccountPresetUuidCash:
      return _PlateColors(
        foreground: expense,
        background: expense.withAlpha(0x26),
      );
    case kAccountPresetUuidSavings:
      return _PlateColors(
        foreground: income,
        background: income.withAlpha(0x26),
      );
    default:
      return _PlateColors(
        foreground: primary,
        background: scheme.surfaceContainerHighest,
      );
  }
}
