import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import '../../tasks/presentation/tasks_notifier.dart';
import '../../finance/presentation/finance_notifier.dart';
import '../../tasks/domain/models/task.dart';
import '../../finance/domain/models/transaction.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final transactions = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const PremiumHeader(
            title: 'Society Analytics',
            subtitle: 'Visual data and performance insights',
            expandedHeight: 160,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Task Distribution'),
                  const SizedBox(height: 16),
                  _buildTaskChart(tasks, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Financial Overview'),
                  const SizedBox(height: 16),
                  _buildFinanceChart(transactions, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Domain Performance'),
                  const SizedBox(height: 16),
                  _buildDomainStats(tasks, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.mediumGrey),
    );
  }

  Widget _buildTaskChart(List<SocietyTask> tasks, bool isDark) {
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final total = tasks.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 15)],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        children: [
          _buildBar('Pending', pending, total, AppColors.priorityHigh),
          const SizedBox(height: 16),
          _buildBar('Active', inProgress, total, AppColors.info),
          const SizedBox(height: 16),
          _buildBar('Completed', completed, total, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildFinanceChart(List<SocietyTransaction> txs, bool isDark) {
    final income = txs.where((t) => t.type == TransactionType.income && t.status == TransactionStatus.approved).fold(0.0, (sum, t) => sum + t.amount);
    final expense = txs.where((t) => t.type == TransactionType.expense && t.status == TransactionStatus.approved).fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightGreen : AppColors.ink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.midnightGreen.withValues(alpha: 0.2), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Society Income', '₹${income.toInt()}', AppColors.success),
              _buildStat('Society Expense', '₹${expense.toInt()}', AppColors.priorityHigh),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (income > 0) Expanded(flex: income.toInt(), child: Container(color: AppColors.success)),
                  if (expense > 0) Expanded(flex: expense.toInt(), child: Container(color: AppColors.priorityHigh)),
                  if (income == 0 && expense == 0) Expanded(child: Container(color: Colors.white10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, int total, Color color) {
    final double percent = total > 0 ? value / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDomainStats(List<SocietyTask> tasks, bool isDark) {
    final Map<String, int> domainCounts = {};
    for (var task in tasks) {
      domainCounts[task.domainId] = (domainCounts[task.domainId] ?? 0) + 1;
    }

    return Column(
      children: domainCounts.entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : Border.all(color: Colors.grey[100]!),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.hub_rounded, size: 18, color: AppColors.primaryGreen),
          ),
          title: Text(e.key.split('-').last.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          trailing: Text('${e.value} TASKS', style: GoogleFonts.inter(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 10)),
        ),
      )).toList(),
    );
  }
}
