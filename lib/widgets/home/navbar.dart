import "dart:ui";

import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/home/navbar/navbar_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Bar height excluding the system safe-area (handled by [BottomAppBar]).
const double kNavbarBarHeight = 66.0;

/// Extra scroll padding for tab content when the home scaffold uses
/// `extendBody: true` so lists clear the frosted bar.
const double kNavbarBodyBottomInset = 88.0;

/// Material [BottomAppBar] with centered FAB notch (`CircularNotchedRectangle`).
/// Frosted "liquid glass" fill via [BackdropFilter] (iOS-style tab bar).
class Navbar extends StatelessWidget {
  final Function(int i) onTap;

  final int activeIndex;

  const Navbar({super.key, required this.onTap, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final Color glassFill = light
        ? Colors.white.withValues(alpha: 0.72)
        : theme.colorScheme.surface.withValues(alpha: 0.78);
    final Color glassBorder = light
        ? Colors.black.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.1);

    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0.0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 11.0,
      height: kNavbarBarHeight,
      clipBehavior: Clip.antiAlias,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: glassFill,
              border: Border(top: BorderSide(color: glassBorder, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NavbarButton(
                  index: 0,
                  tooltip: "tabs.home".t(context),
                  label: "tabs.home".t(context),
                  icon: Symbols.home_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                NavbarButton(
                  index: 1,
                  tooltip: "tabs.stats".t(context),
                  label: "tabs.stats".t(context),
                  icon: Symbols.pie_chart_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                const SizedBox(width: 68.0),
                NavbarButton(
                  index: 2,
                  tooltip: "tabs.accounts".t(context),
                  label: "tabs.accounts".t(context),
                  icon: Symbols.account_balance_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
                NavbarButton(
                  index: 3,
                  tooltip: "tabs.profile".t(context),
                  label: "tabs.profile".t(context),
                  icon: Symbols.person_rounded,
                  onTap: onTap,
                  activeIndex: activeIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
