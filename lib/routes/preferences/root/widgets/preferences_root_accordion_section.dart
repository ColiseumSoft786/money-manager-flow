import "package:animated_accordion/animated_accordion.dart";
import "package:flow/routes/preferences/root/preferences_root_theme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

class PreferencesRootAccordionSection extends StatelessWidget {
  /// Compact row (title only), matches [PreferencesRootNavRow] without subtitle.
  static const double rowHeight = 68.0;

  /// Row with a subtitle line.
  static const double rowHeightWithSubtitle = 76.0;

  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isInitiallyExpanded;

  /// When null, height is derived from [itemCount] or [children.length].
  final double? contentHeight;

  /// Use when [children] are composite widgets (e.g. Privacy) instead of rows.
  final int? itemCount;

  /// Use `true` when most rows show a subtitle (taller).
  final bool tallRows;

  const PreferencesRootAccordionSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.isInitiallyExpanded = false,
    this.contentHeight,
    this.itemCount,
    this.tallRows = false,
  });

  static double heightForRows(
    int count, {
    bool tallRows = false,
    double extra = 4.0,
  }) {
    if (count <= 0) return 0;
    final double perRow = tallRows ? rowHeightWithSubtitle : rowHeight;
    return count * perRow + extra;
  }

  double _resolvedContentHeight() {
    if (contentHeight != null) return contentHeight!;
    final int rows = itemCount ?? children.length;
    return heightForRows(rows, tallRows: tallRows);
  }

  static const ShapeBorder _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(PreferencesRootTheme.cardRadius)),
    side: BorderSide(color: PreferencesRootTheme.cardBorder),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final accent = context.flowAccent;

    return AnimatedAccordion(
      isInitiallyExpanded: isInitiallyExpanded,
      headerTitle: title,
      contentWidgets: children,
      contentHeight: _resolvedContentHeight(),
      contentAnimationType: AnimatedAccordionAnimationType.slideFade,
      animationDuration: const Duration(milliseconds: 280),
      collapsedTileElevation: 0.0,
      expandedTileElevation: 0.0,
      headerElevation: 0.0,
      tileBackgroundColor: PreferencesRootTheme.cardFill,
      headerBackgroundColor: PreferencesRootTheme.cardFill,
      contentBackgroundColor: PreferencesRootTheme.cardFill,
      headerTextColor: PreferencesRootTheme.titleInk,
      headerPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      contentPadding: EdgeInsets.zero,
      headerTitleStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: PreferencesRootTheme.titleInk,
      ),
      tileShape: _cardShape,
      headerShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PreferencesRootTheme.cardRadius),
        ),
        side: BorderSide(color: Colors.transparent),
      ),
      contentBorderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(PreferencesRootTheme.cardRadius),
      ),
      contentBorder: const Border(
        top: BorderSide(color: PreferencesRootTheme.divider),
      ),
      headerLeading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: accent.iconPlateFill,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22.0,
          color: accent.iconPlateInk,
          fill: 0.0,
        ),
      ),
      expandedHeaderLeading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: accent.iconPlateFill,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22.0,
          color: accent.iconPlateInk,
          fill: 0.0,
        ),
      ),
    );
  }
}
