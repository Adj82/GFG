import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/models.dart';
import '../data/providers.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/announcements/announcements_screen.dart';
import '../features/auth/auth_screens.dart';
import '../features/auth/join_screen.dart';
import '../features/events/checkin_screens.dart';
import '../features/events/event_detail_screen.dart';
import '../features/events/events_screen.dart';
import '../features/funds/approvals_screen.dart';
import '../features/funds/expense_detail_screen.dart';
import '../features/funds/funds_screen.dart';
import '../features/handover/handover_screen.dart';
import '../features/home/home_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/meetings/meeting_detail_screen.dart';
import '../features/meetings/meetings_screen.dart';
import '../features/more/more_screen.dart';
import '../features/people/member_screen.dart';
import '../features/people/people_screen.dart';
import '../features/people/requests_screens.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/tasks/task_detail_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/vault/vault_screen.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

const _public = {'/login', '/join', '/forgot'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authUserIdProvider, (_, _) => refresh.value++);
  ref.listen(currentMemberProvider, (a, b) {
    if (a?.status != b?.status ||
        a?.needsPasswordReset != b?.needsPasswordReset ||
        (a == null) != (b == null)) {
      refresh.value++;
    }
  });

  GoRoute detail(
    String path,
    Widget Function(GoRouterState s) build, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, s) => build(s),
    routes: routes,
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final uid = ref.read(authUserIdProvider);
      final me = ref.read(currentMemberProvider);
      final isPublic = _public.contains(loc);

      if (uid == null) return isPublic ? null : '/login';
      if (me == null) return isPublic ? null : '/login';
      if (me.status != MemberStatus.active) {
        return loc == '/status' ? null : '/status';
      }
      if (me.needsPasswordReset) {
        return loc == '/set-password' ? null : '/set-password';
      }
      if (isPublic || loc == '/status' || loc == '/set-password') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/join', builder: (_, _) => const JoinScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/status', builder: (_, _) => const AccountStatusScreen()),
      GoRoute(
        path: '/set-password',
        builder: (_, _) => const SetPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, _) => const TasksScreen(),
                routes: [
                  detail(
                    ':id',
                    (s) => TaskDetailScreen(taskId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (_, _) => const EventsScreen(),
                routes: [
                  detail(
                    ':id',
                    (s) => EventDetailScreen(eventId: s.pathParameters['id']!),
                    routes: [
                      detail(
                        'host',
                        (s) =>
                            CheckInHostScreen(eventId: s.pathParameters['id']!),
                      ),
                      detail(
                        'check-in',
                        (s) => CheckInScreen(eventId: s.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/funds',
                builder: (_, _) => const FundsScreen(),
                routes: [
                  detail('approvals', (_) => const ApprovalsScreen()),
                  detail(
                    'expense/:id',
                    (s) =>
                        ExpenseDetailScreen(expenseId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),
            ],
          ),
        ],
      ),
      detail('/inbox', (_) => const InboxScreen()),
      detail('/search', (_) => const SearchScreen()),
      detail('/announcements', (_) => const AnnouncementsScreen()),
      detail(
        '/meetings',
        (_) => const MeetingsScreen(),
        routes: [
          detail(
            ':id',
            (s) => MeetingDetailScreen(meetingId: s.pathParameters['id']!),
          ),
        ],
      ),
      detail(
        '/people',
        (_) => const PeopleScreen(),
        routes: [
          detail(
            'requests',
            (_) => const RequestsScreen(),
            routes: [
              detail(
                ':id',
                (s) =>
                    RequestDetailScreen(applicationId: s.pathParameters['id']!),
              ),
            ],
          ),
          detail(':id', (s) => MemberScreen(memberId: s.pathParameters['id']!)),
        ],
      ),
      detail(
        '/profile',
        (_) => const MyProfileScreen(),
        routes: [detail('edit', (_) => const EditProfileScreen())],
      ),
      detail('/vault', (_) => const VaultScreen()),
      detail('/analytics', (_) => const AnalyticsScreen()),
      detail('/settings', (_) => const SettingsScreen()),
      detail('/audit', (_) => const AuditLogScreen()),
      detail('/handover', (_) => const HandoverScreen()),
    ],
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
  );
});
