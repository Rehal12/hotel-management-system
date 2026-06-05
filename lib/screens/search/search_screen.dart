import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/hotel_room.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/animations/fade_slide_transition.dart';
import '../../core/animations/scale_transition_wrapper.dart';
import '../../providers/app_state_provider.dart';
import '../booking/room_booking_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppStateProvider>(context, listen: false);
    _searchController.text = state.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final state = Provider.of<AppStateProvider>(context);

            return GlassCard(
              borderRadius: 30,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              opacity: isDark ? 0.12 : 0.85,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FILTER SEARCH",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          state.resetFilters();
                          setModalState(() {});
                        },
                        child: const Text(
                          "RESET ALL",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 0.5),

                  // Room ki kism select karna
                  const Text(
                    "ROOM TYPE",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _typeChip(null, "All Suites", state, setModalState),
                        ...RoomType.values.map(
                          (type) => _typeChip(type, type.displayName, state, setModalState),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Price Range select karne wala
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "MAX COST PER NIGHT",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      Text(
                        "\$${state.maxPriceFilter.toInt()}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.maxPriceFilter,
                    min: 50.0,
                    max: 600.0,
                    divisions: 11,
                    label: "\$${state.maxPriceFilter.toInt()}",
                    onChanged: (val) {
                      state.updateMaxPrice(val);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  // Rating ke Filters
                  const Text(
                    "MINIMUM RATING",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final double ratingValue = index + 1.0;
                      final bool isSelected = state.ratingFilter == ratingValue;
                      return ScaleTransitionWrapper(
                        onTap: () {
                          state.updateRatingFilter(state.ratingFilter == ratingValue ? 0.0 : ratingValue);
                          setModalState(() {});
                        },
                        child: Container(
                          width: 52,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.12)
                                : (isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08)),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: isSelected ? AppColors.primary : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),

                  // Apply karne wala button
                  CustomButton(
                    text: "APPLY FILTERS",
                    type: ButtonType.primary,
                    onTap: () {
                      Navigator.pop(context);
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

  Widget _typeChip(RoomType? type, String label, AppStateProvider state, StateSetter setModalState) {
    final bool isSelected = state.selectedTypeFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransitionWrapper(
      onTap: () {
        state.updateTypeFilter(type);
        setModalState(() {});
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = Provider.of<AppStateProvider>(context);
    final results = state.filteredRooms;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upar wala title
          Text(
            "FIND SUITES",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            "Search and customize filters to lock your premium stay.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Search input aur Filter trigger ki row
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  opacity: isDark ? 0.08 : 0.45,
                  borderColor: AppColors.glassBorderWhite,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      state.updateSearchQuery(val);
                    },
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: "Search suites or details...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Filter drawer kholne wala button
              ScaleTransitionWrapper(
                onTap: () => _showFilterDrawer(context),
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassWhite : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.glassBorderWhite : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.tune_rounded,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search results ki summary ka text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SEARCH RESULTS (${results.length})",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              if (state.searchQuery.isNotEmpty ||
                  state.selectedTypeFilter != null ||
                  state.ratingFilter > 0.0)
                GestureDetector(
                  onTap: () {
                    state.resetFilters();
                    _searchController.clear();
                  },
                  child: const Text(
                    "Clear Filters",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Search results ki scroll hone wali list
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: results.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      final room = results[index];
                      return FadeSlideTransition(
                        key: ValueKey(room.id),
                        slideOffset: 25,
                        delay: Duration(milliseconds: index * 50),
                        child: _buildResultCard(context, room, isDark),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, HotelRoom room, bool isDark) {
    return ScaleTransitionWrapper(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomBookingScreen(room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bayen taraf: Room ki tasveer
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: Hero(
                tag: 'room-img-${room.id}',
                child: Image.network(
                  room.imageUrls[0],
                  width: 110,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dayen taraf: Maloomat
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.type.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " / night",
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                        // Rating ka nishan
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              room.rating.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
                Icons.search_off_rounded,
                size: 40,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Suites Found",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              "Adjust price scales, room categories, or search terms.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
