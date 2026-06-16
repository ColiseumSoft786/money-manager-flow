import "package:flow/data/budgetProgress.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/budget.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/budget_provider.dart";
import "package:flow/services/budget.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/budget_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  List<BudgetProgress>? _progressList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  Future<void> _reload() async {
    final List<Budget> budgets = BudgetsProvider.of(context).budgets;
    final List<BudgetProgress> list = await Future.wait(
      budgets.map(computeBudgetProgress),
    );
    if (!mounted) return;
    setState(() => _progressList = list);
  }

  Money? get _totalSpent {
    if (_progressList == null || _progressList!.isEmpty) return null;
    final String currency = _progressList!.first.spent.currency;
    double total = 0;
    for (final p in _progressList!) {
      total += p.spent.amount;
    }
    return Money(total, currency);
  }

  @override
  Widget build(BuildContext context) {
    final BudgetsProvider provider = BudgetsProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("budgets.title".t(context)),
      ),
      floatingActionButton: _progressList != null && _progressList!.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await context.push("/budget/new");
                _reload();
              },
              child: const Icon(Symbols.add_rounded),
            )
          : null,
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
            await context.push("/budget/new");
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
                  Symbols.account_balance_wallet_rounded,
                  size: 28.0,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "budgets.empty.title".t(context),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "budgets.empty.subtitle".t(context),
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20.0),
              Button(
                leading: const Icon(Symbols.add_rounded),
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                child: Text("budgets.create".t(context)),
                onTap: () async {
                  await context.push("/budget/new");
                  _reload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _computeInsight(BuildContext context) {
    if (_progressList == null || _progressList!.isEmpty) return "";

    final double totalSpent = _progressList!.fold(
      0.0,
      (sum, p) => sum + p.spent.amount,
    );
    final double totalLimit = _progressList!.fold(
      0.0,
      (sum, p) => sum + p.limit.amount,
    );

    final int overCount = _progressList!.where((p) => p.isCritical).length;
    final int alertCount = _progressList!.where((p) => p.shouldAlert).length;
    final double remaining = totalLimit - totalSpent;

    if (overCount > 0) {
      return "budgets.insights.exceeded".t(context, {
        "count": overCount.toString(),
      });
    }

    if (alertCount > 0) {
      return "budgets.insights.approaching".t(context, {
        "count": alertCount.toString(),
      });
    }

    if (remaining > 0) {
      final String currency = _progressList!.first.spent.currency;
      return "budgets.insights.saving".t(context, {
        "amount": "$currency ${remaining.toStringAsFixed(0)}",
      });
    }

    return "budgets.insights.onTrack".t(context);
  }

  Widget _buildInsightsCard(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary,
              primary.withValues(alpha: 0.80),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
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
              "budgets.insights.title".t(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              _computeInsight(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                MoneyText(
                  _totalSpent,
                  displayAbsoluteAmount: true,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  "budgets.totalSpentThisMonth".t(context),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ..._progressList!.map(
            (progress) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: Dismissible(
                key: ValueKey(progress.budget.id),
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
                      title: Text("budgets.delete.title".t(ctx)),
                      content: Text(
                        "budgets.delete.message".t(ctx, {
                          "name": progress.budget.name,
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
                  await BudgetService().delete(progress.budget.id);
                  _reload();
                },
                child: BudgetCard(
                  progress: progress,
                  onTap: () async {
                    await context.push(
                      "/budget/${progress.budget.id}/edit",
                    );
                    _reload();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _buildInsightsCard(context),
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }
}
