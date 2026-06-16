import "package:flow/data/money.dart";
import "package:flow/data/subscription_insight.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/subscription.dart";
import "package:flow/entity/subscription_status.dart";
import "package:flow/services/subscription.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:url_launcher/url_launcher.dart";

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<SubscriptionInsight>? _insights;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await SubscriptionService().buildAllInsights();
    if (!mounted) return;
    setState(() => _insights = list);
  }

  double get _monthlyTotal {
    if (_insights == null) return 0;
    return _insights!
        .where((i) => i.isActive)
        .fold(0.0, (sum, i) => sum + i.monthlyAmount.amount);
  }

  double get _potentialSavings {
    if (_insights == null) return 0;
    return _insights!
        .where((i) => i.isActive && i.isUnusedWarning)
        .fold(0.0, (sum, i) => sum + i.monthlyAmount.amount);
  }

  @override
  Widget build(BuildContext context) {
    final String currency = UserPreferencesService().primaryCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text("subscriptions.title".t(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Symbols.add_rounded),
      ),
      body: _insights == null
          ? const Spinner.center()
          : _insights!.isEmpty
              ? _EmptyImportView(onImported: _reload)
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _SummaryHeader(
                        monthlyTotal: Money(_monthlyTotal, currency),
                        yearlyTotal: Money(_monthlyTotal * 12, currency),
                        potentialSavings: _potentialSavings > 0
                            ? Money(_potentialSavings, currency)
                            : null,
                      ),
                      const SizedBox(height: 16.0),
                      ..._insights!.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _SubscriptionCard(
                            insight: insight,
                            onChanged: _reload,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final List<RecurringTransaction> unlinked =
        SubscriptionService().findUnlinkedRecurringExpensesSync();

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.edit_rounded),
              title: Text("subscriptions.addManually".t(context)),
              onTap: () {
                Navigator.pop(context);
                context.push("/subscription/new");
              },
            ),
            if (unlinked.isNotEmpty)
              ListTile(
                leading: const Icon(Symbols.sync_rounded),
                title: Text(
                  "subscriptions.importFromRecurring".t(context, {
                    "count": unlinked.length.toString(),
                  }),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _importRecurring(context, unlinked);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _importRecurring(
    BuildContext context,
    List<RecurringTransaction> recurrings,
  ) async {
    for (final recurring in recurrings) {
      SubscriptionService().createFromRecurringSync(recurring);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "subscriptions.imported".t(context, {
              "count": recurrings.length.toString(),
            }),
          ),
        ),
      );
    }
    await _reload();
  }
}

class _SummaryHeader extends StatelessWidget {
  final Money monthlyTotal;
  final Money yearlyTotal;
  final Money? potentialSavings;

  const _SummaryHeader({
    required this.monthlyTotal,
    required this.yearlyTotal,
    this.potentialSavings,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Surface(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "subscriptions.monthlyHeader".t(context),
              style: text.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8.0),
            MoneyText(
              monthlyTotal,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              "subscriptions.perYear".t(context, {
                "amount": yearlyTotal.formattedCompact,
              }),
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (potentialSavings != null) ...[
              const SizedBox(height: 12.0),
              Text(
                "subscriptions.potentialSavings".t(context, {
                  "amount": potentialSavings!.formattedCompact,
                }),
                style: text.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionInsight insight;
  final VoidCallback onChanged;

  const _SubscriptionCard({
    required this.insight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Subscription sub = insight.subscription;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    final String statusLabel = switch (sub.status) {
      SubscriptionStatus.active =>
        "subscriptions.status.active".t(context),
      SubscriptionStatus.cancelled =>
        "subscriptions.status.cancelled".t(context),
      SubscriptionStatus.paused => "subscriptions.status.paused".t(context),
    };

    return Surface(
      builder: (context) => InkWell(
        onTap: () async {
          await context.push("/subscription/${sub.id}/edit");
          onChanged();
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sub.name,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  statusLabel,
                  style: text.labelMedium?.copyWith(
                    color: insight.isActive
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            MoneyText(
              insight.monthlyAmount,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (insight.daysSinceLastUse != null) ...[
              const SizedBox(height: 4.0),
              Text(
                insight.isUnusedWarning
                    ? "subscriptions.notUsedIn".t(context, {
                        "days": insight.daysSinceLastUse.toString(),
                      })
                    : "subscriptions.lastUsedDaysAgo".t(context, {
                        "days": insight.daysSinceLastUse.toString(),
                      }),
                style: text.bodySmall?.copyWith(
                  color: insight.isUnusedWarning
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
            if (insight.showCancelReminder && insight.cancelByDate != null) ...[
              const SizedBox(height: 4.0),
              Text(
                "subscriptions.cancelByDate".t(context, {
                  "date": Moment(insight.cancelByDate!).format("MMM D, YYYY"),
                }),
                style: text.bodySmall?.copyWith(
                  color: colors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (sub.cancelUrl != null && sub.cancelUrl!.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              TextButton.icon(
                onPressed: () => _openCancelUrl(sub.cancelUrl!),
                icon: const Icon(Symbols.open_in_new_rounded, size: 18.0),
                label: Text("subscriptions.openCancelPage".t(context)),
              ),
            ],
            if (insight.isActive) ...[
              const SizedBox(height: 4.0),
              TextButton(
                onPressed: () {
                  sub.status = SubscriptionStatus.cancelled;
                  SubscriptionService().upsertSync(sub);
                  onChanged();
                },
                child: Text("subscriptions.markCancelled".t(context)),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _openCancelUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _EmptyImportView extends StatelessWidget {
  final Future<void> Function() onImported;

  const _EmptyImportView({required this.onImported});

  @override
  Widget build(BuildContext context) {
    final List<RecurringTransaction> unlinked =
        SubscriptionService().findUnlinkedRecurringExpensesSync();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.subscriptions_rounded,
              size: 64.0,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16.0),
            Text(
              "subscriptions.empty.title".t(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              "subscriptions.empty.subtitle".t(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20.0),
            if (unlinked.isNotEmpty)
              FilledButton.icon(
                onPressed: () async {
                  for (final r in unlinked) {
                    SubscriptionService().createFromRecurringSync(r);
                  }
                  await onImported();
                },
                icon: const Icon(Symbols.sync_rounded),
                label: Text(
                  "subscriptions.importCount".t(context, {
                    "count": unlinked.length.toString(),
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
