import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/trash_bin/trash_bin_preferences_theme.dart";
import "package:flow/routes/preferences/trash_bin/widgets/trash_bin_section_header.dart";
import "package:flow/routes/preferences/trash_bin/widgets/trash_empty_button.dart";
import "package:flow/routes/preferences/trash_bin/widgets/trash_info_banner.dart";
import "package:flow/routes/preferences/trash_bin/widgets/trash_retention_period_card.dart";
import "package:flow/routes/preferences/trash_bin/widgets/trash_view_deleted_card.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/extensions.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class TrashBinPreferencesPage extends StatefulWidget {
  const TrashBinPreferencesPage({super.key});

  @override
  State<TrashBinPreferencesPage> createState() =>
      _TrashBinPreferencesPageState();

  static const List<Duration> choices = [
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 90),
    Duration(days: 180),
    Duration(days: 365),
  ];
}

class _TrashBinPreferencesPageState extends State<TrashBinPreferencesPage> {
  bool busy = false;

  int _deletedItemCount() {
    final query = TransactionsService().deletedTransactionsQb().build();
    try {
      return query.count();
    } finally {
      query.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrashBinPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: TrashBinPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "preferences.trashBin.settingsTitle".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: TrashBinPreferencesTheme.titleInk,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: kFlowAccountRowDividerLight,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: UserPreferencesService().valueNotifier,
        builder: (context, snapshot, _) {
          final int? trashBinRetentionDays = snapshot.trashBinRetentionDays;

          final bool isCustomPeriod =
              trashBinRetentionDays != null &&
              !TrashBinPreferencesPage.choices.any(
                (preset) => trashBinRetentionDays == preset.inDays,
              );

          final List<Duration> choices = [
            ...TrashBinPreferencesPage.choices,
            if (isCustomPeriod) Duration(days: trashBinRetentionDays),
          ]..sort((a, b) => a.inDays.compareTo(b.inDays));

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TrashBinSectionHeader(
                    first: true,
                    label: "preferences.trashBin.section.retention".t(context),
                  ),
                  TrashRetentionPeriodCard(
                    choices: choices,
                    selectedDays: trashBinRetentionDays,
                    onSelected: updateTrashBinRetentionDays,
                  ),
                  TrashBinSectionHeader(
                    label: "preferences.trashBin.section.management".t(context),
                  ),
                  TrashViewDeletedCard(
                    itemCount: _deletedItemCount(),
                    onTap: () => context.push("/transactions/deleted"),
                  ),
                  const SizedBox(height: 16.0),
                  const TrashInfoBanner(),
                  const SizedBox(height: 20.0),
                  TrashEmptyButton(
                    enabled: !busy,
                    onPressed: emptyTrashBin,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void updateTrashBinRetentionDays(int? days) {
    UserPreferencesService().trashBinRetentionDays = days;
  }

  void emptyTrashBin() async {
    if (busy) return;

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "preferences.trashBin.emptyBin".t(context),
      child: Text("preferences.trashBin.emptyBin.description".t(context)),
    );

    if (confirmation != true) return;

    setState(() {
      busy = true;
    });

    try {
      await TransactionsService().emptyTrashBin();
    } catch (error) {
      log("Failed to empty trash bin", error: error);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}
