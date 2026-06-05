import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary Color (Luxury Gold / Lime Gold)
  static const Color primary = Color(0xFFD3D710);
  static const Color primaryLight = Color(0xFFE4E83C);
  static const Color primaryDark = Color(0xFF9E9F00);
  
  // Secondary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Dark Theme Backgrounds (Obsidian and Charcoal)
  static const Color darkBg = Color(0xFF070707);
  static const Color darkCard = Color(0xFF121212);
  static const Color darkCardSelected = Color(0xFF1C1D15);
  static const Color darkOverlay = Color(0x1F000000);
  
  // Light Theme Backgrounds (Alabaster and Soft Warm White)
  static const Color lightBg = Color(0xFFFAF9F6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSelected = Color(0xFFF4F6DF);
  static const Color lightOverlay = Color(0x0F000000);

  // Glassmorphic Overlays (White transparency aur Gold transparency)
  static const Color glassWhite = Color(0x14FFFFFF);      // Frosted White
  static const Color glassGold = Color(0x14D3D710);       // Frosted Gold
  static const Color glassBorderWhite = Color(0x22FFFFFF); // Patla White Border
  static const Color glassBorderGold = Color(0x3FD3D710);  // Patla Gold Border
  
  static const Color glassWhiteLight = Color(0x75FFFFFF);      // Frosted White (Light Mode)
  static const Color glassBorderWhiteLight = Color(0x33000000); // Patla dark Border (Light Mode)
  
  // Text Colors
  static const Color textDarkPrimary = Color(0xFFF5F5F7);   // Taqreeban safaid text
  static const Color textDarkSecondary = Color(0xFFA1A1A5); // Darmiyana grey text
  static const Color textDarkMuted = Color(0xFF6C6C70);     // Gehra grey text
  
  static const Color textLightPrimary = Color(0xFF121212);  // Taqreeban kala text
  static const Color textLightSecondary = Color(0xFF555558); // Darmiyana grey text
  static const Color textLightMuted = Color(0xFF8E8E93);     // Thanda grey text

  // Accent Status Colors
  static const Color success = Color(0xFF34C759); // Premium hara
  static const Color warning = Color(0xFFFF9500); // Premium narangi
  static const Color error = Color(0xFFFF3B30);   // Premium laal
  static const Color info = Color(0xFF5AC8FA);    // Premium halka neela

  // Premium Gradients
  static const Gradient goldGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF121214), Color(0xFF060607)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [Color(0x22FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
