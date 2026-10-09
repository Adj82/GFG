import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/expense_rules.dart';
import 'expense_form.dart';
import 'fund_widgets.dart';

enum _Filter { all, review, toPay, done, returned }

final _filterProvider = StateProvider<_Filter>((ref) => _Filter.all);
final _tabProvider = StateProvider<int>((ref) => 0);

/// Expenses the signed-in person may see: all if they hold the wallet, those
/// in their reach if they hold scoped finance, and always their own.
final visibleExpensesProvider = Provider<List<Expense>>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null) return const [];
  return ref.watch(expensesProvider).where((e) {
    if (e.submittedBy == a.me.id) return true;
    if (a.can(Permission.viewWallet)) return true;
    if (a.can(Permission.viewScopedFinance) &&
        (e.domainId == null
            ? a.isSocietyWide
            : a.reaches(domainId: e.domainId))) {
      return true;
    }
    return ExpenseRules.canAct(a, e);
  }).toList()..sort((x, y) => y.submittedAt.compareTo(x.submittedAt));
});

class FundsScreen extends ConsumerWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final canSeeWallet = a.can(Permission.viewWallet);
    final expenses = ref.watch(visibleExpensesProvider);
    final income = ref.watch(incomeProvider).toList()
      ..sort((x, y) => y.receivedAt.compareTo(x.receivedAt));
    final filter = ref.watch(_filterProvider);
    final tab = canSeeWallet ? ref.watch(_tabProvider) : 0;
    final pending = ref.watch(pendingApprovalsProvider);
    final allExpenses = ref.watch(expensesProvider);

    final balance = Ledger.balance(income, allExpenses);
    final totalIn = Ledger.incomeTotal(income);
    final totalOut = Ledger.spentTotal(allExpenses);
    final inReview = Ledger.pendingTotal(allExpenses);
    final toReimburse = allExpenses
        .where((e) => e.isApproved && !e.isReimbursed)
        .fold<double>(0, (s, e) => s + e.amount);

    bool match(Expense e) => switch (filter) {
      _Filter.all => true,
      _Filter.review => e.stage.isOpen,
      _Filter.toPay => e.isApproved && !e.isReimbursed,
      _Filter.done => e.isApproved && e.isReimbursed,
      _Filter.returned => e.stage == ExpenseStage.rejected,
    };
    final shown = expenses.where(match).toList();
    int count(_Filter f) => expenses
        .where(
          (e) => switch (f) {
            _Filter.all => true,
            _Filter.review => e.stage.isOpen,
            _Filter.toPay => e.isApproved && !e.isReimbursed,
            _Filter.done => e.isApproved && e.isReimbursed,
            _Filter.returned => e.stage == ExpenseStage.rejected,
          },
        )
        .length;

    return AppPage(
      title: 'Funds',
      subtitle: canSeeWallet ? 'Chapter wallet' : 'Your expense claims',
      showBack: false,
      actions: const [TopActions()],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showExpenseForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Submit expense'),
      ),
      slivers: [
        if (canSeeWallet)
          PagePad(
            top: Gap.sm,
            child: ContentWidth(
              child: Container(
                padding: const EdgeInsets.all(Gap.lg),
                decoration: BoxDecoration(
                  color: p.forest,
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: context.text.bodyMedium?.copyWith(
                        color: p.onForest.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Fmt.money(balance),
                      style: context.text.displayMedium?.copyWith(
                        color: balance < 0
                            ? const Color(0xFFFF9B94)
                            : p.onForest,
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: 'In',
                            value: Fmt.moneyShort(totalIn),
                            icon: Icons.south_west_rounded,
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Spent',
                            value: Fmt.moneyShort(totalOut),
                            icon: Icons.north_east_rounded,
                          ),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'In review',
                            value: Fmt.moneyShort(inReview),
                            icon: Icons.hourglass_top_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (toReimburse > 0) ...[
                      const SizedBox(height: Gap.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: p.onForest.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.payments_rounded,
                              size: 18,
                              color: p.onForest.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${Fmt.money(toReimburse)} approved and waiting to be paid back',
                                style: context.text.bodySmall?.copyWith(
                                  color: p.onForest.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        if (pending > 0)
          PagePad(
            top: Gap.md,
            child: ContentWidth(
              child: Panel(
                onTap: () => context.push('/funds/approvals'),
                color: p.amberTint,
                borderColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(Icons.rule_rounded, color: p.amber),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Text(
                        '${Fmt.plural(pending, 'expense')} waiting for your review',
                        style: context.text.titleSmall?.copyWith(color: p.ink),
                      ),
                    ),
                    Text(
                      'Review',
                      style: context.text.labelLarge?.copyWith(color: p.amber),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.amber),
                  ],
                ),
              ),
            ),
          ),
        if (canSeeWallet)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page, 0),
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(value: 0, label: Text('Expenses')),
                  ButtonSegment(
                    value: 1,
                    label: Text('Income (${income.length})'),
                  ),
                ],
                selected: {tab},
                onSelectionChanged: (s) =>
                    ref.read(_tabProvider.notifier).state = s.first,
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: Gap.lg)),
        if (tab == 0) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Gap.md),
              child: FilterBar<_Filter>(
                values: _Filter.values,
                selected: filter,
                counts: {for (final f in _Filter.values) f: count(f)},
                label: (f) => switch (f) {
                  _Filter.all => 'All',
                  _Filter.review => 'In review',
                  _Filter.toPay => 'To reimburse',
                  _Filter.done => 'Reimbursed',
                  _Filter.returned => 'Returned',
                },
                onSelected: (f) => ref.read(_filterProvider.notifier).state = f,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
          if (shown.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: filter == _Filter.all
                    ? 'No expenses yet'
                    : 'Nothing here',
                message: filter == _Filter.all
                    ? 'Spent your own money on chapter work? Submit the bill and get it paid back.'
                    : 'No expenses in this state.',
                actionLabel: filter == _Filter.all ? 'Submit an expense' : null,
                onAction: filter == _Filter.all
                    ? () => showExpenseForm(context)
                    : null,
              ),
            )
          else
            PagePad(
              child: ContentWidth(
                child: Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) Divider(color: p.line),
                        ExpenseTile(
                          expense: shown[i],
                          onTap: () =>
                              context.push('/funds/expense/${shown[i].id}'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ] else ...[
          if (a.can(Permission.logIncome))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.page,
                  Gap.md,
                  Gap.page,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () => showIncomeForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Log income'),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.greenTint,
                      foregroundColor: p.greenStrong,
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
          if (income.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.savings_rounded,
                title: 'No income logged',
                message:
                    'Sponsorships, grants and fees appear here once logged.',
              ),
            )
          else
            PagePad(
              child: ContentWidth(
                child: Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < income.length; i++) ...[
                        if (i > 0) Divider(color: p.line),
                        IncomeTile(income: income[i]),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: p.onForest.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: p.onForest.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.text.titleLarge?.copyWith(color: p.onForest),
        ),
      ],
    );
  }
}
