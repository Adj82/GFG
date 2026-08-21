// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocietyEvent _$SocietyEventFromJson(Map<String, dynamic> json) {
  return _SocietyEvent.fromJson(json);
}

/// @nodoc
mixin _$SocietyEvent {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String? get domainId => throw _privateConstructorUsedError; // null = global
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get venue => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<String> get rsvpUserIds => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SocietyEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocietyEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocietyEventCopyWith<SocietyEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocietyEventCopyWith<$Res> {
  factory $SocietyEventCopyWith(
    SocietyEvent value,
    $Res Function(SocietyEvent) then,
  ) = _$SocietyEventCopyWithImpl<$Res, SocietyEvent>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String? domainId,
    String title,
    String description,
    String venue,
    DateTime date,
    List<String> rsvpUserIds,
    String createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SocietyEventCopyWithImpl<$Res, $Val extends SocietyEvent>
    implements $SocietyEventCopyWith<$Res> {
  _$SocietyEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocietyEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = freezed,
    Object? title = null,
    Object? description = null,
    Object? venue = null,
    Object? date = null,
    Object? rsvpUserIds = null,
    Object? createdBy = null,
    Object? createdAt = null,
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
            domainId: freezed == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            venue: null == venue
                ? _value.venue
                : venue // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            rsvpUserIds: null == rsvpUserIds
                ? _value.rsvpUserIds
                : rsvpUserIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SocietyEventImplCopyWith<$Res>
    implements $SocietyEventCopyWith<$Res> {
  factory _$$SocietyEventImplCopyWith(
    _$SocietyEventImpl value,
    $Res Function(_$SocietyEventImpl) then,
  ) = __$$SocietyEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String? domainId,
    String title,
    String description,
    String venue,
    DateTime date,
    List<String> rsvpUserIds,
    String createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SocietyEventImplCopyWithImpl<$Res>
    extends _$SocietyEventCopyWithImpl<$Res, _$SocietyEventImpl>
    implements _$$SocietyEventImplCopyWith<$Res> {
  __$$SocietyEventImplCopyWithImpl(
    _$SocietyEventImpl _value,
    $Res Function(_$SocietyEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocietyEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = freezed,
    Object? title = null,
    Object? description = null,
    Object? venue = null,
    Object? date = null,
    Object? rsvpUserIds = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SocietyEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: freezed == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        venue: null == venue
            ? _value.venue
            : venue // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        rsvpUserIds: null == rsvpUserIds
            ? _value._rsvpUserIds
            : rsvpUserIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocietyEventImpl implements _SocietyEvent {
  const _$SocietyEventImpl({
    required this.id,
    required this.orgId,
    this.domainId,
    required this.title,
    required this.description,
    required this.venue,
    required this.date,
    final List<String> rsvpUserIds = const [],
    required this.createdBy,
    required this.createdAt,
  }) : _rsvpUserIds = rsvpUserIds;

  factory _$SocietyEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocietyEventImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String? domainId;
  // null = global
  @override
  final String title;
  @override
  final String description;
  @override
  final String venue;
  @override
  final DateTime date;
  final List<String> _rsvpUserIds;
  @override
  @JsonKey()
  List<String> get rsvpUserIds {
    if (_rsvpUserIds is EqualUnmodifiableListView) return _rsvpUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rsvpUserIds);
  }

  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SocietyEvent(id: $id, orgId: $orgId, domainId: $domainId, title: $title, description: $description, venue: $venue, date: $date, rsvpUserIds: $rsvpUserIds, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocietyEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._rsvpUserIds,
              _rsvpUserIds,
            ) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    domainId,
    title,
    description,
    venue,
    date,
    const DeepCollectionEquality().hash(_rsvpUserIds),
    createdBy,
    createdAt,
  );

  /// Create a copy of SocietyEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocietyEventImplCopyWith<_$SocietyEventImpl> get copyWith =>
      __$$SocietyEventImplCopyWithImpl<_$SocietyEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocietyEventImplToJson(this);
  }
}

abstract class _SocietyEvent implements SocietyEvent {
  const factory _SocietyEvent({
    required final String id,
    required final String orgId,
    final String? domainId,
    required final String title,
    required final String description,
    required final String venue,
    required final DateTime date,
    final List<String> rsvpUserIds,
    required final String createdBy,
    required final DateTime createdAt,
  }) = _$SocietyEventImpl;

  factory _SocietyEvent.fromJson(Map<String, dynamic> json) =
      _$SocietyEventImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String? get domainId; // null = global
  @override
  String get title;
  @override
  String get description;
  @override
  String get venue;
  @override
  DateTime get date;
  @override
  List<String> get rsvpUserIds;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of SocietyEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocietyEventImplCopyWith<_$SocietyEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
