import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../animations/scale_transition_wrapper.dart';

enum ButtonType {
  primary,   // Golden Luxury Bhara hua
  secondary, // White/Black Bhara hua
  outlined,  // Golden Border, transparent background
  glass,     // Translucent glass card border button
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final ButtonType type;
  final IconData? icon;
  final IconData? suffixIcon;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    this.onTap,
    this.type = ButtonType.primary,
    this.icon,
    this.suffixIcon,
    this.height = 54.0,
    this.width,
    this.borderRadius = 16.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransitionWrapper(
      onTap: (onTap == null || isLoading) ? null : onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1.0,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: _buildDecoration(context, isDark),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: _getTextColor(context, isDark)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: _getTextColor(context, isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(suffixIcon, size: 18, color: _getTextColor(context, isDark)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isDark) {
    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: isDark ? AppColors.white : AppColors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case ButtonType.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.primary, width: 1.5),
        );
      case ButtonType.glass:
        return BoxDecoration(
          color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
            width: 1.0,
          ),
        );
    }
  }

  Color _getTextColor(BuildContext context, bool isDark) {
    switch (type) {
      case ButtonType.primary:
        return AppColors.black;
      case ButtonType.secondary:
        return isDark ? AppColors.black : AppColors.white;
      case ButtonType.outlined:
        return AppColors.primary;
      case ButtonType.glass:
        return isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    }
  }
}
