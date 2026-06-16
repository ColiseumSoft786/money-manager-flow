import "package:flow/utils/extensions/directionality.dart";
import "package:flow/utils/flow_haptics.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";

class DirectionalSlidable extends StatefulWidget {
  final List<SlidableAction>? startActions;
  final List<SlidableAction>? endActions;
  final Widget child;
  final Key? dismissibleKey;
  final String? groupTag;

  const DirectionalSlidable({
    super.key,
    this.startActions,
    this.endActions,
    required this.child,
    this.dismissibleKey,
    this.groupTag,
  });

  @override
  State<DirectionalSlidable> createState() => _DirectionalSlidableState();
}

class _DirectionalSlidableState extends State<DirectionalSlidable>
    with SingleTickerProviderStateMixin {
  late final SlidableController _controller;
  bool _slideHapticSent = false;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
    _controller.animation.addListener(_onSlideAnimation);
  }

  @override
  void dispose() {
    _controller.animation.removeListener(_onSlideAnimation);
    _controller.dispose();
    super.dispose();
  }

  void _onSlideAnimation() {
    final double ratio = _controller.animation.value.abs();
    if (ratio > 0.22 && !_slideHapticSent) {
      _slideHapticSent = true;
      flowHapticLight();
    }
    if (ratio < 0.05) {
      _slideHapticSent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr = context.isLtr;

    final List<SlidableAction>? directinalStartActions = (isLtr
        ? widget.startActions
        : widget.endActions);
    final List<SlidableAction>? directinalEndActions = (isLtr
        ? widget.endActions
        : widget.startActions);

    return Slidable(
      controller: _controller,
      key: widget.dismissibleKey,
      groupTag: widget.groupTag,
      startActionPane: getPane(directinalStartActions),
      endActionPane: getPane(directinalEndActions),
      useTextDirection: false,
      child: widget.child,
    );
  }

  ActionPane? getPane(List<SlidableAction>? actions) {
    if (actions == null || actions.isEmpty) {
      return ActionPane(
        motion: const DrawerMotion(),
        closeThreshold: 1 - 0.000000000000001,
        openThreshold: 1 - 0.000000000000001,
        children: const [],
      );
    }

    return ActionPane(motion: const DrawerMotion(), children: actions);
  }
}
