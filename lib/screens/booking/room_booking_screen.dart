import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/hotel_room.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../payment/payment_screen.dart';

class RoomBookingScreen extends StatefulWidget {
  final HotelRoom room;

  const RoomBookingScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  int _activeImageIndex = 0;
  bool _isDescriptionExpanded = false;

  void _selectDates() async {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: state.checkInDate,
        end: state.checkOutDate,
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: AppColors.black,
                    surface: AppColors.darkCard,
                    onSurface: AppColors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryDark,
                    onPrimary: AppColors.white,
                    surface: AppColors.lightCard,
                    onSurface: AppColors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      state.setDates(picked.start, picked.end);
    }
  }

  void _handleBookNow() {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    if (state.currentUserRole == UserRole.guest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            "Guest users cannot reserve suites. Please sign in or register.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }
    
    state.selectRoomForBooking(widget.room);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PaymentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

    // Total din aur price calculate karna
    final int stayDays = state.checkOutDate
        .difference(state.checkInDate)
        .inDays;
    final double totalPrice =
        widget.room.pricePerNight * (stayDays <= 0 ? 1 : stayDays);

    return Scaffold(
      body: Stack(
        children: [
          // Scroll hone wali Room ki Details
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Image Carousel ka Stack
                Stack(
                  children: [
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        itemCount: widget.room.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _activeImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: index == 0
                                ? 'room-img-${widget.room.id}'
                                : 'room-img-carousel-$index',
                            child: Image.network(
                              widget.room.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),

                    // Neeche dark linear overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Color(0xD9000000),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Custom Indicator ke Dots
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.room.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _activeImageIndex == index ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _activeImageIndex == index
                                  ? AppColors.primary
                                  : AppColors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Specs aur Description ka Content Panel
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title aur Reviews
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.room.name,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Rating ka Badge
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.room.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Room ki kism aur Room Number
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.glassBorderGold,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              widget.room.type.displayName.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Room Number: ${widget.room.roomNumber}",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 32,
                        thickness: 0.5,
                        color: AppColors.glassBorderWhite,
                      ),

                      // Premium Date aur Guest Selection ka Frame
                      Text(
                        "RESERVATION DETAILS",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Check-in / Checkout Select karne wala Card
                      GestureDetector(
                        onTap: _selectDates,
                        child: GlassCard(
                          opacity: isDark ? 0.08 : 0.45,
                          borderColor: AppColors.glassBorderWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CHECK-IN  👉  CHECK-OUT",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: isDark
                                            ? AppColors.textDarkMuted
                                            : AppColors.textLightMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${DateFormat('MMM dd, yyyy').format(state.checkInDate)}  -  ${DateFormat('MMM dd, yyyy').format(state.checkOutDate)}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_calendar_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Guest Select karne wala Card
                      GlassCard(
                        opacity: isDark ? 0.08 : 0.45,
                        borderColor: AppColors.glassBorderWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "GUEST CAPACITY",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: isDark
                                          ? AppColors.textDarkMuted
                                          : AppColors.textLightMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${state.guestCount} Guest${state.guestCount > 1 ? 's' : ''}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ScaleTransitionWrapper(
                                  onTap: () {
                                    if (state.guestCount > 1) {
                                      state.setGuestCount(state.guestCount - 1);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.glassBorderWhite,
                                      ),
                                    ),
                                    child: const Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ScaleTransitionWrapper(
                                  onTap: () {
                                    if (state.guestCount < 5) {
                                      state.setGuestCount(state.guestCount + 1);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.glassBorderWhite,
                                      ),
                                    ),
                                    child: const Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 40,
                        thickness: 0.5,
                        color: AppColors.glassBorderWhite,
                      ),

                      // Room ki Amenities ka Section
                      Text(
                        "PREMIUM AMENITIES",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.room.amenities.map((amenity) {
                          return GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            borderRadius: 12,
                            opacity: isDark ? 0.04 : 0.35,
                            borderColor: AppColors.glassBorderWhite,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.brightness_5_rounded,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  amenity,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.textDarkPrimary
                                            : AppColors.textLightPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(
                        height: 40,
                        thickness: 0.5,
                        color: AppColors.glassBorderWhite,
                      ),

                      // Description ka Section
                      Text(
                        "SUITE DESCRIPTION",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Text(
                          widget.room.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 13,
                                height: 1.6,
                                color: isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary,
                              ),
                          maxLines: _isDescriptionExpanded ? null : 4,
                          overflow: _isDescriptionExpanded
                              ? TextOverflow.clip
                              : TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          _isDescriptionExpanded ? "Read Less" : "Read More...",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Sticky bottom bar ke liye spacing
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Top Navigation Bar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScaleTransitionWrapper(
                  onTap: () => Navigator.of(context).pop(),
                  child: GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    opacity: 0.2,
                    blur: 12,
                    borderColor: AppColors.glassBorderWhite,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                ScaleTransitionWrapper(
                  onTap: () {},
                  child: GlassCard(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 14,
                    opacity: 0.2,
                    blur: 12,
                    borderColor: AppColors.glassBorderWhite,
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Premium GlassCard ke sath Sticky Bottom Booking Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassCard(
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              opacity: isDark ? 0.15 : 0.85,
              borderColor: Colors.transparent,
              borderSide: BorderSide.none,
              blur: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOTAL COST (${stayDays <= 0 ? 1 : stayDays} NIGHT${stayDays > 1 ? 'S' : ''})",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isDark
                                ? AppColors.textDarkMuted
                                : AppColors.textLightMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "\$${totalPrice.toInt()}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Taxes incl.",
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: "RESERVE SUITE",
                    width: 170,
                    height: 52,
                    type: ButtonType.primary,
                    onTap: _handleBookNow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
