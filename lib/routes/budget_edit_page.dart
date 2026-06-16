import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/services/budget.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class BudgetEditPage extends StatefulWidget {
  final int budgetId;

  bool get isNew => budgetId == 0;

  const BudgetEditPage.create({super.key}) : budgetId = 0;
  const BudgetEditPage({super.key, required this.budgetId});

  @override
  State<BudgetEditPage> createState() => _BudgetEditPageState();
}

class _BudgetEditPageState extends State<BudgetEditPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  TimeRange _range = TimeRange.thisMonth();
  final Set<String> _categoryUuids = {};
  double _alertThreshold = 0.8;
  bool _notifications = true;
  Budget? _existing;

  @override
  void initState() {
    super.initState();
    if (!widget.isNew) {
      _existing = ObjectBox().box<Budget>().get(widget.budgetId);
      if (_existing != null) {
        _nameController.text = _existing!.name;
        _amountController.text = _existing!.amount.toString();
        _range = _existing!.timeRange;
        _categoryUuids.addAll(_existing!.categoriesUuids ?? []);
        _alertThreshold = _existing!.alertThreshold;
        _notifications = _existing!.notificationsEnabled;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || _nameController.text.trim().isEmpty) return;

    final Budget budget = _existing ??
        Budget(
          name: _nameController.text.trim(),
          amount: amount,
          currency: UserPreferencesService().primaryCurrency,
          range: _range.toString(),
        );

    budget
      ..name = _nameController.text.trim()
      ..amount = amount
      ..range = _range.toString()
      ..alertThreshold = _alertThreshold
      ..notificationsEnabled = _notifications
      ..categoriesUuids = _categoryUuids.toList();

    final List<Category> cats = CategoriesProvider.of(context)
        .categories
        .where((c) => _categoryUuids.contains(c.uuid))
        .toList();

    await BudgetService().upsert(budget, categories: cats);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> all = CategoriesProvider.of(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew ? "budgets.new".t(context) : "budgets.edit".t(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text("general.save".t(context)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Surface(
                color: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.label_rounded,
                            size: 16.0,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            "budgets.label.name".t(context),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "budgets.nameHint".t(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Text(
                            "${UserPreferencesService().primaryCurrency}",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            "budgets.label.amount".t(context),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          prefixText:
                              "${UserPreferencesService().primaryCurrency} ",
                          hintText: "0.00",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                "budgets.label.period".t(context),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10.0),
              _buildPeriodSelector(context),
              const SizedBox(height: 20.0),
              const WavyDivider(),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "budgets.label.categories".t(context),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_categoryUuids.length == all.length) {
                          _categoryUuids.clear();
                        } else {
                          _categoryUuids.addAll(all.map((c) => c.uuid));
                        }
                      });
                    },
                    child: Text(
                      _categoryUuids.length == all.length
                          ? "general.select.deselectAll".t(context)
                          : "general.select.all".t(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Surface(
                color: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                builder: (context) => Column(
                  children: [
                    for (int i = 0; i < all.length; i++) ...[
                      _buildCategoryTile(all[i]),
                      if (i < all.length - 1) const Divider(height: 1.0),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              const WavyDivider(),
              const SizedBox(height: 20.0),
              ListHeader("budgets.alertAt".t(context), padding: EdgeInsets.zero),
              const SizedBox(height: 8.0),
              Surface(
                color: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "budgets.warnAt".t(context, {
                              "percent": (_alertThreshold * 100).round().toString(),
                            }),
                            style: context.textTheme.bodyLarge,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              "${(_alertThreshold * 100).round()}%",
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _alertThreshold,
                        min: 0.5,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (v) => setState(() => _alertThreshold = v),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            _notifications
                                ? Symbols.notifications_active_rounded
                                : Symbols.notifications_off_rounded,
                            size: 20.0,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              "budgets.notifications".t(context),
                              style: context.textTheme.bodyLarge,
                            ),
                          ),
                          Switch(
                            value: _notifications,
                            onChanged: (v) =>
                                setState(() => _notifications = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final periods = [
      (TimeRange.thisLocalWeek(), "budgets.period.week"),
      (TimeRange.thisMonth(), "budgets.period.month"),
      (TimeRange.thisYear(), "budgets.period.year"),
    ];

    return Row(
      children: periods.map((entry) {
        final bool selected = _range.toString() == entry.$1.toString();
        final Color bg = selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent;
        final Color fg = selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface;
        final Color border = selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => setState(() => _range = entry.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: border, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.$2.t(context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryTile(Category category) {
    final bool selected = _categoryUuids.contains(category.uuid);

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _categoryUuids.remove(category.uuid);
          } else {
            _categoryUuids.add(category.uuid);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            FlowIcon(category.icon, size: 32.0, plated: true),
            const SizedBox(width: 14.0),
            Expanded(
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              selected
                  ? Symbols.check_circle_rounded
                  : Symbols.circle_rounded,
              size: 26.0,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
