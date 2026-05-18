import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:lottie/lottie.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class FossSlide extends StatefulWidget {
  const FossSlide({
    super.key,
    required this.pageController,
    required this.slideCount,
    required this.currentPageIndex,
    required this.onContinue,
  });

  final PageController pageController;
  final int slideCount;
  final int currentPageIndex;
  final VoidCallback onContinue;

  @override
  State<FossSlide> createState() => _FossSlideState();
}

class _FossSlideState extends State<FossSlide> with TickerProviderStateMixin {
  late final AnimationController _lottieController;

  static const double _globeDiameter = 220.0;
  static const double _ringBorderWidth = 9.0;
  static const double _badgeSize = 56.0;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color accentBlue = scheme.primary;
    final Color globeRing = context.fossGlobeRing;
    final Color globeInnerBackdrop = context.fossGlobeInnerBackdrop;
    final Color glowCyan = context.fossGlobeGlowCyan;
    final Color glowCyanBright = context.fossGlobeGlowCyanBright;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withAlpha(0x1a),
                          blurRadius: 24.0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                Text(
                  "appName".t(context),
                  style: context.textTheme.displaySmall?.copyWith(
                    color: accentBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Main circular container with border
                    Container(
                      width: _globeDiameter,
                      height: _globeDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: globeInnerBackdrop,
                        border: Border.all(
                          color: globeRing,
                          width: _ringBorderWidth,
                        ),
                      ),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Lottie animation - fills the circle
                            Lottie.asset(
                              "assets/animations/earth.json",
                              controller: _lottieController,
                              repeat: true,
                              animate: true,
                              fit: BoxFit.cover,
                              onLoaded: (composition) {
                                _lottieController
                                  ..duration = composition.duration
                                  ..repeat();
                              },
                            ),
                            // Gradient overlay at bottom
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 72.0,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      glowCyan.withAlpha(0x33),
                                      glowCyanBright.withAlpha(0x55),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Badge at bottom right
                    Positioned(
                      right: 4.0,
                      bottom: 4.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentBlue,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withAlpha(0x40),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: _badgeSize,
                          height: _badgeSize,
                          child: Icon(
                            Symbols.globe_rounded,
                            color: scheme.onPrimary,
                            size: 28.0,
                            fill: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Text(
                  "setup.slides.foss.title".t(context),
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "setup.slides.foss.description".t(context),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                GestureDetector(
                  onTap: ()=> openUrl(flowGitHubRepoLink),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: scheme.inverseSurface,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            SimpleIcons.github,
                            color: scheme.onInverseSurface,
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GitHub Repository",
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                "setup.slides.foss.seeRepo".t(context),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: accentBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                        Icon(
                          Symbols.open_in_new_rounded,
                          color: scheme.onSurfaceVariant,
                          size: 20.0,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: widget.currentPageIndex,
                    count: widget.slideCount,
                    effect: WormEffect(
                      dotColor: context.flowColors.semi,
                      activeDotColor: context.colorScheme.primary,
                      dotWidth: 12.0,
                      dotHeight: 12.0,
                      radius: 12.0,
                      spacing: 8.0,
                    ),
                    onDotClicked: (index) => widget.pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Button(
                  onTap: widget.onContinue,
                  fullWidth: true,
                  elevation: 8.0,
                  shadowColor: accentBlue.withAlpha(0x55),
                  backgroundColor: accentBlue,
                  foregroundColor: scheme.onPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  trailing: const Icon(Symbols.arrow_forward_rounded),
                  child: Text(
                    "setup.continue".t(context),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
          },
        ),
      ),
    );
  }
}
