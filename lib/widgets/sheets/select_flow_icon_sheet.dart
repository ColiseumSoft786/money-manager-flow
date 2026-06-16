import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

enum FlowIconPickerKind { symbol, character, image }

/// Compact menu: pops [FlowIconPickerKind]. Picker opens after this closes.
class SelectFlowIconSheet extends StatelessWidget {
  final FlowIconData? current;

  const SelectFlowIconSheet({super.key, this.current});

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      titleSpacing: 0.0,
      leadingSpacing: 0.0,
      trailingSpacing: 0.0,
      title: Text("flowIcon.change".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuTile(
            context,
            icon: Symbols.interests_rounded,
            label: "flowIcon.type.icon".t(context),
            kind: FlowIconPickerKind.symbol,
          ),
          _menuTile(
            context,
            icon: Symbols.glyphs_rounded,
            label: "flowIcon.type.character".t(context),
            kind: FlowIconPickerKind.character,
          ),
          _menuTile(
            context,
            icon: Symbols.image_rounded,
            label: "flowIcon.type.image".t(context),
            kind: FlowIconPickerKind.image,
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required FlowIconPickerKind kind,
  }) {
    return InkWell(
      onTap: () => context.pop(kind),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 22.0),
            const SizedBox(width: 12.0),
            Expanded(child: Text(label)),
            const LeChevron(),
          ],
        ),
      ),
    );
  }
}
