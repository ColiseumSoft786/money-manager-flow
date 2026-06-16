import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/list_tile_appearance/list_tile_appearance_theme.dart";
import "package:flow/routes/preferences/list_tile_appearance/widgets/list_tile_display_settings_card.dart";
import "package:flow/routes/preferences/list_tile_appearance/widgets/list_tile_leading_segment.dart";
import "package:flow/routes/preferences/list_tile_appearance/widgets/list_tile_preview_section.dart";
import "package:flow/routes/preferences/list_tile_appearance/widgets/list_tile_section_header.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";

class TransactionListItemAppearancePreferencesPage extends StatefulWidget {
  const TransactionListItemAppearancePreferencesPage({super.key});

  @override
  State<TransactionListItemAppearancePreferencesPage> createState() =>
      _TransactionListItemAppearancePreferencesPageState();
}


class _TransactionListItemAppearancePreferencesPageState
    extends State<TransactionListItemAppearancePreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserPreferencesService().valueNotifier,
      builder: (context, _, __) {
        final bool useCategoryNameForUntitledTransactions =
            UserPreferencesService().useCategoryNameForUntitledTransactions;
        final bool transactionListTileShowCategoryName =
            UserPreferencesService().transactionListTileShowCategoryName;
        final bool transactionListTileShowExternalSource =
            UserPreferencesService().transactionListTileShowExternalSource;
        final bool transactionListTileShowAccountForLeading =
            UserPreferencesService().transactionListTileShowAccountForLeading;
        final bool transactionListTileRelaxedDensity =
            UserPreferencesService().transactionListTileRelaxedDensity;

        return Scaffold(
          backgroundColor: ListTileAppearanceTheme.canvas(context),
          appBar: AppBar(
            title: Text("preferences.transactions.listTile".t(context)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTileSectionHeader(
                    first: true,
                    label: "preferences.transactions.listTile.preview".t(
                      context,
                    ),
                  ),
                  const ListTilePreviewSection(),
                  ListTileSectionHeader(
                    label: "preferences.transactions.listTile.leading".t(
                      context,
                    ),
                  ),
                  ListTileLeadingSegment(
                    showAccountForLeading: transactionListTileShowAccountForLeading,
                    onChanged: (bool value) {
                      UserPreferencesService()
                              .transactionListTileShowAccountForLeading =
                          value;
                      setState(() {});
                    },
                  ),
                  ListTileSectionHeader(
                    label: "preferences.transactions.listTile.section.display"
                        .t(context),
                  ),
                  ListTileDisplaySettingsCard(
                    showCategoryInList: transactionListTileShowCategoryName,
                    useCategoryNameForUntitled:
                        useCategoryNameForUntitledTransactions,
                    relaxedDensity: transactionListTileRelaxedDensity,
                    showExternalSource: transactionListTileShowExternalSource,
                    onShowCategoryInListChanged: (bool value) {
                      UserPreferencesService().transactionListTileShowCategoryName =
                          value;
                      setState(() {});
                    },
                    onUseCategoryNameForUntitledChanged: (bool value) {
                      UserPreferencesService()
                              .useCategoryNameForUntitledTransactions =
                          value;
                      setState(() {});
                    },
                    onRelaxedDensityChanged: (bool value) {
                      UserPreferencesService().transactionListTileRelaxedDensity =
                          value;
                      setState(() {});
                    },
                    onShowExternalSourceChanged: (bool value) {
                      UserPreferencesService()
                              .transactionListTileShowExternalSource =
                          value;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
