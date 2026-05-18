import "package:flow/routes/preferences/root/preferences_root_theme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flutter/material.dart";

class PreferencesRootNavRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const PreferencesRootNavRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                            color: PreferencesRootTheme.titleInk,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: PreferencesRootTheme.subtitleInk,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const LeChevron(),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 70.0,
            endIndent: 14.0,
            color: PreferencesRootTheme.divider,
          ),
      ],
    );
  }
}

class PreferencesRootIconPlate extends StatelessWidget {
  final Widget child;

  const PreferencesRootIconPlate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.0,
      height: 44.0,
      decoration: BoxDecoration(
        color: context.flowAccent.iconPlateFill,
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class PreferencesRootSymbolIcon extends StatelessWidget {
  final IconData icon;

  const PreferencesRootSymbolIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return PreferencesRootIconPlate(
      child: Icon(
        icon,
        size: 24.0,
        color: context.flowAccent.iconPlateInk,
        fill: 0.0,
      ),
    );
  }
}
