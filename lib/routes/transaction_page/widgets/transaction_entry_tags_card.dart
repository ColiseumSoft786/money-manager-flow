import "package:flow/entity/transaction/extensions/default/geo.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/providers/transaction_tags_provider.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/transaction_tag_add_chip.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:latlong2/latlong.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntryTagsCard extends StatefulWidget {
  final List<TransactionTag>? selectedTags;
  final VoidCallback selectTags;
  final ValueChanged<List<TransactionTag>> onTagsChanged;
  final Geo? location;
  final bool wrapInCard;

  const TransactionEntryTagsCard({
    super.key,
    this.selectedTags,
    required this.selectTags,
    required this.onTagsChanged,
    this.location,
    this.wrapInCard = true,
  });

  @override
  State<TransactionEntryTagsCard> createState() =>
      _TransactionEntryTagsCardState();
}

class _TransactionEntryTagsCardState extends State<TransactionEntryTagsCard> {
  List<TransactionTag>? _suggestedGeoTags;

  @override
  void initState() {
    super.initState();
    _refreshSuggestions();
  }

  @override
  void didUpdateWidget(covariant TransactionEntryTagsCard oldWidget) {
    if (widget.location != oldWidget.location ||
        widget.selectedTags != oldWidget.selectedTags) {
      _refreshSuggestions();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _refreshSuggestions() {
    _suggestedGeoTags = switch (widget.location?.toLatLngPosition()) {
      LatLng latLng => TransactionTagsProvider.of(
        context,
      ).getCloseGeoTags(latLng, exclusionList: widget.selectedTags),
      _ => null,
    };
  }

  String? _summary(BuildContext context) {
    final List<TransactionTag>? tags = widget.selectedTags;
    if (tags == null || tags.isEmpty) return null;
    if (tags.length == 1) return tags.first.title;
    return "transaction.tags.selectedCount".t(context, tags.length);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasTags = widget.selectedTags?.isNotEmpty == true;
    final bool hasSuggestions = _suggestedGeoTags?.isNotEmpty == true;

    final Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (LocalPreferences().enableHapticFeedback.get()) {
                    HapticFeedback.lightImpact();
                  }
                  widget.selectTags();
                },
                borderRadius: BorderRadius.circular(
                  widget.wrapInCard
                      ? TransactionEntryTheme.cardRadius
                      : 0.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 13.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: TransactionEntryTheme.iconPlateSize,
                        height: TransactionEntryTheme.iconPlateSize,
                        decoration: BoxDecoration(
                          color: TransactionEntryTheme.iconPlateFill(context),
                          borderRadius: BorderRadius.circular(
                            TransactionEntryTheme.iconPlateRadius,
                          ),
                        ),
                        alignment: Alignment.center,
                        child:  Icon(
                          Symbols.sell_rounded,
                          size: 22.0,
                          color: TransactionEntryTheme.iconPlateInk(context),
                          fill: 0.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "transaction.tags".t(context),
                              style: TransactionEntryTheme.rowCaptionStyle(
                                context,
                                theme,
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              _summary(context) ??
                                  "transaction.tags.add".t(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: hasTags
                                  ? TransactionEntryTheme.rowValueStyle(
                                      context,
                                      theme,
                                    )
                                  : TransactionEntryTheme.rowPlaceholderStyle(
                                      context,
                                      theme,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Symbols.chevron_right_rounded,
                        size: 22.0,
                        color: TransactionEntryTheme.chevronInk(context),
                        fill: 0.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              indent: 16.0,
              endIndent: 16.0,
              color: TransactionEntryTheme.rowDivider(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56.0),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      TransactionTagAddChip(
                        onPressed: widget.selectTags,
                        title: "transaction.tags.add".t(context),
                        compact: true,
                      ),
                      ...?_suggestedGeoTags?.map(
                        (tag) => TransactionTagChip(
                          tag: tag,
                          selected: false,
                          isSuggestion: true,
                          compact: true,
                          onPressed: () => _addTag(tag),
                        ),
                      ),
                      ...?widget.selectedTags?.map(
                        (tag) => TransactionTagChip(
                          tag: tag,
                          selected: true,
                          compact: true,
                          onPressed: widget.selectTags,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasSuggestions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 14.0),
                child: InfoText(
                  child: Text("transaction.tags.suggestionGuide".t(context)),
                ),
              ),
          ],
        );

    return RepaintBoundary(
      child: widget.wrapInCard ? TransactionEntryCard(child: content) : content,
    );
  }

  void _addTag(TransactionTag tag) {
    if (widget.selectedTags?.contains(tag) == true) return;

    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    widget.onTagsChanged([...?widget.selectedTags, tag]);
  }
}
