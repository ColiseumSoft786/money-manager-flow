import "dart:async";
import "dart:io";
import "dart:math" as math;
import "dart:ui" as ui;

import "package:flow/l10n/extensions.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/profile_picture.dart";
import "package:flow/widgets/setup/setup_profile_page_canvas.dart";
import "package:flow/widgets/setup/setup_profile_step_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:path/path.dart" as path;

class SetupProfilePhotoPage extends StatefulWidget {
  final String profileImagePath;

  const SetupProfilePhotoPage({super.key, required this.profileImagePath});

  @override
  State<SetupProfilePhotoPage> createState() => _SetupProfilePhotoPageState();
}

class _SetupProfilePhotoPageState extends State<SetupProfilePhotoPage> {
  int _profilePictureUpdateCounter = 0;

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : context.colorScheme.onSurface;

    final double pfpSize = math.min(
      MediaQuery.of(context).size.width * 0.44,
      200.0,
    );

    final Color cardFill =
        light ? Colors.white : context.colorScheme.surfaceContainerHighest;
    final Color cardBorder = light
        ? kFlowSetupAccountCardBorder
        : context.colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Scaffold(
      backgroundColor: light
          ? Colors.white
          : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "setup.profile.appBarTitle".t(context),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SetupProfilePageCanvas(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SetupProfileStepHeader(
                        step: 2,
                        total: 2,
                        headline: "setup.profile.addPhoto".t(context),
                        description:
                            "setup.profile.photoDescription".t(context),
                      ),
                      const SizedBox(height: 28.0),
                      Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: pfpSize + 72.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cardFill,
                              borderRadius: BorderRadius.circular(32.0),
                              border: Border.all(
                                color: cardBorder,
                                width: 1.0,
                              ),
                              boxShadow: light
                                  ? const [
                                      BoxShadow(
                                        color: kFlowSetupAccountCardShadow,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(26.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ProfilePicture(
                                    key: ValueKey(_profilePictureUpdateCounter),
                                    filePath: widget.profileImagePath,
                                    onTap: changeProfilePicture,
                                    showOverlayUponHover: true,
                                    size: pfpSize,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22.0),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320.0),
                          child: Text(
                            "setup.profile.photoFooterHint".t(context),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: kFlowPopularCurrenciesSectionHeading,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContinueButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final double maxWidth = MediaQuery.sizeOf(context).width - 32.0;
    final double width = math.min(342.0, maxWidth);

    return Opacity(
      opacity: _busy ? 0.55 : 1.0,
      child: SizedBox(
        width: width,
        height: 68.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kFlowSetupAccountsContinueButtonFill,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              onTap: _busy ? null : save,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "setup.continue".t(context),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Symbols.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22.0,
                      fill: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> changeProfilePicture() async {
    final cropped = await pickAndCropSquareImage(context, maxDimension: 512);
    if (cropped == null) {
      return;
    }

    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();

    if (bytes == null) throw "";

    final file = File(path.join(ObjectBox.imagesDirectory, widget.profileImagePath));

    try {
      await FileImage(file).evict();
      _profilePictureUpdateCounter++;
    } catch (e) {
      mainLogger.warning(
        "Setup Profile Photo Page > Failed to evict profile FileImage cache due to:\n$e",
      );
    }

    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      unawaited(LocalPreferences().completedInitialSetup.set(true));
      if (!mounted) return;
      GoRouter.of(context).popUntil((route) => route.path == "/setup");
      context.pushReplacement("/");
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
