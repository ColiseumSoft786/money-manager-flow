import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/list_tile_appearance/list_tile_appearance_theme.dart";
import "package:flutter/material.dart";

/// Display toggles — same four [UserPreferencesService] fields as before.
class ListTileDisplaySettingsCard extends StatelessWidget {
  final bool showCategoryInList;
  final bool useCategoryNameForUntitled;
  final bool relaxedDensity;
  final bool showExternalSource;
  final ValueChanged<bool> onShowCategoryInListChanged;
  final ValueChanged<bool> onUseCategoryNameForUntitledChanged;
  final ValueChanged<bool> onRelaxedDensityChanged;
  final ValueChanged<bool> onShowExternalSourceChanged;

  const ListTileDisplaySettingsCard({
    super.key,
    required this.showCategoryInList,
    required this.useCategoryNameForUntitled,
    required this.relaxedDensity,
    required this.showExternalSource,
    required this.onShowCategoryInListChanged,
    required this.onUseCategoryNameForUntitledChanged,
    required this.onRelaxedDensityChanged,
    required this.onShowExternalSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ListTileAppearanceTheme.cardFill(context),
        borderRadius: BorderRadius.circular(ListTileAppearanceTheme.cardRadius),
        border: Border.all(color: ListTileAppearanceTheme.cardBorder(context)),
      ),
      child: Column(
        children: [
          _DisplayToggleRow(
            title: "preferences.transactions.listTile.showCategory.title".t(
              context,
            ),
            subtitle: "preferences.transactions.listTile.showCategory.subtitle"
                .t(context),
            value: showCategoryInList,
            onChanged: onShowCategoryInListChanged,
          ),
          const _RowDivider(),
          _DisplayToggleRow(
            title:
                "preferences.transactions.listTile.fallbackToCategoryName".t(
                  context,
                ),
            subtitle:
                "preferences.transactions.listTile.fallbackToCategoryName.subtitle"
                    .t(context),
            value: useCategoryNameForUntitled,
            onChanged: onUseCategoryNameForUntitledChanged,
          ),
          const _RowDivider(),
          _DisplayToggleRow(
            title: "preferences.transactions.listTile.relaxedDensity".t(context),
            subtitle: "preferences.transactions.listTile.relaxedDensity.subtitle"
                .t(context),
            value: relaxedDensity,
            onChanged: onRelaxedDensityChanged,
          ),
          const _RowDivider(),
          _DisplayToggleRow(
            title: "preferences.transactions.listTile.showExternalSource".t(
              context,
            ),
            subtitle:
                "preferences.transactions.listTile.showExternalSource.subtitle"
                    .t(context),
            value: showExternalSource,
            onChanged: onShowExternalSourceChanged,
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.0,
      thickness: 1.0,
      indent: 16.0,
      endIndent: 16.0,
      color: ListTileAppearanceTheme.divider(context),
    );
  }
}

class _DisplayToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DisplayToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    color: ListTileAppearanceTheme.titleInk(context),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ListTileAppearanceTheme.subtitleInk(context),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ListTileAppearanceTheme.primary(context),
            inactiveTrackColor: ListTileAppearanceTheme.cardBorder(context),
            thumbColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
