import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import '../domain/models/transaction.dart';
import 'finance_notifier.dart';
import 'widgets/add_expense_sheet.dart';
import '../../auth/presentation/auth_state_provider.dart';
import 'expense_approval_screen.dart';
import '../../../core/services/permissions_service.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final allTransactions = ref.watch(financeProvider);
    final user = ref.watch(currentUserProvider);
    final permissions = ref.watch(permissionsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canViewFullLedger = permissions.canViewFinance;
    final canApprove = permissions.canManageFinance;

    final displayedTransactions = canViewFullLedger 
      ? allTransactions 
      : allTransactions.where((tx) => tx.requesterId == user?.uid).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          PremiumHeader(
            title: canViewFullLedger ? 'Society Ledger' : 'My Expense Logs',
            subtitle: canViewFullLedger ? 'Chapter treasury and financial registry' : 'Track your reimbursement requests',
            expandedHeight: 150, // Reduced breadth
            actions: [
              if (canApprove)
                IconButton(
                  icon: const Icon(Icons.fact_check_rounded, color: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseApprovalScreen())),
                ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (canViewFullLedger) 
                  _buildBalanceCard(context, balance, isDark)
                else
                  _buildMemberInfoCard(context),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        canViewFullLedger ? 'Registry' : 'Your History', 
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, 
                          fontSize: 18, 
                          color: isDark ? Colors.white : AppColors.ink
                        )
                      ),
                      _buildHistoryBadge(displayedTransactions.length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          displayedTransactions.isEmpty
              ? SliverFillRemaining(child: _buildEmptyLedger(canViewFullLedger))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildModernTransaction(context, displayedTransactions[index], canViewFullLedger, isDark),
                      childCount: displayedTransactions.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getButtonGradient(isDark),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddExpenseSheet(),
            );
          },
          label: Text('SUBMIT BILL', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.white)),
          icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildHistoryBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.softGrey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Text('$count ENTRIES', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.mediumGrey)),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.getHeaderGradient(isDark),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapter Treasury', 
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
              const Icon(Icons.shield_rounded, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${NumberFormat('#,##,###').format(balance)}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 12),
                const SizedBox(width: 8),
                Text(
                  'Core Team Financial Portal', 
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
            child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reimbursement Policy', 
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.ink, fontSize: 15)
                ),
                Text(
                  'Submit your expense logs with valid bills. The core team will verify and reimburse accordingly.', 
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.mediumGrey, height: 1.4)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTransaction(BuildContext context, SocietyTransaction tx, bool showRequester, bool isDark) {
    final isExpense = tx.type == TransactionType.expense;
    final statusColor = _getStatusColor(tx.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(isExpense ? Icons.north_east_rounded : Icons.south_west_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : AppColors.ink)),
                const SizedBox(height: 2),
                Text(tx.description, style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (showRequester)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
                    child: Text(tx.requesterName ?? 'User', style: GoogleFonts.inter(color: AppColors.primaryGreen, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? "-" : "+"}₹${tx.amount.toInt()}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: isExpense ? AppColors.error : AppColors.success),
              ),
              const SizedBox(height: 4),
              Text(tx.status.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: statusColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLedger(bool canViewFull) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 70, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(canViewFull ? 'Treasury is currently inactive.' : 'Your history is clear.', style: GoogleFonts.inter(color: Colors.grey[400], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.approved: return AppColors.success;
      case TransactionStatus.pending: return AppColors.warning;
      case TransactionStatus.rejected: return AppColors.error;
    }
  }
}
