import "package:flow/l10n/extensions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class ExportQuickLinks extends StatelessWidget {
  const ExportQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickLinkCard(
            icon: Symbols.data_object_rounded,
            iconColor: const Color(0xFF0EA5E9),
            iconFill: const Color(0xFFE0F2FE),
            title: "sync.export.asJSON".t(context),
            subtitle: "sync.export.quick.jsonHint".t(context),
            onTap: () => context.push("/export/json"),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _QuickLinkCard(
            icon: Symbols.history_rounded,
            iconColor: const Color(0xFF64748B),
            iconFill: const Color(0xFFF1F5F9),
            title: "sync.export.history".t(context),
            subtitle: "sync.export.quick.historyHint".t(context),
            onTap: () => context.push("/export/history"),
          ),
        ),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconFill;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.iconColor,
    required this.iconFill,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: ExportOptionsTheme.cardFill(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
        side: BorderSide(color: ExportOptionsTheme.cardBorder(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: iconFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22.0, color: iconColor, fill: 0.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.0,
                  color: ExportOptionsTheme.titleInk(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ExportOptionsTheme.mutedInk(context),
                  fontSize: 11.0,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
