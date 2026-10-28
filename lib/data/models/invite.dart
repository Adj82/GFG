import 'json.dart';
import 'org.dart';

/// A place held for someone the President or VP added before they have ever
/// signed in. When that person first signs in with Google using this email,
/// the invite turns into their member record and is deleted.
///
/// The id is the lower-cased email. Backend: readable only by the person whose
/// verified token email matches the id (see firestore.rules).
class Invite implements Entity {
  const Invite({
    required this.id,
    required this.name,
    required this.roleId,
    required this.createdAt,
    this.domainId,
    this.department,
    this.createdBy = '',
  });

  /// Lower-cased email address.
  @override
  final String id;
  final String name;
  final String roleId;
  final String? domainId;
  final Department? department;
  final String createdBy;
  final DateTime createdAt;

  factory Invite.fromJson(Json j) => Invite(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    roleId: j['roleId'] as String,
    domainId: j['domainId'] as String?,
    department: readEnumOrNull(Department.values, j['department']),
    createdBy: j['createdBy'] as String? ?? '',
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'name': name,
    'roleId': roleId,
    'domainId': domainId,
    'department': department?.name,
    'createdBy': createdBy,
    'createdAt': writeDate(createdAt),
  };
}
