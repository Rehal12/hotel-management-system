import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/booking.dart';
import '../../models/hotel_room.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  void _showCancellationSheet(BuildContext context, String bookingId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isCancelling = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return GlassCard(
              borderRadius: 30,
              padding: const EdgeInsets.all(24),
              opacity: isDark ? 0.15 : 0.85,
              borderColor: AppColors.glassBorderWhite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  
                  // Warning ka Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withOpacity(0.1),
                      border: Border.all(color: AppColors.error, width: 2.0),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    "CANCEL RESERVATION",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2.0,
                        ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    "Are you absolutely sure you wish to cancel this reservation? This action will immediately release the room back into hotel inventory.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          height: 1.5,
                          fontSize: 12,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "KEEP BOOKING",
                          type: ButtonType.glass,
                          onTap: isCancelling ? null : () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "CONFIRM CANCEL",
                          type: ButtonType.primary,
                          isLoading: isCancelling,
                          onTap: isCancelling
                              ? null
                              : () async {
                                  setState(() {
                                    isCancelling = true;
                                  });
                                  try {
                                    await Provider.of<AppStateProvider>(context, listen: false)
                                        .cancelBookingInDb(bookingId);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.error,
                                          content: const Text(
                                            "Reservation cancelled. Refund has been initiated.",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isCancelling = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.error,
                                          content: Text(
                                            "Failed to cancel: ${e.toString().replaceAll('Exception: ', '')}",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);

    // Bookings ko status ke hisaab se filter karein
    final upcomingBookings = state.bookings.where((b) => b.status == BookingStatus.upcoming).toList();
    final completedBookings = state.bookings.where((b) => b.status == BookingStatus.completed).toList();
    final cancelledBookings = state.bookings.where((b) => b.status == BookingStatus.cancelled).toList();

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upar ka Header
            Text(
              "MY BOOKINGS",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              "Track your upcoming stays, historical lists, and receipt logs.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Tabs chunne wale
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
                ),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.black,
                unselectedLabelColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                tabs: const [
                  Tab(text: "UPCOMING"),
                  Tab(text: "PAST"),
                  Tab(text: "CANCELLED"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab ke andar ki cheezein
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingsList(context, upcomingBookings, BookingStatus.upcoming, isDark),
                  _buildBookingsList(context, completedBookings, BookingStatus.completed, isDark),
                  _buildBookingsList(context, cancelledBookings, BookingStatus.cancelled, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<Booking> list, BookingStatus status, bool isDark) {
    if (list.isEmpty) {
      return Center(
        child: FadeSlideTransition(
          slideOffset: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "No ${status.displayName} Bookings",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                "You do not have reservations in this category.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        final booking = list[index];
        return FadeSlideTransition(
          key: ValueKey(booking.id),
          slideOffset: 25,
          delay: Duration(milliseconds: index * 50),
          child: _buildBookingCard(context, booking, isDark),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card ke andar ka header: Room ki tafseel aur status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.room.imageUrls[0],
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.room.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.room.type.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getStatusColor(booking.status), width: 0.5),
                            ),
                            child: Text(
                              booking.status.displayName.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(booking.status),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "ID: ${booking.id}",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),

          // Reservation ki tafseelat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bookingStat("CHECK-IN", DateFormat('MMM dd, yyyy').format(booking.checkIn), isDark),
                _bookingStat("CHECK-OUT", DateFormat('MMM dd, yyyy').format(booking.checkOut), isDark),
                _bookingStat("TOTAL COST", "\$${booking.totalPrice.toInt()}", isDark, valueColor: AppColors.primary),
              ],
            ),
          ),

          // Agar aane wala hai toh Action row
          if (booking.status == BookingStatus.upcoming) ...[
            const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Via ${booking.paymentMethod}",
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Cancel karne ka button
                  ScaleTransitionWrapper(
                    onTap: () => _showCancellationSheet(context, booking.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 0.5),
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookingStat(String label, String val, bool isDark, {Color? valueColor}) {
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
        const SizedBox(height: 3),
        Text(
          val,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return AppColors.info;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }
}
