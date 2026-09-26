import 'package:flutter/material.dart';

/// Academic Indigo Palette for Ilmiya SIS
/// A modern, authoritative, and high-contrast theme inspired by elite collegiate
/// platforms and modern SaaS.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Academic Royal Indigo & Sapphire)
  static const Color forestSage = Color(0xFF2563EB); // Royal Indigo primary
  static const Color forestSageDark = Color(0xFF1D4ED8); // Deep Sapphire
  static const Color softKhaki =
      Color(0xFF60A5FA); // Sky Blue secondary / accent
  static const Color warmSand = Color(0xFFEFF6FF); // Soft Ice Blue tint surface
  static const Color warmSandHover = Color(0xFFDBEAFE); // Hover tint

  // Semantic Aliases
  static const Color primary = forestSage;
  static const Color primaryDark = forestSageDark;
  static const Color primaryLight = softKhaki;
  static const Color primarySubtle = warmSand;

  // Accents & Alerts
  static const Color earthyTerra = Color(0xFFE11D48); // Vibrant Rose/Crimson
  static const Color warmAmber = Color(0xFFF59E0B); // Academic Gold / Amber
  static const Color deepForest = Color(0xFF0F172A); // Midnight Slate
  static const Color emeraldSuccess = Color(0xFF10B981); // Crisp Success Green

  // Canvas & Background Surfaces (Light Mode)
  static const Color naturalParchment =
      Color(0xFFF8FAFC); // Clean Cool Slate canvas
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White cards
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Muted slate surface

  // Text & Typography
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate
  static const Color textSecondary = Color(0xFF475569); // Medium Slate
  static const Color textMuted = Color(0xFF94A3B8); // Muted Slate

  // Borders & Dividers
  static const Color borderLight =
      Color(0xFFE2E8F0); // Crisp Hairline Slate border
  static const Color borderMedium = Color(0xFFCBD5E1); // Cool Slate divider

  // Dark Mode Surfaces (Midnight Navy Slate)
  static const Color darkBg = Color(0xFF0B0F19); // Midnight Navy background
  static const Color darkSurface = Color(0xFF111827); // Deep Navy Surface
  static const Color darkCard = Color(0xFF1E293B); // Navy Slate Card
  static const Color darkBorder = Color(0xFF334155); // Subtle Slate Border
}
