import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserStatus { pending, active, disabled }

@freezed
class SocietyUser with _$SocietyUser {
  const factory SocietyUser({
    required String uid,
    required String orgId,
    required String domainId,
    required String name,
    required String email,
    required String roleName,
    required UserStatus status,
    required DateTime createdAt,
    @Default(false) bool needsPasswordReset,
  }) = _SocietyUser;

  factory SocietyUser.fromJson(Map<String, dynamic> json) => _$SocietyUserFromJson(json);
}
