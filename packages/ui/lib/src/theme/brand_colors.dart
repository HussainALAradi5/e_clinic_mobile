import 'package:flutter/material.dart';

/// Brand tokens — the same values as the web theme: deep pine on a cool off-white, one warm accent (sun).
abstract final class BrandColors {
  static const pine = Color(0xFF0B5D57);
  static const pineDeep = Color(0xFF073C39);
  static const mint = Color(0xFFD3EFE9);
  static const sun = Color(0xFFF2B544);

  static final light = ColorScheme.fromSeed(seedColor: pine).copyWith(
    primary: pine,
    onPrimary: Colors.white,
    primaryContainer: mint,
    onPrimaryContainer: const Color(0xFF06302C),
    secondaryContainer: const Color(0xFFE6F2EF),
    onSecondaryContainer: const Color(0xFF0E2B28),
    tertiary: const Color(0xFF8A5A00),
    tertiaryContainer: const Color(0xFFFFE7B8),
    onTertiaryContainer: const Color(0xFF3D2A00),
    surface: const Color(0xFFF4F7F6),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFAFCFB),
    surfaceContainer: const Color(0xFFEEF3F1),
    surfaceContainerHigh: const Color(0xFFE5EDEA),
    surfaceContainerHighest: const Color(0xFFDBE6E2),
    onSurface: const Color(0xFF10201E),
    onSurfaceVariant: const Color(0xFF566865),
    outline: const Color(0xFF7D8F8B),
    outlineVariant: const Color(0xFFDBE4E1),
  );

  static final dark = ColorScheme.fromSeed(seedColor: pine, brightness: Brightness.dark).copyWith(
    primary: const Color(0xFF7FD3C5),
    onPrimary: const Color(0xFF00201C),
    primaryContainer: const Color(0xFF0D4A45),
    onPrimaryContainer: const Color(0xFFC6F0E8),
    secondaryContainer: const Color(0xFF1D3532),
    onSecondaryContainer: const Color(0xFFCFE7E2),
    tertiary: sun,
    tertiaryContainer: const Color(0xFF4A3500),
    onTertiaryContainer: const Color(0xFFFFE7B8),
    surface: const Color(0xFF0D1312),
    surfaceContainerLowest: const Color(0xFF0A0F0E),
    surfaceContainerLow: const Color(0xFF121A19),
    surfaceContainer: const Color(0xFF162020),
    surfaceContainerHigh: const Color(0xFF1D2827),
    surfaceContainerHighest: const Color(0xFF26312F),
    onSurface: const Color(0xFFE0E9E7),
    onSurfaceVariant: const Color(0xFFA7B7B4),
    outline: const Color(0xFF84958F),
    outlineVariant: const Color(0xFF2C3836),
  );
}
