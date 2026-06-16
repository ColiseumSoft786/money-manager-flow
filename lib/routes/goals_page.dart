import "package:flow/data/goalProgress.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/goal.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/goal_provider.dart";
import "package:flow/services/goal.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/goal_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<GoalProgress>? _progressList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  Future<void> _reload() async {
    final List<Goal> goals = GoalsProvider.of(context).goals;
    final List<GoalProgress> list = goals.map(computeGoalProgress).toList();
    if (!mounted) return;
    setState(() => _progressList = list);
  }

  Money? get _totalSaved {
    if (_progressList == null || _progressList!.isEmpty) return null;
    final String currency = _progressList!.first.saved.currency;
    double total = 0;
    for (final p in _progressList!) {
      total += p.saved.amount;
    }
    return Money(total, currency);
  }

  @override
  Widget build(BuildContext context) {
    final GoalsProvider provider = GoalsProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("goals.title".t(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF005DAA),
              ),
              onPressed: () async {
                await context.push("/goal/new");
                _reload();
              },
              child: Text("goals.new".t(context)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: !provider.ready || _progressList == null
            ? const Spinner.center()
            : _progressList!.isEmpty
                ? _buildEmptyState(context)
                : _buildList(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Button(
          dashedBorder: true,
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          onTap: () async {
            await context.push("/goal/new");
            _reload();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.emoji_events_rounded,
                  size: 28.0,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "goals.empty.title".t(context),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "goals.empty.subtitle".t(context),
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20.0),
              Button(
                dashedBorder: true,
                leading: const Icon(Symbols.add_rounded),
                child: Text("goals.create".t(context)),
                onTap: () async {
                  await context.push("/goal/new");
                  _reload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget heroCard(BuildContext context) {
    const Color primary = Color(0xFF0075D5);
    const Color onPrimary = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary,
              primary.withValues(alpha: 0.80),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "goals.hero.kicker".t(context),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: onPrimary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "goals.hero.title".t(context),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "goals.hero.subtitle".t(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "goals.hero.totalSaved".t(context),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: onPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    MoneyText(
                      _totalSaved,
                      displayAbsoluteAmount: true,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


   //build goal
  

  Widget _buildList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          heroCard(context),
          const SizedBox(height: 20.0),
          ..._progressList!.map(
            (progress) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: Dismissible(
                key: ValueKey(progress.goal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Icon(
                    Symbols.delete_rounded,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("goals.delete.title".t(ctx)),
                      content: Text(
                        "goals.delete.message".t(ctx, {
                          "name": progress.goal.name,
                        }),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text("general.cancel".t(ctx)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text("general.delete".t(ctx)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await GoalService().delete(progress.goal.id);
                  _reload();
                },
                child: GoalCard(
                  progress: progress,
                  onTap: () async {
                    await context.push(
                      "/goal/${progress.goal.id}/edit",
                    );
                    _reload();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }
}
