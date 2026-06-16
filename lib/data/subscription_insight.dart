

import "package:flow/data/money.dart";
import "package:flow/entity/subscription.dart";
import "package:flow/entity/subscription_kind.dart";
import "package:flow/entity/subscription_status.dart";

class SubscriptionInsight {
  final Subscription subscription;
  final Money monthlyAmount;
  final Money? lastPayment;
  final DateTime? lastUsed;
  final DateTime? nextBillingDate;
  final DateTime? cancelByDate;
  final int? daysSinceLastUse;
  final bool isUnusedWarning;
  final bool isCancelDeadlineSoon;
  final String? linkedRecurringTitle;

  const SubscriptionInsight({
    required this.subscription,
    required this.monthlyAmount,
    this.lastPayment,
    this.lastUsed,
    this.nextBillingDate,
    this.cancelByDate,
    this.daysSinceLastUse,
    this.isUnusedWarning=false,
    this.isCancelDeadlineSoon=false,
    this.linkedRecurringTitle,
  });

  bool get isActive=>subscription.status==SubscriptionStatus.active;
  bool get showCancelReminder=>
  subscription.kind==SubscriptionKind.annualContract && isCancelDeadlineSoon && cancelByDate!=null;
}