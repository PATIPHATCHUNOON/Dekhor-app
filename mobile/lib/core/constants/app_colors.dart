// app_colors.dart — สีหลักของ DekHor

import 'package:flutter/material.dart';

class AppColors {
  // Primary — สีม่วงพาสเทลสดใส
  static const Color primary       = Color(0xFF9D76C1);
  static const Color primaryLight  = Color(0xFFE5D9F2);
  static const Color primaryDark   = Color(0xFF7149C6);

  // Secondary — สีชมพูพาสเทล
  static const Color secondary     = Color(0xFFF6A6FF);
  static const Color secondaryLight= Color(0xFFFFDEE9);

  // Accent — สีเหลืองพาสเทล
  static const Color accent        = Color(0xFFFFFFA9);

  // Neutral — สว่าง สะอาดตา
  static const Color background    = Color(0xFFFDFBFD);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF5C5470);
  static const Color textSecondary = Color(0xFFBFA2DB);
  static const Color border        = Color(0xFFD0BFFF);

  // Semantic — สีพาสเทลสำหรับสถานะต่างๆ
  static const Color success       = Color(0xFFB5EAEA);
  static const Color warning       = Color(0xFFFFD28F);
  static const Color error         = Color(0xFFFFAAA5);
  static const Color info          = Color(0xFF90E0EF);

  // Category สำหรับรายจ่าย (ปรับให้สดใสเป็นพาสเทลทั้งหมด)
  static const Map<String, Color> categoryColors = {
    'food':          Color(0xFFFFAAA5),
    'transport':     Color(0xFF90E0EF),
    'rent':          Color(0xFF9D76C1),
    'entertainment': Color(0xFFFFD28F),
    'health':        Color(0xFFB5EAEA),
    'education':     Color(0xFFF6A6FF),
    'allowance':     Color(0xFFC7F464),
    'other':         Color(0xFFD0BFFF),
  };
}