import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/hotel_room.dart';
import '../../models/booking.dart';
import '../../models/staff_member.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _activePanelIndex = 0; // 0: Overview, 1: Rooms, 2: Staff, 3: Bookings

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      state.fetchAnalyticsFromDb();
      state.fetchBookingsFromDb();
      state.fetchRoomsFromDb();
    });
  }

  void _showAddRoomSheet(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    RoomType selectedType = RoomType.single;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      const Text(
                        "ADD NEW ROOM SUITE",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                      ),
                      const Divider(height: 24, thickness: 0.5),

                      CustomTextField(
                        labelText: "Suite Name",
                        hintText: "Grand Monarch Suite",
                        controller: nameController,
                        validator: (v) => v!.trim().isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              labelText: "Suite Room Number",
                              hintText: "302",
                              controller: numberController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.trim().isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              labelText: "Price per Night (\$)",
                              hintText: "180.00",
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.trim().isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Room ki kism select karna
                      const Text(
                        "ROOM CATEGORY",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: RoomType.values.map((type) {
                            final isSel = selectedType == type;
                            return ScaleTransitionWrapper(
                              onTap: () {
                                setModalState(() {
                                  selectedType = type;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : AppColors.glassWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSel ? AppColors.primary : AppColors.glassBorderWhite),
                                ),
                                child: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? AppColors.black : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        labelText: "Suite Description",
                        hintText: "Describe room amenities, size, views...",
                        controller: descController,
                        validator: (v) => v!.trim().isEmpty ? "Description is required" : null,
                      ),
                      const SizedBox(height: 28),

                      CustomButton(
                        text: "REGISTER ROOM INVENTORY",
                        type: ButtonType.primary,
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            final newRoom = HotelRoom(
                              id: "rm-${100 + state.rooms.length + 1}",
                              name: nameController.text,
                              roomNumber: numberController.text,
                              type: selectedType,
                              pricePerNight: double.tryParse(priceController.text) ?? 150.0,
                              rating: 4.8,
                              reviewsCount: 1,
                              imageUrls: ["https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&q=80&w=800"],
                              amenities: ["King Bed", "High-speed WiFi", "Smart TV", "Lakeside View"],
                              description: descController.text,
                              isAvailable: true,
                            );

                            state.addRoomInDb(newRoom);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.success,
                                content: Text(
                                  "Room Suite added to active hotel inventory.",
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
      },
    );
  }

  void _showStaffPermissionsSheet(BuildContext context, StaffMember staff) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Bunyadi permissions ki list
    final List<String> allPerms = ["Manage Bookings", "Edit Rooms", "Full Admin access", "View customer details", "Room Maintenance Services"];
    List<String> activePerms = List.from(staff.permissions);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Text(
                    "EDIT STAFF PERMISSIONS",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  Text(
                    "Modify rights assigned to: ${staff.name}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 28, thickness: 0.5),

                  ...allPerms.map((perm) {
                    final isChecked = activePerms.contains(perm);
                    return CheckboxListTile(
                      activeColor: AppColors.primary,
                      checkColor: AppColors.black,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        perm,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      value: isChecked,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            activePerms.add(perm);
                          } else {
                            activePerms.remove(perm);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: "COMMIT ACCESS RIGHTS",
                    type: ButtonType.primary,
                    onTap: () {
                      state.updateStaffPermissions(staff.id, activePerms);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text(
                            "Staff permission directives updated.",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleAdminLogout(BuildContext context, AppStateProvider state) {
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
                  "Are you sure you wish to log out from SARTE Admin Deck? You will need to authenticate again.",
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
          "SARTE SECURITY BOARD",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        centerTitle: true,
        actions: [
          // Admin ke liye Logout button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            tooltip: "Log Out",
            onPressed: () => _handleAdminLogout(context, state),
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
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                // Panel Navigate karne wale buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorderWhite),
                    ),
                    child: Row(
                      children: [
                        _panelTab(0, Icons.analytics_outlined, "DECK"),
                        _panelTab(1, Icons.meeting_room_outlined, "ROOMS"),
                        _panelTab(2, Icons.badge_outlined, "STAFF"),
                        _panelTab(3, Icons.receipt_long_outlined, "BOOKS"),
                      ],
                    ),
                  ),
                ),

                // Badalne wale Panels
                Expanded(
                  child: IndexedStack(
                    index: _activePanelIndex,
                    children: [
                      _buildOverviewPanel(state, isDark),
                      _buildRoomsPanel(state, isDark),
                      _buildStaffPanel(state, isDark),
                      _buildBookingsPanel(state, isDark),
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

  Widget _panelTab(int idx, IconData icon, String label) {
    final isSelected = _activePanelIndex == idx;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: ScaleTransitionWrapper(
        onTap: () {
          setState(() {
            _activePanelIndex = idx;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.black : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isSelected ? AppColors.black : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Panel 1: Analytics aur charts Overview
  Widget _buildOverviewPanel(AppStateProvider state, bool isDark) {
    final analytics = state.analytics;
    final totalRevenue = analytics['totalRevenue'] ?? 0.0;
    final occupancyRate = analytics['occupancyRate'] ?? 0;
    final totalBookings = analytics['totalBookings'] ?? 0;
    final totalStaff = analytics['totalStaff'] ?? 0;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Analytics ke grids
        Row(
          children: [
            Expanded(
              child: _analyticCard(
                "TOTAL SECURED",
                "\$${totalRevenue.toStringAsFixed(0)}",
                "+12% seasonal delta",
                Icons.monetization_on_outlined,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _analyticCard(
                "OCCUPANCY RATE",
                "$occupancyRate%",
                "Active occupancy level",
                Icons.hotel_outlined,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _analyticCard(
                "TOTAL BOOKS",
                "$totalBookings Stays",
                "Cumulative reservations",
                Icons.receipt_long_outlined,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _analyticCard(
                "ON-DUTY STAFF",
                "$totalStaff Members",
                "Reception & cleaner roster",
                Icons.badge_outlined,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Revenue Chart (dynamically draw kiya gaya)
        Text(
          "REVENUE PERFORMANCE LINE",
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lakeside Revenue Scales",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text("Active indices based on seasonal trends", style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "WEEKLY",
                      style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Revenue chart banane wala painter
              CustomPaint(
                size: const Size(double.infinity, 120),
                painter: RevenueChartPainter(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Panel 2: Rooms ki list aur Add ka button
  Widget _buildRoomsPanel(AppStateProvider state, bool isDark) {
    return Column(
      children: [
        // Upar wala Action: Room Add karna
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: CustomButton(
            text: "ADD NEW INVENTORY SUITE",
            icon: Icons.add_circle_outline_rounded,
            type: ButtonType.primary,
            height: 48,
            onTap: () => _showAddRoomSheet(context),
          ),
        ),

        // Rooms ki List
        Expanded(
          child: ListView.builder(
            itemCount: state.rooms.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            itemBuilder: (context, index) {
              final room = state.rooms[index];
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        room.imageUrls[0],
                        width: 50,
                        height: 50,
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Room ${room.roomNumber} • \$${room.pricePerNight.toInt()}/night",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Dastiab hai ya nahi badalna
                    Row(
                      children: [
                        Text(
                          room.isAvailable ? "ON BOARD" : "BLOCKED",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: room.isAvailable ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Switch(
                          value: room.isAvailable,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            state.toggleRoomAvailabilityInDb(room.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () {
                            state.deleteRoomInDb(room.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Room deleted from registry.")),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Panel 3: Staff ki list aur permissions
  Widget _buildStaffPanel(AppStateProvider state, bool isDark) {
    return ListView.builder(
      itemCount: state.staffList.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemBuilder: (context, index) {
        final staff = state.staffList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorderWhite),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(staff.imageUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          "${staff.role.displayName} • ${staff.email}",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action button
                  ScaleTransitionWrapper(
                    onTap: () => _showStaffPermissionsSheet(context, staff),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorderGold),
                      ),
                      child: const Text(
                        "SET RIGHTS",
                        style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              
              // Assigned Task
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ASSIGNED TASK: ",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Expanded(
                    child: Text(
                      staff.currentTask,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Permissions List view
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SECURITY RIGHTS: ",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: staff.permissions.map((perm) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            perm,
                            style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Panel 4: Active bookings & approvals
  Widget _buildBookingsPanel(AppStateProvider state, bool isDark) {
    return ListView.builder(
      itemCount: state.bookings.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemBuilder: (context, index) {
        final booking = state.bookings[index];
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
                      booking.room.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Guest: ${booking.guestName} • \$${booking.totalPrice.toInt()}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      "Duration: ${booking.checkIn.day}/${booking.checkIn.month} - ${booking.checkOut.day}/${booking.checkOut.month}",
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action buttons
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: booking.status == BookingStatus.upcoming ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      booking.status.displayName,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: booking.status == BookingStatus.upcoming ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (booking.status == BookingStatus.cancelled)
                    ScaleTransitionWrapper(
                      onTap: () {
                        state.approveBookingInDb(booking.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "RE-APPROVE",
                          style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _analyticCard(String label, String val, String cap, IconData icon, bool isDark) {
    return GlassCard(
      opacity: isDark ? 0.08 : 0.45,
      borderColor: AppColors.glassBorderWhite,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const Icon(Icons.trending_up, color: AppColors.success, size: 14),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 3),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            cap,
            style: const TextStyle(fontSize: 8, color: AppColors.success, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a luxury golden revenue line chart programmatically
class RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw line coordinates
    final Path path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.35, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.65, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.15);

    final Path fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw indicator dots on vertices
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), 4.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.3), 4.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
