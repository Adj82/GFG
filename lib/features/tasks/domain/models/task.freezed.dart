// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocietyTask _$SocietyTaskFromJson(Map<String, dynamic> json) {
  return _SocietyTask.fromJson(json);
}

/// @nodoc
mixin _$SocietyTask {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get assigneeId => throw _privateConstructorUsedError;
  DateTime get deadline => throw _privateConstructorUsedError;
  TaskPriority get priority => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SocietyTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocietyTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocietyTaskCopyWith<SocietyTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocietyTaskCopyWith<$Res> {
  factory $SocietyTaskCopyWith(
    SocietyTask value,
    $Res Function(SocietyTask) then,
  ) = _$SocietyTaskCopyWithImpl<$Res, SocietyTask>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String domainId,
    String title,
    String description,
    String assigneeId,
    DateTime deadline,
    TaskPriority priority,
    TaskStatus status,
    String createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SocietyTaskCopyWithImpl<$Res, $Val extends SocietyTask>
    implements $SocietyTaskCopyWith<$Res> {
  _$SocietyTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocietyTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = null,
    Object? title = null,
    Object? description = null,
    Object? assigneeId = null,
    Object? deadline = null,
    Object? priority = null,
    Object? status = null,
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
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            assigneeId: null == assigneeId
                ? _value.assigneeId
                : assigneeId // ignore: cast_nullable_to_non_nullable
                      as String,
            deadline: null == deadline
                ? _value.deadline
                : deadline // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as TaskPriority,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TaskStatus,
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
abstract class _$$SocietyTaskImplCopyWith<$Res>
    implements $SocietyTaskCopyWith<$Res> {
  factory _$$SocietyTaskImplCopyWith(
    _$SocietyTaskImpl value,
    $Res Function(_$SocietyTaskImpl) then,
  ) = __$$SocietyTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String domainId,
    String title,
    String description,
    String assigneeId,
    DateTime deadline,
    TaskPriority priority,
    TaskStatus status,
    String createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SocietyTaskImplCopyWithImpl<$Res>
    extends _$SocietyTaskCopyWithImpl<$Res, _$SocietyTaskImpl>
    implements _$$SocietyTaskImplCopyWith<$Res> {
  __$$SocietyTaskImplCopyWithImpl(
    _$SocietyTaskImpl _value,
    $Res Function(_$SocietyTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocietyTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? domainId = null,
    Object? title = null,
    Object? description = null,
    Object? assigneeId = null,
    Object? deadline = null,
    Object? priority = null,
    Object? status = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SocietyTaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        assigneeId: null == assigneeId
            ? _value.assigneeId
            : assigneeId // ignore: cast_nullable_to_non_nullable
                  as String,
        deadline: null == deadline
            ? _value.deadline
            : deadline // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as TaskPriority,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TaskStatus,
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
class _$SocietyTaskImpl implements _SocietyTask {
  const _$SocietyTaskImpl({
    required this.id,
    required this.orgId,
    required this.domainId,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory _$SocietyTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocietyTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String domainId;
  @override
  final String title;
  @override
  final String description;
  @override
  final String assigneeId;
  @override
  final DateTime deadline;
  @override
  final TaskPriority priority;
  @override
  final TaskStatus status;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SocietyTask(id: $id, orgId: $orgId, domainId: $domainId, title: $title, description: $description, assigneeId: $assigneeId, deadline: $deadline, priority: $priority, status: $status, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocietyTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.assigneeId, assigneeId) ||
                other.assigneeId == assigneeId) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
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
    assigneeId,
    deadline,
    priority,
    status,
    createdBy,
    createdAt,
  );

  /// Create a copy of SocietyTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocietyTaskImplCopyWith<_$SocietyTaskImpl> get copyWith =>
      __$$SocietyTaskImplCopyWithImpl<_$SocietyTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocietyTaskImplToJson(this);
  }
}

abstract class _SocietyTask implements SocietyTask {
  const factory _SocietyTask({
    required final String id,
    required final String orgId,
    required final String domainId,
    required final String title,
    required final String description,
    required final String assigneeId,
    required final DateTime deadline,
    required final TaskPriority priority,
    required final TaskStatus status,
    required final String createdBy,
    required final DateTime createdAt,
  }) = _$SocietyTaskImpl;

  factory _SocietyTask.fromJson(Map<String, dynamic> json) =
      _$SocietyTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get domainId;
  @override
  String get title;
  @override
  String get description;
  @override
  String get assigneeId;
  @override
  DateTime get deadline;
  @override
  TaskPriority get priority;
  @override
  TaskStatus get status;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of SocietyTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocietyTaskImplCopyWith<_$SocietyTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
