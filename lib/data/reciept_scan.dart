
import "package:flow/data/reciept_scan_result.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/entity/transaction/type.dart";

TransactionProgrammableObject? receiptScanToTransactionParams(
  ReceiptScanResult scan, {
  bool includeLineItemsInNotes = true,
}) {
  if (!scan.hasMinimumData) return null;

  // `receipt_recognition` may not always give a non-null / non-zero `total`.
  // We compute the amount from `total`, and fall back to summing line items.
  double? total = scan.total;
  if (total == null || total.abs() <= 0.000001) {
    final double sum = scan.lineItems.fold<double>(0.0, (acc, item) {
      if (item.price == null) return acc;
      final int qty = item.quantity <= 0 ? 1 : item.quantity;
      return acc + item.price! * qty;
    });
    total = sum.abs() <= 0.000001 ? null : sum;
  }

  final double? amount = total == null ? null : -(total.abs());

  String? notes;
  if (includeLineItemsInNotes && scan.lineItems.isNotEmpty) {
    final buffer = StringBuffer("Scanned receipt:\n");
    for (final item in scan.lineItems) {
      if (item.price != null) {
        buffer.writeln("• ${item.quantity}× ${item.label} — ${item.price}");
      } else {
        buffer.writeln("• ${item.label}");
      }
    }
    notes = buffer.toString();
  }

  return TransactionProgrammableObject(
    title: scan.storeName ?? "Receipt",
    amount: amount == null || amount == 0 ? null : amount,
    transactionDate: scan.date ?? DateTime.now(),
    type: TransactionType.expense,
    notes: notes,
    // category: optional fuzzy match against CategoriesService later
  );
}