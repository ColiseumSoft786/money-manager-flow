import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/transaction_geo/transaction_geo_preferences_theme.dart";
import "package:flow/routes/preferences/transaction_geo/widgets/geo_map_preview_card.dart";
import "package:flow/routes/preferences/transaction_geo/widgets/geo_privacy_card.dart";
import "package:flow/routes/preferences/transaction_geo/widgets/geo_section_header.dart";
import "package:flow/routes/preferences/transaction_geo/widgets/geo_settings_card.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/geo_permission_missing_reminder.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:permission_handler/permission_handler.dart";

class TransactionGeoPreferencesPage extends StatefulWidget {
  const TransactionGeoPreferencesPage({super.key});

  @override
  State<TransactionGeoPreferencesPage> createState() =>
      _TransactionGeoPreferencesPageState();
}

class _TransactionGeoPreferencesPageState
    extends State<TransactionGeoPreferencesPage> {
  late final AppLifecycleListener _listener;

  late Future<LocationPermission> _geoPermissionGranted;

  @override
  void initState() {
    super.initState();

    _geoPermissionGranted = Geolocator.checkPermission();

    _listener = AppLifecycleListener(
      onShow: () {
        _geoPermissionGranted = Geolocator.checkPermission();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool geoSupported = !Platform.isLinux;

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool autoAttachTransactionGeo = LocalPreferences()
        .autoAttachTransactionGeo
        .get();

    return Scaffold(
      backgroundColor: TransactionGeoPreferencesTheme.canvas(context),
      appBar: AppBar(
        title: Text("preferences.transactions.geo.settingsTitle".t(context)),
      ),
      body: FutureBuilder(
        future: _geoPermissionGranted,
        builder: (context, snapshot) {
          final LocationPermission? permissionData = snapshot.data;
          final bool hasPermission =
              permissionData != null && resolvePermission(permissionData);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GeoMapPreviewCard(),
                  const SizedBox(height: 12.0),
                  GeoSettingsCard(
                    enableGeo: enableGeo,
                    autoAttach: autoAttachTransactionGeo,
                    showAutoAttach: geoSupported,
                    onEnableGeoChanged: updateEnableGeo,
                    onAutoAttachChanged: updateAutoAttachTransactionGeo,
                  ),
                  if (geoSupported && permissionData != null && !hasPermission)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: GeoPermissionMissingReminder(),
                    ),
                  const SizedBox(height: 16.0),
                  Text(
                    geoSupported
                        ? "preferences.transactions.geo.intro".t(
                            context,
                            {"appName": "appName".t(context)},
                          )
                        : "preferences.transactions.geo.auto.description".t(
                            context,
                          ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TransactionGeoPreferencesTheme.subtitleInk(context),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  GeoSectionHeader(
                    label: "preferences.transactions.geo.section.privacy".t(
                      context,
                    ),
                  ),
                  const GeoPrivacyCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool resolvePermission(LocationPermission permission) => switch (permission) {
    LocationPermission.whileInUse || LocationPermission.always => true,
    _ => false,
  };

  Future<bool> tryRequestPermission([
    bool retryAfterOpeningSettings = true,
  ]) async {
    final LocationPermission currentPermission =
        await Geolocator.checkPermission();

    switch (currentPermission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return true;
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        if (!retryAfterOpeningSettings) return false;

        await openAppSettings();
        return await tryRequestPermission(false);
      case LocationPermission.denied:
        break;
    }

    final LocationPermission newPermission =
        await Geolocator.requestPermission();

    switch (newPermission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return true;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return false;
    }
  }

  void updateEnableGeo(bool newEnableGeo) async {
    await LocalPreferences().enableGeo.set(newEnableGeo);

    if (mounted) setState(() {});
  }

  void updateAutoAttachTransactionGeo(bool newAutoAttachTransactionGeo) async {
    if (newAutoAttachTransactionGeo) {
      final bool granted = await tryRequestPermission();

      if (!mounted) return;

      if (!granted) {
        context.showErrorToast(
          error: "preferences.transactions.geo.auto.permissionDenied".t(
            context,
          ),
        );

        await LocalPreferences().autoAttachTransactionGeo.set(false);

        if (mounted) setState(() {});
        return;
      }

      await LocalPreferences().autoAttachTransactionGeo.set(
        newAutoAttachTransactionGeo,
      );
    } else {
      await LocalPreferences().autoAttachTransactionGeo.set(
        newAutoAttachTransactionGeo,
      );
    }

    if (mounted) setState(() {});
  }
}
