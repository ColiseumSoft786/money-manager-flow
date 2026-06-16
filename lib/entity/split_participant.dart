import "package:flow/entity/_base.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

@Entity()
class SplitParticipant implements EntityBase {
  int id;
  @Unique() String uuid;
  @Property(type: PropertyType.date) DateTime createdDate;

  String splitBillUuid;
  String displayName;

  String? contactId;

  double shareAmount;
  double settledAmount;
  String currency;

  bool isPayer;
  String? settlementTransactionUuid;

  SplitParticipant({
    int? id,
    String? uuid,
    DateTime? createdDate,
    required this.splitBillUuid,
    required this.displayName,
    this.contactId,
    required this.shareAmount,
    this.settledAmount = 0,
    required this.currency,
    this.isPayer = false,
    this.settlementTransactionUuid,
  })  : id = id ?? 0,
        uuid = uuid ?? const Uuid().v4(),
        createdDate = createdDate ?? DateTime.now().toUtc();

  double get openBalance => (shareAmount - settledAmount).clamp(0, double.infinity);
  bool get isFullySettled => openBalance <= 0.000001;
}