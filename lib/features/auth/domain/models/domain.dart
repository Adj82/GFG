import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain.freezed.dart';
part 'domain.g.dart';

enum DomainType { technical, nonTechnical }

@freezed
class SocietyDomain with _$SocietyDomain {
  const factory SocietyDomain({
    required String id,
    required String orgId,
    required String name,
    required DomainType type,
  }) = _SocietyDomain;

  factory SocietyDomain.fromJson(Map<String, dynamic> json) => _$SocietyDomainFromJson(json);
}
