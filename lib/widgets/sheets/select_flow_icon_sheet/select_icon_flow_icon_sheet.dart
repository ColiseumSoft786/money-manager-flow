import "package:flow/data/flow_icon.dart";
import "package:flow/data/icons.dart";
import "package:flow/l10n/extensions.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [IconFlowIcon] or [null]
class SelectIconFlowIconSheet extends StatefulWidget {
  final FlowIconData? initialValue;

  const SelectIconFlowIconSheet({super.key, this.initialValue});

  @override
  State<SelectIconFlowIconSheet> createState() =>
      _SelectIconFlowIconSheetState();
}

class _SelectIconFlowIconSheetState extends State<SelectIconFlowIconSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  String _query = "";

  IconFlowIcon? value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue is IconFlowIcon
        ? widget.initialValue as IconFlowIcon
        : null;

    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> simpleIconsResult = querySimpleIcons(_query);
    final List<IconData> materialSymbolsResult = queryMaterialSymbols(_query);
    final double gridHeight = MediaQuery.sizeOf(context).height * 0.32;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                    Expanded(
                      child: Text(
                        "flowIcon.type.icon".t(context),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(value),
                      child: Text("general.done".t(context)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 4.0),
                child: TextField(
                  onChanged: _updateQuery,
                  onSubmitted: _updateQuery,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "flowIcon.type.icon.search".t(context),
                    prefixIcon: const Icon(Symbols.search_rounded, size: 20.0),
                  ),
                ),
              ),
              TabBar(
                controller: _controller,
                tabs: [
                  Tab(text: "flowIcon.type.icon.brands".t(context)),
                  Tab(text: "flowIcon.type.icon.symbols".t(context)),
                ],
              ),
              SizedBox(
                height: gridHeight,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (context, index) => IconButton(
                        onPressed: () => updateIcon(simpleIconsResult[index]),
                        icon: Icon(simpleIconsResult[index]),
                        iconSize: 40.0,
                      ),
                      itemCount: simpleIconsResult.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 64.0,
                      ),
                    ),
                    GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemBuilder: (context, index) => IconButton(
                        onPressed: () => updateIcon(materialSymbolsResult[index]),
                        icon: Icon(materialSymbolsResult[index]),
                        iconSize: 40.0,
                      ),
                      itemCount: materialSymbolsResult.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 64.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
    );
  }

  void _updateQuery(String value) {
    _query = value;
    setState(() {});
  }

  void updateIcon(IconData iconData) {
    value = IconFlowIcon(iconData);
    setState(() {});
  }
}
