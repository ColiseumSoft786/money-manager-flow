import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/list_tile_appearance/list_tile_appearance_theme.dart";
import "package:flutter/material.dart";

class ListTileLeadingSegment extends StatelessWidget {
  final bool showAccountForLeading;
  final ValueChanged<bool> onChanged;

  const ListTileLeadingSegment({
    super.key,
    required this.showAccountForLeading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ListTileAppearanceTheme.segmentTrack,
        borderRadius: BorderRadius.circular(ListTileAppearanceTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: _SegmentOption(
                label: "preferences.transactions.listTile.leading.category".t(
                  context,
                ),
                selected: !showAccountForLeading,
                onTap: () => onChanged(false),
              ),
            ),
            Expanded(
              child: _SegmentOption(
                label: "preferences.transactions.listTile.leading.account".t(
                  context,
                ),
                selected: showAccountForLeading,
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ListTileAppearanceTheme.cardFill : Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: selected
                    ? ListTileAppearanceTheme.titleInk
                    : ListTileAppearanceTheme.subtitleInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
