import "package:flow/data/home_dashboard_widget_id.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/home_dashboard_preferences.dart";
import "package:flow/routes/preferences/button_order/button_order_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";

class HomeDashboardCustomizePage extends StatefulWidget {
  const HomeDashboardCustomizePage({super.key});

  @override
  State<HomeDashboardCustomizePage> createState() =>
      _HomeDashboardCustomizePageState();
}

class _HomeDashboardCustomizePageState extends State<HomeDashboardCustomizePage> {
  late List<HomeDashboardWidgetId> _order;
  late Set<HomeDashboardWidgetId> _hidden;

  @override
  void initState() {
    super.initState();
    _order = List<HomeDashboardWidgetId>.from(HomeDashboardPreferences.order);
    _hidden = Set<HomeDashboardWidgetId>.from(HomeDashboardPreferences.hidden);
  }

  Future<void> _persist() async {
    await HomeDashboardPreferences.setOrder(_order);
    await HomeDashboardPreferences.setHidden(_hidden);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final HomeDashboardWidgetId item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
    HapticFeedback.lightImpact();
    _persist();
  }

  void _toggleVisible(HomeDashboardWidgetId id, bool visible) {
    setState(() {
      if (visible) {
        _hidden.remove(id);
      } else {
        _hidden.add(id);
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ButtonOrderPreferencesTheme.canvas,
      appBar: AppBar(
        title: Text("home.dashboard.customize".t(context)),
        actions: [
          TextButton(
            onPressed: () async {
              await HomeDashboardPreferences.reset();
              if (!mounted) return;
              setState(() {
                _order = List<HomeDashboardWidgetId>.from(
                  HomeDashboardWidgetId.defaultOrder,
                );
                _hidden = {};
              });
            },
            child: Text("home.dashboard.customize.reset".t(context)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: Text(
                "home.dashboard.customize.hint".t(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ButtonOrderPreferencesTheme.subtitleInk,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
                buildDefaultDragHandles: false,
                itemCount: _order.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final HomeDashboardWidgetId id = _order[index];
                  final bool visible = !_hidden.contains(id);

                  return Card(
                    key: ValueKey(id.storageKey),
                    margin: const EdgeInsets.only(bottom: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ButtonOrderPreferencesTheme.cardRadius,
                      ),
                    ),
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Symbols.drag_indicator_rounded),
                      ),
                      title: Text(id.titleL10nKey.t(context)),
                      trailing: Switch(
                        value: visible,
                        onChanged: (v) => _toggleVisible(id, v),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
