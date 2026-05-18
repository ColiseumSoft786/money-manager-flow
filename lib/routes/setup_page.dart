import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/setup/foss_slide.dart";
import "package:flow/widgets/setup/privacy_slide.dart";
import "package:flow/widgets/setup/welcome_slide.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late final PageController _pageController;

  static const int slideCount = 3;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPageIndex = index);
        },
        children: [
          WelcomeSlide(
            pageController: _pageController,
            slideCount: slideCount,
            currentPageIndex: _currentPageIndex,
          ),
          FossSlide(
            pageController: _pageController,
            slideCount: slideCount,
            currentPageIndex: _currentPageIndex,
            onContinue: next,
          ),
          PrivacySlide(
            pageController: _pageController,
            slideCount: slideCount,
            currentPageIndex: _currentPageIndex,
            onGetStarted: next,
          ),
        ],
      ),
      bottomNavigationBar: (_currentPageIndex == 1 || _currentPageIndex == 2)
          ? null
          : Material(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      _primarySetupActionButton(context),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _nextButtonLabel(BuildContext context) =>
      _currentPageIndex == slideCount - 1
      ? "setup.getStarted".t(context)
      : "setup.next".t(context);

  Widget _primarySetupActionButton(BuildContext context) {
    return Button(
      onTap: next,
      backgroundColor: context.colorScheme.primary,
      foregroundColor: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      trailing: const Icon(Symbols.arrow_forward_rounded),
      child: Text(_nextButtonLabel(context)),
    );
  }

  void next() {
    if (_pageController.page == null) return;

    final int currentPage = _pageController.page!.round();

    if (currentPage < (slideCount - 1)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      context.push("/setup/choose");
    }
  }
}
