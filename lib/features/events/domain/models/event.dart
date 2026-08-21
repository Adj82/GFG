import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class SocietyEvent with _$SocietyEvent {
  const factory SocietyEvent({
    required String id,
    required String orgId,
    String? domainId, // null = global
    required String title,
    required String description,
    required String venue,
    required DateTime date,
    @Default([]) List<String> rsvpUserIds,
    required String createdBy,
    required DateTime createdAt,
  }) = _SocietyEvent;

  factory SocietyEvent.fromJson(Map<String, dynamic> json) => _$SocietyEventFromJson(json);
}
