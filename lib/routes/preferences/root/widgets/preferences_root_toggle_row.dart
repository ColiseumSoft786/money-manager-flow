import "package:flow/routes/preferences/root/preferences_root_theme.dart";
import "package:flow/theme/flow_accent_colors.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

class PreferencesRootToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  const PreferencesRootToggleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FlowAccentColors accent = context.flowAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: accent.iconPlateFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 24.0,
                  color: accent.iconPlateInk,
                  fill: 0.0,
                ),
              ),
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
                        color: PreferencesRootTheme.titleInk(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PreferencesRootTheme.subtitleInk(context),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: accent.primary,
                inactiveTrackColor:
                    PreferencesRootTheme.switchInactiveTrack(context),
                thumbColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 70.0,
            endIndent: 14.0,
            color: PreferencesRootTheme.divider(context),
          ),
      ],
    );
  }
}
