import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sections/icloud.dart";
import "package:flow/routes/preferences/sync/sync_preferences_theme.dart";
import "package:flow/routes/preferences/sync/widgets/sync_info_banner.dart";
import "package:flow/routes/preferences/sync/widgets/sync_interval_grid.dart";
import "package:flow/routes/preferences/sync/widgets/sync_retain_history_section.dart";
import "package:flow/routes/preferences/sync/widgets/sync_section_header.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

class SyncPreferencesPage extends StatefulWidget {
  const SyncPreferencesPage({super.key});

  @override
  State<SyncPreferencesPage> createState() => _SyncPreferencesPageState();
}

class _SyncPreferencesPageState extends State<SyncPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final int? autobackupIntervalInHours =
        UserPreferencesService().autoBackupIntervalInHours;

    final List<int?> options = [null, 12, 24, 48, 72, 168, 336, 720];

    if (autobackupIntervalInHours != null &&
        !options.contains(autobackupIntervalInHours)) {
      options.add(autobackupIntervalInHours);
    }

    final bool showCloudSection = ICloudSyncer.supported || flowDebugMode;

    return Scaffold(
      backgroundColor: SyncPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: SyncPreferencesTheme.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "preferences.sync.settingsTitle".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: SyncPreferencesTheme.titleInk,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCloudSection) ...[
                SyncSectionHeader(
                  label: "preferences.sync.section.cloudServices".t(context),
                ),
                if (!ICloudSyncer.supported)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "DEBUG MODE: Even though your currenct device does not support iCloud, following section is shown because you are in debug mode.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SyncPreferencesTheme.subtitleInk,
                      ),
                    ),
                  ),
                const ICloud(),
                const SizedBox(height: 8.0),
              ],
              SyncSectionHeader(
                label: "preferences.sync.autoBackup.interval".t(context),
              ),
              SyncIntervalGrid(
                options: options,
                selectedHours: autobackupIntervalInHours,
                onSelected: updateAutoBackupIntervalInHours,
              ),
              if (showCloudSection) ...[
                SyncSectionHeader(
                  label: "preferences.sync.section.retainHistory".t(context),
                ),
                const SyncRetainHistorySection(),
              ],
              const SizedBox(height: 24.0),
              const SyncInfoBanner(),
            ],
          ),
        ),
      ),
    );
  }

  void updateAutoBackupIntervalInHours(int? newIntervalInHours) {
    UserPreferencesService().autoBackupIntervalInHours = newIntervalInHours;

    if (mounted) setState(() {});
  }
}
