// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocietyUser _$SocietyUserFromJson(Map<String, dynamic> json) {
  return _SocietyUser.fromJson(json);
}

/// @nodoc
mixin _$SocietyUser {
  String get uid => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get roleName => throw _privateConstructorUsedError;
  UserStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get needsPasswordReset => throw _privateConstructorUsedError;

  /// Serializes this SocietyUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocietyUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocietyUserCopyWith<SocietyUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocietyUserCopyWith<$Res> {
  factory $SocietyUserCopyWith(
    SocietyUser value,
    $Res Function(SocietyUser) then,
  ) = _$SocietyUserCopyWithImpl<$Res, SocietyUser>;
  @useResult
  $Res call({
    String uid,
    String orgId,
    String domainId,
    String name,
    String email,
    String roleName,
    UserStatus status,
    DateTime createdAt,
    bool needsPasswordReset,
  });
}

/// @nodoc
class _$SocietyUserCopyWithImpl<$Res, $Val extends SocietyUser>
    implements $SocietyUserCopyWith<$Res> {
  _$SocietyUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocietyUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? orgId = null,
    Object? domainId = null,
    Object? name = null,
    Object? email = null,
    Object? roleName = null,
    Object? status = null,
    Object? createdAt = null,
    Object? needsPasswordReset = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            orgId: null == orgId
                ? _value.orgId
                : orgId // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            roleName: null == roleName
                ? _value.roleName
                : roleName // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as UserStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            needsPasswordReset: null == needsPasswordReset
                ? _value.needsPasswordReset
                : needsPasswordReset // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocietyUserImplCopyWith<$Res>
    implements $SocietyUserCopyWith<$Res> {
  factory _$$SocietyUserImplCopyWith(
    _$SocietyUserImpl value,
    $Res Function(_$SocietyUserImpl) then,
  ) = __$$SocietyUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String orgId,
    String domainId,
    String name,
    String email,
    String roleName,
    UserStatus status,
    DateTime createdAt,
    bool needsPasswordReset,
  });
}

/// @nodoc
class __$$SocietyUserImplCopyWithImpl<$Res>
    extends _$SocietyUserCopyWithImpl<$Res, _$SocietyUserImpl>
    implements _$$SocietyUserImplCopyWith<$Res> {
  __$$SocietyUserImplCopyWithImpl(
    _$SocietyUserImpl _value,
    $Res Function(_$SocietyUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocietyUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? orgId = null,
    Object? domainId = null,
    Object? name = null,
    Object? email = null,
    Object? roleName = null,
    Object? status = null,
    Object? createdAt = null,
    Object? needsPasswordReset = null,
  }) {
    return _then(
      _$SocietyUserImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        roleName: null == roleName
            ? _value.roleName
            : roleName // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as UserStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        needsPasswordReset: null == needsPasswordReset
            ? _value.needsPasswordReset
            : needsPasswordReset // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocietyUserImpl implements _SocietyUser {
  const _$SocietyUserImpl({
    required this.uid,
    required this.orgId,
    required this.domainId,
    required this.name,
    required this.email,
    required this.roleName,
    required this.status,
    required this.createdAt,
    this.needsPasswordReset = false,
  });

  factory _$SocietyUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocietyUserImplFromJson(json);

  @override
  final String uid;
  @override
  final String orgId;
  @override
  final String domainId;
  @override
  final String name;
  @override
  final String email;
  @override
  final String roleName;
  @override
  final UserStatus status;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool needsPasswordReset;

  @override
  String toString() {
    return 'SocietyUser(uid: $uid, orgId: $orgId, domainId: $domainId, name: $name, email: $email, roleName: $roleName, status: $status, createdAt: $createdAt, needsPasswordReset: $needsPasswordReset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocietyUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.roleName, roleName) ||
                other.roleName == roleName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.needsPasswordReset, needsPasswordReset) ||
                other.needsPasswordReset == needsPasswordReset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    orgId,
    domainId,
    name,
    email,
    roleName,
    status,
    createdAt,
    needsPasswordReset,
  );

  /// Create a copy of SocietyUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocietyUserImplCopyWith<_$SocietyUserImpl> get copyWith =>
      __$$SocietyUserImplCopyWithImpl<_$SocietyUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocietyUserImplToJson(this);
  }
}

abstract class _SocietyUser implements SocietyUser {
  const factory _SocietyUser({
    required final String uid,
    required final String orgId,
    required final String domainId,
    required final String name,
    required final String email,
    required final String roleName,
    required final UserStatus status,
    required final DateTime createdAt,
    final bool needsPasswordReset,
  }) = _$SocietyUserImpl;

  factory _SocietyUser.fromJson(Map<String, dynamic> json) =
      _$SocietyUserImpl.fromJson;

  @override
  String get uid;
  @override
  String get orgId;
  @override
  String get domainId;
  @override
  String get name;
  @override
  String get email;
  @override
  String get roleName;
  @override
  UserStatus get status;
  @override
  DateTime get createdAt;
  @override
  bool get needsPasswordReset;

  /// Create a copy of SocietyUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocietyUserImplCopyWith<_$SocietyUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
