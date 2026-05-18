import "package:flutter/material.dart";

/// Full-bleed background for setup profile flows — flat white (light) / surface (dark), no gradients.
class SetupProfilePageCanvas extends StatelessWidget {
  final Widget child;

  const SetupProfilePageCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color bg =
        light ? Colors.white : Theme.of(context).colorScheme.surface;

    return ColoredBox(color: bg, child: child);
  }
}
