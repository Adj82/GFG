import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SocietyNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SocietyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _buildItem(Icons.grid_view_rounded, 'Feed'),
      _buildItem(Icons.assignment_rounded, 'Tasks'),
      _buildItem(Icons.calendar_month_rounded, 'Events'),
      _buildItem(Icons.account_balance_wallet_rounded, 'Wallet'),
      _buildItem(Icons.campaign_rounded, 'Alerts'),
      _buildItem(Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: AppColors.getNavBarGradient(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? Colors.white : Colors.white54,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white38,
                      ),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _NavItem _buildItem(IconData icon, String label) {
    return _NavItem(icon: icon, label: label);
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
