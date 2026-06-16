import "package:flow/entity/_base.dart";
import "package:flow/entity/subscription_kind.dart";
import "package:flow/entity/subscription_status.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";
import "package:uuid/uuid.dart";

part "subscription.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class Subscription implements EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String name;

  String? recurringTransactionUuid;

  double? manualAmount;

  String? manualCurrency;

  /// Persisted enum name for [kind].
  String? kindStorage;

  /// Persisted enum name for [status].
  String? statusStorage;

  @Transient()
  SubscriptionKind get kind =>
      SubscriptionKindStorage.fromStorage(kindStorage);

  set kind(SubscriptionKind value) => kindStorage = value.storageValue;

  @Transient()
  SubscriptionStatus get status =>
      SubscriptionStatusStorage.fromStorage(statusStorage);

  set status(SubscriptionStatus value) => statusStorage = value.storageValue;

  String? cancelUrl;

  @Property(type: PropertyType.date)
  DateTime? cancelByDate;

  @Property(type: PropertyType.date)
  DateTime? lastUsedOverride;

  int unusedAfterDays;

  String? notes;

  int sortOrder;

  Subscription({
    this.id = 0,
    required this.name,
    this.recurringTransactionUuid,
    this.manualAmount,
    this.manualCurrency,
    SubscriptionKind kind = SubscriptionKind.cancellable,
    SubscriptionStatus status = SubscriptionStatus.active,
    this.cancelUrl,
    this.cancelByDate,
    this.lastUsedOverride,
    this.unusedAfterDays = 60,
    this.notes,
    this.sortOrder = 0,
    String? uuid,
    DateTime? createdDate,
  }) : kindStorage = kind.storageValue,
       statusStorage = status.storageValue,
       uuid = uuid ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now();

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}
