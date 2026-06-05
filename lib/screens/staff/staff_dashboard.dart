import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/booking.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../auth/login_screen.dart';
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).fetchBookingsFromDb();
    });
  }

  // Mock staff ki checklist ke tasks
  final List<HousekeepingTask> _tasks = [
    HousekeepingTask(id: "tk1", roomNumber: "504", desc: "Sanitize Monarch Suite 504 post check-out", priority: "HIGH"),
    HousekeepingTask(id: "tk2", roomNumber: "305", desc: "Refill minibar and espresso capsules in Room 305", priority: "MEDIUM"),
    HousekeepingTask(id: "tk3", roomNumber: "105", desc: "Sanitize workspace desk, restock notebooks Solitude 105", priority: "LOW"),
  ];

  void _approveCheckIn(BuildContext context, Booking booking) async {
    try {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      await state.approveBookingInDb(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              "Check-In Authorized for ${booking.guestName}. Room Key ${booking.room.roomNumber} activated.",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              "Check-In Error: ${e.toString().replaceAll("Exception: ", "")}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  void _handleStaffLogout(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
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
                  "Are you sure you wish to log out from SARTE Staff Deck? You will need to authenticate again.",
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
                          state.logout();
                          Navigator.pop(context); // Dialog band karein
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

    // Staff bookings checklist (upcoming queue) lena
    final pendingQueue = state.bookings.where((b) => b.status == BookingStatus.upcoming).toList();

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
          "SARTE SERVICE DECK",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        centerTitle: true,
        actions: [
          // Staff ke liye Logout button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            tooltip: "Log Out",
            onPressed: () => _handleStaffLogout(context, state),
          ),
          const SizedBox(width: 4),
        ],
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
                      color: AppColors.primary.withOpacity(0.04),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Welcome ka card
                GlassCard(
                  opacity: isDark ? 0.08 : 0.45,
                  borderColor: AppColors.glassBorderWhite,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2.0),
                        ),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage("https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200"),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "Officer Elena Rostova",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.shield_outlined, color: AppColors.primary, size: 14),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Duty Assigned: Reception & Desk Concierge",
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Guest Check-in ki validations
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "DESK ARRIVALS QUEUE (${pendingQueue.length})",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                if (pendingQueue.isEmpty)
                  _buildEmptyState("Arrival Queue Empty", "No guests are currently scheduled for desk verification.", isDark)
                else
                  ...pendingQueue.map((booking) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderWhite),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.guestName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${booking.room.name} • Room ${booking.room.roomNumber}",
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                                Text(
                                  "Arrival ID: ${booking.id} • ${booking.guestCount} Guest(s)",
                                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          
                          // Approve karne wala button
                          ScaleTransitionWrapper(
                            onTap: () => _approveCheckIn(context, booking),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "VALIDATE",
                                style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 24),

                // Section 2: Housekeeping tasks jo assign hue hain
                Text(
                  "LAKESIDE MAINTENANCE CHECKLIST (${_tasks.where((t) => !t.isDone).length})",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
                const SizedBox(height: 10),

                ..._tasks.map((task) {
                  return Opacity(
                    opacity: task.isDone ? 0.6 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderWhite),
                      ),
                      child: Row(
                      children: [
                        Checkbox(
                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,
                          value: task.isDone,
                          onChanged: (val) {
                            setState(() {
                              task.isDone = val ?? false;
                            });
                            
                            if (task.isDone) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  backgroundColor: AppColors.success,
                                  content: Text("Task marked completed."),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Room ${task.roomNumber}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(task.priority).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task.priority,
                                      style: TextStyle(color: _getPriorityColor(task.priority), fontSize: 7, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                task.desc,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String p) {
    if (p == "HIGH") return AppColors.error;
    if (p == "MEDIUM") return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildEmptyState(String t, String desc, bool isDark) {
    return Center(
      child: GlassCard(
        opacity: isDark ? 0.04 : 0.35,
        borderColor: AppColors.glassBorderWhite,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.offline_pin_outlined, color: AppColors.primary, size: 28),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class HousekeepingTask {
  final String id;
  final String roomNumber;
  final String desc;
  final String priority;
  bool isDone;

  HousekeepingTask({
    required this.id,
    required this.roomNumber,
    required this.desc,
    required this.priority,
    this.isDone = false,
  });
}
