import "package:flow/l10n/extensions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ExportHeroHeader extends StatelessWidget {
  const ExportHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ExportOptionsTheme.rangeSummaryFill,
          borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
          border: Border.all(color: ExportOptionsTheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "sync.export.heroTitle".t(context),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: ExportOptionsTheme.titleInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 20.0,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      "sync.export.heroSubtitle".t(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ExportOptionsTheme.mutedInk,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                width: 56.0,
                height: 56.0,
                decoration: const BoxDecoration(
                  color: kFlowSetupAddCategoryIconPlateFill,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Symbols.ios_share_rounded,
                  size: 28.0,
                  color: ExportOptionsTheme.primary(context),
                  fill: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
