import "package:flow/theme/navbar_theme.dart";
import "package:flutter/material.dart";

class NavbarButton extends StatelessWidget {
  final String tooltip;
  final String label;
  final IconData icon;

  final int index;
  final int activeIndex;

  final Function(int) onTap;

  bool get isActive => index == activeIndex;

  const NavbarButton({
    super.key,
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Color active = navbarTheme.activeIconColor;
    final Color inactive = scheme.onSurfaceVariant;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Material(
          type: MaterialType.transparency,
          color: Colors.transparent,
          child: InkWell(
            splashColor: active.withValues(alpha: 0.08),
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 23.0,
                      color: isActive ? active : inactive,
                      fill: isActive ? 1.0 : 0.0,
                      weight: isActive ? 600.0 : 400.0,
                    ),
                    const SizedBox(height: 3.0),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style:
                          Theme.of(context).textTheme.labelSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 11.0,
                                height: 1.15,
                                color: isActive ? active : inactive,
                              ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
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
