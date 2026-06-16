import "package:flow/routes/import/import_page_theme.dart";
import "package:flutter/material.dart";

class ImportSectionHeader extends StatelessWidget {
  final String label;

  const ImportSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 12.0),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ImportPageTheme.sectionLabel(context),
          fontWeight: FontWeight.w700,
          fontSize: 11.0,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
