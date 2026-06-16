import "package:flow/routes/export/export_options_theme.dart";
import "package:flutter/material.dart";

class ExportSectionHeader extends StatelessWidget {
  final String label;

  const ExportSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 22.0, 2.0, 10.0),
      child: Row(
        children: [
          Container(
            width: 3.0,
            height: 14.0,
            decoration: BoxDecoration(
              color: ExportOptionsTheme.primary(context),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ExportOptionsTheme.sectionLabel(context),
              fontWeight: FontWeight.w800,
              fontSize: 11.0,
              letterSpacing: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
