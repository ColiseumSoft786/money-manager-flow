import "dart:async";

import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flutter/material.dart";

class BudgetsProviderScope extends StatefulWidget {
  final Widget child;

  const BudgetsProviderScope({super.key, required this.child});

  @override
  State<BudgetsProviderScope> createState() => _BudgetsProviderScopeState();
}

class _BudgetsProviderScopeState extends State<BudgetsProviderScope> {
  late final StreamSubscription _subscription;
  List<Budget>? _budgets;

  @override
  void initState() {
    super.initState();
    _subscription = ObjectBox()
        .box<Budget>()
        .query()
        .watch(triggerImmediately: true)
        .listen((Query<Budget> query) {
      setState(() {
        _budgets = query.find();
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BudgetsProvider(_budgets, child: widget.child);
}

class BudgetsProvider extends InheritedWidget {
  final List<Budget>? _budgets;

  bool get ready => _budgets != null;
  List<Budget> get budgets => _budgets ?? [];

  const BudgetsProvider(this._budgets, {super.key, required super.child});

  static BudgetsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BudgetsProvider>()!;

  @override
  bool updateShouldNotify(BudgetsProvider oldWidget) =>
      !identical(_budgets, oldWidget._budgets);
}