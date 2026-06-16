import "dart:io";

import "package:flow/data/reciept_scan_result.dart";
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";
import "package:receipt_recognition/receipt_recognition.dart";

class ReceiptScanService {
  static ReceiptScanService? _instance;
  factory ReceiptScanService() => _instance ??= ReceiptScanService._();
  ReceiptScanService._();

  final ReceiptRecognizer _recognizer = ReceiptRecognizer(
    singleScan: true,
    options: ReceiptOptions.defaults(),
  );

  Future<ReceiptScanResult?> scanImageFile(File imageFile) async {
    final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

    // Ensure recognizer is initialized (safe to call repeatedly).
    _recognizer.init();

    try {
      final RecognizedReceipt receipt = await _recognizer.processImage(
        inputImage,
      );
      if (!receipt.isEmpty) {
        final ReceiptScanResult mapped = _mapPackageReceipt(receipt);
        if (mapped.hasMinimumData) return mapped;
      }
    } catch (_) {
      // Fall back to plain OCR below.
    }

    // Fallback: raw OCR + best-effort parsing of store + total.
    return _scanViaRawOcr(inputImage);
  }

  Future<void> dispose() => _recognizer.close();

  Future<ReceiptScanResult?> _scanViaRawOcr(InputImage inputImage) async {
    final TextRecognizer tr = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    try {
      final RecognizedText text = await tr.processImage(inputImage);
      final String raw = text.text.trim();
      if (raw.isEmpty) return null;

      final String? store = _guessStoreName(text);
      final double? total = _guessTotal(raw);

      return ReceiptScanResult(
        storeName: store,
        total: total,
        date: DateTime.now(),
        rawText: raw,
      );
    } finally {
      await tr.close();
    }
  }

  String? _guessStoreName(RecognizedText text) {
    // Use the first non-empty line as a store hint.
    for (final block in text.blocks) {
      for (final line in block.lines) {
        final String v = line.text.trim();
        if (v.isNotEmpty) return v;
      }
    }
    return null;
  }

  double? _guessTotal(String rawText) {
    // Prefer numbers on lines that contain total keywords.
    final List<String> lines = rawText
        .split(RegExp(r"\r?\n"))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final totalLine = lines.lastWhere(
      (l) => RegExp(r"\b(total|amount|sum|grand)\b", caseSensitive: false)
          .hasMatch(l),
      orElse: () => "",
    );

    double? parseAmountFromLine(String line) {
      // Matches: 123.45, 123,45, 1,234.56
      final matches = RegExp(r"(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})|\d+(?:[.,]\d{2}))")
          .allMatches(line);
      if (matches.isEmpty) return null;
      final String last = matches.last.group(0)!;
      final String normalized = last
          .replaceAll(RegExp(r"[ ,]"), "")
          .replaceAll(RegExp(r"(?<=\d)[,](?=\d{2}$)"), ".")
          .replaceAll(RegExp(r"(?<=\d)[.](?=\d{3}([.,]\d{2})?$)"), "");
      return double.tryParse(normalized);
    }

    final double? fromTotalLine =
        totalLine.isEmpty ? null : parseAmountFromLine(totalLine);
    if (fromTotalLine != null && fromTotalLine > 0) return fromTotalLine;

    // Otherwise pick the largest amount-looking number in the whole text.
    double? best;
    for (final l in lines) {
      final v = parseAmountFromLine(l);
      if (v == null) continue;
      if (best == null || v > best) best = v;
    }
    return best;
  }

  ReceiptScanResult _mapPackageReceipt(RecognizedReceipt receipt) {
    // Prefer directly recognized values, but fall back to calculated values
    // (calculated totals come from aggregated line items).
    final String? store =
        receipt.store?.value ?? receipt.company?.value;

    final double? totalCandidate =
        receipt.total?.value ?? receipt.calculatedTotal.value;

    final purchaseDate = receipt.purchaseDate;
    final DateTime? date =
        purchaseDate?.parsedDateTime ?? purchaseDate?.value;

    final List<ReceiptLineItem> items = [];
    for (final RecognizedPosition pos in receipt.positions) {
      items.add(
        ReceiptLineItem(
          label: pos.product.value,
          price: pos.price.value,
          quantity: _lineItemQuantity(pos),
        ),
      );
    }

    final double itemsSum = items.fold<double>(0.0, (sum, item) {
      final double? price = item.price;
      if (price == null) return sum;
      // RecognizedPosition.price is typically a line price; if quantity is
      // meaningful, multiply to get a more stable receipt total.
      return sum + (price * (item.quantity <= 0 ? 1 : item.quantity));
    });

    const double eps = 0.000001;
    double? total = (totalCandidate == null || totalCandidate.abs() <= eps)
        ? null
        : totalCandidate;
    if (total == null && itemsSum.abs() > eps) {
      total = itemsSum;
    }

    return ReceiptScanResult(
      storeName: store,
      total: total,
      date: date ?? DateTime.now(),
      lineItems: items,
    );
  }

  int _lineItemQuantity(RecognizedPosition pos) {
    final dynamic unitQty = pos.unit?.quantity;
    if (unitQty is int) return unitQty;
    if (unitQty is num) return unitQty.round();
    return 1;
  }
}
