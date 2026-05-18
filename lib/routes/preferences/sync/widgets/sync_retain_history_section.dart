import "package:flow/routes/preferences/sync/widgets/sync_retain_history_card.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";

class SyncRetainHistorySection extends StatefulWidget {
  const SyncRetainHistorySection({super.key});

  @override
  State<SyncRetainHistorySection> createState() =>
      _SyncRetainHistorySectionState();
}

class _SyncRetainHistorySectionState extends State<SyncRetainHistorySection> {
  static const List<int?> _retainOptions = [3, 5, 10, 20, 30, 100, -1];

  @override
  Widget build(BuildContext context) {
    final int iCloudBackupsToKeep =
        UserPreferencesService().iCloudBackupsToKeep ?? 5;

    return SyncRetainHistoryCard(
      displayValue: iCloudBackupsToKeep,
      options: _retainOptions,
      onChanged: (int? value) {
        if (value == null) return;
        // Legacy UI used -1 for "infinite"; store as 0 per entity semantics.
        UserPreferencesService().iCloudBackupsToKeep =
            value < 0 ? 0 : value;
        setState(() {});
      },
    );
  }
}
