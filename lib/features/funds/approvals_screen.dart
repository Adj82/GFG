import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/finance_actions.dart';
import '../../domain/expense_rules.dart';

/// Everything waiting on the signed-in person, with one-tap decisions.
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final queue =
        ref
            .watch(expensesProvider)
            .where((e) => ExpenseRules.canAct(a, e))
            .toList()
          ..sort((x, y) => x.submittedAt.compareTo(y.submittedAt));
    final total = queue.fold<double>(0, (s, e) => s + e.amount);

    return AppPage(
      title: 'To review',
      subtitle: queue.isEmpty
          ? 'Nothing waiting'
          : '${Fmt.plural(queue.length, 'expense')} · ${Fmt.money(total)}',
      slivers: [
        if (queue.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.verified_rounded,
              title: 'You’re all caught up',
              message:
                  'New expenses that need your sign-off will show up here, and you’ll get a notification.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            sliver: SliverToBoxAdapter(
              child: ContentWidth(
                child: Column(
                  children: [
                    for (final e in queue)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.md),
                        child: _ApprovalCard(expense: e),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ApprovalCard extends ConsumerStatefulWidget {
  const _ApprovalCard({required this.expense});

  final Expense expense;

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  var _busy = false;

  Future<void> _approve() async {
    setState(() => _busy = true);
    final a = ref.read(accessProvider)!;
    final next = ExpenseRules.stageAfterApproval(a, widget.expense);
    await ref
        .read(financeActionsProvider)
        .decide(widget.expense, approve: true);
    if (!mounted) return;
    setState(() => _busy = false);
    Toast.show(
      context,
      next == ExpenseStage.approved
          ? 'Approved. The core team will pay it back.'
          : 'Approved and passed to ${next.label.toLowerCase()}',
    );
  }

  Future<void> _return() async {
    final reason = await promptDialog(
      context,
      title: 'Return this expense',
      message: 'The submitter will see your reason and can submit again.',
      label: 'Reason',
      confirmLabel: 'Return expense',
      destructive: true,
    );
    if (reason == null) return;
    await ref
        .read(financeActionsProvider)
        .decide(widget.expense, approve: false, note: reason);
    if (mounted) {
      Toast.show(
        context,
        'Returned to ${memberName(ref.read(memberMapProvider), widget.expense.submittedBy)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final e = widget.expense;
    final a = ref.watch(accessProvider)!;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final events = ref.watch(eventMapProvider);
    final stageNow = ExpenseRules.highestStageFor(a, e) ?? e.stage;
    final last = e.history
        .where((h) => h.decision == ApprovalDecision.approved)
        .lastOrNull;

    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/funds/expense/${e.id}'),
            child: Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(AppIcons.expense(e.category), size: 44),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: context.text.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              '${memberName(members, e.submittedBy)}${e.domainId == null ? '' : ' · ${domains[e.domainId]?.name ?? ''}'}',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Fmt.money(e.amount),
                        style: context.text.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill(
                        e.category.label,
                        tone: Tone.neutral(context),
                        dense: true,
                      ),
                      if (events[e.eventId] != null)
                        Pill(
                          events[e.eventId]!.title,
                          tone: Tone.neutral(context),
                          icon: Icons.event_rounded,
                          dense: true,
                        ),
                      if (e.receiptName != null)
                        Pill(
                          'Receipt attached',
                          tone: Tone.green(context),
                          icon: Icons.attach_file_rounded,
                          dense: true,
                        ),
                      Pill(
                        'Submitted ${Fmt.ago(e.submittedAt)}',
                        tone: Tone.neutral(context),
                        dense: true,
                      ),
                    ],
                  ),
                  if (e.description.isNotEmpty) ...[
                    const SizedBox(height: Gap.md),
                    Text(
                      e.description,
                      style: context.text.bodyMedium?.copyWith(
                        color: p.inkMuted,
                      ),
                    ),
                  ],
                  if (last != null && last.note.isNotEmpty) ...[
                    const SizedBox(height: Gap.md),
                    Container(
                      padding: const EdgeInsets.all(Gap.md),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${memberName(members, last.actorId)}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: last.note),
                          ],
                        ),
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Divider(height: 1, color: p.line),
          Padding(
            padding: const EdgeInsets.all(Gap.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : _return,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.red,
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Return'),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _busy ? null : _approve,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Text(
                            stageNow == ExpenseStage.finalApproval
                                ? 'Give final approval'
                                : 'Approve as ${stageNow == ExpenseStage.leadReview ? 'lead' : 'core head'}',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
