import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/palette.dart';
import '../core/widgets/brand.dart';
import '../data/providers.dart';
import '../domain/expense_rules.dart';

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _dests = [
  _Dest('Home', Icons.home_outlined, Icons.home_rounded),
  _Dest(
    'Tasks',
    Icons.check_circle_outline_rounded,
    Icons.check_circle_rounded,
  ),
  _Dest('Events', Icons.event_outlined, Icons.event_rounded),
  _Dest(
    'Funds',
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet_rounded,
  ),
  _Dest('More', Icons.grid_view_outlined, Icons.grid_view_rounded),
];

/// Number of expenses waiting on the signed-in person. Drives the Funds badge.
final pendingApprovalsProvider = Provider<int>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null) return 0;
  return ref
      .watch(expensesProvider)
      .where((e) => ExpenseRules.canAct(a, e))
      .length;
});

final unreadNoticesProvider = Provider<int>((ref) {
  final me = ref.watch(authUserIdProvider);
  return ref
      .watch(noticesProvider)
      .where((n) => n.recipientId == me && !n.read)
      .length;
});

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final pending = ref.watch(pendingApprovalsProvider);
    final org = ref.watch(organizationProvider);

    Widget icon(int i, bool selected) {
      final d = _dests[i];
      final base = Icon(selected ? d.selectedIcon : d.icon);
      if (i == 3 && pending > 0) {
        return Badge(
          label: Text('$pending'),
          backgroundColor: p.red,
          textColor: Colors.white,
          child: base,
        );
      }
      return base;
    }

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1100,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              minExtendedWidth: 208,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: 40),
                    if (MediaQuery.sizeOf(context).width >= 1100) ...[
                      const SizedBox(width: Gap.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SocietyOS', style: context.text.titleMedium),
                          Text(
                            org?.shortName ?? '',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (var i = 0; i < _dests.length; i++)
                  NavigationRailDestination(
                    icon: icon(i, false),
                    selectedIcon: icon(i, true),
                    label: Text(_dests[i].label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: p.line),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (var i = 0; i < _dests.length; i++)
              NavigationDestination(
                icon: icon(i, false),
                selectedIcon: icon(i, true),
                label: _dests[i].label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Used by screens inside the shell that want the top-right inbox + search.
class TopActions extends ConsumerWidget {
  const TopActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNoticesProvider);
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push('/search'),
        ),
        IconButton(
          tooltip: unread == 0 ? 'Inbox' : 'Inbox, $unread unread',
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            backgroundColor: p.red,
            textColor: Colors.white,
            child: const Icon(Icons.notifications_none_rounded),
          ),
          onPressed: () => context.push('/inbox'),
        ),
      ],
    );
  }
}
