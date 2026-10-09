import 'dart:math';

import '../../domain/default_roles.dart';
import '../local/local_repository.dart';
import '../local/local_store.dart';
import '../models/models.dart';
import '../repositories/repository.dart';

/// Demo data for GFG KIIT Student Chapter, written relative to "now" so the
/// app always looks alive: an event this week, a hackathon in prep, expenses
/// at every approval step, a recruitment drive in progress.
///
/// Every seeded account signs in with [Seed.password].
abstract final class Seed {
  static const orgId = 'gfg-kiit';
  static const password = 'gfg@1234';

  /// Accounts shown on the sign-in screen in demo mode.
  static const demoAccounts = [
    (label: 'President', email: '2105101@kiit.ac.in'),
    (label: 'Treasurer', email: '2205077@kiit.ac.in'),
    (label: 'Technical Head', email: '2205140@kiit.ac.in'),
    (label: 'App Dev Lead', email: '2205211@kiit.ac.in'),
    (label: 'Member', email: '2305318@kiit.ac.in'),
    (label: 'Applicant', email: '2405522@kiit.ac.in'),
  ];

  static Future<void> run(LocalStore store) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime day(int offset, [int hour = 10, int minute = 0]) =>
        today.add(Duration(days: offset, hours: hour, minutes: minute));
    final rnd = Random(42);
    var seq = 0;
    String id(String prefix) =>
        '${prefix}_${(++seq).toString().padLeft(3, '0')}';

    // ── Organisation ────────────────────────────────────────────────────────
    final termStart = DateTime(now.month >= 7 ? now.year : now.year - 1, 7, 1);
    final termLabel = '${termStart.year}–${(termStart.year + 1) % 100}';
    final org = Organization(
      id: orgId,
      name: 'GFG KIIT Student Chapter',
      shortName: 'GFG KIIT',
      campus: 'KIIT, Bhubaneswar',
      emailDomain: 'kiit.ac.in',
      currentTerm: termLabel,
      termStartedAt: termStart,
      createdAt: DateTime(2021, 8, 1),
      recruitmentOpen: true,
      recruitmentNote:
          'Induction for first and second years is open until the end of the month.',
    );

    // ── Domains (doc §3) ────────────────────────────────────────────────────
    const tech = Department.technical;
    const nonTech = Department.nonTechnical;
    final domains = [
      const Domain(
        id: 'sysdev',
        name: 'System Development',
        department: tech,
        icon: 'memory',
        blurb: 'Low-level, OS and systems programming.',
      ),
      const Domain(
        id: 'cloud',
        name: 'Cloud',
        department: tech,
        icon: 'cloud',
        blurb: 'Cloud platforms, DevOps and deployment.',
      ),
      const Domain(
        id: 'app',
        name: 'App Development',
        department: tech,
        icon: 'phone',
        blurb: 'Flutter and native mobile apps.',
      ),
      const Domain(
        id: 'web',
        name: 'Web Development',
        department: tech,
        icon: 'web',
        blurb: 'Frontend, backend and the chapter website.',
      ),
      const Domain(
        id: 'cp',
        name: 'Competitive Programming',
        department: tech,
        icon: 'code',
        blurb: 'DSA, contests and the weekly ladder.',
      ),
      const Domain(
        id: 'blockchain',
        name: 'Blockchain',
        department: tech,
        icon: 'link',
        blurb: 'Web3, smart contracts and protocols.',
      ),
      const Domain(
        id: 'aiml',
        name: 'AI/ML',
        department: tech,
        icon: 'brain',
        blurb: 'Machine learning, data and GenAI.',
      ),
      const Domain(
        id: 'cyber',
        name: 'Cybersecurity',
        department: tech,
        icon: 'shield',
        blurb: 'CTFs, security research and hygiene.',
      ),
      const Domain(
        id: 'gamedev',
        name: 'Game Development',
        department: tech,
        icon: 'game',
        blurb: 'Unity, Godot and game jams.',
      ),
      const Domain(
        id: 'admin',
        name: 'Admin',
        department: nonTech,
        icon: 'admin',
        blurb: 'Permissions, venues and paperwork.',
      ),
      const Domain(
        id: 'marketing',
        name: 'Marketing',
        department: nonTech,
        icon: 'campaign',
        blurb: 'Outreach and campus promotion.',
      ),
      const Domain(
        id: 'sponsorship',
        name: 'Sponsorship',
        department: nonTech,
        icon: 'handshake',
        blurb: 'Partners, sponsors and deals.',
      ),
      const Domain(
        id: 'uiux',
        name: 'UI/UX',
        department: nonTech,
        icon: 'palette',
        blurb: 'Design for apps, posters and brand.',
      ),
      const Domain(
        id: 'broadcasting',
        name: 'Broadcasting',
        department: nonTech,
        icon: 'mic',
        blurb: 'Photography, video and live coverage.',
      ),
      const Domain(
        id: 'social',
        name: 'Social Media',
        department: nonTech,
        icon: 'share',
        blurb: 'Instagram, LinkedIn and X.',
      ),
    ];

    // ── People ──────────────────────────────────────────────────────────────
    Member m(
      String roll,
      String name,
      String roleId, {
      String? domain,
      Department? dept,
      int year = 3,
      String branch = 'CSE',
      MemberStatus status = MemberStatus.active,
      int joinedDaysAgo = 300,
      List<String> skills = const [],
      String bio = '',
      List<PastRole> history = const [],
    }) => Member(
      id: 'u_$roll',
      name: name,
      email: '$roll@kiit.ac.in',
      roleId: roleId,
      status: status,
      joinedAt: today.subtract(Duration(days: joinedDaysAgo)),
      domainId: domain,
      department: dept,
      year: year,
      branch: branch,
      skills: skills,
      bio: bio,
      github: status == MemberStatus.active
          ? 'github.com/${name.split(' ').first.toLowerCase()}$roll'
          : '',
      history: history,
      disabledAt: status == MemberStatus.disabled ? termStart : null,
    );

    final members = <Member>[
      m(
        '2105101',
        'Aarav Mohanty',
        DefaultRoles.president,
        year: 4,
        joinedDaysAgo: 1100,
        skills: ['Leadership', 'Go', 'System design'],
        bio:
            'Running the chapter this year. Ask me about anything that’s stuck.',
        history: [
          const PastRole(term: '2025–26', roleId: DefaultRoles.technicalHead),
        ],
      ),
      m(
        '2105188',
        'Ishita Panda',
        DefaultRoles.vicePresident,
        year: 4,
        joinedDaysAgo: 1050,
        skills: ['Operations', 'React'],
      ),
      m(
        '2205077',
        'Rohan Agarwal',
        DefaultRoles.treasurer,
        joinedDaysAgo: 700,
        branch: 'IT',
        skills: ['Finance', 'Excel', 'Python'],
      ),
      m(
        '2205140',
        'Kabir Sinha',
        DefaultRoles.technicalHead,
        dept: tech,
        joinedDaysAgo: 720,
        skills: ['Flutter', 'Firebase', 'Kotlin'],
        bio: 'Coordinating every tech domain. Builder of the chapter app.',
      ),
      m(
        '2205162',
        'Meera Nair',
        DefaultRoles.eventHead,
        dept: nonTech,
        joinedDaysAgo: 710,
        branch: 'CSCE',
        skills: ['Events', 'Logistics'],
      ),
      m(
        '2205170',
        'Dev Malhotra',
        DefaultRoles.sponsorshipHead,
        dept: nonTech,
        joinedDaysAgo: 705,
        branch: 'CSE',
        skills: ['Partnerships', 'Negotiation'],
      ),
      m(
        '2205171',
        'Tanvi Roy',
        DefaultRoles.marketingHead,
        dept: nonTech,
        joinedDaysAgo: 700,
        branch: 'ECE',
        skills: ['Branding', 'Social media'],
      ),
      m(
        '2205211',
        'Arjun Das',
        DefaultRoles.domainLead,
        domain: 'app',
        joinedDaysAgo: 650,
        skills: ['Flutter', 'Riverpod', 'Dart'],
      ),
      m(
        '2205233',
        'Sneha Rath',
        DefaultRoles.domainLead,
        domain: 'web',
        joinedDaysAgo: 640,
        skills: ['Next.js', 'TypeScript'],
      ),
      m(
        '2205245',
        'Vivek Kumar',
        DefaultRoles.domainLead,
        domain: 'cp',
        joinedDaysAgo: 660,
        skills: ['C++', 'Graphs', 'Codeforces Expert'],
      ),
      m(
        '2205256',
        'Tanvi Mishra',
        DefaultRoles.domainLead,
        domain: 'aiml',
        joinedDaysAgo: 620,
        branch: 'CSE (AI)',
        skills: ['PyTorch', 'LLMs'],
      ),
      m(
        '2205267',
        'Yash Jaiswal',
        DefaultRoles.domainLead,
        domain: 'cloud',
        joinedDaysAgo: 600,
        skills: ['GCP', 'Docker', 'Terraform'],
      ),
      m(
        '2205278',
        'Nikhil Behera',
        DefaultRoles.domainLead,
        domain: 'cyber',
        joinedDaysAgo: 610,
        branch: 'IT',
        skills: ['CTF', 'Linux'],
      ),
      m(
        '2205289',
        'Priya Sahoo',
        DefaultRoles.domainLead,
        domain: 'marketing',
        joinedDaysAgo: 590,
        branch: 'ECS',
        skills: ['Copywriting', 'Outreach'],
      ),
      m(
        '2205291',
        'Aditya Patnaik',
        DefaultRoles.domainLead,
        domain: 'sponsorship',
        joinedDaysAgo: 580,
        skills: ['Negotiation', 'Pitch decks'],
      ),
      m(
        '2205302',
        'Diya Kapoor',
        DefaultRoles.domainLead,
        domain: 'uiux',
        joinedDaysAgo: 570,
        branch: 'CSCE',
        skills: ['Figma', 'Illustration'],
      ),
      m(
        '2205313',
        'Riya Choudhury',
        DefaultRoles.domainLead,
        domain: 'social',
        joinedDaysAgo: 560,
        branch: 'ECS',
        skills: ['Reels', 'Canva'],
      ),
      m(
        '2305318',
        'Rahul Kumar',
        DefaultRoles.member,
        domain: 'app',
        year: 2,
        joinedDaysAgo: 330,
        skills: ['Flutter', 'Dart'],
        bio: 'Second year, building my first published app.',
      ),
      m(
        '2305324',
        'Ananya Singh',
        DefaultRoles.member,
        domain: 'app',
        year: 2,
        joinedDaysAgo: 320,
        skills: ['Flutter', 'Figma'],
      ),
      m(
        '2305331',
        'Sahil Gupta',
        DefaultRoles.member,
        domain: 'web',
        year: 2,
        joinedDaysAgo: 310,
        skills: ['React', 'Node'],
      ),
      m(
        '2305342',
        'Pooja Mahapatra',
        DefaultRoles.member,
        domain: 'web',
        year: 2,
        joinedDaysAgo: 300,
        branch: 'IT',
        skills: ['CSS', 'Tailwind'],
      ),
      m(
        '2305353',
        'Harsh Vardhan',
        DefaultRoles.member,
        domain: 'cp',
        year: 2,
        joinedDaysAgo: 330,
        skills: ['C++', 'DP'],
      ),
      m(
        '2305364',
        'Krishna Prasad',
        DefaultRoles.member,
        domain: 'cp',
        year: 2,
        joinedDaysAgo: 290,
        skills: ['Java', 'Greedy'],
      ),
      m(
        '2305375',
        'Neha Tripathy',
        DefaultRoles.member,
        domain: 'aiml',
        year: 2,
        joinedDaysAgo: 280,
        branch: 'CSE (AI)',
        skills: ['Pandas', 'Scikit-learn'],
      ),
      m(
        '2305386',
        'Siddharth Rao',
        DefaultRoles.member,
        domain: 'cloud',
        year: 2,
        joinedDaysAgo: 270,
        skills: ['AWS', 'Linux'],
      ),
      m(
        '2305397',
        'Aisha Khan',
        DefaultRoles.member,
        domain: 'uiux',
        year: 2,
        joinedDaysAgo: 260,
        branch: 'CSCE',
        skills: ['Figma', 'Motion'],
      ),
      m(
        '2305408',
        'Om Prakash',
        DefaultRoles.member,
        domain: 'marketing',
        year: 2,
        joinedDaysAgo: 250,
        branch: 'ECS',
      ),
      m(
        '2305419',
        'Tanya Bose',
        DefaultRoles.member,
        domain: 'sponsorship',
        year: 2,
        joinedDaysAgo: 240,
      ),
      m(
        '2305421',
        'Manav Jha',
        DefaultRoles.member,
        domain: 'social',
        year: 2,
        joinedDaysAgo: 230,
        skills: ['Photography'],
      ),
      m(
        '2305432',
        'Zara Ali',
        DefaultRoles.member,
        domain: 'gamedev',
        year: 2,
        joinedDaysAgo: 220,
        skills: ['Unity', 'C#'],
      ),
      m(
        '2305443',
        'Kunal Dey',
        DefaultRoles.member,
        domain: 'blockchain',
        year: 2,
        joinedDaysAgo: 210,
        skills: ['Solidity'],
      ),
      m(
        '2305454',
        'Ritesh Panigrahi',
        DefaultRoles.member,
        domain: 'broadcasting',
        year: 2,
        joinedDaysAgo: 200,
        skills: ['Premiere Pro'],
      ),
      m(
        '2305465',
        'Shreya Dash',
        DefaultRoles.member,
        domain: 'admin',
        year: 2,
        joinedDaysAgo: 190,
        branch: 'IT',
      ),
      m(
        '2305476',
        'Abhinav Tiwari',
        DefaultRoles.member,
        domain: 'sysdev',
        year: 2,
        joinedDaysAgo: 180,
        skills: ['Rust', 'C'],
      ),
      // Applicants (pending)
      m(
        '2405522',
        'Aryan Mehta',
        DefaultRoles.member,
        domain: 'app',
        year: 1,
        status: MemberStatus.pending,
        joinedDaysAgo: 4,
      ),
      m(
        '2405533',
        'Ritika Jena',
        DefaultRoles.member,
        domain: 'aiml',
        year: 1,
        status: MemberStatus.pending,
        joinedDaysAgo: 6,
      ),
      m(
        '2405544',
        'Dev Patel',
        DefaultRoles.member,
        domain: 'cp',
        year: 1,
        status: MemberStatus.pending,
        joinedDaysAgo: 3,
      ),
      m(
        '2405555',
        'Sana Mohapatra',
        DefaultRoles.member,
        domain: 'uiux',
        year: 1,
        status: MemberStatus.pending,
        joinedDaysAgo: 2,
        branch: 'CSCE',
      ),
      m(
        '2405566',
        'Kartik Rout',
        DefaultRoles.member,
        domain: 'app',
        year: 1,
        status: MemberStatus.pending,
        joinedDaysAgo: 1,
      ),
      // Previous cabinet, now alumni
      m(
        '2005109',
        'Siddhant Roy',
        DefaultRoles.member,
        year: 4,
        status: MemberStatus.disabled,
        joinedDaysAgo: 1400,
        history: [
          const PastRole(term: '2025–26', roleId: DefaultRoles.president),
        ],
      ),
    ];
    String u(String roll) => 'u_$roll';
    final active = members.where((x) => x.isActive).toList();
    List<String> pick(int n, [String? domain]) {
      final pool = domain == null
          ? active
          : active.where((x) => x.domainId == domain).toList();
      final copy = [...pool]..shuffle(rnd);
      return copy.take(min(n, copy.length)).map((x) => x.id).toList();
    }

    final applications = [
      Application(
        id: u('2405522'),
        memberId: u('2405522'),
        domainId: 'app',
        year: 1,
        branch: 'CSE',
        why:
            'I built a notes app in Flutter over the summer and want to work on real projects with a team.',
        experience: 'Flutter basics, Firebase auth, one app on GitHub.',
        portfolio: 'github.com/aryanmehta',
        stage: ApplicationStage.interview,
        interviewAt: day(1, 17),
        notes: [
          ReviewNote(
            authorId: u('2205211'),
            text: 'Good repo, clean widgets. Ask about state management.',
            at: day(-2, 19),
          ),
        ],
        createdAt: day(-4, 21),
      ),
      Application(
        id: u('2405533'),
        memberId: u('2405533'),
        domainId: 'aiml',
        year: 1,
        branch: 'CSE (AI)',
        why:
            'Want to learn ML properly and contribute to the chapter’s GenAI workshops.',
        experience: 'Andrew Ng’s ML course, Kaggle Titanic.',
        stage: ApplicationStage.shortlisted,
        createdAt: day(-6, 20),
      ),
      Application(
        id: u('2405544'),
        memberId: u('2405544'),
        domainId: 'cp',
        year: 1,
        branch: 'CSE',
        why: 'Pupil on Codeforces, want a group to practise with every week.',
        experience: 'Codeforces 1350.',
        portfolio: 'codeforces.com/profile/devpatel',
        createdAt: day(-3, 23),
      ),
      Application(
        id: u('2405555'),
        memberId: u('2405555'),
        domainId: 'uiux',
        year: 1,
        branch: 'CSCE',
        why:
            'I design posters for my hostel fests and want to design real product screens.',
        portfolio: 'behance.net/sanam',
        createdAt: day(-2, 18),
      ),
      Application(
        id: u('2405566'),
        memberId: u('2405566'),
        domainId: 'app',
        year: 1,
        branch: 'IT',
        why: 'Interested in Android development and open source.',
        createdAt: day(-1, 22),
      ),
    ];

    // ── Events ──────────────────────────────────────────────────────────────
    String secret() =>
        List.generate(24, (_) => rnd.nextInt(36).toRadixString(36)).join();
    final coreTeam = [u('2105101'), u('2105188'), u('2205140'), u('2205162')];
    final hackathonDay = day(9, 9);
    final events = <SocietyEvent>[
      SocietyEvent(
        id: 'ev_orientation',
        title: 'Orientation ${termStart.year}',
        type: EventType.orientation,
        description:
            'Meet the chapter: what each domain does, how induction works, and what’s planned this term.',
        startsAt: day(-58, 16),
        endsAt: day(-58, 18),
        venue: 'Campus 6 Auditorium',
        organizerIds: coreTeam,
        budget: 12000,
        capacity: 400,
        checkInSecret: secret(),
        rsvpIds: pick(26),
        createdBy: u('2105101'),
        createdAt: day(-75),
        outcome: '340 students attended. 120 sign-ups for induction.',
      ),
      SocietyEvent(
        id: 'ev_dsa',
        title: 'DSA Bootcamp: Arrays to Graphs',
        type: EventType.bootcamp,
        domainId: 'cp',
        description:
            'Four evenings of guided problem solving with the CP team. Bring a laptop.',
        startsAt: day(-24, 17),
        endsAt: day(-21, 19),
        venue: 'Campus 15, Lab 3',
        organizerIds: [u('2205245'), u('2305353')],
        budget: 2500,
        capacity: 120,
        checkInSecret: secret(),
        rsvpIds: pick(18),
        createdBy: u('2205245'),
        createdAt: day(-40),
        outcome: '95 participants on day one, 60 finished all four days.',
      ),
      SocietyEvent(
        id: 'ev_flutter_intro',
        title: 'Build your first Flutter app',
        type: EventType.workshop,
        domainId: 'app',
        description: 'From flutter create to a working to-do app in two hours.',
        startsAt: day(-12, 16),
        endsAt: day(-12, 18, 30),
        venue: 'Campus 14, Seminar Hall',
        organizerIds: [u('2205211'), u('2305318')],
        budget: 3000,
        capacity: 100,
        checkInSecret: secret(),
        rsvpIds: pick(16),
        createdBy: u('2205211'),
        createdAt: day(-30),
        outcome: '82 attendees, 61 pushed their app to GitHub by the end.',
      ),
      SocietyEvent(
        id: 'ev_oss',
        title: 'Open Source 101',
        type: EventType.talk,
        domainId: 'web',
        description:
            'How to find your first issue, open a clean PR and get it merged. Live demo on a real repo.',
        startsAt: day(0, 17),
        endsAt: day(0, 19),
        venue: 'Campus 15, Seminar Hall 2',
        organizerIds: [u('2205233'), u('2305331')],
        budget: 1500,
        capacity: 150,
        checkInSecret: secret(),
        rsvpIds: pick(20),
        checkInOpen: true,
        createdBy: u('2205233'),
        createdAt: day(-14),
      ),
      SocietyEvent(
        id: 'ev_flutter_forward',
        title: 'Flutter Forward: State management',
        type: EventType.workshop,
        domainId: 'app',
        description:
            'Riverpod vs BLoC vs Provider on the same app, and when each one makes sense.',
        startsAt: day(3, 16),
        endsAt: day(3, 18, 30),
        venue: 'Campus 14, Seminar Hall',
        organizerIds: [u('2205211'), u('2305324')],
        budget: 3500,
        capacity: 120,
        checkInSecret: secret(),
        rsvpIds: pick(14),
        createdBy: u('2205211'),
        createdAt: day(-10),
      ),
      SocietyEvent(
        id: 'ev_contest',
        title: 'GFG Weekly Ladder #12',
        type: EventType.contest,
        domainId: 'cp',
        description:
            'Six problems, two hours, rated. Top three get chapter swag.',
        startsAt: day(5, 20),
        endsAt: day(5, 22),
        venue: 'Online',
        organizerIds: [u('2205245')],
        budget: 1500,
        checkInSecret: secret(),
        rsvpIds: pick(12),
        createdBy: u('2205245'),
        createdAt: day(-6),
      ),
      SocietyEvent(
        id: 'ev_coderush',
        title: 'CodeRush ${now.year}',
        type: EventType.hackathon,
        description:
            '24-hour campus hackathon. Teams of up to four, three tracks: AI for campus, '
            'developer tools, and open innovation. Mentors from the chapter alumni network.',
        startsAt: hackathonDay,
        endsAt: hackathonDay.add(const Duration(hours: 24)),
        venue: 'Campus 17 Atrium',
        organizerIds: [u('2105101'), u('2205140'), u('2205162'), u('2205291')],
        budget: 75000,
        capacity: 75,
        teamMin: 2,
        teamMax: 4,
        checkInSecret: secret(),
        rsvpIds: pick(24),
        createdBy: u('2105101'),
        createdAt: day(-28),
      ),
      SocietyEvent(
        id: 'ev_cloud',
        title: 'Cloud Study Jam',
        type: EventType.bootcamp,
        domainId: 'cloud',
        description:
            'Hands-on labs: deploy a container, set up CI, and keep the bill at zero.',
        startsAt: day(16, 15),
        endsAt: day(16, 18),
        venue: 'Campus 15, Lab 1',
        organizerIds: [u('2205267')],
        budget: 2000,
        capacity: 80,
        checkInSecret: secret(),
        rsvpIds: pick(8),
        createdBy: u('2205267'),
        createdAt: day(-3),
      ),
    ];

    // Attendance for past events + today's talk (partly checked in).
    final attendance = <AttendanceRecord>[];
    for (final e in events.where(
      (e) => e.endsAt.isBefore(now) || e.id == 'ev_oss',
    )) {
      final goers = e.id == 'ev_oss'
          ? e.rsvpIds.take(7)
          : e.rsvpIds.where((_) => rnd.nextDouble() < 0.8);
      for (final mid in goers) {
        attendance.add(
          AttendanceRecord(
            id: AttendanceRecord.idFor(AttendanceTarget.event, e.id, mid),
            target: AttendanceTarget.event,
            targetId: e.id,
            memberId: mid,
            at: e.id == 'ev_oss' && e.startsAt.isAfter(now)
                ? now.subtract(Duration(minutes: rnd.nextInt(40)))
                : e.startsAt.add(Duration(minutes: rnd.nextInt(25))),
            method: rnd.nextBool() ? CheckInMethod.qr : CheckInMethod.code,
            markedBy: mid,
          ),
        );
      }
    }

    // ── Tasks ───────────────────────────────────────────────────────────────
    SocietyTask t(
      String title, {
      String? domain,
      String? event,
      required List<String> to,
      required int due,
      TaskStatus status = TaskStatus.todo,
      TaskPriority priority = TaskPriority.medium,
      required String by,
      String desc = '',
      List<(String, bool)> checklist = const [],
      int createdAgo = 7,
    }) {
      final created = today.subtract(Duration(days: createdAgo));
      final dueAt = day(due, 23, 59);
      return SocietyTask(
        id: id('task'),
        title: title,
        description: desc,
        domainId: domain,
        eventId: event,
        assigneeIds: to,
        due: dueAt,
        priority: priority,
        status: status,
        checklist: [
          for (final c in checklist)
            ChecklistItem(id: id('chk'), text: c.$1, done: c.$2),
        ],
        createdBy: by,
        createdAt: created,
        updatedAt: created,
        completedAt: status == TaskStatus.done
            ? (dueAt.isBefore(now)
                  ? dueAt.subtract(Duration(days: rnd.nextInt(2), hours: 6))
                  : now.subtract(Duration(hours: 2 + rnd.nextInt(40))))
            : null,
      );
    }

    final president = u('2105101');
    final techHead = u('2205140');
    final opsHead = u('2205162');
    final tasks = <SocietyTask>[
      // CodeRush workspace
      t(
        'Book Campus 17 Atrium for 24 hours',
        event: 'ev_coderush',
        to: [u('2305465')],
        due: -4,
        status: TaskStatus.done,
        priority: TaskPriority.high,
        by: opsHead,
        checklist: [
          ('Request letter signed by faculty advisor', true),
          ('Night permission from the hostel office', true),
        ],
      ),
      t(
        'Close title sponsor',
        event: 'ev_coderush',
        domain: 'sponsorship',
        to: [u('2205291'), u('2305419')],
        due: 2,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: president,
        desc:
            'Two companies are interested. We need one confirmed to fund prizes and food.',
        checklist: [
          ('Send revised deck', true),
          ('Follow-up call', true),
          ('Signed confirmation', false),
        ],
      ),
      t(
        'Lock problem statements for all three tracks',
        event: 'ev_coderush',
        domain: 'cp',
        to: [u('2205245'), u('2205256')],
        due: -1,
        status: TaskStatus.review,
        priority: TaskPriority.high,
        by: techHead,
      ),
      t(
        'Design poster and social creatives',
        event: 'ev_coderush',
        domain: 'uiux',
        to: [u('2205302'), u('2305397')],
        due: -6,
        status: TaskStatus.done,
        by: opsHead,
      ),
      t(
        'Build registration and team-formation form',
        event: 'ev_coderush',
        domain: 'web',
        to: [u('2205233'), u('2305342')],
        due: -3,
        status: TaskStatus.done,
        priority: TaskPriority.high,
        by: techHead,
      ),
      t(
        'Confirm judges and mentors',
        event: 'ev_coderush',
        to: [president, techHead],
        due: 3,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: president,
        checklist: [
          ('3 alumni judges', true),
          ('6 mentors (2 per track)', false),
          ('Brief doc for judges', false),
        ],
      ),
      t(
        'Order prizes and swag',
        event: 'ev_coderush',
        domain: 'sponsorship',
        to: [u('2305419')],
        due: 4,
        by: opsHead,
      ),
      t(
        'Arrange dinner and midnight snacks',
        event: 'ev_coderush',
        domain: 'admin',
        to: [u('2305465')],
        due: 6,
        by: opsHead,
      ),
      t(
        'Campus-wide promotion push',
        event: 'ev_coderush',
        domain: 'marketing',
        to: [u('2205289'), u('2305408')],
        due: 1,
        status: TaskStatus.inProgress,
        by: opsHead,
        checklist: [
          ('Classroom announcements in 10 blocks', true),
          ('Hostel notice boards', false),
          ('Instagram countdown', false),
        ],
      ),
      t(
        'Set up Discord server for participants',
        event: 'ev_coderush',
        domain: 'web',
        to: [u('2305331')],
        due: 5,
        by: techHead,
      ),
      t(
        'Live coverage plan',
        event: 'ev_coderush',
        domain: 'broadcasting',
        to: [u('2305454')],
        due: 7,
        by: opsHead,
      ),
      // Flutter Forward
      t(
        'Prepare Riverpod vs BLoC demo repo',
        event: 'ev_flutter_forward',
        domain: 'app',
        to: [u('2205211')],
        due: 1,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: u('2205211'),
        checklist: [
          ('Same app in 3 approaches', true),
          ('README with setup steps', false),
          ('Dry run with Ananya', false),
        ],
      ),
      t(
        'Slides for the state management session',
        event: 'ev_flutter_forward',
        domain: 'app',
        to: [u('2305324')],
        due: 2,
        by: u('2205211'),
      ),
      t(
        'Print 120 handouts',
        event: 'ev_flutter_forward',
        domain: 'app',
        to: [u('2305318')],
        due: 2,
        by: u('2205211'),
      ),
      // Open Source 101
      t(
        'Pick 10 good-first-issues for the live demo',
        event: 'ev_oss',
        domain: 'web',
        to: [u('2305331')],
        due: -1,
        status: TaskStatus.done,
        by: u('2205233'),
      ),
      t(
        'Send reminder to registrants',
        event: 'ev_oss',
        domain: 'web',
        to: [u('2305342')],
        due: 0,
        status: TaskStatus.review,
        by: u('2205233'),
      ),
      // Domain work
      t(
        'Fix overflow on the events screen on small phones',
        domain: 'app',
        to: [u('2305318')],
        due: 2,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: u('2205211'),
        desc:
            'Reported on a 5.5" Android. The date chip pushes the venue off screen.',
      ),
      t(
        'Write onboarding doc for new App Dev members',
        domain: 'app',
        to: [u('2305324'), u('2305318')],
        due: 8,
        by: u('2205211'),
      ),
      t(
        'Migrate chapter website to Next.js 15',
        domain: 'web',
        to: [u('2205233'), u('2305331')],
        due: 12,
        by: techHead,
      ),
      t(
        'Set problems for Weekly Ladder #12',
        domain: 'cp',
        to: [u('2305353'), u('2305364')],
        due: 3,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: u('2205245'),
      ),
      t(
        'Curate GenAI reading list',
        domain: 'aiml',
        to: [u('2305375')],
        due: 6,
        by: u('2205256'),
      ),
      t(
        'Draft CTF challenge set for next month',
        domain: 'cyber',
        to: [u('2205278')],
        due: 15,
        priority: TaskPriority.low,
        by: techHead,
      ),
      t(
        'Quarterly sponsorship report',
        domain: 'sponsorship',
        to: [u('2205291')],
        due: -2,
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        by: opsHead,
      ),
      t(
        'Instagram content calendar for next month',
        domain: 'social',
        to: [u('2205313'), u('2305421')],
        due: 5,
        by: opsHead,
      ),
      t(
        'Update brand kit with new chapter logo lockups',
        domain: 'uiux',
        to: [u('2305397')],
        due: 9,
        priority: TaskPriority.low,
        by: u('2205302'),
      ),
      t(
        'Collect attendance sheets from last term',
        domain: 'admin',
        to: [u('2305465')],
        due: -5,
        status: TaskStatus.inProgress,
        by: u('2105188'),
      ),
      t(
        'Prepare lab list for Cloud Study Jam',
        domain: 'cloud',
        event: 'ev_cloud',
        to: [u('2305386')],
        due: 10,
        by: u('2205267'),
      ),
    ];

    // History: completed work spread over the last 16 weeks for the activity grid.
    const pastTitles = [
      'Review PRs on chapter website',
      'Post contest editorial',
      'Edit event recap reel',
      'Update member sheet',
      'Draft newsletter section',
      'Fix login bug in chapter app',
      'Design certificate template',
      'Collect feedback form responses',
      'Write blog on DSA bootcamp',
      'Set up GitHub org permissions',
      'Clean up Drive folders',
      'Prepare induction quiz',
    ];
    for (var i = 0; i < 140; i++) {
      final who = active[rnd.nextInt(active.length)];
      final ago = rnd.nextInt(112);
      final weekday = today.subtract(Duration(days: ago)).weekday;
      if (weekday == DateTime.sunday && rnd.nextBool()) continue;
      final done = today.subtract(Duration(days: ago, hours: -rnd.nextInt(20)));
      tasks.add(
        SocietyTask(
          id: id('task'),
          title: pastTitles[rnd.nextInt(pastTitles.length)],
          domainId: who.domainId,
          assigneeIds: [who.id],
          due: done.add(const Duration(days: 1)),
          status: TaskStatus.done,
          priority: TaskPriority.values[rnd.nextInt(3)],
          createdBy: who.id,
          createdAt: done.subtract(Duration(days: 3 + rnd.nextInt(5))),
          completedAt: done,
          updatedAt: done,
        ),
      );
    }

    // ── Announcements ───────────────────────────────────────────────────────
    final announcements = [
      Announcement(
        id: id('ann'),
        title: 'CodeRush registrations are open',
        body:
            'Teams of up to four, three tracks, 24 hours. Register before the deadline and tell your juniors — '
            'first years are welcome. Volunteers: tell your domain lead which shift you can take.',
        audience: Audience.society,
        authorId: president,
        createdAt: today.subtract(const Duration(days: 5, hours: -11)),
        pinned: true,
        readBy: pick(20),
      ),
      Announcement(
        id: id('ann'),
        title: 'Core team sync on Saturday',
        body:
            'All leads and core heads: 11 AM in the Campus 15 discussion room. Agenda is in the Meetings tab. '
            'Bring your domain’s status for CodeRush.',
        audience: Audience.society,
        authorId: u('2105188'),
        createdAt: today.subtract(const Duration(days: 1, hours: -9)),
        readBy: pick(12),
      ),
      Announcement(
        id: id('ann'),
        title: 'Tech domains: repo hygiene',
        body:
            'Every project repo now lives in the chapter GitHub org. Add a README and a CODEOWNERS file by Friday.',
        audience: Audience.department,
        department: tech,
        authorId: techHead,
        createdAt: today.subtract(const Duration(days: 3, hours: -15)),
        readBy: pick(10),
      ),
      Announcement(
        id: id('ann'),
        title: 'App Dev weekly moves to Thursday',
        body:
            'From this week our weekly sync is on Thursday at 6 PM, same room. We’ll review the Flutter Forward demo.',
        audience: Audience.domain,
        domainId: 'app',
        authorId: u('2205211'),
        createdAt: today.subtract(const Duration(hours: 20)),
        readBy: [u('2205211')],
      ),
      Announcement(
        id: id('ann'),
        title: 'Reimbursement window',
        body:
            'Submit receipts within 7 days of spending. Approved expenses are paid out every Friday.',
        audience: Audience.society,
        authorId: u('2205077'),
        createdAt: today.subtract(const Duration(days: 9, hours: -12)),
        readBy: pick(22),
      ),
      Announcement(
        id: id('ann'),
        title: 'Design reviews every Tuesday',
        body:
            'Non-tech domains: drop your creatives in the vault by Monday night for Tuesday’s review.',
        audience: Audience.department,
        department: nonTech,
        authorId: opsHead,
        createdAt: today.subtract(const Duration(days: 6, hours: -10)),
        readBy: pick(8),
      ),
    ];

    // ── Finance ─────────────────────────────────────────────────────────────
    final treasurer = u('2205077');
    final vp = u('2105188');
    ApprovalStep s(
      ExpenseStage st,
      ApprovalDecision d,
      String who,
      DateTime at, [
      String note = '',
    ]) =>
        ApprovalStep(stage: st, decision: d, actorId: who, at: at, note: note);
    const lead = ExpenseStage.leadReview;
    const head = ExpenseStage.headVerification;
    const fin = ExpenseStage.finalApproval;
    const ok = ApprovalDecision.approved;
    const sub = ApprovalDecision.submitted;

    final expenses = <Expense>[
      Expense(
        id: id('exp'),
        title: 'Orientation refreshments',
        amount: 8400,
        category: ExpenseCategory.food,
        domainId: 'admin',
        eventId: 'ev_orientation',
        submittedBy: u('2305465'),
        submittedAt: day(-57, 12),
        receiptName: 'refreshments_invoice.pdf',
        stage: ExpenseStage.approved,
        history: [
          s(lead, sub, u('2305465'), day(-57, 12)),
          s(lead, ok, opsHead, day(-57, 18), 'Covering for the Admin lead.'),
          s(fin, ok, president, day(-56, 10)),
          s(
            ExpenseStage.approved,
            ApprovalDecision.reimbursed,
            treasurer,
            day(-54, 15),
            'UPI 4182 7736 0021',
          ),
        ],
        reimbursedAt: day(-54, 15),
        paymentRef: 'UPI 4182 7736 0021',
      ),
      Expense(
        id: id('exp'),
        title: 'Orientation standees and banners',
        amount: 2150,
        category: ExpenseCategory.printing,
        domainId: 'uiux',
        eventId: 'ev_orientation',
        submittedBy: u('2205302'),
        submittedAt: day(-60, 15),
        receiptName: 'print_shop_bill.jpg',
        stage: ExpenseStage.approved,
        history: [
          s(head, sub, u('2205302'), day(-60, 15)),
          s(head, ok, opsHead, day(-60, 20)),
          s(fin, ok, vp, day(-59, 11)),
          s(
            ExpenseStage.approved,
            ApprovalDecision.reimbursed,
            treasurer,
            day(-57, 16),
            'Cash',
          ),
        ],
        reimbursedAt: day(-57, 16),
        paymentRef: 'Cash',
      ),
      Expense(
        id: id('exp'),
        title: 'Bootcamp certificates',
        amount: 1350,
        category: ExpenseCategory.printing,
        domainId: 'cp',
        eventId: 'ev_dsa',
        submittedBy: u('2305353'),
        submittedAt: day(-20, 13),
        receiptName: 'certificates.pdf',
        stage: ExpenseStage.approved,
        history: [
          s(lead, sub, u('2305353'), day(-20, 13)),
          s(lead, ok, u('2205245'), day(-20, 17)),
          s(head, ok, techHead, day(-19, 10)),
          s(fin, ok, president, day(-19, 21)),
        ],
      ),
      Expense(
        id: id('exp'),
        title: 'Workshop snacks and water',
        amount: 1800,
        category: ExpenseCategory.food,
        domainId: 'app',
        eventId: 'ev_flutter_intro',
        submittedBy: u('2305318'),
        submittedAt: day(-12, 20),
        receiptName: 'snacks.jpg',
        stage: ExpenseStage.approved,
        history: [
          s(lead, sub, u('2305318'), day(-12, 20)),
          s(lead, ok, u('2205211'), day(-11, 9)),
          s(head, ok, techHead, day(-11, 13)),
          s(fin, ok, vp, day(-10, 18)),
          s(
            ExpenseStage.approved,
            ApprovalDecision.reimbursed,
            treasurer,
            day(-8, 17),
            'UPI 5519 0042 8810',
          ),
        ],
        reimbursedAt: day(-8, 17),
        paymentRef: 'UPI 5519 0042 8810',
      ),
      Expense(
        id: id('exp'),
        title: 'Cab to sponsor office',
        amount: 1200,
        category: ExpenseCategory.travel,
        domainId: 'sponsorship',
        submittedBy: u('2305419'),
        submittedAt: day(-9, 18),
        receiptName: 'cab_receipt.png',
        stage: ExpenseStage.rejected,
        history: [
          s(lead, sub, u('2305419'), day(-9, 18)),
          s(
            lead,
            ApprovalDecision.rejected,
            u('2205291'),
            day(-8, 12),
            'Local travel isn’t covered. Book the chapter’s shared cab next time.',
          ),
        ],
      ),
      Expense(
        id: id('exp'),
        title: 'Handouts for Flutter Forward',
        amount: 650,
        category: ExpenseCategory.printing,
        domainId: 'app',
        eventId: 'ev_flutter_forward',
        submittedBy: u('2305318'),
        submittedAt: today.subtract(const Duration(hours: 5)),
        receiptName: 'xerox_bill.jpg',
        stage: lead,
        history: [
          s(lead, sub, u('2305318'), today.subtract(const Duration(hours: 5))),
        ],
      ),
      Expense(
        id: id('exp'),
        title: 'Weekly Ladder prize vouchers',
        amount: 3000,
        category: ExpenseCategory.prizes,
        domainId: 'cp',
        eventId: 'ev_contest',
        submittedBy: u('2205245'),
        submittedAt: day(-1, 21),
        receiptName: 'vouchers_quote.pdf',
        stage: head,
        history: [s(head, sub, u('2205245'), day(-1, 21))],
      ),
      Expense(
        id: id('exp'),
        title: 'CodeRush sound and stage',
        amount: 18500,
        category: ExpenseCategory.venue,
        domainId: 'admin',
        eventId: 'ev_coderush',
        submittedBy: u('2305465'),
        submittedAt: day(-3, 14),
        receiptName: 'av_vendor_quote.pdf',
        stage: fin,
        history: [
          s(lead, sub, u('2305465'), day(-3, 14)),
          s(
            head,
            ok,
            opsHead,
            day(-3, 19),
            'Admin lead seat is vacant, verified directly.',
          ),
        ],
      ),
      Expense(
        id: id('exp'),
        title: 'CodeRush T-shirts (300)',
        amount: 42000,
        category: ExpenseCategory.swag,
        domainId: 'sponsorship',
        eventId: 'ev_coderush',
        submittedBy: u('2205291'),
        submittedAt: day(-2, 11),
        receiptName: 'tshirt_invoice.pdf',
        stage: fin,
        description:
            'Quote from the campus vendor. 50% advance needed by Friday.',
        history: [
          s(head, sub, u('2205291'), day(-2, 11)),
          s(
            head,
            ok,
            opsHead,
            day(-2, 16),
            'Checked against two other quotes. This is the lowest.',
          ),
        ],
      ),
      Expense(
        id: id('exp'),
        title: 'Domain for the chapter website (1 year)',
        amount: 899,
        category: ExpenseCategory.software,
        domainId: 'web',
        submittedBy: u('2205233'),
        submittedAt: day(-30, 10),
        receiptName: 'domain_invoice.pdf',
        stage: ExpenseStage.approved,
        history: [
          s(head, sub, u('2205233'), day(-30, 10)),
          s(head, ok, techHead, day(-30, 14)),
          s(fin, ok, president, day(-29, 9)),
        ],
      ),
    ];

    final income = [
      Income(
        id: id('inc'),
        title: 'GeeksforGeeks chapter grant',
        amount: 40000,
        source: IncomeSource.grant,
        loggedBy: treasurer,
        receivedAt: day(-80, 12),
        reference: 'NEFT GFG/CH/0921',
      ),
      Income(
        id: id('inc'),
        title: 'Induction fee collection',
        amount: 9600,
        source: IncomeSource.membershipFee,
        loggedBy: treasurer,
        receivedAt: day(-45, 17),
        note: '96 members × ₹100',
      ),
      Income(
        id: id('inc'),
        title: 'ByteForge Labs — CodeRush partner',
        amount: 50000,
        source: IncomeSource.sponsorship,
        eventId: 'ev_coderush',
        loggedBy: treasurer,
        receivedAt: day(-6, 15),
        reference: 'INV-BF-2207',
      ),
      Income(
        id: id('inc'),
        title: 'Orientation merch sales',
        amount: 3800,
        source: IncomeSource.ticketSales,
        eventId: 'ev_orientation',
        loggedBy: treasurer,
        receivedAt: day(-57, 20),
      ),
    ];

    // ── Meetings ────────────────────────────────────────────────────────────
    final meetings = [
      Meeting(
        id: 'mt_core_prev',
        title: 'Core sync: CodeRush planning',
        startsAt: day(-6, 11),
        durationMinutes: 60,
        audience: Audience.society,
        venue: 'Campus 15 discussion room',
        createdBy: vp,
        createdAt: day(-9),
        agenda: ['Sponsor status', 'Venue and permissions', 'Volunteer shifts'],
        minutes:
            'Venue confirmed for 24 hours. One sponsor verbally confirmed; waiting on paperwork. '
            'Volunteer shifts to be split by domain leads by Wednesday.',
        actionItems: [
          ActionItem(
            id: id('ai'),
            text: 'Close title sponsor',
            assigneeId: u('2205291'),
            taskId: tasks[1].id,
          ),
          ActionItem(
            id: id('ai'),
            text: 'Share volunteer shift sheet with all leads',
            assigneeId: opsHead,
          ),
          ActionItem(
            id: id('ai'),
            text: 'Confirm judges and mentors',
            assigneeId: president,
            taskId: tasks[5].id,
          ),
        ],
      ),
      Meeting(
        id: 'mt_core_next',
        title: 'Core sync: final CodeRush checks',
        startsAt: day(_daysUntil(today, DateTime.saturday), 11),
        durationMinutes: 60,
        audience: Audience.society,
        venue: 'Campus 15 discussion room',
        createdBy: vp,
        createdAt: day(-1),
        agenda: [
          'Track readiness',
          'Food and night logistics',
          'Budget vs spend',
          'Comms plan for the day',
        ],
      ),
      Meeting(
        id: 'mt_app',
        title: 'App Dev weekly',
        startsAt: day(_daysUntil(today, DateTime.thursday), 18),
        durationMinutes: 45,
        audience: Audience.domain,
        domainId: 'app',
        venue: 'Campus 14, Room 102',
        link: 'https://meet.google.com/',
        createdBy: u('2205211'),
        createdAt: day(-2),
        agenda: ['Flutter Forward dry run', 'Bug triage for the chapter app'],
      ),
      Meeting(
        id: 'mt_tech',
        title: 'Tech leads check-in',
        startsAt: day(-13, 18),
        durationMinutes: 40,
        audience: Audience.department,
        department: tech,
        venue: 'Online',
        link: 'https://meet.google.com/',
        createdBy: techHead,
        createdAt: day(-15),
        agenda: ['Domain goals for the term', 'Shared GitHub org'],
        minutes:
            'Every domain set two goals for the term. GitHub org migration owned by Web Dev.',
        actionItems: [
          ActionItem(
            id: id('ai'),
            text: 'Migrate chapter website to Next.js 15',
            assigneeId: u('2205233'),
            taskId: tasks[18].id,
          ),
        ],
      ),
    ];
    for (final mt in meetings.where((x) => x.endsAt.isBefore(now))) {
      for (final mid in pick(9)) {
        attendance.add(
          AttendanceRecord(
            id: AttendanceRecord.idFor(AttendanceTarget.meeting, mt.id, mid),
            target: AttendanceTarget.meeting,
            targetId: mt.id,
            memberId: mid,
            at: mt.startsAt,
            method: CheckInMethod.manual,
            markedBy: mt.createdBy,
          ),
        );
      }
    }

    // ── Vault ───────────────────────────────────────────────────────────────
    final vault = [
      VaultItem(
        id: id('vlt'),
        title: 'Chapter brand kit',
        category: VaultCategory.brand,
        url: 'https://drive.google.com/',
        description: 'Logos, colours and type. Use these on every poster.',
        addedBy: u('2205302'),
        addedAt: day(-70),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Poster templates',
        category: VaultCategory.templates,
        url: 'https://figma.com/',
        description: 'A3, Instagram 4:5 and story sizes.',
        addedBy: u('2205302'),
        addedAt: day(-65),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Certificate template',
        category: VaultCategory.templates,
        fileName: 'certificate_template.pptx',
        sizeBytes: 2400000,
        addedBy: u('2305397'),
        addedAt: day(-22),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Event SOP',
        category: VaultCategory.docs,
        fileName: 'event_sop_v3.pdf',
        sizeBytes: 860000,
        description: 'Permissions, venue booking and the day-of checklist.',
        addedBy: opsHead,
        addedAt: day(-80),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Sponsorship deck',
        category: VaultCategory.docs,
        fileName: 'gfg_kiit_sponsor_deck.pdf',
        sizeBytes: 5300000,
        addedBy: u('2205291'),
        addedAt: day(-35),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Orientation photos',
        category: VaultCategory.eventAssets,
        url: 'https://photos.google.com/',
        addedBy: u('2305454'),
        addedAt: day(-55),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'DSA sheet (chapter edition)',
        category: VaultCategory.learning,
        url: 'https://www.geeksforgeeks.org/',
        description: '180 problems, ordered for the bootcamp.',
        addedBy: u('2205245'),
        addedAt: day(-30),
      ),
      VaultItem(
        id: id('vlt'),
        title: 'Flutter starter repo',
        category: VaultCategory.learning,
        url: 'https://github.com/',
        addedBy: u('2205211'),
        addedAt: day(-13),
      ),
    ];

    // ── Comments ────────────────────────────────────────────────────────────
    final comments = [
      Comment(
        id: id('cmt'),
        parent: CommentParent.task,
        parentId: tasks[1].id,
        authorId: u('2205291'),
        text: 'ByteForge confirmed on call. Waiting for the signed letter.',
        createdAt: day(-1, 18),
      ),
      Comment(
        id: id('cmt'),
        parent: CommentParent.task,
        parentId: tasks[1].id,
        authorId: president,
        text: 'Great. Loop me in on the email so I can sign from our side.',
        createdAt: day(-1, 19),
      ),
      Comment(
        id: id('cmt'),
        parent: CommentParent.event,
        parentId: 'ev_coderush',
        authorId: techHead,
        text:
            'Problem statements are in review. Will share the final set with judges on Friday.',
        createdAt: day(-1, 22),
      ),
      Comment(
        id: id('cmt'),
        parent: CommentParent.expense,
        parentId: expenses[8].id,
        authorId: u('2205077'),
        text: 'We have ₹50k from ByteForge for this. Fine to approve.',
        createdAt: day(-1, 12),
      ),
    ];

    // ── Inbox ───────────────────────────────────────────────────────────────
    Notice n(
      String to,
      NoticeKind k,
      String title,
      String body,
      int hoursAgo, {
      String? route,
      bool read = false,
    }) => Notice(
      id: id('ntc'),
      recipientId: to,
      kind: k,
      title: title,
      body: body,
      route: route,
      read: read,
      createdAt: now.subtract(Duration(hours: hoursAgo)),
    );
    final notices = [
      n(
        president,
        NoticeKind.finance,
        'Expense to review: ₹42,000',
        'Aditya Patnaik · CodeRush T-shirts (300)',
        20,
        route: '/funds/expense/${expenses[8].id}',
      ),
      n(
        president,
        NoticeKind.finance,
        'Expense to review: ₹18,500',
        'Shreya Dash · CodeRush sound and stage',
        68,
        route: '/funds/expense/${expenses[7].id}',
      ),
      n(
        president,
        NoticeKind.people,
        'New join request',
        'Kartik Rout wants to join App Development.',
        22,
        route: '/people/requests/${u('2405566')}',
      ),
      n(
        president,
        NoticeKind.task,
        'Ready for review: Lock problem statements',
        'Vivek Kumar moved it to in review.',
        10,
        route: '/tasks/${tasks[2].id}',
      ),
      n(
        u('2205211'),
        NoticeKind.finance,
        'Expense to review: ₹650',
        'Rahul Kumar · Handouts for Flutter Forward',
        5,
        route: '/funds/expense/${expenses[5].id}',
      ),
      n(
        u('2205211'),
        NoticeKind.people,
        'New join request',
        'Kartik Rout wants to join App Development.',
        22,
        route: '/people/requests/${u('2405566')}',
      ),
      n(
        techHead,
        NoticeKind.finance,
        'Expense to review: ₹3,000',
        'Vivek Kumar · Weekly Ladder prize vouchers',
        14,
        route: '/funds/expense/${expenses[6].id}',
      ),
      n(
        u('2305318'),
        NoticeKind.task,
        'New task: Print 120 handouts',
        'Arjun Das assigned this to you.',
        30,
        route: '/tasks/${tasks[13].id}',
      ),
      n(
        u('2305318'),
        NoticeKind.finance,
        'Reimbursed: ₹1,800',
        'Workshop snacks and water · ref UPI 5519 0042 8810',
        190,
        read: true,
      ),
      n(
        u('2305318'),
        NoticeKind.event,
        'Open Source 101 is today',
        'Check-in is open at Campus 15, Seminar Hall 2.',
        3,
        route: '/events/ev_oss',
      ),
      n(
        treasurer,
        NoticeKind.finance,
        'To reimburse: ₹1,350',
        'Harsh Vardhan · Bootcamp certificates',
        450,
        route: '/funds/expense/${expenses[2].id}',
      ),
      n(
        u('2405522'),
        NoticeKind.people,
        'You’re invited to an interview',
        'Tomorrow at 5:00 PM with the App Dev lead.',
        26,
      ),
    ];

    final audit = [
      AuditEntry(
        id: id('aud'),
        actorId: president,
        action: 'term.rollover',
        summary:
            'Aarav Mohanty started the $termLabel term (14 offices assigned)',
        at: termStart,
        term: termLabel,
      ),
      AuditEntry(
        id: id('aud'),
        actorId: treasurer,
        action: 'income.logged',
        summary:
            'Rohan Agarwal logged ₹40,000 from GeeksforGeeks chapter grant',
        at: day(-80, 12),
        term: termLabel,
      ),
      AuditEntry(
        id: id('aud'),
        actorId: president,
        action: 'expense.approved',
        summary:
            'Aarav Mohanty gave final approval to ₹8,400 for Orientation refreshments',
        at: day(-56, 10),
        term: termLabel,
      ),
      AuditEntry(
        id: id('aud'),
        actorId: treasurer,
        action: 'income.logged',
        summary:
            'Rohan Agarwal logged ₹50,000 from ByteForge Labs — CodeRush partner',
        at: day(-6, 15),
        term: termLabel,
      ),
      AuditEntry(
        id: id('aud'),
        actorId: u('2205291'),
        action: 'expense.rejected',
        summary: 'Aditya Patnaik rejected ₹1,200 for Cab to sponsor office',
        at: day(-8, 12),
        term: termLabel,
      ),
      AuditEntry(
        id: id('aud'),
        actorId: opsHead,
        action: 'expense.forwarded',
        summary: 'Meera Nair passed CodeRush T-shirts (300) to final approval',
        at: day(-2, 16),
        term: termLabel,
      ),
    ];

    // ── Write ───────────────────────────────────────────────────────────────
    Future<void> put<T extends Entity>(String c, List<T> items) =>
        store.putAll(c, items.map((e) => e.toJson()));
    await store.clear();
    await put(Collections.organization, [org]);
    await put(Collections.domains, domains);
    await put(Collections.roles, DefaultRoles.all);
    await put(Collections.members, members);
    await put(Collections.applications, applications);
    await put(Collections.events, events);
    await put(Collections.attendance, attendance);
    // Earlier-term work, so contribution grids and streaks look lived-in.
    const doneTitles = [
      'Post-event report',
      'Update the member sheet',
      'Design the poster',
      'Write the event recap',
      'Share slides with attendees',
      'Reconcile the bills',
      'Draft the sponsor email',
      'Test the demo build',
      'Record the session',
      'Clean up the vault',
      'Schedule social posts',
      'Review pull requests',
    ];
    for (final m in members.where((m) => m.status == MemberStatus.active)) {
      final weight = switch (m.roleId) {
        DefaultRoles.president || DefaultRoles.vicePresident => 7,
        DefaultRoles.domainLead ||
        DefaultRoles.technicalHead ||
        DefaultRoles.eventHead ||
        DefaultRoles.sponsorshipHead ||
        DefaultRoles.marketingHead ||
        DefaultRoles.treasurer => 11,
        _ => 5,
      };
      for (var i = 0; i < weight; i++) {
        final ago = 2 + rnd.nextInt(104);
        final finished = now.subtract(
          Duration(days: ago, hours: rnd.nextInt(9)),
        );
        tasks.add(
          SocietyTask(
            id: id('task'),
            title: doneTitles[rnd.nextInt(doneTitles.length)],
            description: '',
            domainId: m.domainId,
            assigneeIds: [m.id],
            due: finished.add(const Duration(hours: 8)),
            priority: TaskPriority.low,
            status: TaskStatus.done,
            checklist: const [],
            createdBy: president,
            createdAt: finished.subtract(const Duration(days: 5)),
            updatedAt: finished,
            completedAt: finished,
          ),
        );
      }
    }
    await put(Collections.tasks, tasks);
    await put(Collections.announcements, announcements);
    await put(Collections.expenses, expenses);
    await put(Collections.income, income);
    await put(Collections.meetings, meetings);
    await put(Collections.vault, vault);
    await put(Collections.comments, comments);
    await put(Collections.notices, notices);
    await put(Collections.audit, audit);
    await store.putAll(Collections.credentials, [
      for (final mem in members)
        {
          'id': mem.id,
          'email': mem.email,
          'hash': LocalAuthRepository.hash(mem.email, password),
        },
    ]);
    await store.markSeeded();
  }

  static int _daysUntil(DateTime today, int weekday) {
    final d = (weekday - today.weekday) % 7;
    return d == 0 ? 7 : d;
  }
}
