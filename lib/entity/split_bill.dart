import "package:flow/entity/_base.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

@Entity()
class SplitBill implements EntityBase {
  int id;
  @Unique() String uuid;
  @Property(type: PropertyType.date) DateTime createdDate;
  @Unique() String transactionUuid;

  String mode;

  SplitBill({
    int? id,
    String? uuid,
    DateTime? createdDate,
    required this.transactionUuid,
    this.mode = "equal",
  })  : id = id ?? 0,
        uuid = uuid ?? const Uuid().v4(),
        createdDate = createdDate ?? DateTime.now().toUtc();
}