import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF205C53);
  static const primaryDark = Color(0xFF173F39);
  static const secondary = Color(0xFFCC9368);
  static const secondaryDark = Color(0xFF8C532F);
  static const success = Color(0xFF37745C);
  static const successDark = Color(0xFF24523F);
  static const error = Color(0xFFB84940);
  static const errorDark = Color(0xFF8D352E);
  static const locked = Color(0xFFE3E3DB);
  static const lockedDark = Color(0xFFB5BCB2);
  static const background = Color(0xFFF7F5EF);
  static const surface = Color(0xFFFFFEFA);
  static const ink = Color(0xFF203B35);
  static const textMuted = Color(0xFF626E64);
  static const line = Color(0xFFDFE3D9);
}

abstract final class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
  );
  static const success = LinearGradient(
    colors: [AppColors.success, AppColors.successDark],
  );
  static const secondary = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );
  static const error = LinearGradient(
    colors: [AppColors.error, AppColors.errorDark],
  );
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A685B), Color(0xFF173F39)],
  );
}

class AppTheme {
  AppTheme._();
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
          .copyWith(
            headlineLarge: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -1.2,
              color: AppColors.ink,
            ),
            headlineSmall: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
            titleLarge: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          )
          .apply(fontFamily: 'Roboto'),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
    );
  }
}
