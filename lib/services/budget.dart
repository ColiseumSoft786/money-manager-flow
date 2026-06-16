// class BudgetService {
//   static BudgetService? _instance;

//   factory BudgetService() => _instance ??= BudgetService._internal();

//   BudgetService._internal() {
//     // Constructor
//   }
// }


import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/categories.dart";
import "package:uuid/uuid.dart";

class BudgetService {
  static BudgetService? _instance;

  factory BudgetService() => _instance ??= BudgetService._internal();

  BudgetService._internal();

  Future<List<Budget>> getAll() =>
      ObjectBox().box<Budget>().getAllAsync();

  List<Budget> getAllSync() => ObjectBox().box<Budget>().getAll();

  Future<Budget?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return ObjectBox().box<Budget>().getAsync(identifier);
    }

    if (identifier case String uuid
        when Uuid.isValidUUID(fromString: uuid)) {
      final Query<Budget> q = ObjectBox()
          .box<Budget>()
          .query(Budget_.uuid.equals(uuid))
          .build();
      try {
        return await q.findFirstAsync();
      } finally {
        q.close();
      }
    }

    return null;
  }

  Budget? findOneSync(dynamic identifier) {
    if (identifier is int) {
      return ObjectBox().box<Budget>().get(identifier);
    }

    if (identifier case String uuid
        when Uuid.isValidUUID(fromString: uuid)) {
      final Query<Budget> q = ObjectBox()
          .box<Budget>()
          .query(Budget_.uuid.equals(uuid))
          .build();
      try {
        return q.findFirst();
      } finally {
        q.close();
      }
    }

    return null;
  }

  Future<int> upsert(
    Budget budget, {
    List<Category>? categories,
  }) async {
    if (categories != null) {
      budget.setCategories(categories);
    } else if (budget.categoriesUuids case List<String> uuids
        when uuids.isNotEmpty) {
      final List<Category> resolved = uuids
          .map(CategoriesService().findOneSync)
          .nonNulls
          .toList();
      budget.setCategories(resolved);
    }
    return ObjectBox().box<Budget>().putAsync(budget);
  }

  Future<bool> delete(dynamic identifier) async {
    final Budget? budget = await findOne(identifier);
    if (budget == null) return false;
    return ObjectBox().box<Budget>().removeAsync(budget.id);
  }
}