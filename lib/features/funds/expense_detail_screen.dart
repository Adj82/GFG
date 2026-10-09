import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/comments.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/finance_actions.dart';
import '../../domain/expense_rules.dart';
import 'fund_widgets.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final e = ref
        .watch(expensesProvider)
        .where((x) => x.id == expenseId)
        .firstOrNull;
    if (a == null) return const SizedBox.shrink();
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'This expense isn’t available',
          ),
        ),
      );
    }
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final event = ref.watch(eventMapProvider)[e.eventId];
    final canAct = ExpenseRules.canAct(a, e);
    final canPay =
        a.can(Permission.reimburse) && e.isApproved && !e.isReimbursed;
    final actions = ref.read(financeActionsProvider);

    return AppPage(
      title: e.title,
      subtitle: stageLabel(e),
      bottomBar: canAct || canPay
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(Gap.md),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: ContentWidth(
                  child: canPay
                      ? FilledButton.icon(
                          onPressed: () async {
                            final ref0 = await promptDialog(
                              context,
                              title: 'Mark as reimbursed',
                              message:
                                  '${Fmt.money(e.amount)} to ${memberName(members, e.submittedBy)}.',
                              label: 'Payment reference (UPI id, cash…)',
                              confirmLabel: 'Mark paid',
                              required: false,
                              maxLines: 1,
                            );
                            if (ref0 == null) return;
                            await actions.markReimbursed(e, paymentRef: ref0);
                            if (context.mounted) {
                              Toast.show(context, 'Marked as reimbursed');
                            }
                          },
                          icon: const Icon(Icons.payments_rounded),
                          label: const Text('Mark as reimbursed'),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: p.red,
                                ),
                                onPressed: () async {
                                  final reason = await promptDialog(
                                    context,
                                    title: 'Return this expense',
                                    message:
                                        'The submitter will see your reason and can submit again.',
                                    label: 'Reason',
                                    confirmLabel: 'Return expense',
                                    destructive: true,
                                  );
                                  if (reason == null) return;
                                  await actions.decide(
                                    e,
                                    approve: false,
                                    note: reason,
                                  );
                                  if (context.mounted) {
                                    Toast.show(
                                      context,
                                      'Returned to submitter',
                                    );
                                  }
                                },
                                child: const Text('Return'),
                              ),
                            ),
                            const SizedBox(width: Gap.md),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () async {
                                  final note = await promptDialog(
                                    context,
                                    title: 'Approve ${Fmt.money(e.amount)}?',
                                    label: 'Add a note (optional)',
                                    confirmLabel: 'Approve',
                                    required: false,
                                  );
                                  if (note == null) return;
                                  await actions.decide(
                                    e,
                                    approve: true,
                                    note: note,
                                  );
                                  if (context.mounted) {
                                    Toast.show(context, 'Approved');
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          : null,
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        Fmt.money(e.amount),
                        style: context.text.displayMedium,
                      ),
                    ),
                    Pill(
                      stageLabel(e),
                      tone: stageTone(context, e),
                      icon: stageIcon(e),
                    ),
                  ],
                ),
                if (e.stage == ExpenseStage.rejected &&
                    e.history.isNotEmpty &&
                    e.history.last.note.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  Container(
                    padding: const EdgeInsets.all(Gap.md),
                    decoration: BoxDecoration(
                      color: p.redTint,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Returned by ${memberName(members, e.history.last.actorId)}',
                          style: context.text.titleSmall?.copyWith(
                            color: p.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.history.last.note,
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                Panel(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Submitted by',
                        value:
                            '${memberName(members, e.submittedBy)} · ${Fmt.date(e.submittedAt)}',
                        onTap: members[e.submittedBy] == null
                            ? null
                            : () => context.push('/people/${e.submittedBy}'),
                      ),
                      InfoRow(
                        icon: AppIcons.expense(e.category),
                        label: 'Category',
                        value: e.category.label,
                      ),
                      if (e.domainId != null)
                        InfoRow(
                          icon: Icons.workspaces_rounded,
                          label: 'Domain',
                          value: domains[e.domainId]?.name ?? '',
                        ),
                      if (event != null)
                        InfoRow(
                          icon: Icons.event_rounded,
                          label: 'Event',
                          value: event.title,
                          onTap: () => context.push('/events/${event.id}'),
                        ),
                      if (e.receiptName != null)
                        InfoRow(
                          icon: Icons.attach_file_rounded,
                          label: 'Receipt',
                          value: e.receiptName!,
                        ),
                      if (e.description.isNotEmpty)
                        InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Notes',
                          value: e.description,
                        ),
                      if (e.isReimbursed)
                        InfoRow(
                          icon: Icons.payments_rounded,
                          label: 'Paid back',
                          value:
                              '${Fmt.date(e.reimbursedAt!)}${e.paymentRef.isEmpty ? '' : ' · ${e.paymentRef}'}',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text('Approval trail', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                _Trail(expense: e),
                const SizedBox(height: Gap.xl),
                Text('Comments', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                CommentsThread(
                  parent: CommentParent.expense,
                  parentId: e.id,
                  subject: e.title,
                  route: '/funds/expense/${e.id}',
                  notifyIds: {
                    e.submittedBy,
                    ...e.history.map((h) => h.actorId),
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrailItem {
  const _TrailItem({
    required this.title,
    required this.state,
    this.subtitle,
    this.note,
  });

  final String title;
  final _State state;
  final String? subtitle;
  final String? note;
}

enum _State { done, current, upcoming, rejected }

class _Trail extends ConsumerWidget {
  const _Trail({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(memberMapProvider);
    final e = expense;
    final items = <_TrailItem>[];

    for (final h in e.history) {
      final who = memberName(members, h.actorId);
      items.add(switch (h.decision) {
        ApprovalDecision.submitted => _TrailItem(
          title: 'Submitted',
          state: _State.done,
          subtitle: '$who · ${Fmt.dateTime(h.at)}',
        ),
        ApprovalDecision.approved => _TrailItem(
          title: '${h.stage.label} approved',
          state: _State.done,
          subtitle: '$who · ${Fmt.dateTime(h.at)}',
          note: h.note,
        ),
        ApprovalDecision.rejected => _TrailItem(
          title: 'Returned at ${h.stage.label.toLowerCase()}',
          state: _State.rejected,
          subtitle: '$who · ${Fmt.dateTime(h.at)}',
          note: h.note,
        ),
        ApprovalDecision.reimbursed => _TrailItem(
          title: 'Reimbursed',
          state: _State.done,
          subtitle: '$who · ${Fmt.dateTime(h.at)}',
          note: h.note,
        ),
      });
    }

    if (e.stage.isOpen) {
      const chain = ExpenseStage.chain;
      final i = chain.indexOf(e.stage);
      for (var k = i; k < chain.length; k++) {
        items.add(
          _TrailItem(
            title: k == i
                ? 'Waiting for ${chain[k].label.toLowerCase()}'
                : chain[k].label,
            state: k == i ? _State.current : _State.upcoming,
          ),
        );
      }
      items.add(
        const _TrailItem(title: 'Reimbursement', state: _State.upcoming),
      );
    } else if (e.isApproved && !e.isReimbursed) {
      items.add(
        const _TrailItem(
          title: 'Waiting for reimbursement',
          state: _State.current,
          subtitle: 'Approved claims are paid every Friday.',
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _TrailRow(item: items[i], last: i == items.length - 1),
      ],
    );
  }
}

class _TrailRow extends StatelessWidget {
  const _TrailRow({required this.item, required this.last});

  final _TrailItem item;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (item.state) {
      _State.done => p.green,
      _State.current => p.amber,
      _State.upcoming => p.line,
      _State.rejected => p.red,
    };
    final icon = switch (item.state) {
      _State.done => Icons.check_rounded,
      _State.current => Icons.more_horiz_rounded,
      _State.upcoming => null,
      _State.rejected => Icons.close_rounded,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.state == _State.upcoming
                        ? Colors.transparent
                        : color,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: icon == null
                      ? null
                      : Icon(icon, size: 15, color: Colors.white),
                ),
                if (!last) Expanded(child: Container(width: 2, color: p.line)),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.text.titleSmall?.copyWith(
                      color: item.state == _State.upcoming ? p.inkFaint : p.ink,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(item.subtitle!, style: context.text.bodySmall),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '“${item.note}”',
                      style: context.text.bodyMedium?.copyWith(
                        color: p.inkMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
