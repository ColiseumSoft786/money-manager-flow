import "package:flow/routes/import/import_page_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ImportOptionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ImportOptionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: ImportPageTheme.cardFill,
        elevation: 0,
        shadowColor: ImportPageTheme.cardShadow.first.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImportPageTheme.cardRadius),
          side: const BorderSide(color: ImportPageTheme.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ImportPageTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: ImportPageTheme.titleInk,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ImportPageTheme.subtitleInk,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: ImportPageTheme.chevronInk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImportOptionIconPlate extends StatelessWidget {
  final Color fill;
  final Widget child;

  const ImportOptionIconPlate({
    super.key,
    required this.fill,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.0,
      height: 44.0,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
