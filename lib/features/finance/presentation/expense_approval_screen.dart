import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/models/transaction.dart';
import 'finance_notifier.dart';
import '../../auth/presentation/auth_state_provider.dart';

class ExpenseApprovalScreen extends ConsumerWidget {
  const ExpenseApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(financeProvider);
    final pending = transactions.where((tx) => tx.status == TransactionStatus.pending).toList();
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reimbursement Portal',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: pending.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final tx = pending[index];
                return _buildApprovalCard(context, ref, tx, user?.uid ?? '');
              },
            ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, WidgetRef ref, SocietyTransaction tx, String approverId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.category_rounded, size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  tx.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${tx.id.substring(0, 8)}',
                  style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Claimed',
                            style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '₹${tx.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                    _buildBillBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tx.description,
                  style: GoogleFonts.inter(color: AppColors.darkGrey, height: 1.4, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.ink,
                      child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Requested by ${tx.requesterName}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref.read(financeProvider.notifier).updateTransactionStatus(tx.id, TransactionStatus.rejected, approverId),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('REJECT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ref.read(financeProvider.notifier).updateTransactionStatus(tx.id, TransactionStatus.approved, approverId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('APPROVE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.attachment_rounded, size: 14, color: Colors.blue),
          SizedBox(width: 6),
          Text('BILL', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'All claims are cleared!',
            style: GoogleFonts.inter(color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
