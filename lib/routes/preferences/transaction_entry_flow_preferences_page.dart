import "package:flow/entity/user_preferences/transaction_entry_flow.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/transaction_entry_flow/transaction_entry_flow_preferences_theme.dart";
import "package:flow/routes/preferences/transaction_entry_flow/widgets/entry_flow_action_tile.dart";
import "package:flow/routes/preferences/transaction_entry_flow/widgets/entry_flow_add_actions_section.dart";
import "package:flow/routes/preferences/transaction_entry_flow/widgets/entry_flow_hero_card.dart";
import "package:flow/routes/preferences/transaction_entry_flow/widgets/entry_flow_settings_card.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";

class TransactionEntryFlowPreferencesPage extends StatefulWidget {
  const TransactionEntryFlowPreferencesPage({super.key});

  @override
  State<TransactionEntryFlowPreferencesPage> createState() =>
      _TransactionEntryFlowPreferencesPageState();
}

class _TransactionEntryFlowPreferencesPageState
    extends State<TransactionEntryFlowPreferencesPage> {
  late final List<TransactionEntryAction> _actions;
  bool _abandonUponActionCancelled = false;
  bool _skipSelectedFields = true;

  @override
  void initState() {
    super.initState();

    _actions = List.from(UserPreferencesService().transactionEntryFlow.actions);
    _abandonUponActionCancelled = UserPreferencesService()
        .transactionEntryFlow
        .abandonUponActionCancelled;
    _skipSelectedFields =
        UserPreferencesService().transactionEntryFlow.skipSelectedFields;
  }

  @override
  void dispose() {
    UserPreferencesService().transactionEntryFlow = TransactionEntryFlow(
      actions: _actions,
      abandonUponActionCancelled: _abandonUponActionCancelled,
      skipSelectedFields: _skipSelectedFields,
    );
    super.dispose();
  }

  List<TransactionEntryAction> get _availableActions =>
      TransactionEntryAction.values
          .where((action) => !_actions.contains(action))
          .toList();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TransactionEntryFlowPreferencesTheme.canvas(context),
      appBar: AppBar(
        title: Text("preferences.transactionEntryFlow.settingsTitle".t(context)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const EntryFlowHeroCard(),
                        const SizedBox(height: 16.0),
                        EntryFlowSettingsCard(
                          skipSelectedFields: _skipSelectedFields,
                          abandonUponActionCancelled: _abandonUponActionCancelled,
                          onSkipSelectedFieldsChanged: (bool value) {
                            setState(() => _skipSelectedFields = value);
                          },
                          onAbandonUponActionCancelledChanged: (bool value) {
                            setState(
                              () => _abandonUponActionCancelled = value,
                            );
                          },
                        ),
                        const SizedBox(height: 20.0),
                        _SequenceHeader(),
                        const SizedBox(height: 10.0),
                      ]),
                    ),
                  ),
                  if (_actions.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          "preferences.transactionEntryFlow.actions.description"
                              .t(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TransactionEntryFlowPreferencesTheme.subtitleInk(
                              context,
                            ),
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverReorderableList(
                        itemBuilder: (context, int index) {
                          final TransactionEntryAction action = _actions[index];
                          return Padding(
                            key: ValueKey(action.value),
                            padding: EdgeInsets.only(
                              bottom: index < _actions.length - 1 ? 10.0 : 0.0,
                            ),
                            child: EntryFlowActionTile(
                              action: action,
                              stepNumber: index + 1,
                              listIndex: index,
                              onDelete: () {
                                setState(() => _actions.remove(action));
                              },
                            ),
                          );
                        },
                        itemCount: _actions.length,
                        onReorder: onReorder,
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    sliver: SliverToBoxAdapter(
                      child: EntryFlowAddActionsSection(
                        availableActions: _availableActions,
                        onAdd: (TransactionEntryAction action) {
                          setState(() => _actions.add(action));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TransactionEntryAction removed = _actions.removeAt(oldIndex);
    _actions.insert(newIndex, removed);

    if (_actions.contains(TransactionEntryAction.inputTitle)) {
      _actions.remove(TransactionEntryAction.inputTitle);
      _actions.add(TransactionEntryAction.inputTitle);
    }

    setState(() {});
  }
}

class _SequenceHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "preferences.transactionEntryFlow.section.entrySequence"
                .t(context)
                .toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: TransactionEntryFlowPreferencesTheme.sectionLabel(context),
              fontWeight: FontWeight.w700,
              fontSize: 11.0,
              letterSpacing: 1.1,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: TransactionEntryFlowPreferencesTheme.dragChipFill,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(
              "preferences.transactionEntryFlow.dragToReorder".t(context),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TransactionEntryFlowPreferencesTheme.subtitleInk(context),
                fontWeight: FontWeight.w700,
                fontSize: 10.0,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
