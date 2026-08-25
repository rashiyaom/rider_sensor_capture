import 'package:flutter/material.dart';

class AppColors {
  // Pure OLED Dark Palette
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0F0F12);
  static const Color card = Color(0xFF141418);
  static const Color cardElevated = Color(0xFF1B1B20);
  static const Color cardBorder = Color(0xFF24242B);
  
  // Accents
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF5A5A5F);

  // Status & Badges
  static const Color accentGreen = Color(0xFF30D158);
  static const Color accentGreenBg = Color(0x2030D158);
  static const Color accentAmber = Color(0xFFFF9F0A);
  static const Color accentAmberBg = Color(0x20FF9F0A);
  static const Color accentRed = Color(0xFFFF453A);
  static const Color accentRedBg = Color(0x20FF453A);
  static const Color accentCyan = Color(0xFF64D2FF);
  static const Color accentCyanBg = Color(0x2064D2FF);

  // Navigation dock
  static const Color dockBackground = Color(0xF018181C);
  static const Color dockBorder = Color(0x22FFFFFF);
}

class AppStyles {
  // Standard card decoration
  static BoxDecoration cardDecoration({
    Color backgroundColor = AppColors.card,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(22),
      border: border ?? Border.all(color: AppColors.cardBorder, width: 1),
    );
  }

  // Large hero number style (e.g. 363.2k, 17, 329)
  static const TextStyle heroNumber = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );

  // Stat subtitle / label style
  static const TextStyle statLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // Green percentage badge text
  static const TextStyle badgeGreen = TextStyle(
    color: AppColors.accentGreen,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.card,
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.card,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryWhite,
      onPrimary: Colors.black,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.accentRed,
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.cardBorder,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardElevated,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
    ),
  );
}
