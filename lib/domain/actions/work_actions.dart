import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../checkin_code.dart';
import '../event_templates.dart';
import 'base.dart';

final taskActionsProvider = Provider((ref) => TaskActions(ref));
final eventActionsProvider = Provider((ref) => EventActions(ref));
final announcementActionsProvider = Provider((ref) => AnnouncementActions(ref));
final meetingActionsProvider = Provider((ref) => MeetingActions(ref));
final vaultActionsProvider = Provider((ref) => VaultActions(ref));
final commentActionsProvider = Provider((ref) => CommentActions(ref));
final noticeActionsProvider = Provider((ref) => NoticeActions(ref));

class TaskActions extends ActionsBase {
  TaskActions(super.ref);

  Future<SocietyTask> create({
    required String title,
    String description = '',
    String? domainId,
    String? eventId,
    String? meetingId,
    List<String> assigneeIds = const [],
    DateTime? due,
    TaskPriority priority = TaskPriority.medium,
    List<String> checklist = const [],
  }) async {
    final t = SocietyTask(
      id: newId(),
      title: title.trim(),
      description: description.trim(),
      domainId: domainId,
      eventId: eventId,
      meetingId: meetingId,
      assigneeIds: assigneeIds,
      due: due,
      priority: priority,
      checklist: [
        for (final c in checklist) ChecklistItem(id: newId(), text: c),
      ],
      createdBy: myId,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(taskRepo).save(t);
    await notify(
      assigneeIds,
      kind: NoticeKind.task,
      title: 'New task: ${t.title}',
      body:
          '${nameOf(myId)} assigned this to you${due == null ? '' : ' · due ${due.day}/${due.month}'}.',
      route: '/tasks/${t.id}',
    );
    return t;
  }

  Future<void> update(SocietyTask before, SocietyTask after) async {
    await ref.read(taskRepo).save(after.copyWith(updatedAt: now));
    final added = after.assigneeIds.where(
      (id) => !before.assigneeIds.contains(id),
    );
    await notify(
      added,
      kind: NoticeKind.task,
      title: 'New task: ${after.title}',
      body: '${nameOf(myId)} added you to this task.',
      route: '/tasks/${after.id}',
    );
  }

  Future<void> move(SocietyTask t, TaskStatus status) async {
    if (t.status == status) return;
    await ref
        .read(taskRepo)
        .save(
          t.copyWith(
            status: status,
            completedAt: status == TaskStatus.done ? now : null,
            updatedAt: now,
          ),
        );
    if (status == TaskStatus.review || status == TaskStatus.done) {
      await notify(
        [t.createdBy],
        kind: NoticeKind.task,
        title: status == TaskStatus.done
            ? 'Done: ${t.title}'
            : 'Ready for review: ${t.title}',
        body: '${nameOf(myId)} moved it to ${status.label.toLowerCase()}.',
        route: '/tasks/${t.id}',
      );
    }
  }

  Future<void> toggleChecklist(SocietyTask t, String itemId) => ref
      .read(taskRepo)
      .save(
        t.copyWith(
          checklist: [
            for (final c in t.checklist)
              c.id == itemId ? c.copyWith(done: !c.done) : c,
          ],
          updatedAt: now,
        ),
      );

  Future<void> addChecklistItem(SocietyTask t, String text) => ref
      .read(taskRepo)
      .save(
        t.copyWith(
          checklist: [
            ...t.checklist,
            ChecklistItem(id: newId(), text: text.trim()),
          ],
          updatedAt: now,
        ),
      );

  Future<void> delete(SocietyTask t) => ref.read(taskRepo).delete(t.id);
}

class EventActions extends ActionsBase {
  EventActions(super.ref);

  static String _secret() {
    final r = Random.secure();
    return List.generate(24, (_) => r.nextInt(36).toRadixString(36)).join();
  }

  Future<SocietyEvent> create({
    required String title,
    required EventType type,
    required DateTime startsAt,
    required DateTime endsAt,
    required String venue,
    String description = '',
    String? domainId,
    List<String> organizerIds = const [],
    double budget = 0,
    int? capacity,
    bool isPublic = true,
    bool addPrepTasks = true,
  }) async {
    final e = SocietyEvent(
      id: newId(),
      title: title.trim(),
      type: type,
      description: description.trim(),
      startsAt: startsAt,
      endsAt: endsAt,
      venue: venue.trim(),
      domainId: domainId,
      organizerIds: {myId, ...organizerIds}.toList(),
      budget: budget,
      capacity: capacity,
      isPublic: isPublic,
      checkInSecret: _secret(),
      createdBy: myId,
      createdAt: now,
    );
    await ref.read(eventRepo).save(e);

    if (addPrepTasks) {
      final tasks = [
        for (final t in EventTemplates.forType(type))
          SocietyTask(
            id: newId(),
            title: t.title,
            eventId: e.id,
            domainId: domainId,
            priority: t.priority,
            due: startsAt.subtract(Duration(days: t.daysBefore)),
            checklist: [
              for (final c in t.checklist) ChecklistItem(id: newId(), text: c),
            ],
            createdBy: myId,
            createdAt: now,
            updatedAt: now,
          ),
      ];
      await ref.read(taskRepo).saveAll(tasks);
    }

    await notify(
      audienceIds(
        audience: domainId == null ? Audience.society : Audience.domain,
        domainId: domainId,
      ),
      kind: NoticeKind.event,
      title: 'New event: ${e.title}',
      body:
          '${e.type.label} on ${startsAt.day}/${startsAt.month} at ${e.venue}. RSVP in the app.',
      route: '/events/${e.id}',
    );
    return e;
  }

  Future<void> update(SocietyEvent e) => ref.read(eventRepo).save(e);

  Future<void> toggleRsvp(SocietyEvent e) {
    final going = e.rsvpIds.contains(myId);
    return ref
        .read(eventRepo)
        .save(
          e.copyWith(
            rsvpIds: going
                ? e.rsvpIds.where((id) => id != myId).toList()
                : [...e.rsvpIds, myId],
          ),
        );
  }

  Future<void> setCheckInOpen(SocietyEvent e, bool open) =>
      ref.read(eventRepo).save(e.copyWith(checkInOpen: open));

  Future<void> cancel(SocietyEvent e) async {
    await ref
        .read(eventRepo)
        .save(e.copyWith(cancelled: true, checkInOpen: false));
    await notify(
      e.rsvpIds,
      kind: NoticeKind.event,
      title: 'Cancelled: ${e.title}',
      body:
          'This event won’t happen as planned. Watch announcements for updates.',
      route: '/events/${e.id}',
    );
    await audit('event.cancelled', 'Cancelled ${e.title}', targetId: e.id);
  }

  /// Self check-in with a scanned or typed code. Returns an error message,
  /// or null on success.
  Future<String?> checkIn(SocietyEvent e, String code) async {
    if (e.cancelled) return 'This event was cancelled.';
    if (!e.checkInOpen) {
      return 'Check-in isn’t open yet. Ask an organiser to open it.';
    }
    if (!CheckInCode.verify(e.checkInSecret, e.id, code, now)) {
      return 'That code has expired or is wrong. Scan the code on screen again.';
    }
    await _mark(e.id, myId, CheckInMethod.code);
    return null;
  }

  Future<void> markPresent(SocietyEvent e, String memberId) =>
      _mark(e.id, memberId, CheckInMethod.manual);

  Future<void> unmark(SocietyEvent e, String memberId) => ref
      .read(attendanceRepo)
      .delete(AttendanceRecord.idFor(AttendanceTarget.event, e.id, memberId));

  Future<void> _mark(String eventId, String memberId, CheckInMethod method) =>
      ref
          .read(attendanceRepo)
          .save(
            AttendanceRecord(
              id: AttendanceRecord.idFor(
                AttendanceTarget.event,
                eventId,
                memberId,
              ),
              target: AttendanceTarget.event,
              targetId: eventId,
              memberId: memberId,
              at: now,
              method: method,
              markedBy: myId,
            ),
          );
}

class AnnouncementActions extends ActionsBase {
  AnnouncementActions(super.ref);

  Future<void> post({
    required String title,
    required String body,
    required Audience audience,
    String? domainId,
    Department? dept,
    bool pinned = false,
  }) async {
    final a = Announcement(
      id: newId(),
      title: title.trim(),
      body: body.trim(),
      audience: audience,
      domainId: audience == Audience.domain ? domainId : null,
      department: audience == Audience.department ? dept : null,
      authorId: myId,
      createdAt: now,
      pinned: pinned,
      readBy: [myId],
    );
    await ref.read(announcementRepo).save(a);
    await notify(
      audienceIds(audience: audience, domainId: a.domainId, dept: a.department),
      kind: NoticeKind.announcement,
      title: a.title,
      body: a.body.length > 120 ? '${a.body.substring(0, 117)}…' : a.body,
      route: '/announcements',
    );
  }

  Future<void> togglePin(Announcement a) =>
      ref.read(announcementRepo).save(a.copyWith(pinned: !a.pinned));

  Future<void> markRead(Announcement a) async {
    if (a.readBy.contains(myId)) return;
    await ref
        .read(announcementRepo)
        .save(a.copyWith(readBy: [...a.readBy, myId]));
  }

  Future<void> delete(Announcement a) =>
      ref.read(announcementRepo).delete(a.id);
}

class MeetingActions extends ActionsBase {
  MeetingActions(super.ref);

  Future<Meeting> schedule({
    required String title,
    required DateTime startsAt,
    required int durationMinutes,
    required Audience audience,
    String? domainId,
    Department? dept,
    String venue = '',
    String link = '',
    List<String> agenda = const [],
  }) async {
    final m = Meeting(
      id: newId(),
      title: title.trim(),
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      audience: audience,
      domainId: audience == Audience.domain ? domainId : null,
      department: audience == Audience.department ? dept : null,
      venue: venue.trim(),
      link: link.trim(),
      agenda: agenda
          .where((a) => a.trim().isNotEmpty)
          .map((a) => a.trim())
          .toList(),
      createdBy: myId,
      createdAt: now,
    );
    await ref.read(meetingRepo).save(m);
    await notify(
      audienceIds(audience: audience, domainId: m.domainId, dept: m.department),
      kind: NoticeKind.meeting,
      title: 'Meeting: ${m.title}',
      body:
          '${startsAt.day}/${startsAt.month} at ${startsAt.hour}:${startsAt.minute.toString().padLeft(2, '0')}'
          '${m.venue.isEmpty ? '' : ' · ${m.venue}'}',
      route: '/meetings/${m.id}',
    );
    return m;
  }

  Future<void> saveMinutes(Meeting m, String minutes) =>
      ref.read(meetingRepo).save(m.copyWith(minutes: minutes));

  Future<void> addActionItem(Meeting m, String text, String? assigneeId) => ref
      .read(meetingRepo)
      .save(
        m.copyWith(
          actionItems: [
            ...m.actionItems,
            ActionItem(id: newId(), text: text.trim(), assigneeId: assigneeId),
          ],
        ),
      );

  Future<void> removeActionItem(Meeting m, String itemId) => ref
      .read(meetingRepo)
      .save(
        m.copyWith(
          actionItems: m.actionItems.where((a) => a.id != itemId).toList(),
        ),
      );

  /// Turns an action item into a task on the board (doc §5 Meetings).
  Future<void> convertToTask(
    Meeting m,
    ActionItem item, {
    DateTime? due,
  }) async {
    final task = await ref
        .read(taskActionsProvider)
        .create(
          title: item.text,
          description: 'From meeting: ${m.title}',
          domainId: m.domainId,
          meetingId: m.id,
          assigneeIds: item.assigneeId == null ? const [] : [item.assigneeId!],
          due: due ?? now.add(const Duration(days: 5)),
        );
    await ref
        .read(meetingRepo)
        .save(
          m.copyWith(
            actionItems: [
              for (final a in m.actionItems)
                a.id == item.id ? a.copyWith(taskId: task.id) : a,
            ],
          ),
        );
  }

  Future<void> toggleAttendance(Meeting m, String memberId) async {
    final id = AttendanceRecord.idFor(AttendanceTarget.meeting, m.id, memberId);
    final repo = ref.read(attendanceRepo);
    if (await repo.fetch(id) != null) {
      await repo.delete(id);
    } else {
      await repo.save(
        AttendanceRecord(
          id: id,
          target: AttendanceTarget.meeting,
          targetId: m.id,
          memberId: memberId,
          at: m.startsAt,
          method: CheckInMethod.manual,
          markedBy: myId,
        ),
      );
    }
  }

  Future<void> delete(Meeting m) => ref.read(meetingRepo).delete(m.id);
}

class VaultActions extends ActionsBase {
  VaultActions(super.ref);

  Future<void> addLink({
    required String title,
    required String url,
    required VaultCategory category,
    String description = '',
  }) {
    final u = url.trim();
    return ref
        .read(vaultRepo)
        .save(
          VaultItem(
            id: newId(),
            title: title.trim(),
            url: u.startsWith('http') ? u : 'https://$u',
            category: category,
            description: description.trim(),
            addedBy: myId,
            addedAt: now,
          ),
        );
  }

  /// Backend: upload bytes to Storage first and store the Storage path in [fileRef].
  Future<void> addFile({
    required String title,
    required String fileName,
    required int sizeBytes,
    String? localPath,
    required VaultCategory category,
    String description = '',
  }) => ref
      .read(vaultRepo)
      .save(
        VaultItem(
          id: newId(),
          title: title.trim(),
          fileName: fileName,
          fileRef: localPath,
          sizeBytes: sizeBytes,
          category: category,
          description: description.trim(),
          addedBy: myId,
          addedAt: now,
        ),
      );

  Future<void> delete(VaultItem item) => ref.read(vaultRepo).delete(item.id);
}

class CommentActions extends ActionsBase {
  CommentActions(super.ref);

  Future<void> add({
    required CommentParent parent,
    required String parentId,
    required String text,
    Iterable<String> notifyIds = const [],
    String? route,
    String? subject,
  }) async {
    await ref
        .read(commentRepo)
        .save(
          Comment(
            id: newId(),
            parent: parent,
            parentId: parentId,
            authorId: myId,
            text: text.trim(),
            createdAt: now,
          ),
        );
    await notify(
      notifyIds,
      kind: parent == CommentParent.expense
          ? NoticeKind.finance
          : NoticeKind.task,
      title:
          '${nameOf(myId)} commented${subject == null ? '' : ' on $subject'}',
      body: text.trim(),
      route: route,
    );
  }

  Future<void> delete(Comment c) => ref.read(commentRepo).delete(c.id);
}

class NoticeActions extends ActionsBase {
  NoticeActions(super.ref);

  Future<void> markRead(Notice n) async {
    if (n.read) return;
    await ref.read(noticeRepo).save(n.copyWith(read: true));
  }

  Future<void> markAllRead() async {
    final mine = ref
        .read(noticesProvider)
        .where((n) => n.recipientId == myId && !n.read);
    await ref.read(noticeRepo).saveAll(mine.map((n) => n.copyWith(read: true)));
  }
}
