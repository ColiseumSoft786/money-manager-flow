import "package:flow/l10n/extensions.dart";
import "package:flow/theme/navbar_theme.dart";
import "package:flow/widgets/home/navbar/navbar_button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Material [BottomAppBar] with centered FAB notch (`CircularNotchedRectangle`).
/// Matches the docked FAB + segmented tab layout — no external package needed.
class Navbar extends StatelessWidget {
  final Function(int i) onTap;

  final int activeIndex;

  const Navbar({super.key, required this.onTap, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color barBg = light ? Colors.white : navbarTheme.backgroundColor;
    final Color topLine = light
        ? const Color(0xFFE8E8E8)
        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1.0, thickness: 1.0, color: topLine),
        BottomAppBar(
          padding: EdgeInsets.zero,
          color: barBg,
          elevation: 0.0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 11.0,
          height: 66.0,
          clipBehavior: Clip.antiAlias,
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
      ],
    );
  }
}
