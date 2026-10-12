import 'package:flutter/material.dart';

/// Palette taken from the mockup: soft teal primary, peach accents,
/// near-white glassy surfaces.
abstract final class AppColors {
  static const primary = Color(0xFF1FB5A8);
  static const primaryDark = Color(0xFF13897F);
  static const primarySoft = Color(0xFFE3F6F4);
  static const accent = Color(0xFFFF8A80);
  static const accentSoft = Color(0xFFFFEDE8);
  static const purple = Color(0xFF9B8AFB);
  static const purpleSoft = Color(0xFFF0EDFF);
  static const amber = Color(0xFFFFB547);
  static const amberSoft = Color(0xFFFFF4E0);

  static const background = Color(0xFFF4FAF9);
  static const surface = Colors.white;
  static const border = Color(0xFFE6EEED);

  static const textPrimary = Color(0xFF1C2B2A);
  static const textSecondary = Color(0xFF6B7C7A);
  static const textMuted = Color(0xFFA3B1AF);

  static const success = Color(0xFF2EBD85);
  static const danger = Color(0xFFF0525B);
  static const star = Color(0xFFFFB800);

  static const onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDDF4F1), Color(0xFFF7FBFB), Color(0xFFFFE9E2)],
  );
}
