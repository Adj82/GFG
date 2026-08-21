import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/permissions_service.dart';
import '../../../core/widgets/search/global_search_delegate.dart';
import '../../../core/widgets/premium_header.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../tasks/presentation/tasks_notifier.dart';
import '../../announcements/presentation/announcements_notifier.dart';
import '../../tasks/domain/models/task.dart';
import '../../events/presentation/events_notifier.dart';
import '../../finance/presentation/finance_notifier.dart';

class DashboardFeedScreen extends ConsumerWidget {
  const DashboardFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tasks = ref.watch(tasksProvider);
    final announcements = ref.watch(announcementsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final walletBalance = ref.watch(walletBalanceProvider);
    final permissions = ref.watch(permissionsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          PremiumHeader(
            title: 'Hi, ${user.name.split(' ')[0]} 👋',
            subtitle: 'Welcome to your society pulse',
            expandedHeight: 160,
            actions: [
              _buildCircularAction(Icons.search_rounded, () => showSearch(context: context, delegate: GlobalSearchDelegate())),
              _buildCircularAction(Icons.notifications_active_outlined, () => context.push('/inbox')),
              _buildCircularAction(Icons.tune_rounded, () => _showRoleSwitcher(context, ref, isDark)),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionHeader('Society Pulse', isDark),
                  const SizedBox(height: 16),
                  _buildStatCards(context, tasks, user, walletBalance, permissions.canViewFinance, isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Control Center', isDark),
                  const SizedBox(height: 16),
                  _buildControlCenter(context, permissions.canViewFinance, isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Up Next', isDark),
                  const SizedBox(height: 16),
                  if (upcomingEvents.isNotEmpty)
                    _buildPremiumEventCard(context, upcomingEvents.first, isDark)
                  else
                    _EmptyBox(text: 'No events on the radar.', isDark: isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Latest Alert', isDark),
                  const SizedBox(height: 16),
                  if (announcements.isNotEmpty)
                    _buildAnnouncementGlassCard(context, announcements.first, isDark)
                  else
                    _EmptyBox(text: 'All clear. No active alerts.', isDark: isDark),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, dynamic tasks, dynamic user, double balance, bool showWallet, bool isDark) {
    final pending = tasks.where((t) => t.assigneeId == user.uid && t.status == TaskStatus.pending).length;
    final active = tasks.where((t) => t.assigneeId == user.uid && t.status == TaskStatus.inProgress).length;

    return Row(
      children: [
        _buildStatTile(context, 'Tasks', '$pending', AppColors.priorityHigh, Icons.checklist_rtl_rounded, isDark),
        const SizedBox(width: 12),
        _buildStatTile(context, 'Active', '$active', AppColors.info, Icons.rocket_launch_rounded, isDark),
        if (showWallet) ...[
          const SizedBox(width: 12),
          _buildStatTile(context, 'Wallet', '₹${(balance / 1000).toStringAsFixed(1)}k', AppColors.primaryGreen, Icons.account_balance_wallet_rounded, isDark, onTap: () => context.go('/wallet')),
        ],
      ],
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, Color color, IconData icon, bool isDark, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05), blurRadius: 15)],
            border: Border.all(color: isDark ? Colors.white10 : color.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 16),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.ink)),
              Text(label, style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlCenter(BuildContext context, bool showStats, bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildActionItem(context, 'New Task', Icons.add_task_rounded, AppColors.primaryGreen, isDark, () => context.go('/tasks')),
          _buildActionItem(context, 'Expense', Icons.receipt_long_rounded, AppColors.ink, isDark, () => context.go('/wallet')),
          _buildActionItem(context, 'Society Vault', Icons.inventory_2_rounded, AppColors.deepAccent, isDark, () => context.push('/vault')),
          if (showStats)
            _buildActionItem(context, 'Analytics', Icons.analytics_rounded, AppColors.priorityMedium, isDark, () => context.push('/analytics')),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    final iconColor = isDark && color == AppColors.ink ? Colors.white : color;
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? Colors.white12 : color.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              textAlign: TextAlign.center, 
              style: GoogleFonts.inter(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white70 : AppColors.ink
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEventCard(BuildContext context, dynamic event, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.03), blurRadius: 20, offset: const Offset(0, 10))],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.event_note_rounded, color: Colors.white),
        ),
        title: Text(event.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : AppColors.ink)),
        subtitle: Text(event.venue, style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.lightGrey),
        onTap: () => context.go('/events'),
      ),
    );
  }

  Widget _buildAnnouncementGlassCard(BuildContext context, dynamic announcement, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightGreen : AppColors.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 25, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Text('PRIORITY ALERT', style: GoogleFonts.inter(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(announcement.title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(announcement.body, style: GoogleFonts.inter(color: Colors.white70, height: 1.6, fontSize: 14), maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20, 
        fontWeight: FontWeight.w900, 
        color: isDark ? Colors.white : AppColors.ink, 
        letterSpacing: -0.5
      ),
    );
  }

  void _showRoleSwitcher(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Switch Chapter View', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 20, color: isDark ? Colors.white : AppColors.ink)),
              const SizedBox(height: 32),
              _buildRoleRow(ref, context, 'President', 'Aditya Raj', 'user-pres', Icons.stars_rounded, isDark),
              _buildRoleRow(ref, context, 'Tech Head', 'Ishaan Sharma', 'user-tech-head', Icons.terminal_rounded, isDark),
              _buildRoleRow(ref, context, 'Marketing', 'Ananya Roy', 'user-marketing-head', Icons.campaign_rounded, isDark),
              _buildRoleRow(ref, context, 'Member', 'Rahul Kumar', 'user-member', Icons.person_rounded, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleRow(WidgetRef ref, BuildContext context, String role, String name, String uid, IconData icon, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1), child: Icon(icon, color: AppColors.primaryGreen, size: 22)),
      title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.ink)),
      subtitle: Text(role, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mediumGrey)),
      onTap: () {
        ref.read(authStateProvider.notifier).switchToUser(uid);
        Navigator.pop(context);
      },
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  final bool isDark;
  const _EmptyBox({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.softGrey, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(color: AppColors.mediumGrey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
