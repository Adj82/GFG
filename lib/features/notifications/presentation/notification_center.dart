import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const PremiumHeader(
            title: 'Chapter Inbox',
            subtitle: 'Real-time society alerts and notifications',
            expandedHeight: 160,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final items = [
                    {'title': 'New Task Assigned', 'body': 'Finish the society website redesign.', 'icon': Icons.task_alt_rounded, 'time': '10m ago'},
                    {'title': 'Event Update', 'body': 'Orientation time changed to 5 PM.', 'icon': Icons.event_rounded, 'time': '2h ago'},
                    {'title': 'Fund Approved', 'body': 'Your request for ₹500 was approved.', 'icon': Icons.account_balance_wallet_rounded, 'time': '1d ago'},
                  ];
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item['icon'] as IconData, color: AppColors.primaryGreen, size: 22),
                      ),
                      title: Text(
                        item['title'] as String, 
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.ink)
                      ),
                      subtitle: Text(
                        item['body'] as String,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.mediumGrey),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['time'] as String, 
                            style: GoogleFonts.inter(fontSize: 9, color: AppColors.mediumGrey, fontWeight: FontWeight.w600)
                          ),
                          const SizedBox(height: 6),
                          const CircleAvatar(radius: 3, backgroundColor: AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
