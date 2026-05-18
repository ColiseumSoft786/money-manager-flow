import "package:flow/l10n/extensions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flow/sync/export/mode.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ExportFormatSelector extends StatelessWidget {
  final ExportMode selected;
  final ValueChanged<ExportMode> onSelected;

  const ExportFormatSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<ExportMode> _modes = [
    ExportMode.csv,
    ExportMode.zip,
    ExportMode.pdf,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _modes.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          _FormatTile(
            mode: _modes[i],
            selected: selected == _modes[i],
            onTap: () => onSelected(_modes[i]),
          ),
        ],
      ],
    );
  }
}

class _FormatTile extends StatelessWidget {
  final ExportMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _FormatTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  ({IconData icon, Color accent, Color plate, String title, String description})
  _data(BuildContext context) => switch (mode) {
    ExportMode.csv => (
      icon: Symbols.table_chart_rounded,
      accent: ExportOptionsTheme.csvAccent,
      plate: ExportOptionsTheme.csvPlate,
      title: "sync.export.asCSV".t(context),
      description: "sync.export.asCSV.description".t(context),
    ),
    ExportMode.zip => (
      icon: Symbols.folder_rounded,
      accent: ExportOptionsTheme.zipAccent,
      plate: ExportOptionsTheme.zipPlate,
      title: "sync.export.asZIP".t(context),
      description: "sync.export.asZIP.description".t(context),
    ),
    ExportMode.pdf => (
      icon: Symbols.picture_as_pdf_rounded,
      accent: ExportOptionsTheme.pdfAccent,
      plate: ExportOptionsTheme.pdfPlate,
      title: "sync.export.asPDF".t(context),
      description: "sync.export.asPDF.description".t(context),
    ),
    ExportMode.json => (
      icon: Symbols.data_object_rounded,
      accent: ExportOptionsTheme.primary(context),
      plate: ExportOptionsTheme.rangeSummaryFill,
      title: "sync.export.asJSON".t(context),
      description: "sync.export.asJSON.description".t(context),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final data = _data(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: ExportOptionsTheme.cardFill,
        borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
        border: Border.all(
          color: selected ? data.accent : ExportOptionsTheme.cardBorder,
          width: selected ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: data.plate,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    data.icon,
                    size: 26.0,
                    color: data.accent,
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                          color: ExportOptionsTheme.titleInk,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        data.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ExportOptionsTheme.mutedInk,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? data.accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? data.accent
                          : const Color(0xFFCBD5E1),
                      width: 2.0,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Symbols.check_rounded,
                          size: 16.0,
                          color: Colors.white,
                          fill: 1,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
