import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import '../../../core/mock/mock_data.dart';
import '../../auth/domain/models/user_model.dart';
import '../../auth/presentation/auth_state_provider.dart';

class ManageMembersScreen extends ConsumerStatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  ConsumerState<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends ConsumerState<ManageMembersScreen> {
  late List<SocietyUser> _localUsers;

  @override
  void initState() {
    super.initState();
    _localUsers = List.from(MockData.users);
  }

  void _approveUser(String uid) {
    setState(() {
      _localUsers = [
        for (final u in _localUsers)
          if (u.uid == uid) u.copyWith(status: UserStatus.active) else u
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Member approved successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isCoreTeam = currentUser?.roleName == 'President' || 
                      currentUser?.roleName == 'Vice President' || 
                      (currentUser?.roleName.contains('Head') ?? false);
    
    final List<SocietyUser> pendingUsers;
    
    if (isCoreTeam) {
      pendingUsers = _localUsers.where((u) => u.status == UserStatus.pending && u.roleName == 'Domain Lead').toList();
    } else if (currentUser?.roleName == 'Domain Lead') {
      pendingUsers = _localUsers.where((u) => 
        u.status == UserStatus.pending && 
        u.roleName == 'Member' && 
        u.domainId == currentUser?.domainId
      ).toList();
    } else {
      pendingUsers = [];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          PremiumHeader(
            title: isCoreTeam ? 'Gatekeeping' : 'Membership',
            subtitle: isCoreTeam ? 'Authorize chapter leadership roles' : 'Approve domain member entries',
            expandedHeight: 150,
          ),
          pendingUsers.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final u = pendingUsers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                            child: Icon(u.roleName == 'Domain Lead' ? Icons.stars_rounded : Icons.person_outline_rounded, color: AppColors.primaryGreen),
                          ),
                          title: Text(u.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.ink)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.email, style: GoogleFonts.inter(fontSize: 11, color: AppColors.mediumGrey)),
                              const SizedBox(height: 4),
                              Text('Role: ${u.roleName}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryGreen, letterSpacing: 0.5)),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _approveUser(u.uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('APPROVE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                      );
                    },
                    childCount: pendingUsers.length,
                  ),
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
          Icon(Icons.how_to_reg_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'The gate is clear.',
            style: GoogleFonts.inter(color: Colors.grey[400], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
