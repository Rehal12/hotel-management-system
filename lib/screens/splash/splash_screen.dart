import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pulseScale = Tween<double>(begin: 0.9, end: 1.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) {
      _pulseController.repeat();
    });

    // 3.8 seconds baad Onboarding Screen par khud jana named route ke zariye
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF161712),
              AppColors.darkBg,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pulsating Gold Glow Ring ke sath Luxury Custom Drawn Emblem
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsating gold ambient ki ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value * _pulseOpacity.value,
                      child: Transform.scale(
                        scale: _pulseScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                
                // Main logo ka emblem
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: LuxuryLogoPainter(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Brand ki Typography
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    "S A R T E",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 42,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "LUXURY HOTEL & SUITES",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDarkSecondary,
                          letterSpacing: 4,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Assets ke bina programmatically modern luxury gold emblem banane ke liye Custom Painter
class LuxuryLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint goldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Diamond outline banana
    final Path path = Path()
      ..moveTo(size.width / 2, 0)                  // Upar wala point
      ..lineTo(size.width, size.height / 2)        // Dayen wala point
      ..lineTo(size.width / 2, size.height)        // Neeche wala point
      ..lineTo(0, size.height / 2)                 // Bayen wala point
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, goldPaint);

    // Andar ki details (luxury S shape / geometric folds)
    final Paint innerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path innerPath = Path()
      ..moveTo(size.width / 2, 15)
      ..lineTo(size.width * 0.8, size.height / 2)
      ..lineTo(size.width / 2, size.height - 15)
      ..lineTo(size.width * 0.2, size.height / 2)
      ..close();
    canvas.drawPath(innerPath, innerPaint);

    // Dynamic crown/monogram style ki lines
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.3),
      Offset(size.width / 2, size.height * 0.7),
      innerPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height / 2),
      Offset(size.width * 0.7, size.height / 2),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
