
import "package:flow/data/quickAddParse.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction/type.dart";
import "package:moment_dart/moment_dart.dart";

class QuickAddParser {
  QuickAddParser._();

  static final RegExp _amountPattern = RegExp(
    r"([+-])?\s*(\d+(?:[.,]\d+)?)",
  );

  
  static const List<(String keyword, String categoryHint)> _categoryHints = [
    ("grocery", "groc"),
    ("groceries", "groc"),
    ("food", "eat"), 
    ("restaurant", "eat"),
    ("uber", "transport"),
    ("taxi", "transport"),
    ("bus", "transport"),
    ("train", "transport"),
    ("petrol", "petrol"),
    ("gas", "petrol"),
    ("fuel", "petrol"),
    ("rent", "rent"),
    ("salary", "salary"),
    ("wage", "salary"),
    ("netflix", "online"),
    ("spotify", "online"),
    ("shopping", "shop"),
    ("amazon", "shop"),
    ("health", "health"),
    ("doctor", "health"),
    ("movie", "entertain"),
    ("cinema", "entertain"),
  ];

  static const List<(String keyword, int dayOffset)> _dateKeywords = [
    ("today", 0),
    ("yesterday", -1),
    ("last week", -7),
  ];

  static const List<String> _incomeKeywords = [
    "salary",
    "paycheck",
    "income",
    "wage",
    "bonus",
  ];

 
  static QuickaddparseResult? parse({
    required String raw,
    required List<Category> categories,
    DateTime? now,
  }) {
    final String input = raw.trim();
    if (input.isEmpty) return null;

    final DateTime reference = now ?? DateTime.now();
    String working = input.toLowerCase();

    
    TransactionType type = TransactionType.expense;
    if (working.startsWith("+")) {
      type = TransactionType.income;
      working = working.substring(1).trim();
    } else if (_incomeKeywords.any((k) => working.contains(k))) {
      type = TransactionType.income;
    }

    DateTime transactionDate = reference;
    for (final (keyword, offset) in _dateKeywords) {
      if (working.contains(keyword)) {
        transactionDate = Moment(reference).add(Duration(days: offset)).date;
       working = working.replaceFirst(RegExp(r'\b' + keyword + r'\b'), " ");
      }
    }

    
    final RegExpMatch? amountMatch = _amountPattern.firstMatch(working);
    if (amountMatch == null) return null;

    final String amountRaw = amountMatch.group(2)!.replaceAll(",", ".");
    final double? amount = double.tryParse(amountRaw);
    if (amount == null || amount <= 0) return null;

    if (amountMatch.group(1) == "-") {
      type = TransactionType.expense;
    }

    working = working.replaceRange(amountMatch.start, amountMatch.end, " ");

    
    final Category? category = _matchCategory(working, categories);

   
    String title = working
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    if (title.isEmpty) {
      title = category?.name ?? (type == TransactionType.income ? "Income" : "Expense");
    }

  
    title = title[0].toUpperCase() + title.substring(1);

    return QuickaddparseResult(
      amount: amount,
      type: type,
      title: title,
      category: category,
      transactionDate: transactionDate,
    );
  }

  static Category? _matchCategory(String text, List<Category> categories) {
    final String lower = text.toLowerCase();

   
  
  
  Category? best;
  int bestLen = 0;
  
  for (final Category category in categories) {
    final String name = category.name.toLowerCase();
    
  
    int categoryBestLen = 0;
    
    
    if (name.length >= 3 && lower.contains(name)) {
      categoryBestLen = name.length;
    }
    // Check words - but only if they are LONGER than whole name match
    for (final String word in name.split(RegExp(r"\s+"))) {
      if (word.length >= 3 && 
          lower.contains(word) && 
          word.length > categoryBestLen) {  
        categoryBestLen = word.length;
      }
    }
      // Now compare THIS category's best against global best
    if (categoryBestLen > bestLen) {
      best = category;
      bestLen = categoryBestLen;
    }
  }
  
  if (best != null) return best;
  
  


    for (final (keyword, hint) in _categoryHints) {
      if (!lower.contains(keyword)) continue;
      final Category? match = categories.cast<Category?>().firstWhere(
        (c) => c!.name.toLowerCase().contains(hint),
        orElse: () => null,
      );
      if (match != null) return match;
    }

    return null;
  }
}