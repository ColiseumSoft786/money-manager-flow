

import "dart:async";

import "package:flow/entity/subscription.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flutter/material.dart";

class SubscriptionsProviderScope extends StatefulWidget {
  final Widget child;
  const SubscriptionsProviderScope({super.key, required this.child});
  @override
  State<SubscriptionsProviderScope> createState() =>
      _SubscriptionsProviderScopeState();
}

class _SubscriptionsProviderScopeState extends State<SubscriptionsProviderScope> {
  late final StreamSubscription _subscription;
  List<Subscription>? _items;
    @override
  void initState() {
    super.initState();
    _subscription = ObjectBox()
        .box<Subscription>()
        .query()
        .order(Subscription_.sortOrder)
        .watch(triggerImmediately: true)
        .listen((Query<Subscription> query) {
      setState(() => _items = query.find());
    });
  }

   @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) =>
      SubscriptionsProvider(_items, child: widget.child);

}
class SubscriptionsProvider extends InheritedWidget {
  final List<Subscription>? _items;
  bool get ready => _items != null;
  List<Subscription> get subscriptions => _items ?? [];
  const SubscriptionsProvider(this._items, {super.key, required super.child});
  static SubscriptionsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SubscriptionsProvider>()!;
  @override
  bool updateShouldNotify(SubscriptionsProvider oldWidget) =>
      !identical(_items, oldWidget._items);
}