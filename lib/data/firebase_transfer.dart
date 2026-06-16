import "package:cloud_firestore/cloud_firestore.dart";

class PeerTransfer {
  const PeerTransfer({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    required this.fromDisplayName,
    required this.fromHandle,
    required this.toDisplayName,
    required this.toHandle,
    required this.status,
    this.note,
    this.createdAt,
    this.bookedLocally = false,
    this.localTransactionUuid,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currency;
  final String fromDisplayName;
  final String fromHandle;
  final String toDisplayName;
  final String toHandle;
  final String status;
  final String? note;
  final DateTime? createdAt;
  final bool bookedLocally;
  final String? localTransactionUuid;

  factory PeerTransfer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PeerTransfer(
      id: doc.id,
      fromUserId: data["fromUserId"] as String? ?? "",
      toUserId: data["toUserId"] as String? ?? "",
      amount: (data["amount"] as num?)?.toDouble() ?? 0,
      currency: data["currency"] as String? ?? "",
      fromDisplayName: data["fromDisplayName"] as String? ?? "",
      fromHandle: data["fromHandle"] as String? ?? "",
      toDisplayName: data["toDisplayName"] as String? ?? "",
      toHandle: data["toHandle"] as String? ?? "",
      status: data["status"] as String? ?? "sent",
      note: data["note"] as String?,
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
      bookedLocally: data["bookedLocally"] as bool? ?? false,
      localTransactionUuid: data["localTransactionUuid"] as String?,
    );
  }
}
