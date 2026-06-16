
import "package:flow/data/quickAddParse.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/category.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/quick_add_aprser.dart";

class QuickAddService {
  QuickAddService._();
  static final QuickAddService instance = QuickAddService._();
  QuickaddparseResult? preview(String raw) {
    final List<Category> categories =
        CategoriesService().getAllUuidsSync()
            .map((uuid) => CategoriesService().findOneSync(uuid))
            .whereType<Category>()
            .toList();
    return QuickAddParser.parse(raw: raw, categories: categories);
  }


  int submit(String raw){
    final QuickaddparseResult? parsed=preview(raw);
    if(parsed==null || !parsed.isValid){
      throw QuickAddException("Could not understand that input");
    }

    return TransactionProgrammableObject(
      amount: parsed.signedAmount,
      type: parsed.type,
      title: parsed.title,
      category: parsed.category?.name,
      transactionDate: parsed.transactionDate
    ).save();
  }

  

}

class QuickAddException implements Exception{
  final String message;
  QuickAddException(this.message);
}