import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final tasks = ref.watch(tasksProvider);
    final events = ref
        .watch(eventsProvider)
        .where((e) => !e.cancelled)
        .toList();
    final expenses = ref.watch(expensesProvider);
    final attendance = ref.watch(attendanceProvider);
    final domains = ref.watch(domainsProvider);
    final members = ref.watch(activeMembersProvider);
    final now = DateTime.now();

    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final rate = tasks.isEmpty ? 0.0 : done / tasks.length;
    final overdue = tasks
        .where(
          (t) =>
              t.status != TaskStatus.done &&
              t.due != null &&
              t.due!.isBefore(now),
        )
        .length;
    final eventAttendance = attendance
        .where((r) => r.target == AttendanceTarget.event)
        .length;

    // Events per month, last 6 months.
    final months = [
      for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i),
    ];
    final perMonth = [
      for (final m in months)
        events
            .where(
              (e) => e.startsAt.year == m.year && e.startsAt.month == m.month,
            )
            .length
            .toDouble(),
    ];

    // Task completion by domain.
    final byDomain = <Domain, (int, int)>{};
    for (final d in domains) {
      final ts = tasks.where((t) => t.domainId == d.id).toList();
      if (ts.isEmpty) continue;
      byDomain[d] = (
        ts.where((t) => t.status == TaskStatus.done).length,
        ts.length,
      );
    }
    final domainRows = byDomain.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));

    // Spend by category (approved + in review).
    final spend = <ExpenseCategory, double>{};
    for (final e in expenses.where((e) => e.stage != ExpenseStage.rejected)) {
      spend[e.category] = (spend[e.category] ?? 0) + e.amount;
    }
    final spendRows = spend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSpend = spendRows.isEmpty ? 1.0 : spendRows.first.value;

    TextStyle? axis() => context.text.labelSmall?.copyWith(color: p.inkMuted);

    return AppPage(
      title: 'Analytics',
      subtitle: 'This term at a glance',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Panel(
                        child: Stat(
                          value: Fmt.percent(rate),
                          label: 'Tasks done',
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Panel(
                        child: Stat(
                          value: '$overdue',
                          label: 'Overdue',
                          color: overdue > 0 ? p.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    Expanded(
                      child: Panel(
                        child: Stat(
                          value: '${events.length}',
                          label: 'Events run',
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Panel(
                        child: Stat(
                          value: '$eventAttendance',
                          label: 'Check-ins',
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Panel(
                        child: Stat(
                          value: '${members.length}',
                          label: 'Members',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xl),
                Text('Events per month', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                Panel(
                  child: SizedBox(
                    height: 170,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  Fmt.month(months[v.toInt()]),
                                  style: axis(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < perMonth.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: perMonth[i],
                                  width: 22,
                                  color: i == perMonth.length - 1
                                      ? p.green
                                      : p.greenTint,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text(
                  'Task completion by domain',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: Gap.md),
                Panel(
                  child: domainRows.isEmpty
                      ? Text(
                          'No tasks yet.',
                          style: context.text.bodyMedium?.copyWith(
                            color: p.inkFaint,
                          ),
                        )
                      : Column(
                          children: [
                            for (final r in domainRows)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: Text(
                                        r.key.name,
                                        style: context.text.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      child: ThinProgress(
                                        value: r.value.$1 / r.value.$2,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      child: Text(
                                        '${r.value.$1}/${r.value.$2}',
                                        textAlign: TextAlign.right,
                                        style: context.text.labelMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: Gap.xl),
                Text('Spend by category', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                Panel(
                  child: spendRows.isEmpty
                      ? Text(
                          'No expenses yet.',
                          style: context.text.bodyMedium?.copyWith(
                            color: p.inkFaint,
                          ),
                        )
                      : Column(
                          children: [
                            for (final r in spendRows)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: Text(
                                        r.key.label,
                                        style: context.text.bodyMedium,
                                      ),
                                    ),
                                    Expanded(
                                      child: ThinProgress(
                                        value: r.value / maxSpend,
                                        color: p.amber,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        Fmt.moneyShort(r.value),
                                        textAlign: TextAlign.right,
                                        style: context.text.labelMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
