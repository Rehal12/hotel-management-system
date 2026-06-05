import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/hotel_room.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../search/search_screen.dart';
import '../booking_history/booking_history_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard.dart';
import '../staff/staff_dashboard.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/room_card_horizontal.dart';
import '../booking/room_booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  // Home dashboard body ke liye selected category filter
  RoomType? _selectedHomeCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

    // Tab bodies ki list
    final List<Widget> _tabBodies = [
      _buildHomeBody(state, isDark),
      const SearchScreen(),
      state.currentUserRole == UserRole.guest 
          ? _buildGuestRestrictionScreen(isDark, "Booking history is only visible to premium registered members.")
          : const BookingHistoryScreen(),
      state.currentUserRole == UserRole.guest 
          ? _buildGuestRestrictionScreen(isDark, "Your premium profile dashboard is restricted. Register an account now.")
          : const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Peeche ki ambient lights
          if (isDark && _currentTabIndex == 0) ...[
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Active Body ka content
          SafeArea(
            child: _tabBodies[_currentTabIndex],
          ),

          // Custom Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              opacity: isDark ? 0.16 : 0.85,
              borderColor: AppColors.glassBorderWhite,
              blur: 20,
              boxShadow: BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
                  _navItem(1, Icons.search_rounded, Icons.search_rounded, "Search"),
                  _navItem(2, Icons.receipt_long_rounded, Icons.receipt_long_outlined, "Bookings"),
                  _navItem(3, Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentTabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransitionWrapper(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dashboard Tab 1 ka Body
  Widget _buildHomeBody(AppStateProvider state, bool isDark) {
    // Current local time ke mutabiq dynamic greeting
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    if (hour >= 17) greeting = "Good Evening";

    // Home categories ke mutabiq featured list ki dynamic filtering
    final List<HotelRoom> featuredRooms = state.rooms.where((room) {
      return _selectedHomeCategory == null || room.type == _selectedHomeCategory;
    }).toList();

    final String displayName = state.currentUserRole == UserRole.guest ? "Guest" : state.userName;

    return RefreshIndicator(
      onRefresh: () async {
        await state.fetchRoomsFromDb();
        if (state.isAuthenticated) {
          await state.fetchBookingsFromDb();
        }
      },
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Upar wala Header: Welcome User aur Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$greeting, $displayName",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.currentUserRole == UserRole.guest 
                          ? "Browse SARTE lodging deck (Guest Mode)."
                          : "SARTE Lakeside Deck is active.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
                
                // VIP badge ya profile avatar
                ScaleTransitionWrapper(
                  onTap: () {
                    setState(() {
                      _currentTabIndex = 3; // Shift to profile
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(state.userProfilePic),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Guest Mode warning ka banner
          if (state.currentUserRole == UserRole.guest)
            Container(
              margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Running in Guest Mode. Register or Sign In to unlock room booking privileges and manage history.",
                      style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      "LOG IN",
                      style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

          // Core Role Dashboards ke gateways (Agar Admin/Staff banners active hon)
          if (state.currentUserRole == UserRole.admin)
            _buildAdminBanner(context, isDark)
          else if (state.currentUserRole == UserRole.staff)
            _buildStaffBanner(context, isDark),

          // Search Bar Mockup (tap karne par Search tab par le jata hai)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = 1; // Direct jump to Search screen
                });
              },
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 16,
                opacity: isDark ? 0.08 : 0.45,
                borderColor: AppColors.glassBorderWhite,
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Search lakeside suites or features...",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.tune_rounded,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Promotional banner ka carousel
          const FadeSlideTransition(
            slideOffset: 20,
            delay: Duration(milliseconds: 100),
            child: BannerCarousel(),
          ),
          const SizedBox(height: 24),

          // Categories Selection ki badging
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "SUITE CATEGORIES",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _categoryChip(null, "All Suites"),
                ...RoomType.values.map(
                  (type) => _categoryChip(type, type.displayName),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured list horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "FEATURED COLLECTIONS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTabIndex = 1; // Jump to search with all
                    });
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 290,
            child: featuredRooms.isEmpty
                ? _buildEmptyCategoryState(isDark)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredRooms.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 24),
                    itemBuilder: (context, index) {
                      final room = featuredRooms[index];
                      return FadeSlideTransition(
                        key: ValueKey(room.id),
                        slideOffset: 30,
                        direction: Axis.horizontal,
                        delay: Duration(milliseconds: index * 100),
                        child: RoomCardHorizontal(room: room),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          
          // Recommended Grid vertical
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "RECOMMENDED RETREATS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(3, state.rooms.length),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return _buildRecommendedCard(context, room, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(RoomType? type, String label) {
    final bool isSelected = _selectedHomeCategory == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransitionWrapper(
      onTap: () {
        setState(() {
          _selectedHomeCategory = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.black
                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, HotelRoom room, bool isDark) {
    return ScaleTransitionWrapper(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomBookingScreen(room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderWhite),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                room.imageUrls[0],
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${room.type.displayName} • Room ${room.roomNumber}",
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${room.pricePerNight.toInt()}",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "/ night",
                  style: TextStyle(fontSize: 8, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Admin Dashboard switch ka overlay banner
  Widget _buildAdminBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: ScaleTransitionWrapper(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminDashboard(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorderGold),
          ),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔐 ADMINISTRATIVE PANEL ACTIVE",
                      style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Text(
                      "Authorized: Open SARTE Admin control deck.",
                      style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Staff Dashboard switch ka overlay banner
  Widget _buildStaffBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: ScaleTransitionWrapper(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StaffDashboard(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💼 STAFF DUTY ASSIGNMENT ACTIVE",
                      style: TextStyle(color: AppColors.info, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Text(
                      "Elena: Open task deck and check-in rosters.",
                      style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.info, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryState(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted, size: 24),
          const SizedBox(height: 8),
          const Text("No suites in this category.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Guest Mode restrictions ke liye Premium lock overlay screen
  Widget _buildGuestRestrictionScreen(bool isDark, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: GlassCard(
          opacity: isDark ? 0.06 : 0.85,
          borderColor: AppColors.glassBorderWhite,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_clock_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "MEMBERSHIP REQUIRED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: isDark ? Colors.grey : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: "SIGN IN / SIGN UP",
                type: ButtonType.primary,
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
