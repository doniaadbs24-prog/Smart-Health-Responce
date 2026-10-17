import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0B3142);
  static const Color primaryDark = Color(0xFF062533);
  static const Color primaryLight = Color(0xFF1A4756);

  static const Color secondary = Color(0xFFA8C5C0);
  static const Color secondaryDark = Color(0xFF7FA8A0);

  static const Color accent = Color(0xFF2BB7B0);

  static const Color background = Color(0xFFF4F2EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEEF1EF);

  static const Color textPrimary = Color(0xFF0B3142);
  static const Color textSecondary = Color(0xFF5C6B72);
  static const Color textTertiary = Color(0xFF9AA5AA);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFD9DEDB);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF2E9E5F);
  static const Color warning = Color(0xFFE0A526);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF3D7FB8);

  static const Color shadow = Color(0x1F0B3142);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
