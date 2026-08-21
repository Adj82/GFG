import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import 'vault_notifier.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(vaultProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const PremiumHeader(
            title: 'Society Vault',
            subtitle: 'Secure repository for society assets',
            expandedHeight: 160,
          ),
          resources.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final res = resources[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: isDark ? Border.all(color: Colors.white10) : Border.all(color: Colors.grey[100]!),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getTypeColor(res.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(_getTypeIcon(res.type), color: _getTypeColor(res.type), size: 24),
                            ),
                            title: Text(res.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.ink)),
                            subtitle: Text('${res.type} • ${(res.sizeKb / 1024).toStringAsFixed(1)} MB', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mediumGrey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.cloud_download_rounded, color: AppColors.primaryGreen),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Initiating safe download...'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.ink,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  )
                                );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: resources.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
        child: const Icon(Icons.upload_file_rounded, color: Colors.white),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Icons.description_rounded;
      case 'PNG':
      case 'JPG': return Icons.image_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Colors.redAccent;
      case 'PNG': return Colors.blueAccent;
      default: return AppColors.mediumGrey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'The vault is empty.',
            style: GoogleFonts.inter(color: Colors.grey[400], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
