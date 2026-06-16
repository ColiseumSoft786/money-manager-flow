import "dart:async";
import "dart:math" as math;

import "package:flow/entity/profile.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/setup/setup_profile_hero_orb.dart";
import "package:flow/widgets/setup/setup_profile_page_canvas.dart";
import "package:flow/widgets/setup/setup_profile_step_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  late final AppLifecycleListener _listener;

  final TextEditingController _textEditingController = TextEditingController();

  late Profile? _currentlyEditing;

  final GlobalKey<FormState> formKey = GlobalKey();

  bool testMode = false;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(onShow: () => _updateProfile());

    _updateProfile();
    if (_currentlyEditing != null) {
      _textEditingController.text = _currentlyEditing!.name;
    }
    _textEditingController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color titleColor =
        light ? kFlowAccountEditTitleColor : context.colorScheme.onSurface;

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
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: SetupProfileHeroOrb(diameter: 118.0),
                        ),
                        const SizedBox(height: 24.0),
                        SetupProfileStepHeader(
                          step: 1,
                          total: 2,
                          headline: "setup.profile.setup".t(context),
                          description:
                              "setup.profile.nameDescription".t(context),
                        ),
                        const SizedBox(height: 28.0),
                        _buildNameCard(context, light),
                        if (_textEditingController.text
                                .trim()
                                .toLowerCase() ==
                            "test") ...[
                          const SizedBox(height: 20.0),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("setup.demoMode".t(context)),
                            value: testMode,
                            onChanged: (value) {
                              setState(() {
                                testMode = value ?? testMode;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
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

  Widget _buildNameCard(BuildContext context, bool light) {
    final ColorScheme scheme = context.colorScheme;
    final Color cardFill = light ? Colors.white : scheme.surfaceContainerHighest;
    final Color borderColor =
        light ? kFlowSetupAccountCardBorder : scheme.outlineVariant;

    final double maxFieldWidth = math.min(
      kFlowAccountEditNameFieldMaxWidth,
      MediaQuery.sizeOf(context).width - 40.0,
    );

    final OutlineInputBorder fieldShape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(
        color: light
            ? kFlowAccountEditNameFieldBorder
            : scheme.outlineVariant,
        width: 1.0,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 1.0),
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
        padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "setup.profile.nameLabel".t(context),
              style: context.textTheme.titleSmall?.copyWith(
                color: kFlowPopularCurrenciesSectionHeading,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10.0),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFieldWidth),
                child: SizedBox(
                  height: kFlowAccountEditNameFieldHeight,
                  child: TextFormField(
                    controller: _textEditingController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => save(),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: light
                          ? kFlowAccountEditTitleColor
                          : scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: "setup.profile.nameLabel".t(context),
                      hintStyle: context.textTheme.titleMedium?.copyWith(
                        color: kFlowPopularCurrenciesSectionHeading,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                      filled: true,
                      fillColor: light
                          ? kFlowAccountEditFieldFill
                          : scheme.surfaceContainerHigh,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(
                        18.0,
                        17.0,
                        18.0,
                        17.0,
                      ),
                      border: fieldShape,
                      enabledBorder: fieldShape,
                      disabledBorder: fieldShape,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                          color: scheme.primary.withValues(alpha: 0.85),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: validateRequiredField,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Primary Continue — flat (no elevation); setup profile only.
  Widget _buildContinueButton(BuildContext context) {
    final double maxWidth = MediaQuery.sizeOf(context).width - 32.0;
    final double width = math.min(342.0, maxWidth);

    return Opacity(
      opacity: busy ? 0.55 : 1.0,
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
              onTap: busy ? null : save,
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

  Future<void> save() async {
    if (busy) return;

    if (formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      busy = true;
    });

    _updateProfile();

    final String trimmed = _textEditingController.text.trim();
    try {
      if (_currentlyEditing != null) {
        _currentlyEditing!.name = trimmed;
      } else {
        _currentlyEditing = Profile(name: trimmed);
      }

      final updatedProfile = await ObjectBox().box<Profile>().putAndGetAsync(
        _currentlyEditing!,
      );

      if (testMode) {
        unawaited(LocalPreferences().primaryCurrency.set("USD"));
        unawaited(ObjectBox().createAndPutDebugData());
        if (mounted) {
          GoRouter.of(context).popUntil((route) => route.path == "/setup");

          context.pushReplacement("/");
        }
      } else if (mounted) {
        await context.push(
          "/setup/profile/photo",
          extra: updatedProfile.imagePath,
        );
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateProfile() {
    final Query<Profile> profileQuery = ObjectBox()
        .box<Profile>()
        .query()
        .build();

    _currentlyEditing = profileQuery.findFirst();

    profileQuery.close();
  }
}
