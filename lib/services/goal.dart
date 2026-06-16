import "package:flow/entity/account.dart";
import "package:flow/entity/goal.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/accounts.dart";
import "package:uuid/uuid.dart";

class GoalService {
  static GoalService? _instance;

  factory GoalService() => _instance ??= GoalService._internal();

  GoalService._internal();

  Future<List<Goal>> getAll() => ObjectBox().box<Goal>().getAllAsync();

  List<Goal> getAllSync() => ObjectBox().box<Goal>().getAll();

  Future<Goal?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return ObjectBox().box<Goal>().getAsync(identifier);
    }

    if (identifier case String uuid
        when Uuid.isValidUUID(fromString: uuid)) {
      final Query<Goal> q = ObjectBox()
          .box<Goal>()
          .query(Goal_.uuid.equals(uuid))
          .build();
      try {
        return await q.findFirstAsync();
      } finally {
        q.close();
      }
    }

    return null;
  }

  Goal? findOneSync(dynamic identifier) {
    if (identifier is int) {
      return ObjectBox().box<Goal>().get(identifier);
    }

    if (identifier case String uuid
        when Uuid.isValidUUID(fromString: uuid)) {
      final Query<Goal> q = ObjectBox()
          .box<Goal>()
          .query(Goal_.uuid.equals(uuid))
          .build();
      try {
        return q.findFirst();
      } finally {
        q.close();
      }
    }

    return null;
  }

  Future<int> upsert(Goal goal, {Account? account}) async {
    if (account != null) {
      goal.setAccount(account);
    } else if (goal.accountUuid case String uuid) {
      goal.setAccount(AccountsService().findOneSync(uuid));
    }
    return ObjectBox().box<Goal>().putAsync(goal);
  }

  Future<bool> delete(dynamic identifier) async {
    final Goal? goal = await findOne(identifier);
    if (goal == null) return false;
    return ObjectBox().box<Goal>().removeAsync(goal.id);
  }
}