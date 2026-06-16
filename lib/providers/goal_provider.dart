import "dart:async";

import "package:flow/entity/goal.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flutter/material.dart";

class GoalsProviderScope extends StatefulWidget {
  final Widget child;

  const GoalsProviderScope({super.key, required this.child});

  @override
  State<GoalsProviderScope> createState() => _GoalsProviderScopeState();
}

class _GoalsProviderScopeState extends State<GoalsProviderScope> {
  late final StreamSubscription _subscription;
  List<Goal>? _goals;

  @override
  void initState() {
    super.initState();
    _subscription = ObjectBox()
        .box<Goal>()
        .query()
        .watch(triggerImmediately: true)
        .listen((Query<Goal> query) {
      setState(() {
        _goals = query.find();
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
      GoalsProvider(_goals, child: widget.child);
}

class GoalsProvider extends InheritedWidget {
  final List<Goal>? _goals;

  bool get ready => _goals != null;
  List<Goal> get goals => _goals ?? [];

  const GoalsProvider(this._goals, {super.key, required super.child});

  static GoalsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GoalsProvider>()!;

  @override
  bool updateShouldNotify(GoalsProvider oldWidget) =>
      !identical(_goals, oldWidget._goals);
}