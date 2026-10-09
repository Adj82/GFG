import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final role = ref.watch(roleMapProvider)[a.me.roleId];
    final requests = ref.watch(pendingRequestsProvider).length;

    final workspace = <_Item>[
      const _Item(
        Icons.campaign_rounded,
        'Announcements',
        'Updates from your leads',
        '/announcements',
      ),
      const _Item(
        Icons.groups_rounded,
        'Meetings',
        'Agenda, minutes, action items',
        '/meetings',
      ),
      const _Item(
        Icons.folder_rounded,
        'Vault',
        'Templates, brand kit, credentials',
        '/vault',
      ),
      const _Item(
        Icons.people_alt_rounded,
        'People',
        'Directory and join requests',
        '/people',
      ),
    ];
    final admin = <_Item>[
      if (a.can(Permission.viewAnalytics))
        const _Item(
          Icons.insights_rounded,
          'Analytics',
          'Tasks, events and spend',
          '/analytics',
        ),
      if (a.can(Permission.viewAudit))
        const _Item(
          Icons.history_rounded,
          'Audit log',
          'Who changed what',
          '/audit',
        ),
      if (a.can(Permission.manageTerm))
        const _Item(
          Icons.swap_horizontal_circle_rounded,
          'Term handover',
          'Pass the baton, keep the history',
          '/handover',
        ),
    ];

    Widget group(String title, List<_Item> items) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: Gap.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title,
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                ),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) Divider(color: p.line, height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Gap.lg,
                            vertical: 4,
                          ),
                          leading: IconTile(items[i].icon, size: 40),
                          title: Text(items[i].title),
                          subtitle: Text(items[i].subtitle),
                          trailing: items[i].route == '/people' && requests > 0
                              ? Badge(
                                  label: Text('$requests'),
                                  backgroundColor: p.amber,
                                )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(items[i].route),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );

    return AppPage(
      title: 'More',
      showBack: false,
      actions: const [TopActions()],
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Panel(
                  onTap: () => context.push('/profile'),
                  child: Row(
                    children: [
                      Avatar(a.me.name, size: 52),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.me.name, style: context.text.titleMedium),
                            Text(
                              role?.name ?? '',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                group('Workspace', workspace),
                group('Admin', admin),
                group('App', const [
                  _Item(
                    Icons.sports_esports_rounded,
                    'Take a break',
                    'Snake on the contribution graph',
                    '/play',
                  ),
                  _Item(
                    Icons.settings_rounded,
                    'Settings',
                    'Appearance, password, sign out',
                    '/settings',
                  ),
                ]),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Item {
  const _Item(this.icon, this.title, this.subtitle, this.route);

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
