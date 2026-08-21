import 'package:uuid/uuid.dart';
import '../../features/auth/domain/models/organization.dart';
import '../../features/auth/domain/models/domain.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/domain/models/role.dart';
import '../../features/auth/domain/permissions_matrix.dart';
import '../../features/tasks/domain/models/task.dart';
import '../../features/announcements/domain/models/announcement.dart';

class MockData {
  static const String orgId = 'gfg-kiit-id';
  static const _uuid = Uuid();

  static final organization = Organization(
    id: orgId,
    name: 'GFG KIIT Student Chapter',
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
  );

  static final organizations = [organization];

  static const domains = [
    SocietyDomain(id: 'dom-tech', orgId: orgId, name: 'Technical', type: DomainType.technical),
    SocietyDomain(id: 'dom-creative', orgId: orgId, name: 'Creative', type: DomainType.nonTechnical),
    SocietyDomain(id: 'dom-pr', orgId: orgId, name: 'Public Relations', type: DomainType.nonTechnical),
    SocietyDomain(id: 'dom-ops', orgId: orgId, name: 'Operations', type: DomainType.nonTechnical),
  ];

  static final roles = PermissionsMatrix.defaults.entries.map((e) => SocietyRole(
    id: 'role-${e.key.toLowerCase().replaceAll(' ', '-')}',
    orgId: orgId,
    name: e.key,
    permissions: e.value,
  )).toList();

  static final users = [
    SocietyUser(
      uid: 'user-pres',
      orgId: orgId,
      domainId: 'dom-tech',
      name: 'Aditya Raj',
      email: 'president@kiit.ac.in',
      roleName: 'President',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    SocietyUser(
      uid: 'user-vp',
      orgId: orgId,
      domainId: 'dom-tech',
      name: 'Sanya Singh',
      email: 'vp@kiit.ac.in',
      roleName: 'Vice President',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 190)),
    ),
    SocietyUser(
      uid: 'user-tech-head',
      orgId: orgId,
      domainId: 'dom-tech',
      name: 'Ishaan Sharma',
      email: 'tech.head@kiit.ac.in',
      roleName: 'Tech Head',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    SocietyUser(
      uid: 'user-marketing-head',
      orgId: orgId,
      domainId: 'dom-pr',
      name: 'Ananya Roy',
      email: 'marketing.head@kiit.ac.in',
      roleName: 'Marketing Head',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 140)),
    ),
    SocietyUser(
      uid: 'user-event-head',
      orgId: orgId,
      domainId: 'dom-ops',
      name: 'Vikram Seth',
      email: 'event.head@kiit.ac.in',
      roleName: 'Event Head',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 130)),
    ),
    SocietyUser(
      uid: 'user-sponsorship-head',
      orgId: orgId,
      domainId: 'dom-pr',
      name: 'Neha Sharma',
      email: 'sponsorship@kiit.ac.in',
      roleName: 'Sponsorship Head',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    SocietyUser(
      uid: 'user-member',
      orgId: orgId,
      domainId: 'dom-tech',
      name: 'Rahul Kumar',
      email: '2105123@kiit.ac.in',
      roleName: 'Member',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SocietyUser(
      uid: 'user-pending',
      orgId: orgId,
      domainId: 'dom-creative',
      name: 'Sneha Gupta',
      email: '2205456@kiit.ac.in',
      roleName: 'Member',
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    ),
  ];

  static final initialTasks = [
    SocietyTask(
      id: _uuid.v4(),
      orgId: orgId,
      domainId: 'dom-tech',
      title: 'Fix Navigation Bug',
      description: 'The bottom navigation bar overlaps on some devices.',
      assigneeId: 'user-member',
      deadline: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      createdBy: 'user-tech-head',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SocietyTask(
      id: _uuid.v4(),
      orgId: orgId,
      domainId: 'dom-tech',
      title: 'Update Flutter Version',
      description: 'Upgrade the project to Flutter 3.27.3.',
      assigneeId: 'user-tech-head',
      deadline: DateTime.now().add(const Duration(days: 7)),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdBy: 'user-pres',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SocietyTask(
      id: _uuid.v4(),
      orgId: orgId,
      domainId: 'dom-creative',
      title: 'Design Event Poster',
      description: 'Need a high-res poster for the orientation.',
      assigneeId: 'user-pending',
      deadline: DateTime.now().add(const Duration(days: 5)),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      createdBy: 'user-pres',
      createdAt: DateTime.now(),
    ),
  ];

  static final initialAnnouncements = [
    Announcement(
      id: _uuid.v4(),
      orgId: orgId,
      domainId: null,
      title: 'Welcome to SocietyOS',
      body: 'Phase 1 and 2 are now live for testing.',
      postedBy: 'Aditya Raj',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Announcement(
      id: _uuid.v4(),
      orgId: orgId,
      domainId: 'dom-tech',
      title: 'Technical Sync Meeting',
      body: 'All technical domain members please join the meet at 6 PM.',
      postedBy: 'Ishaan Sharma',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
}
