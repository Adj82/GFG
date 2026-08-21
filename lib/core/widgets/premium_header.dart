import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final Widget? bottom;
  final double expandedHeight;

  const PremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
    this.bottom,
    this.expandedHeight = 140, 
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      elevation: 0,
      stretch: true,
      toolbarHeight: 56, // Standardized
      backgroundColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(
          left: 20, 
          bottom: bottom != null ? 56 : 14, // Tighter padding
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: BoxDecoration(gradient: AppColors.getHeaderGradient(isDark))),
            // Center Aligned Logo-style Watermark
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  'GFG',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -12, // Mimicking logo compaction
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: actions,
      bottom: bottom != null ? PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: bottom!,
      ) : null,
    );
  }
}
