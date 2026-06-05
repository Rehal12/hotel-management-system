import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/particle_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../providers/app_state_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpRequested = false;
  bool _successSent = false;
  String _demoOtp = '';

  void _handleRequestOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<AppStateProvider>(context, listen: false);
        final otp = await provider.requestForgotPasswordOTP(_emailController.text.trim());
        
        setState(() {
          _otpRequested = true;
          _demoOtp = otp;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              backgroundColor: AppColors.success,
              content: Text(
                "Demo OTP Code Dispatched: $otp (Copied to Clipboard)",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<AppStateProvider>(context, listen: false);
        await provider.completeResetPassword(
          _emailController.text.trim(),
          _otpController.text.trim(),
          _newPasswordController.text,
        );

        setState(() {
          _successSent = true;
        });
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
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
              right: -80,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "RECOVER ACCESS",
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _otpRequested
                                ? "Enter the 6-digit OTP code received and configure your new secure password."
                                : "Provide your registered email. We will generate and dispatch a secure login verification OTP.",
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

                    FadeSlideTransition(
                      slideOffset: 30,
                      delay: const Duration(milliseconds: 150),
                      child: GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.05),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        child: _successSent
                            ? _buildSuccessUI(isDark)
                            : (_otpRequested ? _buildOTPFormUI() : _buildRequestEmailFormUI()),
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

  Widget _buildRequestEmailFormUI() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "REQUEST DEMO OTP",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
          ),
          const Divider(height: 24, thickness: 0.5),
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
          const SizedBox(height: 24),
          CustomButton(
            text: "DISPATCH RESET OTP",
            type: ButtonType.primary,
            isLoading: _isLoading,
            onTap: _handleRequestOTP,
          ),
        ],
      ),
    );
  }

  Widget _buildOTPFormUI() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ENTER RESET CODE (DEMO: $_demoOtp)",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0, color: AppColors.primary),
          ),
          const Divider(height: 24, thickness: 0.5),
          
          CustomTextField(
            labelText: "6-Digit OTP Code",
            hintText: "123456",
            prefixIcon: Icons.lock_open_rounded,
            controller: _otpController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter the OTP code";
              }
              if (value.trim().length != 6) {
                return "OTP code must be 6 digits";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            labelText: "New Password",
            hintText: "••••••••",
            prefixIcon: Icons.lock_outline,
            controller: _newPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your new password";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          CustomButton(
            text: "RECONCILE PASSWORD",
            type: ButtonType.primary,
            isLoading: _isLoading,
            onTap: _handleResetPassword,
          ),
          const SizedBox(height: 12),
          
          CustomButton(
            text: "RESEND OTP CODE",
            type: ButtonType.glass,
            onTap: () {
              setState(() {
                _otpRequested = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessUI(bool isDark) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withOpacity(0.1),
            border: Border.all(color: AppColors.success, width: 2.0),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "PASSWORD VERIFIED",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2.0),
        ),
        const SizedBox(height: 12),
        Text(
          "Your credential reset is complete. You can now authenticate with your new credentials.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                height: 1.6,
                fontSize: 13,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: "RETURN TO LOGIN",
          type: ButtonType.primary,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
