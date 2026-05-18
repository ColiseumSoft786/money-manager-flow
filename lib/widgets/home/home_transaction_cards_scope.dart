import "package:flutter/material.dart";

/// When present under the subtree, transaction list tiles gain elevated-card chrome
/// (home history design). Other tabs/routes omit this ancestor.
class HomeTransactionCardsScope extends InheritedWidget {
  /// When false, behaves like no scope (delegates unchanged tile styling).
  final bool enabled;

  const HomeTransactionCardsScope({
    super.key,
    required super.child,
    this.enabled = true,
  });

  static bool enabledIn(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<HomeTransactionCardsScope>()
            ?.enabled ??
        false;
  }

  @override
  bool updateShouldNotify(covariant HomeTransactionCardsScope oldWidget) =>
      oldWidget.enabled != enabled;
}
