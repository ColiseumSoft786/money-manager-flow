import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";

class WelcomeSlide extends StatelessWidget {
  const WelcomeSlide({
    super.key,
    required this.pageController,
    required this.slideCount,
    required this.currentPageIndex,
  });

  final PageController pageController;
  final int slideCount;
  final int currentPageIndex;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 240.0,
                        height: 240.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.secondary,
                          ),
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary,
                                borderRadius: BorderRadius.circular(24.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 24.0,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 140.0,
                                height: 140.0,
                                child: Center(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(999),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 84.0,
                                      height: 44.0,
                                      child: Center(
                                        child: Text(
                                          r"$",
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w700,
                                            color: context.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Cash",
                            style: context.textTheme.displayMedium?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: "Pilot",
                            style: context.textTheme.displayMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "appShortDesc".t(context),
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40.0),
                    AnimatedSmoothIndicator(
                      activeIndex: currentPageIndex,
                      count: slideCount,
                      effect: WormEffect(
                        dotColor: context.flowColors.semi,
                        activeDotColor: context.colorScheme.primary,
                        dotWidth: 12.0,
                        dotHeight: 12.0,
                        radius: 12.0,
                        spacing: 8.0,
                      ),
                      onDotClicked: (index) => pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
