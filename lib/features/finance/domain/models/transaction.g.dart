// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyTransactionImpl _$$SocietyTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$SocietyTransactionImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  category: json['category'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  requesterId: json['requesterId'] as String,
  requesterName: json['requesterName'] as String?,
  approverId: json['approverId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SocietyTransactionImplToJson(
  _$SocietyTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'category': instance.category,
  'description': instance.description,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'requesterId': instance.requesterId,
  'requesterName': instance.requesterName,
  'approverId': instance.approverId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.approved: 'approved',
  TransactionStatus.rejected: 'rejected',
};
