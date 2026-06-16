import "dart:math" as math;

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [Optional<FlowColorScheme>] when the user saves, or `null` if dismissed.
class SelectColorSchemeSheet extends StatefulWidget {
  final FlowThemeGroup group;
  final String? initialScheme;

  const SelectColorSchemeSheet({
    super.key,
    required this.group,
    this.initialScheme,
  });

  @override
  State<SelectColorSchemeSheet> createState() => _SelectColorSchemeSheetState();
}

class _SelectColorSchemeSheetState extends State<SelectColorSchemeSheet>
    with SingleTickerProviderStateMixin {
  static const int _gridCrossAxisCount = 5;

  late AnimationController _introController;

  FlowColorScheme? _pendingScheme;

  @override
  void initState() {
    super.initState();
    _pendingScheme = _schemeForName(widget.initialScheme);
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  FlowColorScheme? _schemeForName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    final int i = widget.group.schemes.indexWhere((s) => s.name == name);
    return i >= 0 ? widget.group.schemes[i] : null;
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color dividerColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFE2E8F0)
        : scheme.outlineVariant;

    final List<FlowColorScheme> schemes = widget.group.schemes;
    final int rows =
        (schemes.length + _gridCrossAxisCount - 1) ~/ _gridCrossAxisCount;
    final double gridNaturalHeight =
        rows * 52.0 + math.max(0, rows - 1) * 16.0;
    final double maxGridHeight = MediaQuery.sizeOf(context).height * 0.36;
    final double gridHeight = math.min(gridNaturalHeight, maxGridHeight);
    final bool gridScrolls = gridNaturalHeight > maxGridHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        "account.themeColor".t(context),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Symbols.close_rounded,
                        color: scheme.onSurface,
                        fill: 0.0,
                      ),
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ],
                ),
              ),
              Divider(height: 1.0, thickness: 1.0, color: dividerColor),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: gridHeight,
                  child: GridView.builder(
                    physics: gridScrolls
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCrossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      mainAxisExtent: 52.0,
                    ),
                    itemCount: schemes.length,
                    itemBuilder: (context, index) {
                      final FlowColorScheme colorScheme = schemes[index];
                      final bool selected =
                          _pendingScheme?.name == colorScheme.name;
                      return _AnimatedThemeColorCell(
                        index: index,
                        controller: _introController,
                        child: _ThemeColorCircle(
                          scheme: colorScheme,
                          selected: selected,
                          onTap: () =>
                              setState(() => _pendingScheme = colorScheme),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Button(
                  fullWidth: true,
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 4.0,
                  shadowColor: scheme.primary.withValues(alpha: 0.28),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  onTap: () =>
                      context.pop(Optional<FlowColorScheme>(_pendingScheme)),
                  child: Text(
                    "select.color.save".t(context),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _pendingScheme = null),
                  child: Text(
                    "select.color.clear".t(context),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedThemeColorCell extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedThemeColorCell({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const double stagger = 0.048;
    const double window = 0.44;
    final double start = math.min(
      1.0 - window,
      index * stagger,
    );
    final double end = math.min(1.0, start + window);

    final Animation<double> reveal = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: reveal,
      builder: (context, _) {
        final double t = reveal.value;
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.12 + 0.88 * t,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

class _ThemeColorCircle extends StatelessWidget {
  final FlowColorScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeColorCircle({
    required this.scheme,
    required this.selected,
    required this.onTap,
  });

  static const double _selectedSize = 48.0;
  static const double _plainSize = 42.0;

  @override
  Widget build(BuildContext context) {
    final Color c = scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: _selectedSize,
          height: _selectedSize,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: selected ? _selectedSize : _plainSize,
              height: selected ? _selectedSize : _plainSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : c,
                border: selected
                    ? Border.all(color: c, width: 2.0)
                    : null,
                boxShadow: selected
                    ? null
                    : [
                        BoxShadow(
                          color: c.withValues(alpha: 0.32),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              padding: selected ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
