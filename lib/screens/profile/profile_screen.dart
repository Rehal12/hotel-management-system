import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../../models/booking.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showEditProfileSheet(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: state.userName);
    final emailController = TextEditingController(text: state.userEmail);
    final phoneController = TextEditingController(text: state.userPhone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            opacity: isDark ? 0.15 : 0.85,
            borderColor: AppColors.glassBorderWhite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "EDIT PROFILE",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  
                  CustomTextField(
                    labelText: "Full Name",
                    hintText: "Alex Rivera",
                    prefixIcon: Icons.person_outline,
                    controller: nameController,
                    validator: (v) => v!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    labelText: "Email Address",
                    hintText: "alex@sarte.com",
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                    validator: (v) => v!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    labelText: "Phone Number",
                    hintText: "+1 (555) 019-2834",
                    prefixIcon: Icons.phone_android_outlined,
                    controller: phoneController,
                    validator: (v) => v!.isEmpty ? "Enter phone" : null,
                  ),
                  const SizedBox(height: 28),
                  
                  CustomButton(
                    text: "UPDATE PROFILE",
                    type: ButtonType.primary,
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        state.updateProfile(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                        );
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text(
                              "Profile details updated.",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            opacity: isDark ? 0.15 : 0.85,
            borderColor: AppColors.glassBorderWhite,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TERMINATE SESSION",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you wish to log out from SARTE Deck? You will need to authenticate again.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "CANCEL",
                        type: ButtonType.glass,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "LOG OUT",
                        type: ButtonType.primary,
                        onTap: () {
                          final state = Provider.of<AppStateProvider>(context, listen: false);
                          state.logout();
                          Navigator.pop(context); // Pop dialog
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

    final int upcomingCount = state.bookings.where((b) => b.status == BookingStatus.upcoming).toList().length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upar ka hissa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "USER PROFILE",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
              ScaleTransitionWrapper(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 12,
                  opacity: isDark ? 0.08 : 0.45,
                  borderColor: AppColors.glassBorderWhite,
                  child: const Icon(Icons.settings_outlined, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Bio ka card
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Avatar, Name, Email ka Card
                GlassCard(
                  opacity: isDark ? 0.08 : 0.45,
                  borderColor: AppColors.glassBorderWhite,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Gold frame ke sath Circular Profile Image
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(state.userProfilePic),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  state.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.userEmail,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.userPhone,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Edit karne wala button
                      ScaleTransitionWrapper(
                        onTap: () => _showEditProfileSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Loyalty aur stay ke counts
                Row(
                  children: [
                    Expanded(
                      child: _statCard("VIP LEVEL", "GOLD STAR", Icons.stars_rounded, isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard("ACTIVE STAYS", "$upcomingCount STAYS", Icons.hotel_class_outlined, isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard("VIP POINTS", "5,400 PTS", Icons.wallet_giftcard_rounded, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 24),


                // General menu ki list
                Text(
                  "HELP & SUPPORT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                const SizedBox(height: 10),
                
                _profileListItem(Icons.security_rounded, "Privacy & Security Options", isDark, () {}),
                _profileListItem(Icons.contact_support_outlined, "Contact Hospitality Desk", isDark, () {}),
                _profileListItem(Icons.receipt_long_rounded, "Billing & Invoices", isDark, () {}),
                _profileListItem(Icons.info_outline_rounded, "SARTE Licensing & Version v1.0", isDark, () {}),
                
                const SizedBox(height: 24),
                
                // Logout karne wala button
                CustomButton(
                  text: "LOG OUT SESSION",
                  type: ButtonType.outlined,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String val, IconData icon, bool isDark) {
    return GlassCard(
      opacity: isDark ? 0.04 : 0.35,
      borderColor: AppColors.glassBorderWhite,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileListItem(IconData icon, String title, bool isDark, VoidCallback onTap) {
    return ScaleTransitionWrapper(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ],
        ),
      ),
    );
  }
}
