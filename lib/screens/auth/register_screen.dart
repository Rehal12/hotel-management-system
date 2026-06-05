import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/particle_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../providers/app_state_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  String _passwordStrength = "";
  double _strengthValue = 0.0;
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = "";
        _strengthValue = 0.0;
        _strengthColor = Colors.transparent;
      });
      return;
    }

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;

    setState(() {
      if (score <= 2) {
        _passwordStrength = "WEAK PROTOCOL";
        _strengthValue = 0.33;
        _strengthColor = AppColors.error;
      } else if (score <= 4) {
        _passwordStrength = "MEDIUM PROTOCOL";
        _strengthValue = 0.66;
        _strengthColor = AppColors.warning;
      } else {
        _passwordStrength = "STRONG PROTOCOL";
        _strengthValue = 1.0;
        _strengthColor = AppColors.success;
      }
    });
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final state = Provider.of<AppStateProvider>(context, listen: false);
        await state.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          _showSuccessDialog();
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

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            opacity: isDark ? 0.15 : 0.85,
            borderColor: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.1),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated luxury success ka nishan
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(color: AppColors.primary, width: 2.0),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  "WELCOME TO SARTE",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isDark ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2.0,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  "Your premium member account has been registered successfully in our database. Welcome to first-class hospitality.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        height: 1.5,
                        fontSize: 13,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                
                CustomButton(
                  text: "PROCEED TO SIGN IN",
                  type: ButtonType.primary,
                  onTap: () {
                    Navigator.of(context).pop(); // Dialog band karein
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.white : AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Floating Particles ka Background
          if (isDark) const Positioned.fill(child: ParticleBackground()),

          // Peeche ki ambient lights
          if (isDark) ...[
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 90,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand ka Header
                  FadeSlideTransition(
                    slideOffset: 30,
                    delay: const Duration(milliseconds: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CREATE ACCOUNT",
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join SARTE and unlock exclusive luxury lodging experiences.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Registration ka Form
                  FadeSlideTransition(
                    slideOffset: 30,
                    delay: const Duration(milliseconds: 150),
                    child: GlassCard(
                      opacity: isDark ? 0.08 : 0.45,
                      borderColor: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "REGISTRATION FORM",
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.0,
                                  ),
                            ),
                            const SizedBox(height: 20),

                            // Poore Naam ka Field
                            CustomTextField(
                              labelText: "Full Name",
                              hintText: "Rehal Kumar",
                              prefixIcon: Icons.person_outline_rounded,
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your full name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

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
                            const SizedBox(height: 16),

                            // Phone ka Field
                            CustomTextField(
                              labelText: "Phone Number",
                              hintText: "+91 98765 43210",
                              prefixIcon: Icons.phone_android_outlined,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your phone number";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password ka Field
                            CustomTextField(
                              labelText: "Password",
                              hintText: "••••••••",
                              prefixIcon: Icons.lock_outline,
                              controller: _passwordController,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Password ki taqat dikhane wali patti
                            if (_passwordStrength.isNotEmpty) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _strengthValue,
                                        backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                        valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _passwordStrength,
                                    style: TextStyle(
                                      color: _strengthColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ] else ...[
                              const SizedBox(height: 0),
                            ],
                            const SizedBox(height: 16),

                            // Password confirm karne ka Field
                            CustomTextField(
                              labelText: "Confirm Password",
                              hintText: "••••••••",
                              prefixIcon: Icons.lock_clock_outlined,
                              controller: _confirmPasswordController,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please confirm your password";
                                }
                                if (value != _passwordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Jama karne wala button
                            CustomButton(
                              text: "CREATE ACCOUNT",
                              type: ButtonType.primary,
                              isLoading: _isLoading,
                              onTap: _handleRegister,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login par wapas jane ka link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                           "Sign In",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
