import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import '../../auth/presentation/auth_state_provider.dart';
import 'events_notifier.dart';
import 'widgets/create_event_sheet.dart';
import '../../../core/services/permissions_service.dart';
import 'widgets/event_qr_view.dart';
import '../../attendance/presentation/scanner_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(upcomingEventsProvider);
    final user = ref.watch(currentUserProvider);
    final permissions = ref.watch(permissionsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canCreate = permissions.canPostGlobalAnnouncement || permissions.canPostDomainAnnouncement;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const PremiumHeader(
            title: 'Society Timeline',
            subtitle: 'Upcoming chapter events and meetups',
            expandedHeight: 160,
          ),
          events.isEmpty
              ? SliverFillRemaining(child: _buildEmptyEvents())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildEventCard(context, ref, events[index], user, canCreate, isDark),
                      childCount: events.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: canCreate ? FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CreateEventSheet(),
          );
        },
        backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text(
          'PLAN EVENT',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
      ) : null,
    );
  }

  Widget _buildEventCard(BuildContext context, WidgetRef ref, dynamic event, dynamic user, bool canCreate, bool isDark) {
    final isRsvped = event.rsvpUserIds.contains(user?.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen.withValues(alpha: 0.8), AppColors.deepAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.event_available_rounded, size: 120, color: Colors.white),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(event.date).toUpperCase(),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.primaryGreen),
                      ),
                      Text(
                        DateFormat('dd').format(event.date),
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : AppColors.ink),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.mediumGrey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('hh:mm a').format(event.date),
                      style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.mediumGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  event.description,
                  style: GoogleFonts.inter(color: isDark ? Colors.white70 : AppColors.darkGrey, height: 1.5, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (user != null) {
                            ref.read(eventsProvider.notifier).toggleRsvp(event.id, user.uid);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRsvped ? AppColors.ink : AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          isRsvped ? 'CANCEL RSVP' : 'RSVP NOW',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (canCreate)
                      _buildIconButton(Icons.qr_code_rounded, isDark, () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EventQRView(event: event),
                        );
                      })
                    else if (isRsvped)
                      _buildIconButton(Icons.qr_code_scanner_rounded, isDark, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerScreen(eventId: event.id)));
                      }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      '${event.rsvpUserIds.length} members are joining',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryGreen),
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

  Widget _buildIconButton(IconData icon, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: isDark ? Colors.white : AppColors.primaryGreen, size: 20),
      ),
    );
  }

  Widget _buildEmptyEvents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'The timeline is clear.',
            style: GoogleFonts.inter(color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
