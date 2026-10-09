import '../data/models/models.dart';

/// "Event in a box": prep checklists generated when an event is created, so
/// leads don't start from a blank board every time.
class TemplateTask {
  const TemplateTask(
    this.title,
    this.daysBefore, {
    this.priority = TaskPriority.medium,
    this.checklist = const [],
  });

  final String title;

  /// Deadline relative to the event start.
  final int daysBefore;
  final TaskPriority priority;
  final List<String> checklist;
}

abstract final class EventTemplates {
  static const _common = [
    TemplateTask(
      'Book venue and AV',
      14,
      priority: TaskPriority.high,
      checklist: [
        'Send booking request to the campus office',
        'Confirm projector, mics and Wi-Fi',
      ],
    ),
    TemplateTask(
      'Design poster and social creatives',
      10,
      checklist: ['Poster (A3 + Instagram 4:5)', 'Story and WhatsApp versions'],
    ),
    TemplateTask('Open registrations', 9, priority: TaskPriority.high),
    TemplateTask('Announce on all channels', 7),
    TemplateTask('Send reminder to registrants', 1),
    TemplateTask('Collect feedback and photos', -2),
  ];

  static List<TemplateTask> forType(EventType type) => switch (type) {
    EventType.hackathon => [
      ..._common,
      const TemplateTask(
        'Lock problem statements',
        12,
        priority: TaskPriority.high,
      ),
      const TemplateTask(
        'Confirm judges and mentors',
        10,
        priority: TaskPriority.high,
      ),
      const TemplateTask('Arrange food for participants', 5),
      const TemplateTask('Order prizes and swag', 7),
    ],
    EventType.workshop || EventType.bootcamp => [
      ..._common,
      const TemplateTask(
        'Prepare session material and repo',
        5,
        priority: TaskPriority.high,
        checklist: [
          'Slides',
          'Starter repo with setup steps',
          'Dry run with a member',
        ],
      ),
      const TemplateTask('Share setup instructions with attendees', 2),
    ],
    EventType.contest => [
      const TemplateTask(
        'Set and test problems',
        7,
        priority: TaskPriority.high,
      ),
      const TemplateTask('Create contest on the judge platform', 4),
      const TemplateTask('Announce contest', 5),
      const TemplateTask('Publish editorial and results', -1),
    ],
    EventType.talk => [
      const TemplateTask(
        'Confirm speaker and topic',
        14,
        priority: TaskPriority.high,
      ),
      ..._common,
    ],
    EventType.meetup || EventType.orientation => _common,
  };
}
