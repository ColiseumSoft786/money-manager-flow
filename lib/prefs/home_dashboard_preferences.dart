import "package:flow/data/home_dashboard_widget_id.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flutter/foundation.dart";

/// Persisted order and visibility for Home dashboard cards.
class HomeDashboardPreferences {
  HomeDashboardPreferences._();

  static final ValueNotifier<int> revision = ValueNotifier(0);

  static List<HomeDashboardWidgetId> get order {
    final String? raw = LocalPreferences().homeDashboardOrder.value;
    if (raw == null || raw.trim().isEmpty) {
      return List<HomeDashboardWidgetId>.from(
        HomeDashboardWidgetId.defaultOrder,
      );
    }
    final List<HomeDashboardWidgetId> parsed = raw
        .split(",")
        .map((s) => HomeDashboardWidgetId.tryParse(s.trim()))
        .whereType<HomeDashboardWidgetId>()
        .toList();
    if (parsed.isEmpty) {
      return List<HomeDashboardWidgetId>.from(
        HomeDashboardWidgetId.defaultOrder,
      );
    }
    final Set<HomeDashboardWidgetId> seen = {};
    final List<HomeDashboardWidgetId> merged = [];
    for (final HomeDashboardWidgetId id in parsed) {
      if (seen.add(id)) merged.add(id);
    }
    for (final HomeDashboardWidgetId id in HomeDashboardWidgetId.defaultOrder) {
      if (seen.add(id)) merged.add(id);
    }
    return merged;
  }

  static Set<HomeDashboardWidgetId> get hidden {
    final String? raw = LocalPreferences().homeDashboardHidden.value;
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(",")
        .map((s) => HomeDashboardWidgetId.tryParse(s.trim()))
        .whereType<HomeDashboardWidgetId>()
        .toSet();
  }

  static List<HomeDashboardWidgetId> get visibleOrder =>
      order.where((id) => !hidden.contains(id)).toList();

  static Future<void> setOrder(List<HomeDashboardWidgetId> next) async {
    await LocalPreferences().homeDashboardOrder.set(
      next.map((e) => e.storageKey).join(","),
    );
    revision.value++;
  }

  static Future<void> setHidden(Set<HomeDashboardWidgetId> next) async {
    await LocalPreferences().homeDashboardHidden.set(
      next.map((e) => e.storageKey).join(","),
    );
    revision.value++;
  }

  static Future<void> reset() async {
    await LocalPreferences().homeDashboardOrder.remove();
    await LocalPreferences().homeDashboardHidden.remove();
    revision.value++;
  }
}
