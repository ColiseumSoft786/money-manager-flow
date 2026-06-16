import "package:flutter/material.dart";

/// Fades and slides [child] in once when the list row is built.
class StaggeredListEntry extends StatefulWidget {
  final int listIndex;
  final Widget child;
  final bool enabled;

  const StaggeredListEntry({
    super.key,
    required this.listIndex,
    required this.child,
    this.enabled = true,
  });

  @override
  State<StaggeredListEntry> createState() => _StaggeredListEntryState();
}

class _StaggeredListEntryState extends State<StaggeredListEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    if (!widget.enabled || widget.listIndex > 14) {
      _controller.value = 1.0;
      return;
    }

    final int delayMs = (widget.listIndex % 8) * 40;
    Future<void>.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(_opacity),
        child: widget.child,
      ),
    );
  }
}
