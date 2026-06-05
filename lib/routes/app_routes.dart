import 'package:flutter/material.dart';
import '../models/hotel_room.dart';
import '../models/booking.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/room_booking_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/payment/payment_success_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/staff/staff_dashboard.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
  static const String admin = '/admin';
  static const String staff = '/staff';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case register:
        return _fadeRoute(const RegisterScreen(), settings);
      case forgotPassword:
        return _fadeRoute(const ForgotPasswordScreen(), settings);
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      case booking:
        final room = settings.arguments as HotelRoom;
        return _fadeRoute(RoomBookingScreen(room: room), settings);
      case payment:
        return _fadeRoute(const PaymentScreen(), settings);
      case paymentSuccess:
        final bookingObj = settings.arguments as Booking;
        return _fadeRoute(PaymentSuccessScreen(booking: bookingObj), settings);
      case admin:
        return _fadeRoute(const AdminDashboard(), settings);
      case staff:
        return _fadeRoute(const StaffDashboard(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
