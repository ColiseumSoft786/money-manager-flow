import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/routes/preferences/sync/widgets/sync_cloud_card.dart";
import "package:flow/services/local_auth.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flow/widgets/icloud_failed_error_box.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// iCloud sync toggle for [SyncPreferencesPage].
///
/// Expects [LocalAuthService] to be initialized.
class ICloud extends StatefulWidget {
  const ICloud({super.key});

  @override
  State<ICloud> createState() => _ICloudState();
}

class _ICloudState extends State<ICloud> {
  bool iCloudSyncWorkingFine = true;

  @override
  void initState() {
    super.initState();

    TransitiveLocalPreferences().iCloudSyncWorkingFine.addListener(
      _updateICloudSyncWorkingFine,
    );
    _updateICloudSyncWorkingFine();
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().iCloudSyncWorkingFine.removeListener(
      _updateICloudSyncWorkingFine,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableICloudSync = UserPreferencesService().enableICloudSync;

    final DateTime? lastSuccessfulICloudSyncAt = TransitiveLocalPreferences()
        .lastSuccessfulICloudSyncAt
        .get();

    final String? lastSyncedLabel = lastSuccessfulICloudSyncAt != null
        ? "preferences.sync.iCloud.lastSyncedAt".t(
            context,
            lastSuccessfulICloudSyncAt.toMoment().lll,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ICloudSyncer.supported && !iCloudSyncWorkingFine)
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: ICloudFailedErrorBox(),
          ),
        SyncCloudCard(
          enabled: enableICloudSync,
          lastSyncedLabel: lastSyncedLabel,
          onChanged: (bool value) => updateEnableICloudSync(value),
        ),
      ],
    );
  }

  Future<void> updateEnableICloudSync(bool newEnableICloudSync) async {
    bool? confirm = false;

    if (!newEnableICloudSync) {
      confirm = true;
    } else {
      confirm = await context.showConfirmationSheet(
        child: Text(
          "preferences.sync.iCloud.singleDeviceSupportDisclaimer".t(context),
        ),
      );
    }

    if (confirm != true) return;

    UserPreferencesService().enableICloudSync = newEnableICloudSync;

    if (mounted) setState(() {});
  }

  void _updateICloudSyncWorkingFine() {
    if (!ICloudSyncer.supported) return;
    if (!ICloudSyncer().syncing) return;

    iCloudSyncWorkingFine = TransitiveLocalPreferences().iCloudSyncWorkingFine
        .get();
    if (mounted) {
      setState(() {});
    }
  }
}
