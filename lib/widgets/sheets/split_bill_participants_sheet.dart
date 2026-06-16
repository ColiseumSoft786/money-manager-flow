import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class SplitBillParticipantsResult {
  final List<String> names;
  final String payerName;

  const SplitBillParticipantsResult({
    required this.names,
    required this.payerName,
  });
}

class SplitBillParticipantsSheet extends StatefulWidget {
  final List<String> initialNames;
  final String initialPayerName;

  const SplitBillParticipantsSheet({
    super.key,
    required this.initialNames,
    required this.initialPayerName,
  });

  @override
  State<SplitBillParticipantsSheet> createState() =>
      _SplitBillParticipantsSheetState();
}

class _SplitBillParticipantsSheetState
    extends State<SplitBillParticipantsSheet> {
  late final List<TextEditingController> _controllers;
  late String _payerName;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialNames
        .map((name) => TextEditingController(text: name))
        .toList();
    _payerName = widget.initialPayerName;
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _names => _controllers
      .map((c) => c.text.trim())
      .where((n) => n.isNotEmpty)
      .toList();

  void _addParticipant() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeParticipant(int index) {
    if (_controllers.length <= 2) return;
    final String removed = _controllers[index].text.trim();
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      if (_payerName == removed) {
        _payerName = _names.isNotEmpty ? _names.first : "";
      }
    });
  }

  void _save() {
    final List<String> names = _names;
    if (names.length < 2) return;

    String payer = _payerName;
    if (!names.contains(payer)) {
      payer = names.first;
    }

    Navigator.of(context).pop(
      SplitBillParticipantsResult(names: names, payerName: payer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canSave = _names.length >= 2;

    return ModalSheet(
      title: Text("splitBill.participants.title".t(context)),
      trailing: TextButton(
        onPressed: canSave ? _save : null,
        child: Text("general.done".t(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "splitBill.participants.hint".t(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(0x99),
              ),
            ),
            const SizedBox(height: 12.0),
            ...List.generate(_controllers.length, (index) {
              final String name = _controllers[index].text.trim();
              final bool isPayer = name.isNotEmpty && name == _payerName;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: "splitBill.participants.name".t(
                            context,
                            {"index": "${index + 1}"},
                          ),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      tooltip: "splitBill.participants.payer".t(context),
                      onPressed: name.isEmpty
                          ? null
                          : () => setState(() => _payerName = name),
                      icon: Icon(
                        Symbols.paid_rounded,
                        fill: isPayer ? 1.0 : 0.0,
                        color: isPayer
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    if (_controllers.length > 2)
                      IconButton(
                        tooltip: "general.delete".t(context),
                        onPressed: () => _removeParticipant(index),
                        icon: const Icon(Symbols.close_rounded),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addParticipant,
              icon: const Icon(Symbols.person_add_rounded, size: 20.0),
              label: Text("splitBill.participants.add".t(context)),
            ),
          ],
        ),
      ),
    );
  }
}
