import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Year picker bottom sheet — three stacked years (`year - 2`, `year - 1`,
/// `year`) where the selected year (bottom row) renders large in
/// [ColorScheme.primary]. Matches the Figma year-selector mockup.
class YearSelectorSheet extends StatefulWidget {
  final DateTime? initialDate;

  const YearSelectorSheet({super.key, this.initialDate});

  @override
  State<YearSelectorSheet> createState() => _YearSelectorSheetState();
}

class _YearSelectorSheetState extends State<YearSelectorSheet>
    with SingleTickerProviderStateMixin {
  late int year;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  /// Accumulates vertical drag pixels; every full step rolls the year by 1.
  double _dragAccumulator = 0.0;
  static const double _dragStepPixels = 36.0;

  @override
  void initState() {
    super.initState();

    final DateTime current = widget.initialDate ?? DateTime.now();
    year = current.year;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateYearChange() {
    _animationController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    final Color titleInk = light
        ? kFlowHomeTransactionHeadingInk
        : theme.colorScheme.onSurface;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color chevronInk = light
        ? kFlowMonthSelectorChevronInkLight
        : theme.colorScheme.onSurfaceVariant;
    final Color yearPillFill = light
        ? kFlowMonthSelectorYearPillFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color pastInk = light
        ? kFlowYearSelectorPastInkLight
        : theme.colorScheme.outlineVariant;
    final Color nowFill = light
        ? kFlowMonthSelectorNowFillLight
        : theme.colorScheme.surfaceContainerHigh;
    final Color nowInk =
        light ? kFlowMonthSelectorNowInkLight : theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: light ? Colors.white : theme.colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0),
                  Center(
                    child: Container(
                      width: 36.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 16.0,
                            ),
                            child: Text(
                              "select.time.select.year".t(context),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                letterSpacing: -0.1,
                                color: titleInk,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).cancelButtonLabel,
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Symbols.close_rounded,
                              fill: light ? 0.0 : 1.0,
                              color: chevronInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      14.0,
                      24.0,
                      18.0,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _onVerticalDrag,
                      onVerticalDragEnd: (_) => _dragAccumulator = 0.0,
                      child: _YearStack(
                        year: year,
                        farInk: pastInk,
                        selectedInk: primaryAccent,
                        pillFill: yearPillFill,
                        onTapOlder: () {
                          setState(() {
                            year -= 1;
                            _animateYearChange();
                          });
                        },
                        onTapNewer: () {
                          setState(() {
                            year += 1;
                            _animateYearChange();
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      4.0,
                      24.0,
                      20.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 36,
                          child: Button(
                            onTap: _setNow,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 14.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: nowFill,
                            foregroundColor: nowInk,
                            child: Text(
                              "select.time.now".t(context),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          flex: 62,
                          child: Button(
                            onTap: _confirm,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 16.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: primaryAccent,
                            foregroundColor: onPrimary,
                            iconColor: onPrimary,
                            child: Text(
                              "general.done".t(context),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onVerticalDrag(DragUpdateDetails details) {
    _dragAccumulator += details.delta.dy;
    if (_dragAccumulator.abs() < _dragStepPixels) return;

    final int steps = (_dragAccumulator / _dragStepPixels).truncate();
    if (steps == 0) return;

    setState(() {
      // Drag DOWN (positive dy) reveals older years above → year decreases.
      // Drag UP (negative dy) advances to newer years.
      year -= steps;
    });
    _animateYearChange();
    _dragAccumulator -= steps * _dragStepPixels;
  }

  void _setNow() {
    setState(() {
      year = DateTime.now().year;
      _animateYearChange();
    });
  }

  void _confirm() {
    if (year <= 0 || year > 3000) {
      context.pop(null);
    } else {
      context.pop(DateTime(year));
    }
  }
}

class _YearStack extends StatelessWidget {
  final int year;
  final Color farInk;
  final Color selectedInk;
  final Color pillFill;
  final VoidCallback onTapOlder;
  final VoidCallback onTapNewer;

  const _YearStack({
    required this.year,
    required this.farInk,
    required this.selectedInk,
    required this.pillFill,
    required this.onTapOlder,
    required this.onTapNewer,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: InkWell(
            onTap: onTapOlder,
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              height: 30.0,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: farInk,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  child: Text((year - 1).toString()),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (value * 0.1),
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pillFill,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.headlineSmall!.copyWith(
                color: selectedInk,
                fontSize: 28.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              child: Text(year.toString()),
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, -10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: InkWell(
            onTap: onTapNewer,
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              height: 30.0,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: farInk,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  child: Text((year + 1).toString()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}