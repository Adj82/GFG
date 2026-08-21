import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/models/transaction.dart';
import '../finance_notifier.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Events';
  bool _hasBill = false;

  final List<String> _categories = ['Events', 'Marketing', 'Logistics', 'Technical', 'Miscellaneous'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Submit Expense',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : AppColors.ink
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attach your bill and submit for reimbursement approval.',
              style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            _buildField(context, _amountController, 'Amount Spent', Icons.currency_rupee_rounded, isDark, type: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              initialValue: _selectedCategory,
              style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
                prefixIcon: const Icon(Icons.category_outlined, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),
            _buildField(context, _descController, 'Description', null, isDark, maxLines: 2),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => setState(() => _hasBill = !_hasBill),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _hasBill ? AppColors.primaryGreen : (isDark ? Colors.white12 : Colors.grey[300]!),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: _hasBill ? AppColors.primaryGreen.withValues(alpha: 0.05) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasBill ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                      color: _hasBill ? AppColors.primaryGreen : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _hasBill ? 'Receipt Captured' : 'Attach Receipt / Bill',
                        style: GoogleFonts.inter(
                          color: _hasBill ? AppColors.primaryGreen : AppColors.mediumGrey,
                          fontWeight: _hasBill ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_hasBill) const Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.getButtonGradient(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_amountController.text.isNotEmpty && user != null && _hasBill) {
                    final tx = SocietyTransaction(
                      id: const Uuid().v4(),
                      orgId: MockData.orgId,
                      amount: double.parse(_amountController.text),
                      type: TransactionType.expense,
                      category: _selectedCategory,
                      description: _descController.text,
                      status: TransactionStatus.pending,
                      requesterId: user.uid,
                      requesterName: user.name,
                      createdAt: DateTime.now(),
                    );
                    ref.read(financeProvider.notifier).addTransaction(tx);
                    Navigator.pop(context);
                  } else if (!_hasBill) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please attach a bill proof.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'SUBMIT LOG',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller, String label, IconData? icon, bool isDark, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: type,
      style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
      ),
    );
  }
}
