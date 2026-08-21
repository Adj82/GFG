import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import 'announcements_notifier.dart';
import 'widgets/post_announcement_sheet.dart';
import '../../../core/services/permissions_service.dart';
import '../../../core/mock/mock_data.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsServiceProvider);
    final user = ref.watch(permissionsServiceProvider).user;
    final announcements = ref.watch(filteredAnnouncementsProvider(user?.domainId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canPost = permissions.canPostGlobalAnnouncement || permissions.canPostDomainAnnouncement;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const PremiumHeader(
            title: 'Broadcast Hub',
            subtitle: 'Official society alerts and updates',
            expandedHeight: 160,
          ),
          announcements.isEmpty 
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnnouncementCard(context, announcements[index], isDark),
                    childCount: announcements.length,
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: canPost ? FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PostAnnouncementSheet(),
          );
        },
        backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
        elevation: 10,
        icon: const Icon(Icons.bolt_rounded, color: Colors.white),
        label: Text('DISPATCH ALERT', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, dynamic a, bool isDark) {
    final isGlobal = a.domainId == null;
    final domainName = isGlobal ? 'GLOBAL BROADCAST' : '${MockData.domains.firstWhere((d) => d.id == a.domainId).name.toUpperCase()} DOMAIN';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isGlobal ? (isDark ? Colors.white12 : AppColors.ink) : AppColors.primaryGreen,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                const Icon(Icons.public_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 10),
                Text(
                  domainName,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
                ),
                const Spacer(),
                Text(
                  DateFormat('hh:mm a').format(a.createdAt),
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? Colors.white : AppColors.ink, height: 1.2),
                ),
                const SizedBox(height: 12),
                Text(
                  a.body,
                  style: GoogleFonts.inter(color: isDark ? Colors.white70 : AppColors.mediumGrey, height: 1.6, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Divider(color: isDark ? Colors.white10 : null),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.postedBy, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : AppColors.ink)),
                        Text('Core Team Authority', style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.cell_tower_rounded, size: 60, color: AppColors.lightGrey),
          ),
          const SizedBox(height: 24),
          Text(
            'Frequency is Silent',
            style: GoogleFonts.plusJakartaSans(color: AppColors.mediumGrey, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'No broadcasts found for your domain.',
            style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
