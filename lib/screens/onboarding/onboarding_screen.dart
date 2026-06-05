import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Exquisite Lakeside Comfort",
      subtitle: "Experience luxury living redefined at SARTE's premier resort destination. We welcome you with high-end suites designed for discerning travelers, executives, and distinguished guests.",
      imageUrl: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80&w=1200",
    ),
    OnboardingData(
      title: "Premium Venues & Events",
      subtitle: "From corporate conferences and private celebrations to family vacations, reserve our fully integrated, automated spaces tailored with state-of-the-art facilities.",
      imageUrl: "https://images.unsplash.com/photo-1517840901100-8179e982acb7?auto=format&fit=crop&q=80&w=1200",
    ),
    OnboardingData(
      title: "First-Class Service & Care",
      subtitle: "Indulge in 24/7 dedicated professional service. Whether ordering in-room dining or customizing room automation, our staff ensures a flawless premium experience.",
      imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=1200",
    ),
  ];

  void _onNextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView ke zariye peeche ki tasveerein (horizontal parallax shift ke sath)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 0.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                  }
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_pages[index].imageUrl),
                        fit: BoxFit.cover,
                        alignment: Alignment(value * 0.5, 0.0), // Parallax ka offset
                      ),
                    ),
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xD9000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              );
            },
          ),

          // Safe Area ka Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Upar wali Row: Brand aur Skip Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SARTE",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 3,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_currentIndex < _pages.length - 1)
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            "SKIP",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.white.withOpacity(0.7),
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),

                  // Neeche ka content: Glassmorphic Information Card
                  FadeSlideTransition(
                    key: ValueKey(_currentIndex),
                    slideOffset: 30,
                    child: GlassCard(
                      opacity: 0.12,
                      blur: 20,
                      borderColor: AppColors.glassBorderWhite,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pages[_currentIndex].title,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _pages[_currentIndex].subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textDarkSecondary,
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Indicator Dots aur Next button ki Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Indicator ke Dots
                              Row(
                                children: List.generate(
                                  _pages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 6),
                                    width: _currentIndex == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentIndex == index
                                          ? AppColors.primary
                                          : AppColors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Touch par bada hone wala Interactive button
                              CustomButton(
                                text: _currentIndex == _pages.length - 1 ? "GET STARTED" : "NEXT",
                                width: 140,
                                height: 48,
                                borderRadius: 12,
                                type: ButtonType.primary,
                                onTap: _onNextPage,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class OnboardingData {
  final String title;
  final String subtitle;
  final String imageUrl;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}
