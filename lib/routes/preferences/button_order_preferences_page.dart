import "package:flow/data/flow_button_type.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/button_order/button_order_preferences_theme.dart";
import "package:flow/routes/preferences/button_order/widgets/button_order_info_banner.dart";
import "package:flow/routes/preferences/button_order/widgets/button_order_reorder_tile.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class ButtonOrderPreferencesPage extends StatefulWidget {
  const ButtonOrderPreferencesPage({super.key});

  @override
  State<ButtonOrderPreferencesPage> createState() =>
      ButtonOrderPreferencesPageState();
}

class ButtonOrderPreferencesPageState extends State<ButtonOrderPreferencesPage> {
  late List<FlowButtonType> _buttonOrder;

  @override
  void initState() {
    super.initState();
    _buttonOrder = _visibleButtonOrder();
  }

  List<FlowButtonType> _visibleButtonOrder() {
    final List<FlowButtonType> order = List<FlowButtonType>.from(
      UserPreferencesService().transactionButtonOrder,
    );

    if (EnyService().apiKey.value?.startsWith("eny") != true) {
      order.remove(FlowButtonType.eny);
    }

    return order;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ButtonOrderPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: ButtonOrderPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "preferences.transactionButtonOrder".t(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: ButtonOrderPreferencesTheme.titleInk,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: kFlowAccountRowDividerLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "preferences.transactionButtonOrder.section.reorder".t(
                      context,
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: ButtonOrderPreferencesTheme.titleInk,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "preferences.transactionButtonOrder.section.reorderDescription"
                        .t(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ButtonOrderPreferencesTheme.subtitleInk,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                buildDefaultDragHandles: false,
                proxyDecorator:
                    (Widget child, int index, Animation<double> animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          return Material(
                            elevation: 4.0 * animation.value,
                            color: Colors.transparent,
                            shadowColor: Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              ButtonOrderPreferencesTheme.cardRadius,
                            ),
                            child: child,
                          );
                        },
                      );
                    },
                onReorder: _handleReorder,
                itemCount: _buttonOrder.length,
                itemBuilder: (context, int index) {
                  final FlowButtonType type = _buttonOrder[index];

                  return Padding(
                    key: ValueKey<FlowButtonType>(type),
                    padding: EdgeInsets.only(
                      bottom: index < _buttonOrder.length - 1 ? 10.0 : 0.0,
                    ),
                    child: ButtonOrderReorderTile(
                      type: type,
                      index: index,
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: ButtonOrderInfoBanner(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final FlowButtonType moved = _buttonOrder.removeAt(oldIndex);
    final List<FlowButtonType> nextOrder = List<FlowButtonType>.from(_buttonOrder)
      ..insert(newIndex, moved);

    setState(() {
      _buttonOrder = nextOrder;
    });

    UserPreferencesService().transactionButtonOrder = _mergeWithHiddenEny(nextOrder);

    if (LocalPreferences().enableHapticFeedback.value == true) {
      HapticFeedback.lightImpact();
    }
  }

  /// Keeps [FlowButtonType.eny] in stored order when it is hidden in this UI.
  List<FlowButtonType> _mergeWithHiddenEny(List<FlowButtonType> visibleOrder) {
    if (EnyService().apiKey.value?.startsWith("eny") == true) {
      return visibleOrder;
    }

    final List<FlowButtonType> stored = List<FlowButtonType>.from(
      UserPreferencesService().transactionButtonOrder,
    );

    if (!stored.contains(FlowButtonType.eny)) {
      return visibleOrder;
    }

    final List<FlowButtonType> merged = List<FlowButtonType>.from(visibleOrder);
    final int enyIndex = stored.indexOf(FlowButtonType.eny);
    merged.insert(enyIndex.clamp(0, merged.length), FlowButtonType.eny);
    return merged;
  }
}
