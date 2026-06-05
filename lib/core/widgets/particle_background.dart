import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({Key? key}) : super(key: key);

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 25 halki particles initialize karein
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2 + 1,
        speed: _random.nextDouble() * 0.02 + 0.005,
        angle: _random.nextDouble() * 2 * pi,
        opacity: _random.nextDouble() * 0.15 + 0.05,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Particles ki position update karein
        for (var p in _particles) {
          p.x += cos(p.angle) * p.speed * 0.01;
          p.y += sin(p.angle) * p.speed * 0.01;

          // Boundary checks
          if (p.x < 0) p.x = 1.0;
          if (p.x > 1) p.x = 0.0;
          if (p.y < 0) p.y = 1.0;
          if (p.y > 1) p.y = 0.0;
        }

        return CustomPaint(
          painter: ParticlePainter(_particles),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double radius;
  double speed;
  double angle;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = AppColors.primary.withOpacity(p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
