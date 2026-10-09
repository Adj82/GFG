import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

Tone stageTone(BuildContext c, Expense e) {
  if (e.stage == ExpenseStage.rejected) return Tone.red(c);
  if (e.stage == ExpenseStage.approved) {
    return e.isReimbursed ? Tone.green(c) : Tone.blue(c);
  }
  return Tone.amber(c);
}

String stageLabel(Expense e) {
  if (e.stage == ExpenseStage.approved) {
    return e.isReimbursed ? 'Reimbursed' : 'Approved · to reimburse';
  }
  if (e.stage == ExpenseStage.rejected) return 'Returned';
  return switch (e.stage) {
    ExpenseStage.leadReview => 'Lead review',
    ExpenseStage.headVerification => 'Head check',
    _ => 'Final approval',
  };
}

IconData stageIcon(Expense e) {
  if (e.stage == ExpenseStage.rejected) return Icons.undo_rounded;
  if (e.stage == ExpenseStage.approved) {
    return e.isReimbursed ? Icons.payments_rounded : Icons.check_rounded;
  }
  return Icons.hourglass_top_rounded;
}

class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onTap,
    this.showSubmitter = true,
  });

  final Expense expense;
  final VoidCallback onTap;
  final bool showSubmitter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(memberMapProvider);
    final events = ref.watch(eventMapProvider);
    final e = expense;
    final sub = [
      if (showSubmitter) memberName(members, e.submittedBy),
      if (events[e.eventId] != null) events[e.eventId]!.title,
      Fmt.ago(e.submittedAt),
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconTile(AppIcons.expense(e.category), size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Fmt.money(e.amount), style: context.text.titleSmall),
                const SizedBox(height: 4),
                Pill(
                  stageLabel(e),
                  tone: stageTone(context, e),
                  icon: stageIcon(e),
                  dense: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeTile extends ConsumerWidget {
  const IncomeTile({super.key, required this.income});

  final Income income;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final events = ref.watch(eventMapProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconTile(
            AppIcons.income(income.source),
            size: 40,
            tone: Tone.green(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.title,
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    income.source.label,
                    if (events[income.eventId] != null)
                      events[income.eventId]!.title,
                    Fmt.date(income.receivedAt),
                  ].join(' · '),
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '+${Fmt.money(income.amount)}',
            style: context.text.titleSmall?.copyWith(color: p.greenStrong),
          ),
        ],
      ),
    );
  }
}
