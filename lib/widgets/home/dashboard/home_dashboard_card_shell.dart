import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Compact titled glass container for optional Home dashboard cards.
class HomeDashboardCardShell extends StatelessWidget {
  final String titleKey;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;

  const HomeDashboardCardShell({
    super.key,
    required this.titleKey,
    required this.child,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(22.0)),
      padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titleKey.t(context),
                  style: context.textTheme.titleSmall?.semi(context).copyWith(
                    letterSpacing: 0.1,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              ?trailing,
              if (onTap != null) ...[
                const SizedBox(width: 4.0),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 20.0,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }
}
