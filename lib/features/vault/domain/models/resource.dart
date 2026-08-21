import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource.freezed.dart';
part 'resource.g.dart';

@freezed
class SocietyResource with _$SocietyResource {
  const factory SocietyResource({
    required String id,
    required String orgId,
    required String title,
    required String type, // e.g., 'PDF', 'PNG', 'Doc'
    required String downloadUrl,
    required String uploadedBy,
    required DateTime createdAt,
    required double sizeKb,
  }) = _SocietyResource;

  factory SocietyResource.fromJson(Map<String, dynamic> json) => _$SocietyResourceFromJson(json);
}
