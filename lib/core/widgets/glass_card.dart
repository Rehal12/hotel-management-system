import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final BorderSide? borderSide;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxShadow? boxShadow;

  const GlassCard({
    Key? key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.08,
    this.color,
    this.borderColor,
    this.borderRadius = 24.0,
    this.borderSide,
    this.gradient,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Active theme ke mutabiq munasib background aur border defaults chunein
    final fallbackColor = color ?? 
        (isDark ? AppColors.white.withOpacity(opacity) : AppColors.white.withOpacity(0.65));
        
    final fallbackBorderColor = borderColor ?? 
        (isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: fallbackColor,
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient ?? (isDark ? AppColors.glassGradient : null),
            border: Border.fromBorderSide(
              borderSide ?? BorderSide(color: fallbackBorderColor, width: 0.8),
            ),
            boxShadow: boxShadow != null ? [boxShadow!] : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
