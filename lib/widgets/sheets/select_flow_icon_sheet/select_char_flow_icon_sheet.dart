import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SelectCharFlowIconSheet extends StatefulWidget {
  final FlowIconData? initialValue;

  final double iconSize;

  const SelectCharFlowIconSheet({
    super.key,
    this.initialValue,
    required this.iconSize,
  });

  @override
  State<SelectCharFlowIconSheet> createState() =>
      _SelectCharFlowIconSheetState();
}

class _SelectCharFlowIconSheetState extends State<SelectCharFlowIconSheet> {
  late final TextEditingController _characterTextController;

  final FocusNode _textFieldFocusNode = FocusNode();

  CharacterFlowIcon? value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue is CharacterFlowIcon
        ? widget.initialValue as CharacterFlowIcon
        : null;
    _characterTextController = TextEditingController(text: value?.character);
  }

  @override
  void dispose() {
    _characterTextController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        "flowIcon.type.character".t(context),
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
                padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 12.0),
                child: Center(
                  child: Surface(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                      side: BorderSide(
                        color:
                            (_textFieldFocusNode.hasPrimaryFocus ||
                                _textFieldFocusNode.hasFocus)
                            ? scheme.primary
                            : kTransparent,
                        width: 2.0,
                      ),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox.square(
                        dimension: widget.iconSize,
                        child: Center(
                          child: TextField(
                            autofocus: true,
                            focusNode: _textFieldFocusNode,
                            showCursor: false,
                            cursorWidth: 0.0,
                            controller: _characterTextController,
                            onChanged: (_) => updateCharacter(),
                            style: TextStyle(
                              fontSize: widget.iconSize * 0.5,
                              height: 1.0,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSecondary,
                              decoration: null,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: "?",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 12.0),
                child: Text(
                  "flowIcon.type.character.description".t(context),
                  style: context.textTheme.bodySmall?.semi(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateCharacter() {
    if (_characterTextController.text.characters.isEmpty) return;

    _characterTextController.text =
        _characterTextController.text.characters.last;
    value = CharacterFlowIcon(_characterTextController.text);
    setState(() {});
  }
}
