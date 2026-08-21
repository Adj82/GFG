import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@freezed
class SocietyMeeting with _$SocietyMeeting {
  const factory SocietyMeeting({
    required String id,
    required String orgId,
    String? domainId, // null = global
    required String title,
    required String agenda,
    required DateTime time,
    required String venue,
    String? link,
    required String scheduledBy,
    required DateTime createdAt,
  }) = _SocietyMeeting;

  factory SocietyMeeting.fromJson(Map<String, dynamic> json) => _$SocietyMeetingFromJson(json);
}
