// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocietyTransaction _$SocietyTransactionFromJson(Map<String, dynamic> json) {
  return _SocietyTransaction.fromJson(json);
}

/// @nodoc
mixin _$SocietyTransaction {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  TransactionStatus get status => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String? get requesterName => throw _privateConstructorUsedError;
  String? get approverId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SocietyTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocietyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocietyTransactionCopyWith<SocietyTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocietyTransactionCopyWith<$Res> {
  factory $SocietyTransactionCopyWith(
    SocietyTransaction value,
    $Res Function(SocietyTransaction) then,
  ) = _$SocietyTransactionCopyWithImpl<$Res, SocietyTransaction>;
  @useResult
  $Res call({
    String id,
    String orgId,
    double amount,
    TransactionType type,
    String category,
    String description,
    TransactionStatus status,
    String requesterId,
    String? requesterName,
    String? approverId,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$SocietyTransactionCopyWithImpl<$Res, $Val extends SocietyTransaction>
    implements $SocietyTransactionCopyWith<$Res> {
  _$SocietyTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocietyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? description = null,
    Object? status = null,
    Object? requesterId = null,
    Object? requesterName = freezed,
    Object? approverId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orgId: null == orgId
                ? _value.orgId
                : orgId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TransactionStatus,
            requesterId: null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                      as String,
            requesterName: freezed == requesterName
                ? _value.requesterName
                : requesterName // ignore: cast_nullable_to_non_nullable
                      as String?,
            approverId: freezed == approverId
                ? _value.approverId
                : approverId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocietyTransactionImplCopyWith<$Res>
    implements $SocietyTransactionCopyWith<$Res> {
  factory _$$SocietyTransactionImplCopyWith(
    _$SocietyTransactionImpl value,
    $Res Function(_$SocietyTransactionImpl) then,
  ) = __$$SocietyTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    double amount,
    TransactionType type,
    String category,
    String description,
    TransactionStatus status,
    String requesterId,
    String? requesterName,
    String? approverId,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SocietyTransactionImplCopyWithImpl<$Res>
    extends _$SocietyTransactionCopyWithImpl<$Res, _$SocietyTransactionImpl>
    implements _$$SocietyTransactionImplCopyWith<$Res> {
  __$$SocietyTransactionImplCopyWithImpl(
    _$SocietyTransactionImpl _value,
    $Res Function(_$SocietyTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocietyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? description = null,
    Object? status = null,
    Object? requesterId = null,
    Object? requesterName = freezed,
    Object? approverId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SocietyTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TransactionStatus,
        requesterId: null == requesterId
            ? _value.requesterId
            : requesterId // ignore: cast_nullable_to_non_nullable
                  as String,
        requesterName: freezed == requesterName
            ? _value.requesterName
            : requesterName // ignore: cast_nullable_to_non_nullable
                  as String?,
        approverId: freezed == approverId
            ? _value.approverId
            : approverId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocietyTransactionImpl implements _SocietyTransaction {
  const _$SocietyTransactionImpl({
    required this.id,
    required this.orgId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.status,
    required this.requesterId,
    this.requesterName,
    this.approverId,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$SocietyTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocietyTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final double amount;
  @override
  final TransactionType type;
  @override
  final String category;
  @override
  final String description;
  @override
  final TransactionStatus status;
  @override
  final String requesterId;
  @override
  final String? requesterName;
  @override
  final String? approverId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SocietyTransaction(id: $id, orgId: $orgId, amount: $amount, type: $type, category: $category, description: $description, status: $status, requesterId: $requesterId, requesterName: $requesterName, approverId: $approverId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocietyTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.requesterName, requesterName) ||
                other.requesterName == requesterName) &&
            (identical(other.approverId, approverId) ||
                other.approverId == approverId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    amount,
    type,
    category,
    description,
    status,
    requesterId,
    requesterName,
    approverId,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SocietyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocietyTransactionImplCopyWith<_$SocietyTransactionImpl> get copyWith =>
      __$$SocietyTransactionImplCopyWithImpl<_$SocietyTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SocietyTransactionImplToJson(this);
  }
}

abstract class _SocietyTransaction implements SocietyTransaction {
  const factory _SocietyTransaction({
    required final String id,
    required final String orgId,
    required final double amount,
    required final TransactionType type,
    required final String category,
    required final String description,
    required final TransactionStatus status,
    required final String requesterId,
    final String? requesterName,
    final String? approverId,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$SocietyTransactionImpl;

  factory _SocietyTransaction.fromJson(Map<String, dynamic> json) =
      _$SocietyTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  double get amount;
  @override
  TransactionType get type;
  @override
  String get category;
  @override
  String get description;
  @override
  TransactionStatus get status;
  @override
  String get requesterId;
  @override
  String? get requesterName;
  @override
  String? get approverId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of SocietyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocietyTransactionImplCopyWith<_$SocietyTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
