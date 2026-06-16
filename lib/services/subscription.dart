import "package:flow/data/money.dart";
import "package:flow/data/subscription_insight.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/subscription.dart";
import "package:flow/entity/subscription_kind.dart";
import "package:flow/entity/subscription_status.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions/recurring_transaction.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

class SubscriptionService {
   static SubscriptionService? _instance;
   factory SubscriptionService()=>_instance ??= SubscriptionService._internal();
   SubscriptionService._internal();
   

   List<Subscription> getAllSync() {
    final Query<Subscription> q = ObjectBox()
        .box<Subscription>()
        .query()
        .order(Subscription_.sortOrder)
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }


  Subscription? findByUuidSync(String uuid){
    final Query<Subscription>q=ObjectBox()
    .box<Subscription>()
    .query(Subscription_.uuid.equals(uuid))
    .build();
    try{
      return q.findFirst();
    }finally{
      q.close();
    }
  }

  int upsertSync(Subscription subscription)=>
    ObjectBox().box<Subscription>().put(subscription);

  void deleteSync(Subscription subscription)=>
  ObjectBox().box<Subscription>().remove(subscription.id);

 Subscription createFromRecurringSync(
    RecurringTransaction recurring, {
    SubscriptionKind kind = SubscriptionKind.cancellable,
    String? cancelUrl,
    DateTime? cancelByDate,
  }) {
    final Transaction template = recurring.template;
    final Subscription sub = Subscription(
      name: template.title ?? "Subscription",
      recurringTransactionUuid: recurring.uuid,
      kind: kind,
      cancelUrl: cancelUrl,
      cancelByDate: cancelByDate,
    );
    upsertSync(sub);
    return sub;
  }

  List<RecurringTransaction>findUnlinkedRecurringExpensesSync(){
    final Set<String> linked=getAllSync()
    .map((s)=>s.recurringTransactionUuid)
    .whereType<String>()
    .toSet();

    return RecurringTransactionsService()
    .getAllSync()
    .where((r)=>  !r.disabled && r.template.amount<0)
    .where((r)=> !linked.contains(r.uuid))
    .toList();
  }

  Future<SubscriptionInsight> buildInsight(Subscription sub) async {
    final String primary = UserPreferencesService().primaryCurrency;
    RecurringTransaction? recurring;
    Transaction? template;
    if (sub.recurringTransactionUuid != null) {
      recurring = await RecurringTransactionsService().findOne(
        sub.recurringTransactionUuid,
      );
      template = recurring?.template;
    }
    final Money monthly = _monthlyAmount(
      sub: sub,
      template: template,
      recurring: recurring,
      primaryCurrency: primary,
    );
    final List<Transaction> related = await _relatedTransactions(sub, recurring);
    related.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final Transaction? lastPayment = related.isEmpty ? null : related.first;
    final DateTime? lastUsed = sub.lastUsedOverride ??
        lastPayment?.transactionDate;
    final int? daysSince = lastUsed == null
        ? null
        : DateTime.now().difference(lastUsed).inDays;
    final bool unused = sub.status == SubscriptionStatus.active &&
        daysSince != null &&
        daysSince >= sub.unusedAfterDays;
    final DateTime? nextBilling = recurring == null
        ? null
        : recurring.recurrence
            .nextAbsoluteOccurrence(DateTime.now())
            ?.startOfMillisecond();
    final DateTime? cancelBy = sub.kind == SubscriptionKind.annualContract
        ? sub.cancelByDate
        : null;
    final bool cancelSoon = cancelBy != null &&
        cancelBy.difference(DateTime.now()).inDays <= 30 &&
        cancelBy.isAfter(DateTime.now());
    return SubscriptionInsight(
      subscription: sub,
      monthlyAmount: monthly,
      lastPayment: lastPayment == null
          ? null
          : Money(lastPayment.amount.abs(), lastPayment.currency),
      lastUsed: lastUsed,
      nextBillingDate: nextBilling,
      cancelByDate: cancelBy,
      daysSinceLastUse: daysSince,
      isUnusedWarning: unused,
      isCancelDeadlineSoon: cancelSoon,
      linkedRecurringTitle: template?.title,
    );
  }


   Future<List<SubscriptionInsight>> buildAllInsights() async {
    final List<Subscription> subs = getAllSync();
    return Future.wait(subs.map(buildInsight));
  }

  Future<Money>totalMonthlyActive()async{
    final insights=await buildAllInsights();
    final String primary=UserPreferencesService().primaryCurrency;
    double sum=0;
    for(final i in insights){
      if (!i.isActive) continue;
      if(i.monthlyAmount.currency==primary) sum+=i.monthlyAmount.amount;

    }
    return Money(sum, primary);
  }


  Future<double>potentialMonthlySavings()async{
    final insights=await buildAllInsights();
    double sum=0;
    for(final i in insights){
      if (!i.isActive) continue;
      if(i.isUnusedWarning)
      sum+=i.monthlyAmount.amount;
    }
    return sum;
  }

  Money _monthlyAmount({
    required Subscription sub,
    required Transaction? template,
    required RecurringTransaction? recurring,
    required String primaryCurrency,
  }){
    if(recurring !=null && template !=null){
      final double perCharge=template.amount.abs();
      final double factor=_monthlyFactor(recurring.recurrenceRules);
      final String currency=template.currency;
      return Money(perCharge*factor, currency);
    }
    return Money(
      sub.manualAmount??0,
      sub.manualCurrency??primaryCurrency,
    );
  }

   double _monthlyFactor(List<RecurrenceRule> rules) {
    if (rules.isEmpty) return 1;
    final RecurrenceRule rule = rules.first;
    return switch (rule) {
      WeeklyRecurrenceRule() => 52 / 12,
      MonthlyRecurrenceRule() => 1,
      YearlyRecurrenceRule() => 1 / 12,
      IntervalRecurrenceRule(:final data) =>
        data.inDays > 0 ? 30 / data.inDays : 1,
      _ => 1,
    };
  }

  Future<List<Transaction>> _relatedTransactions(
    Subscription sub,
    RecurringTransaction? recurring,
  ) async {
    if (recurring != null) {
      return TransactionsService().findMany(
        TransactionFilter(extraTag: recurring.extensionIdentifierTag),
      );
    }// Manual subscription: match by title (simple v1)
    return TransactionsService().findMany(
      TransactionFilter(
        searchData: TransactionSearchData(keyword: sub.name),
        types: [TransactionType.expense],
      ),
    );
  }



}