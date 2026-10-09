import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _c = TextEditingController();
  var _q = '';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool _hit(String s) => s.toLowerCase().contains(_q);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = ref.watch(accessProvider);
    final q = _q;
    final tasks = q.isEmpty
        ? const []
        : ref
              .watch(visibleTasksProvider)
              .where((t) => _hit(t.title) || _hit(t.description))
              .take(6)
              .toList();
    final events = q.isEmpty
        ? const []
        : ref
              .watch(eventsProvider)
              .where((e) => _hit(e.title))
              .take(6)
              .toList();
    final people = q.isEmpty
        ? const []
        : ref
              .watch(activeMembersProvider)
              .where((m) => _hit(m.name) || _hit(m.email) || m.skills.any(_hit))
              .take(8)
              .toList();
    final posts = q.isEmpty
        ? const []
        : ref
              .watch(visibleAnnouncementsProvider)
              .where((x) => _hit(x.title) || _hit(x.body))
              .take(5)
              .toList();
    final vault = q.isEmpty
        ? const []
        : ref
              .watch(vaultProvider)
              .where((v) => _hit(v.title) || _hit(v.description))
              .take(5)
              .toList();
    final nothing =
        q.isNotEmpty &&
        tasks.isEmpty &&
        events.isEmpty &&
        people.isEmpty &&
        posts.isEmpty &&
        vault.isEmpty;

    Widget group(String title, List<Widget> rows) => rows.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: Gap.lg),
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
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) Divider(color: p.line),
                        rows[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );

    Widget row(IconData icon, String title, String sub, String route) =>
        ListTile(
          leading: IconTile(icon, size: 36),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: sub.isEmpty
              ? null
              : Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.push(route),
        );

    return AppPage(
      title: 'Search',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _c,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Tasks, events, people, files…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _q.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _c.clear();
                              _q = '';
                            }),
                          ),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                if (a == null || q.isEmpty)
                  const EmptyState(
                    icon: Icons.manage_search_rounded,
                    title: 'Find anything',
                    message:
                        'Search across everything you can see in the chapter.',
                    compact: true,
                  )
                else if (nothing)
                  EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: 'Nothing found for “${_c.text.trim()}”.',
                    compact: true,
                  )
                else ...[
                  group('People', [
                    for (final m in people)
                      row(
                        Icons.person_rounded,
                        m.name,
                        m.email.split('@').first,
                        '/people/${m.id}',
                      ),
                  ]),
                  group('Tasks', [
                    for (final t in tasks)
                      row(
                        Icons.task_alt_rounded,
                        t.title,
                        t.status.label,
                        '/tasks/${t.id}',
                      ),
                  ]),
                  group('Events', [
                    for (final e in events)
                      row(
                        Icons.event_rounded,
                        e.title,
                        e.venue,
                        '/events/${e.id}',
                      ),
                  ]),
                  group('Announcements', [
                    for (final x in posts)
                      row(
                        Icons.campaign_rounded,
                        x.title,
                        '',
                        '/announcements',
                      ),
                  ]),
                  group('Vault', [
                    for (final v in vault)
                      row(
                        Icons.folder_rounded,
                        v.title,
                        v.category.label,
                        '/vault',
                      ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
