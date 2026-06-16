import "package:flow/entity/split_bill.dart";
import "package:flow/entity/split_participant.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";

class SplitBillService {
  static SplitBillService? _instance;

  factory SplitBillService() => _instance ??= SplitBillService._internal();

  SplitBillService._internal();

  void syncEqualSplit({
    required Transaction transaction,
    required List<String> participantNames,
    required String payerName,
  }) {
    deleteForTransaction(transaction.uuid);
    createEqualSplit(
      transaction: transaction,
      participantNames: participantNames,
      payerName: payerName,
    );
  }

  SplitBill createEqualSplit({
    required Transaction transaction,
    required List<String> participantNames,
    required String payerName,
  }) {
    final List<String> names = participantNames
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      throw ArgumentError("participantNames must not be empty");
    }

    final double totalAbs = transaction.money.amount.abs();
    final List<double> shares = _splitEqually(totalAbs, names.length);
    final String currency = transaction.currency;

    final SplitBill bill = SplitBill(transactionUuid: transaction.uuid);
    ObjectBox().box<SplitBill>().put(bill);

    for (int i = 0; i < names.length; i++) {
      final String name = names[i];
      final bool isPayer = name == payerName;
      final double share = shares[i];

      ObjectBox().box<SplitParticipant>().put(
        SplitParticipant(
          splitBillUuid: bill.uuid,
          displayName: name,
          shareAmount: share,
          settledAmount: isPayer ? share : 0,
          currency: currency,
          isPayer: isPayer,
        ),
      );
    }

    return bill;
  }

  List<SplitParticipant> getParticipants(String splitBillUuid) {
    final Query<SplitParticipant> q = ObjectBox()
        .box<SplitParticipant>()
        .query(SplitParticipant_.splitBillUuid.equals(splitBillUuid))
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  SplitBill? getByTransactionUuid(String transactionUuid) {
    final Query<SplitBill> q = ObjectBox()
        .box<SplitBill>()
        .query(SplitBill_.transactionUuid.equals(transactionUuid))
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  Future<void> recordSettlement({
    required SplitParticipant participant,
    required double amount,
    String? settlementTransactionUuid,
  }) async {
    if (amount <= 0) return;

    final double capped = (participant.settledAmount + amount)
        .clamp(0, participant.shareAmount);
    participant.settledAmount = capped;
    if (settlementTransactionUuid != null) {
      participant.settlementTransactionUuid = settlementTransactionUuid;
    }
    ObjectBox().box<SplitParticipant>().put(participant);
  }

  
  Map<String, double> openBalancesByPerson() {
    final Query<SplitParticipant> q = ObjectBox()
        .box<SplitParticipant>()
        .query()
        .build();
    try {
      final Map<String, double> balances = {};
      for (final SplitParticipant p in q.find()) {
        if (p.isPayer || p.isFullySettled) continue;
        balances[p.displayName] =
            (balances[p.displayName] ?? 0) + p.openBalance;
      }
      return balances;
    } finally {
      q.close();
    }
  }

  void deleteForTransaction(String transactionUuid) {
    final SplitBill? bill = getByTransactionUuid(transactionUuid);
    if (bill == null) return;

    final Query<SplitParticipant> pq = ObjectBox()
        .box<SplitParticipant>()
        .query(SplitParticipant_.splitBillUuid.equals(bill.uuid))
        .build();
    try {
      ObjectBox().box<SplitParticipant>().removeMany(pq.findIds());
    } finally {
      pq.close();
    }

    ObjectBox().box<SplitBill>().remove(bill.id);
  }

  /// Splits [totalAbs] into [count] parts; last entry absorbs cent remainder.
  static List<double> _splitEqually(double totalAbs, int count) {
    final int totalCents = (totalAbs * 100).round();
    final int baseCents = totalCents ~/ count;
    final int remainderCents = totalCents % count;
    final List<double> shares = List<double>.filled(
      count,
      baseCents / 100.0,
    );
    shares[count - 1] += remainderCents / 100.0;
    return shares;
  }
}
