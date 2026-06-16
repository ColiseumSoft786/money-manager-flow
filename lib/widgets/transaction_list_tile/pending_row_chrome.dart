import "package:flow/entity/transaction.dart";
import "package:flutter/material.dart";

/// Animates the pending confirm strip when it appears or disappears.
class PendingRowChrome extends StatelessWidget {
  final Transaction transaction;
  final bool showPendingConfirmation;
  final Widget confirmButtonRow;

  const PendingRowChrome({
    super.key,
    required this.transaction,
    required this.showPendingConfirmation,
    required this.confirmButtonRow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: showPendingConfirmation
          ? KeyedSubtree(
              key: ValueKey<String>("pending-${transaction.uuid}"),
              child: confirmButtonRow,
            )
          : SizedBox(
              key: ValueKey<String>("confirmed-${transaction.uuid}"),
            ),
    );
  }
}
