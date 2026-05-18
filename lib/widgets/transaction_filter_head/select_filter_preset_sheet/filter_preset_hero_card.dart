import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Highlights the active preset in the filter preset sheet (pastel fill, star
/// plate, primary check badge) — mirrors the homepage bottom-sheet mockup.
class FilterPresetHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showFavoriteStar;

  const FilterPresetHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showFavoriteStar,
  });

  static const Color _fillLight = Color(0xFFE8F0FE);
  static const Color _fillDark = Color(0xFF1A3050);
  static const Color _borderLight = Color(0xFFB9CEF5);
  static const Color _borderDark = Color(0xFF3D5A80);
  static const Color _iconPlateLight = Color(0xFFD4E7FC);
  static const Color _iconPlateDark = Color(0xFF254565);

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color fill = light ? _fillLight : _fillDark;
    final Color border = light ? _borderLight : _borderDark;
    final Color iconPlate = light ? _iconPlateLight : _iconPlateDark;
    final Color ink = light
        ? const Color(0xFF0F172A)
        : Theme.of(context).colorScheme.onSurface;
    final Color subtitleInk = light
        ? const Color(0xFF64748B)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 14.0),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: border, width: 1.0),
        boxShadow: light
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(37, 99, 235, 0.06),
                  blurRadius: 10.0,
                  offset: Offset(0.0, 4.0),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.0,
            height: 46.0,
            decoration: BoxDecoration(
              color: iconPlate,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              showFavoriteStar
                  ? Symbols.star_rounded
                  : Symbols.star_outline_rounded,
              color: kFlowSetupPrimaryCurrencyInfoTitle,
              size: 26.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtitleInk,
                        height: 1.35,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kFlowSetupPrimaryCurrencyInfoTitle,
              boxShadow: light
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(37, 140, 244, 0.35),
                        blurRadius: 6.0,
                        offset: Offset(0.0, 2.0),
                      ),
                    ]
                  : null,
            ),
            child: const Icon(
              Symbols.check_rounded,
              size: 18.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
