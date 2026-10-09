import 'json.dart';

/// The tenant. Every other record lives under one organisation, which is what
/// lets the same codebase serve IEEE, E-Cell, etc. later (doc §8, §11).
class Organization implements Entity {
  const Organization({
    required this.id,
    required this.name,
    required this.shortName,
    required this.campus,
    required this.emailDomain,
    required this.currentTerm,
    required this.termStartedAt,
    required this.createdAt,
    this.recruitmentOpen = false,
    this.recruitmentNote = '',
  });

  @override
  final String id;
  final String name;
  final String shortName;
  final String campus;

  /// Only addresses on this domain can sign up (e.g. kiit.ac.in).
  final String emailDomain;

  /// Academic year label, e.g. "2026–27".
  final String currentTerm;
  final DateTime termStartedAt;
  final DateTime createdAt;
  final bool recruitmentOpen;
  final String recruitmentNote;

  Organization copyWith({
    String? name,
    String? currentTerm,
    DateTime? termStartedAt,
    bool? recruitmentOpen,
    String? recruitmentNote,
  }) => Organization(
    id: id,
    name: name ?? this.name,
    shortName: shortName,
    campus: campus,
    emailDomain: emailDomain,
    currentTerm: currentTerm ?? this.currentTerm,
    termStartedAt: termStartedAt ?? this.termStartedAt,
    createdAt: createdAt,
    recruitmentOpen: recruitmentOpen ?? this.recruitmentOpen,
    recruitmentNote: recruitmentNote ?? this.recruitmentNote,
  );

  factory Organization.fromJson(Json j) => Organization(
    id: j['id'] as String,
    name: j['name'] as String,
    shortName: j['shortName'] as String,
    campus: j['campus'] as String? ?? '',
    emailDomain: j['emailDomain'] as String,
    currentTerm: j['currentTerm'] as String,
    termStartedAt: readDate(j['termStartedAt']),
    createdAt: readDate(j['createdAt']),
    recruitmentOpen: j['recruitmentOpen'] as bool? ?? false,
    recruitmentNote: j['recruitmentNote'] as String? ?? '',
  );

  @override
  Json toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
    'campus': campus,
    'emailDomain': emailDomain,
    'currentTerm': currentTerm,
    'termStartedAt': writeDate(termStartedAt),
    'createdAt': writeDate(createdAt),
    'recruitmentOpen': recruitmentOpen,
    'recruitmentNote': recruitmentNote,
  };
}

enum Department {
  technical('Technical'),
  nonTechnical('Non-technical');

  const Department(this.label);
  final String label;
}

class Domain implements Entity {
  const Domain({
    required this.id,
    required this.name,
    required this.department,
    required this.icon,
    this.blurb = '',
  });

  @override
  final String id;
  final String name;
  final Department department;

  /// Key into the icon map in the UI layer (keeps Flutter out of the model).
  final String icon;
  final String blurb;

  factory Domain.fromJson(Json j) => Domain(
    id: j['id'] as String,
    name: j['name'] as String,
    department: readEnum(
      Department.values,
      j['department'],
      Department.technical,
    ),
    icon: j['icon'] as String? ?? 'code',
    blurb: j['blurb'] as String? ?? '',
  );

  @override
  Json toJson() => {
    'id': id,
    'name': name,
    'department': department.name,
    'icon': icon,
    'blurb': blurb,
  };
}
