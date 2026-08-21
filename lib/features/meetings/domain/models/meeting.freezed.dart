// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocietyMeeting _$SocietyMeetingFromJson(Map<String, dynamic> json) {
  return _SocietyMeeting.fromJson(json);
}

/// @nodoc
mixin _$SocietyMeeting {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String? get domainId => throw _privateConstructorUsedError; // null = global
  String get title => throw _privateConstructorUsedError;
  String get agenda => throw _privateConstructorUsedError;
  DateTime get time => throw _privateConstructorUsedError;
  String get venue => throw _privateConstructorUsedError;
  String? get link => throw _privateConstructorUsedError;
  String get scheduledBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SocietyMeeting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocietyMeeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocietyMeetingCopyWith<SocietyMeeting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocietyMeetingCopyWith<$Res> {
  factory $SocietyMeetingCopyWith(
    SocietyMeeting value,
    $Res Function(SocietyMeeting) then,
  ) = _$SocietyMeetingCopyWithImpl<$Res, SocietyMeeting>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String? domainId,
    String title,
    String agenda,
    DateTime time,
    String venue,
    String? link,
    String scheduledBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SocietyMeetingCopyWithImpl<$Res, $Val extends SocietyMeeting>
    implements $SocietyMeetingCopyWith<$Res> {
  _$SocietyMeetingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocietyMeeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = freezed,
    Object? title = null,
    Object? agenda = null,
    Object? time = null,
    Object? venue = null,
    Object? link = freezed,
    Object? scheduledBy = null,
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
            agenda: null == agenda
                ? _value.agenda
                : agenda // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            venue: null == venue
                ? _value.venue
                : venue // ignore: cast_nullable_to_non_nullable
                      as String,
            link: freezed == link
                ? _value.link
                : link // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledBy: null == scheduledBy
                ? _value.scheduledBy
                : scheduledBy // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SocietyMeetingImplCopyWith<$Res>
    implements $SocietyMeetingCopyWith<$Res> {
  factory _$$SocietyMeetingImplCopyWith(
    _$SocietyMeetingImpl value,
    $Res Function(_$SocietyMeetingImpl) then,
  ) = __$$SocietyMeetingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String? domainId,
    String title,
    String agenda,
    DateTime time,
    String venue,
    String? link,
    String scheduledBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SocietyMeetingImplCopyWithImpl<$Res>
    extends _$SocietyMeetingCopyWithImpl<$Res, _$SocietyMeetingImpl>
    implements _$$SocietyMeetingImplCopyWith<$Res> {
  __$$SocietyMeetingImplCopyWithImpl(
    _$SocietyMeetingImpl _value,
    $Res Function(_$SocietyMeetingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocietyMeeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = freezed,
    Object? title = null,
    Object? agenda = null,
    Object? time = null,
    Object? venue = null,
    Object? link = freezed,
    Object? scheduledBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SocietyMeetingImpl(
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
        agenda: null == agenda
            ? _value.agenda
            : agenda // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        venue: null == venue
            ? _value.venue
            : venue // ignore: cast_nullable_to_non_nullable
                  as String,
        link: freezed == link
            ? _value.link
            : link // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledBy: null == scheduledBy
            ? _value.scheduledBy
            : scheduledBy // ignore: cast_nullable_to_non_nullable
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
class _$SocietyMeetingImpl implements _SocietyMeeting {
  const _$SocietyMeetingImpl({
    required this.id,
    required this.orgId,
    this.domainId,
    required this.title,
    required this.agenda,
    required this.time,
    required this.venue,
    this.link,
    required this.scheduledBy,
    required this.createdAt,
  });

  factory _$SocietyMeetingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocietyMeetingImplFromJson(json);

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
  final String agenda;
  @override
  final DateTime time;
  @override
  final String venue;
  @override
  final String? link;
  @override
  final String scheduledBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SocietyMeeting(id: $id, orgId: $orgId, domainId: $domainId, title: $title, agenda: $agenda, time: $time, venue: $venue, link: $link, scheduledBy: $scheduledBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocietyMeetingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.agenda, agenda) || other.agenda == agenda) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.scheduledBy, scheduledBy) ||
                other.scheduledBy == scheduledBy) &&
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
    agenda,
    time,
    venue,
    link,
    scheduledBy,
    createdAt,
  );

  /// Create a copy of SocietyMeeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocietyMeetingImplCopyWith<_$SocietyMeetingImpl> get copyWith =>
      __$$SocietyMeetingImplCopyWithImpl<_$SocietyMeetingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SocietyMeetingImplToJson(this);
  }
}

abstract class _SocietyMeeting implements SocietyMeeting {
  const factory _SocietyMeeting({
    required final String id,
    required final String orgId,
    final String? domainId,
    required final String title,
    required final String agenda,
    required final DateTime time,
    required final String venue,
    final String? link,
    required final String scheduledBy,
    required final DateTime createdAt,
  }) = _$SocietyMeetingImpl;

  factory _SocietyMeeting.fromJson(Map<String, dynamic> json) =
      _$SocietyMeetingImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String? get domainId; // null = global
  @override
  String get title;
  @override
  String get agenda;
  @override
  DateTime get time;
  @override
  String get venue;
  @override
  String? get link;
  @override
  String get scheduledBy;
  @override
  DateTime get createdAt;

  /// Create a copy of SocietyMeeting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocietyMeetingImplCopyWith<_$SocietyMeetingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
