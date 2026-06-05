import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/booking.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../providers/app_state_provider.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Booking booking;

  const PaymentSuccessScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkScale;
  late Animation<double> _ticketHeight;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _ticketHeight = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Peeche ki ambient lights
          if (isDark) ...[
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 100,
                      spreadRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Confetti Gold Particles (musalsal painter ke zariye)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GoldConfettiPainter(progress: _animationController.value),
                );
              },
            ),
          ),

          // Main content ka scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  
                  // Kamyabi ka check icon
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkScale.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.12),
                        border: Border.all(color: AppColors.primary, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Upar wale Texts
                  FadeSlideTransition(
                    slideOffset: 20,
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        Text(
                          "RESERVATION LOCKED",
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 3,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your premium suite check-in keys are secured.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Animate hoti hui virtual ticket
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _ticketHeight,
                        axis: Axis.vertical,
                        axisAlignment: -1.0,
                        child: Opacity(
                          // easeOutBack curve 1.0 se zyada value de sakta hai, isliye clamp karna zaroori hai
                          opacity: _ticketHeight.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: _buildReceiptTicket(context, isDark),
                  ),
                  const SizedBox(height: 40),

                  // Wapas jane ka Button
                  FadeSlideTransition(
                    slideOffset: 10,
                    delay: const Duration(milliseconds: 1200),
                    child: CustomButton(
                      text: "RETURN TO HOME DECK",
                      type: ButtonType.primary,
                      onTap: () {
                        // Sab routes pop karein aur HomeScreen par wapas jayein
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTicket(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderWhite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Room ka Name banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.glassBorderWhite, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.room.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Suite Room ${widget.booking.room.roomNumber} • Floor 5",
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Tareekh ki tafseelat
                Row(
                  children: [
                    Expanded(
                      child: _ticketStat("CHECK-IN DATE", DateFormat('EEE, MMM dd').format(widget.booking.checkIn), isDark),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.glassBorderWhite,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _ticketStat("CHECK-OUT DATE", DateFormat('EEE, MMM dd').format(widget.booking.checkOut), isDark),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 0.5),

                // Mehmaan aur ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ticketStat("GUESTS", "${widget.booking.guestCount} Adults", isDark),
                    _ticketStat("BOOKING KEY", widget.booking.id, isDark, valColor: AppColors.primary),
                  ],
                ),
                const Divider(height: 32, thickness: 0.5),

                // Raqam ki tafseel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ticketStat("PAYMENT METHOD", widget.booking.paymentMethod.toUpperCase(), isDark),
                    _ticketStat("AMOUNT PAID", "\$${widget.booking.totalPrice.toInt()}", isDark, valColor: AppColors.success),
                  ],
                ),
                const Divider(height: 32, thickness: 0.5),

                // Programmatic QR Code mockup
                const Text(
                  "SCAN KEY AT DESK LOBBY",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomPaint(
                  size: const Size(110, 110),
                  painter: MockQRCodePainter(isDark: isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketStat(String label, String val, bool isDark, {Color? valColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }
}

// Luxury golden check/confetti effect banane ke liye Custom Painter
class GoldConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  GoldConfettiPainter({required this.progress})
      : particles = List.generate(35, (index) {
          final random = Random(index);
          return ConfettiParticle(
            x: random.nextDouble() * 400,
            y: random.nextDouble() * 800 - 100,
            speed: random.nextDouble() * 150 + 100,
            radius: random.nextDouble() * 3.5 + 1.5,
            color: index % 2 == 0 ? AppColors.primary : AppColors.white.withOpacity(0.5),
            angle: random.nextDouble() * 2 * pi,
          );
        });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    for (var p in particles) {
      // Animated coordinates ka bahaao calculate karna
      final double dy = p.y + (p.speed * progress);
      final double dx = p.x + (sin(progress * 4 + p.angle) * 20);

      // Sirf frame ke andar ho toh draw karein
      if (dy < size.height && dx < size.width) {
        final Paint paint = Paint()..color = p.color;
        canvas.drawCircle(Offset(dx, dy), p.radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiParticle {
  final double x;
  final double y;
  final double speed;
  final double radius;
  final Color color;
  final double angle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.color,
    required this.angle,
  });
}

// Assets ke bina programmatic QR Code draw karne wala Custom Painter
class MockQRCodePainter extends CustomPainter {
  final bool isDark;
  MockQRCodePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint qrPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    final double squareSize = size.width / 10;

    // Konon ke squares
    _drawAnchor(canvas, 0, 0, squareSize, qrPaint);
    _drawAnchor(canvas, size.width - 3 * squareSize, 0, squareSize, qrPaint);
    _drawAnchor(canvas, 0, size.height - 3 * squareSize, squareSize, qrPaint);

    // Kuch sajawati QR binary pixels draw karna
    final Random random = Random(42); // Seed set ki taake QR code same dikhe
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        // Kone wale anchor coordinates ko chhod dein
        if ((r < 3 && c < 3) || (r < 3 && c >= 7) || (r >= 7 && c < 3)) {
          continue;
        }
        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * squareSize, r * squareSize, squareSize - 1, squareSize - 1),
            qrPaint,
          );
        }
      }
    }
  }

  void _drawAnchor(Canvas canvas, double x, double y, double sq, Paint paint) {
    // Bahar wala square
    canvas.drawRect(Rect.fromLTWH(x, y, 3 * sq, 3 * sq), paint);
    // Andar ka hissa (cutout)
    final Paint cutPaint = Paint()
      ..color = isDark ? AppColors.darkCard : AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x + 0.6 * sq, y + 0.6 * sq, 1.8 * sq, 1.8 * sq), cutPaint);
    // Markazi square
    canvas.drawRect(Rect.fromLTWH(x + 1 * sq, y + 1 * sq, 1.0 * sq, 1.0 * sq), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
