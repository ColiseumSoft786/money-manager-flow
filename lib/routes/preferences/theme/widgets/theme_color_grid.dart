import "dart:math" as math;

import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/names.dart";
import "package:flow/routes/preferences/theme/theme_preferences_theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";

class ThemeColorGrid extends StatefulWidget {
  final List<FlowThemeGroup> groups;
  final ValueChanged<FlowColorScheme> onChanged;
  final bool playInitialAnimation;
  final Duration animationDuration;
  final Duration animationStartDelay;

  const ThemeColorGrid({
    super.key,
    required this.groups,
    required this.onChanged,
    this.playInitialAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationStartDelay = const Duration(milliseconds: 250),
  });

  @override
  State<ThemeColorGrid> createState() => _ThemeColorGridState();
}

class _ThemeColorGridState extends State<ThemeColorGrid>
    with SingleTickerProviderStateMixin {
  late int _selectedGroupIndex;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedGroupIndex = _indexForCurrentTheme();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _playEntranceAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThemeColorGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      final int index = _indexForCurrentTheme();
      if (index != _selectedGroupIndex) {
        _selectedGroupIndex = index;
      }
      _playEntranceAnimation();
    }
  }

  void _playEntranceAnimation() {
    if (!widget.playInitialAnimation) {
      _animationController.value = 1.0;
      return;
    }

    _animationController.reset();
    Future<void>.delayed(widget.animationStartDelay, () {
      if (!mounted) return;
      _animationController.forward(from: 0.0);
    });
  }

  int _indexForCurrentTheme() {
    final String currentTheme = UserPreferencesService().themeName;

    for (int i = 0; i < widget.groups.length; i++) {
      if (widget.groups[i].schemes.any((scheme) => scheme.name == currentTheme)) {
        return i;
      }
    }

    return 0;
  }

  void _selectSubGroup(int index) {
    if (index == _selectedGroupIndex) return;
    setState(() {
      _selectedGroupIndex = index;
    });
    _playEntranceAnimation();
  }

  Animation<double> _swatchAnimation(int index, int count) {
    if (count <= 0) {
      return const AlwaysStoppedAnimation<double>(1.0);
    }

    final double staggerSpan = 0.75;
    final double itemSpan = staggerSpan / count;
    final double start = (index * itemSpan).clamp(0.0, 1.0);
    final double end = math.min(start + itemSpan + 0.15, 1.0);

    return CurvedAnimation(
      parent: _animationController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentTheme = UserPreferencesService().themeName;
    final FlowThemeGroup activeGroup = widget.groups[_selectedGroupIndex];
    final List<FlowColorScheme> schemes = activeGroup.schemes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.groups.length > 1) ...[
          Row(
            children: [
              for (int i = 0; i < widget.groups.length; i++) ...[
                if (i > 0) const SizedBox(width: 8.0),
                Expanded(
                  child: _SubGroupChip(
                    group: widget.groups[i],
                    selected: i == _selectedGroupIndex,
                    onTap: () => _selectSubGroup(i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14.0),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            const double cellSize = 44.0;
            const double spacing = 10.0;
            final int crossAxisCount = ((constraints.maxWidth + spacing) /
                    (cellSize + spacing))
                .floor()
                .clamp(4, 8);
            final int count = schemes.length;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1.0,
              ),
              itemCount: count,
              itemBuilder: (context, int index) {
                final FlowColorScheme scheme = schemes[index];
                final bool selected = scheme.name == currentTheme;
                final Animation<double> animation = _swatchAnimation(
                  index,
                  count,
                );

                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: _ColorSwatch(
                      scheme: scheme,
                      selected: selected,
                      onTap: () => widget.onChanged(scheme),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SubGroupChip extends StatelessWidget {
  final FlowThemeGroup group;
  final bool selected;
  final VoidCallback onTap;

  const _SubGroupChip({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ThemePreferencesTheme.cardFill : Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: selected
                  ? ThemePreferencesTheme.primary(context).withValues(alpha: 0.35)
                  : ThemePreferencesTheme.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (group.icon != null) ...[
                FlowIcon(
                  group.icon!,
                  size: 18.0,
                  color: selected
                      ? ThemePreferencesTheme.titleInk
                      : ThemePreferencesTheme.subtitleInk,
                ),
                const SizedBox(width: 6.0),
              ],
              Flexible(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    color: selected
                        ? ThemePreferencesTheme.titleInk
                        : ThemePreferencesTheme.subtitleInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final FlowColorScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.scheme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color onPrimary = scheme.onPrimary ?? Colors.white;

    return Semantics(
      label: themeNames[scheme.name] ?? scheme.name,
      button: true,
      selected: selected,
      child: Tooltip(
        message: themeNames[scheme.name] ?? scheme.name,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
                border: Border.all(
                  color: selected
                      ? ThemePreferencesTheme.primary(context)
                      : ThemePreferencesTheme.cardBorder.withValues(alpha: 0.6),
                  width: selected ? 2.5 : 1.0,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, color: onPrimary, size: 22.0)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
