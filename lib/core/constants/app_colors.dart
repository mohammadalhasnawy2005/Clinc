import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (من التصميم)
  static const Color primary = Color(0xFF4A9B8E);
  static const Color primaryLight = Color(0xFF6BB6AB);
  static const Color primaryDark = Color(0xFF3A7B6E);

  // Background Colors
  static const Color background = Color(0xFFF8FFFE);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF0F9F8);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderFocus = primary;

  // Shadow Colors
  static const Color shadow = Color(0x0F000000);
  static const Color shadowDark = Color(0x1A000000);

  // Appointment Status Colors
  static const Color pending = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);
  static const Color completed = Color(0xFF6366F1);

  // Subscription Package Colors
  static const Color packageBasic = Color(0xFF6B7280);
  static const Color packageGold = Color(0xFFF59E0B);
  static const Color packageDiamond = Color(0xFF8B5CF6);
  static const Color packagePremium = Color(0xFFEF4444);
}
