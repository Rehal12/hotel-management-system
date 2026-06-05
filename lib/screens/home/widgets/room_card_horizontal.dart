import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/hotel_room.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/animations/scale_transition_wrapper.dart';
import '../../booking/room_booking_screen.dart';

class RoomCardHorizontal extends StatelessWidget {
  final HotelRoom room;

  const RoomCardHorizontal({
    Key? key,
    required this.room,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransitionWrapper(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomBookingScreen(room: room),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 18, bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? AppColors.darkCard : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tasweer ka Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Hero(
                    tag: 'room-img-${room.id}',
                    child: Image.network(
                      room.imageUrls[0],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Rating ka Badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 12,
                    opacity: 0.25,
                    blur: 10,
                    borderColor: AppColors.glassBorderWhite,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Room ki Qism ka Badge
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 12,
                    opacity: 0.25,
                    blur: 10,
                    borderColor: AppColors.glassBorderWhite,
                    child: Text(
                      room.type.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Text ki Maloomat
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.door_sliding_outlined,
                        size: 13,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Suite ${room.roomNumber}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "\$${room.pricePerNight.toInt()}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            " / night",
                            style: TextStyle(
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: isDark ? AppColors.primary : AppColors.primaryDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
