import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = "English (US)";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "SETTINGS DECK",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
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
                      spreadRadius: 90,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Theme Settings ka Group
                FadeSlideTransition(
                  slideOffset: 25,
                  delay: const Duration(milliseconds: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "VISUAL EXPERIENCE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: AppColors.glassBorderWhite,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Active Theme",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      isDark ? "Obsidian Dark Mode Active" : "Ice Light Mode Active",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Switch ka button
                            Switch(
                              value: state.themeMode == ThemeMode.dark,
                              activeColor: AppColors.primary,
                              activeTrackColor: AppColors.primary.withOpacity(0.3),
                              onChanged: (val) {
                                state.toggleTheme();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications Settings ka Group
                FadeSlideTransition(
                  slideOffset: 25,
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SYSTEM PREFERENCES",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Notification ki Row
                      GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: AppColors.glassBorderWhite,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 22),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Push Alerts",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          "Receive check-in keys and butler status updates",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _notificationsEnabled,
                                  activeColor: AppColors.primary,
                                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                                  onChanged: (val) {
                                    setState(() {
                                      _notificationsEnabled = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 28, thickness: 0.5),

                            // Language Select karne wala
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.translate_rounded, color: AppColors.primary, size: 22),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Deck Language",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          "App translation and voice butler guides",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                                // Dropdown select karne wala
                                ScaleTransitionWrapper(
                                  onTap: () => _showLanguageSelector(context, isDark),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.glassBorderWhite),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _selectedLanguage,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down, size: 14),
                                      ],
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
                const SizedBox(height: 24),

                // Account Support Settings ka Group
                FadeSlideTransition(
                  slideOffset: 25,
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SECURITY CONTROLS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: AppColors.glassBorderWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            _settingsMenuItem(Icons.vpn_key_outlined, "Modify Account Password", isDark),
                            _settingsMenuItem(Icons.fingerprint_rounded, "Biometric Face ID Authorization", isDark),
                            _settingsMenuItem(Icons.delete_forever_outlined, "Deactivate Hotel Membership", isDark, isCritical: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, bool isDark) {
    final languages = ["English (US)", "Spanish (ES)", "French (FR)", "German (DE)", "Hindi (IN)"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassCard(
          borderRadius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          opacity: isDark ? 0.15 : 0.85,
          borderColor: AppColors.glassBorderWhite,
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
              const Text(
                "SELECT LANGUAGE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
              ),
              const Divider(height: 24, thickness: 0.5),
              
              ...languages.map((lang) {
                final isSel = _selectedLanguage == lang;
                return ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSel ? const Icon(Icons.check, color: AppColors.primary, size: 18) : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _settingsMenuItem(IconData icon, String title, bool isDark, {bool isCritical = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isCritical ? AppColors.error : AppColors.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCritical ? AppColors.error : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
      onTap: () {},
    );
  }
}
