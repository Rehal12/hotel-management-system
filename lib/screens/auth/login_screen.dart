import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/particle_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../providers/app_state_provider.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<AppStateProvider>(context, listen: false);
        await provider.login(_emailController.text.trim(), _passwordController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                "Authentication Verified. Welcome to SARTE.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );

          // Role ke hisaab se direct redirection!
          final role = provider.currentUserRole;
          if (role == UserRole.admin) {
            Navigator.of(context).pushNamedAndRemoveUntil('/admin', (route) => false);
          } else if (role == UserRole.staff) {
            Navigator.of(context).pushNamedAndRemoveUntil('/staff', (route) => false);
          } else {
            _navigateToHome();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                e.toString().replaceAll("Exception: ", ""),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleGuestLogin() {
    Provider.of<AppStateProvider>(context, listen: false).enterGuestMode();
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Floating Particles ka Background
          if (isDark) const Positioned.fill(child: ParticleBackground()),
          
          // Peeche ki ambient lights
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 80,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Scroll hone wala layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo/Header ka hissa
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SARTE",
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Welcome back. Please sign in to experience world-class luxury hospitality.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Glassmorphic Card ke andar Login form
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 250),
                      child: GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.05),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SIGN IN",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Email ka Field
                              CustomTextField(
                                labelText: "Email Address",
                                hintText: "rehal@gmail.com",
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter your email address";
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password ka Field
                              CustomTextField(
                                labelText: "Password",
                                hintText: "••••••••",
                                prefixIcon: Icons.lock_outline,
                                controller: _passwordController,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password bhoolne ka link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Premium login ka button
                              CustomButton(
                                text: "AUTHENTICATE",
                                type: ButtonType.primary,
                                isLoading: _isLoading,
                                onTap: _handleLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Testing aur Guest logins ke liye Quick Role Selection options
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 350),
                      child: Column(
                        children: [
                          // Guest Login ka button
                          CustomButton(
                            text: "CONTINUE AS GUEST",
                            type: ButtonType.glass,
                            isLoading: _isLoading,
                            onTap: _handleGuestLogin,
                          ),
                          const SizedBox(height: 20),

                          // Or ka separator
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "OR CONNECT WITH",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Logins (Google, Apple, Facebook ke buttons)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialIcon(FontAwesomeIcons.google, () {}),
                              const SizedBox(width: 16),
                              _socialIcon(FontAwesomeIcons.apple, () {}),
                              const SizedBox(width: 16),
                              _socialIcon(FontAwesomeIcons.facebookF, () {}),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Account banane ka Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(FaIconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
          ),
        ),
        alignment: Alignment.center,
        child: FaIcon(
          icon,
          size: 20,
          color: isDark ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}
