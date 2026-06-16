// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) =>
    Subscription(
        name: json['name'] as String,
        recurringTransactionUuid: json['recurringTransactionUuid'] as String?,
        manualAmount: (json['manualAmount'] as num?)?.toDouble(),
        manualCurrency: json['manualCurrency'] as String?,
        kind:
            $enumDecodeNullable(_$SubscriptionKindEnumMap, json['kind']) ??
            SubscriptionKind.cancellable,
        status:
            $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
            SubscriptionStatus.active,
        cancelUrl: json['cancelUrl'] as String?,
        cancelByDate: _$JsonConverterFromJson<String, DateTime>(
          json['cancelByDate'],
          const UTCDateTimeConverter().fromJson,
        ),
        lastUsedOverride: _$JsonConverterFromJson<String, DateTime>(
          json['lastUsedOverride'],
          const UTCDateTimeConverter().fromJson,
        ),
        unusedAfterDays: (json['unusedAfterDays'] as num?)?.toInt() ?? 60,
        notes: json['notes'] as String?,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        uuid: json['uuid'] as String?,
        createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'],
          const UTCDateTimeConverter().fromJson,
        ),
      )
      ..kindStorage = json['kindStorage'] as String?
      ..statusStorage = json['statusStorage'] as String?;

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'name': instance.name,
      'recurringTransactionUuid': instance.recurringTransactionUuid,
      'manualAmount': instance.manualAmount,
      'manualCurrency': instance.manualCurrency,
      'kindStorage': instance.kindStorage,
      'statusStorage': instance.statusStorage,
      'kind': _$SubscriptionKindEnumMap[instance.kind]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'cancelUrl': instance.cancelUrl,
      'cancelByDate': _$JsonConverterToJson<String, DateTime>(
        instance.cancelByDate,
        const UTCDateTimeConverter().toJson,
      ),
      'lastUsedOverride': _$JsonConverterToJson<String, DateTime>(
        instance.lastUsedOverride,
        const UTCDateTimeConverter().toJson,
      ),
      'unusedAfterDays': instance.unusedAfterDays,
      'notes': instance.notes,
      'sortOrder': instance.sortOrder,
    };

const _$SubscriptionKindEnumMap = {
  SubscriptionKind.cancellable: 'cancellable',
  SubscriptionKind.essential: 'essential',
  SubscriptionKind.annualContract: 'annualContract',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.paused: 'paused',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
