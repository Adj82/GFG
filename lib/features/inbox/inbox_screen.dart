import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../domain/actions/work_actions.dart';

IconData _icon(NoticeKind k) => switch (k) {
  NoticeKind.task => Icons.task_alt_rounded,
  NoticeKind.event => Icons.event_rounded,
  NoticeKind.finance => Icons.account_balance_wallet_rounded,
  NoticeKind.announcement => Icons.campaign_rounded,
  NoticeKind.people => Icons.group_rounded,
  NoticeKind.meeting => Icons.groups_rounded,
  NoticeKind.system => Icons.auto_awesome_rounded,
};

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final items = ref.watch(myNoticesProvider);
    final unread = items.where((n) => !n.read).length;
    return AppPage(
      title: 'Inbox',
      subtitle: unread == 0 ? 'All caught up' : '$unread unread',
      actions: [
        if (unread > 0)
          TextButton(
            onPressed: () => ref.read(noticeActionsProvider).markAllRead(),
            child: const Text('Mark all read'),
          ),
      ],
      slivers: [
        if (items.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Nothing yet',
              message:
                  'Task assignments, approvals and announcements land here.',
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) Divider(color: p.line),
                      InkWell(
                        onTap: () {
                          ref.read(noticeActionsProvider).markRead(items[i]);
                          final r = items[i].route;
                          if (r != null) context.push(r);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(Gap.lg),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconTile(_icon(items[i].kind), size: 38),
                              const SizedBox(width: Gap.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items[i].title,
                                      style: context.text.titleSmall?.copyWith(
                                        fontWeight: items[i].read
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                      ),
                                    ),
                                    if (items[i].body.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          items[i].body,
                                          style: context.text.bodySmall,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Fmt.ago(items[i].createdAt),
                                      style: context.text.labelSmall?.copyWith(
                                        color: p.inkFaint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!items[i].read)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    left: 8,
                                  ),
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: p.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
