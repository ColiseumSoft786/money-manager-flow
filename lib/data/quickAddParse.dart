
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction/type.dart";

class QuickaddparseResult {
  final double amount;
  final TransactionType type;
  final String title;
  final Category? category;
  final DateTime transactionDate;

  const QuickaddparseResult({
    required this.amount,
    required this.type,
    required this.title,
    required this.category,
    required this.transactionDate,
  });

  double get signedAmount=>switch(type){
    TransactionType.expense=>-amount.abs(),
    TransactionType.income=>amount.abs(),
    TransactionType.transfer=>amount.abs(),
  };

  bool get isValid=>amount >0 && title.trim().isNotEmpty;
}