import 'json.dart';
import 'org.dart';

enum MemberStatus {
  /// Signed up, waiting for a lead to accept the join request.
  pending,
  active,

  /// Off-boarded (e.g. outgoing cabinet). History stays queryable — never deleted.
  disabled,

  /// Join request declined.
  rejected,
}

/// A role someone held in a past term — kept for the handover history (doc §7).
class PastRole {
  const PastRole({required this.term, required this.roleId, this.domainId});

  final String term;
  final String roleId;
  final String? domainId;

  factory PastRole.fromJson(Json j) => PastRole(
    term: j['term'] as String,
    roleId: j['roleId'] as String,
    domainId: j['domainId'] as String?,
  );

  Json toJson() => {'term': term, 'roleId': roleId, 'domainId': domainId};
}

class Member implements Entity {
  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.status,
    required this.joinedAt,
    this.domainId,
    this.department,
    this.phone = '',
    this.year,
    this.branch = '',
    this.bio = '',
    this.skills = const [],
    this.github = '',
    this.linkedin = '',
    this.history = const [],
    this.needsPasswordReset = false,
    this.disabledAt,
  });

  /// Same as the auth uid.
  @override
  final String id;
  final String name;
  final String email;
  final String roleId;
  final MemberStatus status;
  final DateTime joinedAt;

  /// Domain the member belongs to. Null for society-level office bearers.
  final String? domainId;

  /// Set for core heads who own a whole department rather than a domain.
  final Department? department;

  final String phone;
  final int? year;
  final String branch;
  final String bio;
  final List<String> skills;
  final String github;
  final String linkedin;
  final List<PastRole> history;

  /// True for accounts created by the President with a temporary password.
  final bool needsPasswordReset;
  final DateTime? disabledAt;

  bool get isActive => status == MemberStatus.active;

  /// KIIT roll number is the local part of the email for students.
  String get rollNo => email.split('@').first;

  Member copyWith({
    String? name,
    String? roleId,
    MemberStatus? status,
    Object? domainId = unset,
    Object? department = unset,
    String? phone,
    Object? year = unset,
    String? branch,
    String? bio,
    List<String>? skills,
    String? github,
    String? linkedin,
    List<PastRole>? history,
    bool? needsPasswordReset,
    Object? disabledAt = unset,
  }) => Member(
    id: id,
    name: name ?? this.name,
    email: email,
    roleId: roleId ?? this.roleId,
    status: status ?? this.status,
    joinedAt: joinedAt,
    domainId: identical(domainId, unset) ? this.domainId : domainId as String?,
    department: identical(department, unset)
        ? this.department
        : department as Department?,
    phone: phone ?? this.phone,
    year: identical(year, unset) ? this.year : year as int?,
    branch: branch ?? this.branch,
    bio: bio ?? this.bio,
    skills: skills ?? this.skills,
    github: github ?? this.github,
    linkedin: linkedin ?? this.linkedin,
    history: history ?? this.history,
    needsPasswordReset: needsPasswordReset ?? this.needsPasswordReset,
    disabledAt: identical(disabledAt, unset)
        ? this.disabledAt
        : disabledAt as DateTime?,
  );

  factory Member.fromJson(Json j) => Member(
    id: j['id'] as String,
    name: j['name'] as String,
    email: j['email'] as String,
    roleId: j['roleId'] as String,
    status: readEnum(MemberStatus.values, j['status'], MemberStatus.pending),
    joinedAt: readDate(j['joinedAt']),
    domainId: j['domainId'] as String?,
    department: readEnumOrNull(Department.values, j['department']),
    phone: j['phone'] as String? ?? '',
    year: j['year'] as int?,
    branch: j['branch'] as String? ?? '',
    bio: j['bio'] as String? ?? '',
    skills: readStrings(j['skills']),
    github: j['github'] as String? ?? '',
    linkedin: j['linkedin'] as String? ?? '',
    history: readList(j['history'], PastRole.fromJson),
    needsPasswordReset: j['needsPasswordReset'] as bool? ?? false,
    disabledAt: readDateOrNull(j['disabledAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'roleId': roleId,
    'status': status.name,
    'joinedAt': writeDate(joinedAt),
    'domainId': domainId,
    'department': department?.name,
    'phone': phone,
    'year': year,
    'branch': branch,
    'bio': bio,
    'skills': skills,
    'github': github,
    'linkedin': linkedin,
    'history': history.map((h) => h.toJson()).toList(),
    'needsPasswordReset': needsPasswordReset,
    'disabledAt': writeDate(disabledAt),
  };
}
