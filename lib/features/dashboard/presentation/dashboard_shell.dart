import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/society_nav_bar.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/events');
        break;
      case 3:
        context.go('/wallet');
        break;
      case 4:
        context.go('/announcements');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/events')) return 2;
    if (location.startsWith('/wallet')) return 3;
    if (location.startsWith('/announcements')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: SocietyNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
