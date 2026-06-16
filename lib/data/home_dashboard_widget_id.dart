/// Identifiers for reorderable Home dashboard cards.
enum HomeDashboardWidgetId {
  totalBalance,
  incomeExpense,
  netWorthSparkline,
  budgetProgress,
  topCategory,
  goalProgress,
  upcomingBills,
  exchangeRates;

  static const List<HomeDashboardWidgetId> defaultOrder = [
    HomeDashboardWidgetId.totalBalance,
    HomeDashboardWidgetId.incomeExpense,
    HomeDashboardWidgetId.netWorthSparkline,
    HomeDashboardWidgetId.budgetProgress,
    HomeDashboardWidgetId.topCategory,
    HomeDashboardWidgetId.goalProgress,
    HomeDashboardWidgetId.upcomingBills,
    HomeDashboardWidgetId.exchangeRates,
  ];

  String get storageKey => name;

  String get titleL10nKey => "home.dashboard.widget.$name.title";

  static HomeDashboardWidgetId? tryParse(String raw) {
    for (final HomeDashboardWidgetId id in values) {
      if (id.name == raw) return id;
    }
    return null;
  }
}
