class ReceiptScanResult {
  final String? storeName;
  final double? total;
  final DateTime? date;
  final List<ReceiptLineItem> lineItems;
  final String? rawText; 

  const ReceiptScanResult({
    this.storeName,
    this.total,
    this.date,
    this.lineItems = const [],
    this.rawText,
  });

  bool get hasMinimumData =>
      (total != null && total!.abs() > 0.000001) ||
      lineItems.any((e) => e.price != null && e.price!.abs() > 0.000001);
}

class ReceiptLineItem {
  final String label;
  final double? price;
  final int quantity;

  const ReceiptLineItem({
    required this.label,
    this.price,
    this.quantity = 1,
  });
}