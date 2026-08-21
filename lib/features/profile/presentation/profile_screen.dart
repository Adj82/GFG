import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../../core/mock/mock_data.dart';
import '../../../main.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    final domain = MockData.domains.firstWhere((d) => d.id == user.domainId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Me',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, 
                      fontSize: 20, 
                      color: Colors.white
                    ),
                  ),
                  Text(
                    'Manage your account and preferences',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [AppColors.midnightGreen, Colors.black] 
                      : [AppColors.primaryGreen, AppColors.deepAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGreen, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: isDark ? AppColors.ink : Colors.white,
                          child: const Icon(Icons.person_rounded, size: 60, color: AppColors.primaryGreen),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? Colors.white : AppColors.ink
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      user.roleName.toUpperCase(),
                      style: GoogleFonts.inter(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    'Dark Mode', 
                    'Switch to high-contrast dark theme', 
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    trailing: Switch.adaptive(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeTrackColor: AppColors.primaryGreen,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: 16),
                  _buildInfoTile(context, 'Campus Email', user.email, Icons.alternate_email_rounded, isDark),
                  _buildInfoTile(context, 'Assigned Domain', domain.name, Icons.hub_rounded, isDark),
                  _buildInfoTile(context, 'Account Status', user.status.name.toUpperCase(), Icons.shield_moon_rounded, isDark),
                  
                  const SizedBox(height: 40),
                  if (user.roleName == 'President' || user.roleName == 'Vice President' || user.roleName.contains('Head')) ...[
                    const Divider(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Chapter Management'),
                    const SizedBox(height: 16),
                    _buildAdminButton(
                      context, 
                      'APPROVE PENDING MEMBERS', 
                      Icons.how_to_reg_rounded, 
                      () => context.push('/manage-members'),
                      isDark
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mediumGrey),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: AppColors.mediumGrey, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}
