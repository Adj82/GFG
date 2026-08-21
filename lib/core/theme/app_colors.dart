import 'package:flutter/material.dart';

class AppColors {
  // GFG Official Brand Colors
  static const Color primaryGreen = Color(0xFF2F8D46);
  static const Color deepAccent = Color(0xFF00895E);
  
  // Dark Mode Palette
  static const Color midnightGreen = Color(0xFF004D40); 
  static const Color darkDeepAccent = Color(0xFF002B20);
  
  // Backgrounds
  static const Color background = Color(0xFFF8F9FA); 
  static const Color darkBackground = Color(0xFF000000);
  
  // Neutrals
  static const Color ink = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF1F3F4);
  
  // Status
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1976D2);

  // Priorities
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityMedium = Color(0xFFFFAB40);
  static const Color priorityLow = Color(0xFF69F0AE);

  static LinearGradient getHeaderGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
        ? [const Color(0xFF001A14), midnightGreen] 
        : [primaryGreen, deepAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getButtonGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
        ? [midnightGreen, darkDeepAccent] 
        : [primaryGreen, deepAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static LinearGradient getNavBarGradient(bool isDark) {
    return LinearGradient(
      colors: isDark 
        ? [const Color(0xFF001A14), const Color(0xFF003D33)] 
        : [primaryGreen, deepAccent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
