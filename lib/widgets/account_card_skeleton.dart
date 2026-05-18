import "package:dashed_border/dashed_border.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/home/accounts/accounts_tab_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

enum AccountCardSkeletonStyle { classic, accountsTab }

class AccountCardSkeleton extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final AccountCardSkeletonStyle style;

  const AccountCardSkeleton({
    super.key,
    this.onTap,
    this.borderRadius = const .all(Radius.circular(24.0)),
    this.style = AccountCardSkeletonStyle.classic,
  });

  @override
  Widget build(BuildContext context) {
    if (style == AccountCardSkeletonStyle.accountsTab) {
      final BorderRadius radius = BorderRadius.circular(
        AccountsTabTheme.cardRadius,
      );

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            decoration: BoxDecoration(
              color: AccountsTabTheme.addCardFill,
              borderRadius: radius,
              border: DashedBorder(
                color: AccountsTabTheme.addCardBorder,
                width: 1.5,
                borderRadius: radius,
                dashLength: 6.0,
                dashGap: 4.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AccountsTabTheme.iconPlateFill(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.add_rounded,
                    size: 26.0,
                    color: AccountsTabTheme.primary(context),
                    weight: 600.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "account.new".t(context),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AccountsTabTheme.primary(context),
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          height: 179.0,
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "account.new".t(context),
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                const Icon(
                  Symbols.add_rounded,
                  size: 40.0,
                  weight: 600.0,
                  opticalSize: 40.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
