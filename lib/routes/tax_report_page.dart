import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TaxReportPage extends StatefulWidget {
  const TaxReportPage({super.key});

  @override
  State<TaxReportPage> createState() => _TaxReportPageState();
}

class _TaxReportPageState extends State<TaxReportPage> {
  late int _selectedYear;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _availableYears = _getAvailableYears();
  }

  List<int> _getAvailableYears() {
    final int currentYear = DateTime.now().year;
    return List.generate(5, (i) => currentYear - i);
  }

  static final Condition<Transaction> _notDeletedCondition =
      Transaction_.isDeleted.equals(false) |
      Transaction_.isDeleted.isNull();

  List<Transaction> _getDeductibleTransactions() {
    final DateTime start = DateTime(_selectedYear, 1, 1);
    final DateTime end = DateTime(_selectedYear, 12, 31, 23, 59, 59, 999);

    final query = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.isDeductible.equals(true) &
          Transaction_.transactionDate.betweenDate(start, end) &
          _notDeletedCondition,
        )
        .order(Transaction_.transactionDate, flags: Order.descending)
        .build();

    final results = query.find();
    query.close();
    return results;
  }

  List<Transaction> _getAllExpenses() {
    final DateTime start = DateTime(_selectedYear, 1, 1);
    final DateTime end = DateTime(_selectedYear, 12, 31, 23, 59, 59, 999);

    final query = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.amount.lessThan(0) &
          Transaction_.transactionDate.betweenDate(start, end) &
          _notDeletedCondition,
        )
        .build();

    final results = query.find();
    query.close();
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final String currency = UserPreferencesService().primaryCurrency;

    final deductible = _getDeductibleTransactions();
    final allExpenses = _getAllExpenses();

    final double totalDeductible = deductible.fold(
      0.0,
      (sum, t) => sum + t.amount.abs(),
    );
    final double totalExpenses = allExpenses.fold(
      0.0,
      (sum, t) => sum + t.amount.abs(),
    );
    final double totalNonDeductible = totalExpenses - totalDeductible;

    final Map<String, double> byCategory = {};
    for (final t in deductible) {
      final name = t.category.target?.name ?? "Uncategorized";
      byCategory[name] = (byCategory[name] ?? 0) + t.amount.abs();
    }

    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tax Report",
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearSelector(colors, text),
            const SizedBox(height: 20.0),
            _buildSummaryCard(
              colors,
              text,
              currency,
              totalDeductible,
              totalNonDeductible,
              totalExpenses,
            ),
            const SizedBox(height: 20.0),
            if (sortedCategories.isNotEmpty) ...[
              Text(
                "DEDUCTIBLE BY CATEGORY",
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10.0),
              _buildCategoryBreakdown(
                colors,
                text,
                currency,
                sortedCategories,
                totalDeductible,
              ),
            ],
            const SizedBox(height: 20.0),
            if (deductible.isNotEmpty) ...[
              Text(
                "DEDUCTIBLE TRANSACTIONS",
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10.0),
              _buildTransactionsList(colors, text, currency, deductible),
            ],
            if (deductible.isEmpty) _buildEmptyState(colors, text),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector(ColorScheme colors, TextTheme text) {
    return Row(
      children: _availableYears.take(4).map((year) {
        final bool selected = year == _selectedYear;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedYear = year),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF005DAA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF005DAA)
                        : colors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  year.toString(),
                  style: text.bodyMedium?.copyWith(
                    color: selected ? Colors.white : colors.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(
    ColorScheme colors,
    TextTheme text,
    String currency,
    double totalDeductible,
    double totalNonDeductible,
    double totalExpenses,
  ) {
    final double percentage = totalExpenses > 0
        ? (totalDeductible / totalExpenses * 100)
        : 0;

    return Surface(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005DAA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Symbols.receipt_long_rounded,
                    color: Color(0xFF005DAA),
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Deductible",
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "$currency ${totalDeductible.toStringAsFixed(2)}",
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF005DAA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: LinearProgressIndicator(
                value: totalExpenses > 0
                    ? totalDeductible / totalExpenses
                    : 0,
                minHeight: 8.0,
                backgroundColor: colors.outlineVariant.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF005DAA)),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${percentage.toStringAsFixed(1)}% of expenses are deductible",
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 1.0),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Non-Deductible",
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "$currency ${totalNonDeductible.toStringAsFixed(2)}",
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Expenses",
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "$currency ${totalExpenses.toStringAsFixed(2)}",
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    ColorScheme colors,
    TextTheme text,
    String currency,
    List<MapEntry<String, double>> categories,
    double total,
  ) {
    return Surface(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: categories.map((entry) {
            final double percent = total > 0 ? entry.value / total : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6.0,
                        backgroundColor:
                            colors.outlineVariant.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF005DAA)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    width: 80.0,
                    child: Text(
                      "$currency ${entry.value.toStringAsFixed(0)}",
                      textAlign: TextAlign.end,
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    ColorScheme colors,
    TextTheme text,
    String currency,
    List<Transaction> transactions,
  ) {
    return Surface(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: transactions.take(20).map((t) {
            final String date = Moment(t.transactionDate).format("MMM DD");
            final String categoryName =
                t.category.target?.name ?? "Uncategorized";

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF005DAA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Symbols.receipt_rounded,
                      size: 18.0,
                      color: Color(0xFF005DAA),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title ?? categoryName,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$categoryName • $date",
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$currency ${t.amount.abs().toStringAsFixed(2)}",
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF005DAA),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, TextTheme text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Icon(
              Symbols.receipt_long_rounded,
              size: 64.0,
              color: colors.outlineVariant,
            ),
            const SizedBox(height: 16.0),
            Text(
              "No deductible expenses",
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Mark transactions as tax deductible\nwhen adding them to see them here",
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
