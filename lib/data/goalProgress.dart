import "package:flow/data/money.dart";
import "package:flow/entity/goal.dart";
import "package:flow/services/accounts.dart";
import "package:moment_dart/moment_dart.dart";

class GoalProgress {
  final Goal goal;
  final Money saved;
  final Money target;

  const GoalProgress({
    required this.goal,
    required this.saved,
    required this.target,
  });

  double get fraction {
    if (target.amount <= 0) return 0;
    return (saved.amount / target.amount).clamp(0.0, 2.0);
  }

  double get percent => fraction * 100;

  bool get isCompleted =>
      target.amount > 0 && saved.amount >= target.amount;

  /// Progress capped at 100% for UI meters and labels.
  double get displayFraction => fraction.clamp(0.0, 1.0);

  int get displayPercentRounded => (displayFraction * 100).round();

  Money get remaining {
    final double left = target.amount - saved.amount;
    return Money(left < 0 ? 0 : left, target.currency);
  }

  DateTime? get targetDate => goal.timeRange?.to;

  Duration? get timeLeft {
    final DateTime? end = targetDate;
    if (end == null) return null;
    final Duration d = end.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  double? get suggestedMonthlySave {
    final int days = timeLeft?.inDays ?? 0;
    if (days <= 0 || remaining.amount <= 0) return null;
    return remaining.amount / (days / 30.0);
  }
}

GoalProgress computeGoalProgress(Goal goal) {
  final account = AccountsService().findOneSync(goal.accountUuid);
  final double balance = account?.balance.amount ?? 0;
  final double baseline = goal.baseLineBalance ?? 0;
  final double savedAmount = (balance - baseline).clamp(0, double.infinity);

  return GoalProgress(
    goal: goal,
    saved: Money(savedAmount, goal.currency),
    target: Money(goal.targetBalance, goal.currency),
  );
}
