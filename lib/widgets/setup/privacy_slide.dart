import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class PrivacySlide extends StatelessWidget {
  const PrivacySlide({
    super.key,
    required this.pageController,
    required this.slideCount,
    required this.currentPageIndex,
    required this.onGetStarted,
  });

  final PageController pageController;
  final int slideCount;
  final int currentPageIndex;
  final VoidCallback onGetStarted;

  static const double _stackSize = 200.0;
  static const double _innerCircle = 160.0;
  static const double _shieldSize = 80.0;
  static const double _ringStroke = 4.0;
  /// Max width for the bottom Get started pill (narrower than full-bleed).
  static const double _getStartedButtonMaxWidth = 256.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final List<Color> radial = context.privacySetupHeroRadialPrimaryGradient;
    final Color glow = context.privacySetupHeroPrimaryGlow;
    final Color badge = context.flowColors.income;
    final Color lockFg = context.privacySetupLockOnIncomeBadge;
    final Color badgeShadow = context.privacySetupBadgeShadow;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double ctaWidth = _getStartedButtonMaxWidth > constraints.maxWidth
                ? constraints.maxWidth
                : _getStartedButtonMaxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: inner.maxWidth,
                            minHeight: inner.maxHeight,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: inner.maxWidth,
                              child: Container(
                                padding: const EdgeInsets.all(32.0),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.setupSlideCardShadowColor,
                                      blurRadius: 24.0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: _stackSize,
                                        height: _stackSize,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: _innerCircle,
                                              height: _innerCircle,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: radial,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: glow,
                                                    blurRadius: 30.0,
                                                    spreadRadius: 10.0,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: scheme.surface,
                                                  width: _ringStroke,
                                                ),
                                              ),
                                              child: Icon(
                                                Symbols.shield_person_rounded,
                                                size: _shieldSize,
                                                color: scheme.primary,
                                                fill: 1.0,
                                              ),
                                            ),
                                            Positioned(
                                              top: 10.0,
                                              right: 10.0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: badge,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: badgeShadow,
                                                      blurRadius: 8.0,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Symbols.lock_rounded,
                                                  color: lockFg,
                                                  size: 20.0,
                                                  fill: 1.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    Text(
                                      "setup.slides.privacy".t(context),
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      "setup.slides.privacy.description"
                                          .t(context),
                                      style: context.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16.0),
                                    Center(
                                      child: AnimatedSmoothIndicator(
                                        activeIndex: currentPageIndex,
                                        count: slideCount,
                                        effect: WormEffect(
                                          dotColor: context.flowColors.semi,
                                          activeDotColor: scheme.primary,
                                          dotWidth: 12.0,
                                          dotHeight: 12.0,
                                          radius: 12.0,
                                          spacing: 8.0,
                                        ),
                                        onDotClicked: (index) =>
                                            pageController.animateToPage(
                                          index,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  child: Center(
                    child: SizedBox(
                      width: ctaWidth,
                      child: Button(
                        onTap: onGetStarted,
                        fullWidth: true,
                        elevation: 6.0,
                        shadowColor: scheme.primary.withAlpha(0x44),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Text(
                          "setup.getStarted".t(context),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
