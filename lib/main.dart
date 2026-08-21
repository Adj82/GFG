import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/persistence/local_storage_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/dashboard/presentation/dashboard_shell.dart';
import 'features/tasks/presentation/tasks_screen.dart';
import 'features/announcements/presentation/announcements_screen.dart';
import 'features/dashboard/presentation/dashboard_feed_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/manage_members_screen.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/meetings/presentation/meetings_screen.dart';
import 'features/finance/presentation/wallet_screen.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/vault/presentation/vault_screen.dart';
import 'features/notifications/presentation/notification_center.dart';

// Persistence Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// Theme Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SocietyOS(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardFeedScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/manage-members',
            builder: (context, state) => const ManageMembersScreen(),
          ),
          GoRoute(
            path: '/meetings',
            builder: (context, state) => const MeetingsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/vault',
            builder: (context, state) => const VaultScreen(),
          ),
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const NotificationCenter(),
          ),
        ],
      ),
    ],
  );
});

class SocietyOS extends ConsumerWidget {
  const SocietyOS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SocietyOS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
