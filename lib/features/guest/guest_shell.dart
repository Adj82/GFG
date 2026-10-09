import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/brand.dart';

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _dests = [
  _Dest('Events', Icons.event_outlined, Icons.event_rounded),
  _Dest('Study', Icons.menu_book_outlined, Icons.menu_book_rounded),
  _Dest('Play', Icons.sports_esports_outlined, Icons.sports_esports_rounded),
];

/// Frame for everyone who isn't signed in: events, study help and a game.
/// Members get to their own panel through the Member login button.
class GuestShell extends StatelessWidget {
  const GuestShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final wide = MediaQuery.sizeOf(context).width >= 840;

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
                      Text('GFG KIIT', style: context.text.titleMedium),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (final d in _dests)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
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
            for (final d in _dests)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// The way in for members. Sits in the top bar of every public tab.
class MemberLoginButton extends StatelessWidget {
  const MemberLoginButton({super.key});

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    onPressed: () => context.push('/login'),
    icon: const Icon(Icons.login_rounded, size: 18),
    label: const Text('Member login'),
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    ),
  );
}
