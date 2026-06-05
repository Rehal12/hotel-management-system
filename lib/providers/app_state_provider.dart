import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hotel_room.dart';
import '../models/booking.dart';
import '../models/staff_member.dart';
import '../services/api_service.dart';

enum UserRole {
  guest,
  member,
  staff,
  admin,
}

class AppStateProvider extends ChangeNotifier {
  // Loading indicators (Loading dikhane wale variables)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Theme Mode (App ka theme color)
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Active User Token aur Profile Settings
  String _token = "";
  String get token => _token;
  bool get isAuthenticated => _token.isNotEmpty;

  UserRole _currentUserRole = UserRole.guest;
  UserRole get currentUserRole => _currentUserRole;

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  String _userName = "Guest User";
  String get userName => _userName;
  
  String _userEmail = "";
  String get userEmail => _userEmail;

  String _userPhone = "";
  String get userPhone => _userPhone;

  String _userProfilePic = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=300";
  String get userProfilePic => _userProfilePic;

  // Active Rooms aur Bookings ki Lists
  List<HotelRoom> _rooms = [];
  List<HotelRoom> get rooms => _rooms;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  // Naye Alert Notifications, Audit logs aur Analytics states
  List<dynamic> _notifications = [];
  List<dynamic> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).length;

  List<dynamic> _auditLogs = [];
  List<dynamic> get auditLogs => _auditLogs;

  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> get analytics => _analytics;

  // Constructor: Session initialize karein aur rooms fetch karein
  AppStateProvider() {
    initializeState();
  }

  // Session data ko shuru karna aur rooms fetch karna
  Future<void> initializeState() async {
    setLoading(true);
    try {
      await fetchRoomsFromDb();
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token') ?? "";

      if (savedToken.isNotEmpty) {
        _token = savedToken;
        await loadUserProfile();
      } else {
        _currentUserRole = UserRole.guest;
      }
    } catch (e) {
      debugPrint("Error initializing AppStateProvider: $e");
      _currentUserRole = UserRole.guest;
    } finally {
      setLoading(false);
    }
  }

  // Token se user profile load karna
  Future<void> loadUserProfile() async {
    if (_token.isEmpty) return;
    try {
      final response = await ApiService.getProfile(_token);
      final userData = response['data'];

      _currentUserId = userData['id'];
      _userName = userData['full_name'] ?? "User";
      _userEmail = userData['email'] ?? "";
      _userPhone = userData['phone'] ?? "";

      // Backend role ko UserRole enum se map karna
      final dbRole = userData['role'];
      if (dbRole == 'admin') {
        _currentUserRole = UserRole.admin;
      } else if (dbRole == 'staff') {
        _currentUserRole = UserRole.staff;
      } else {
        _currentUserRole = UserRole.member;
      }

      // State details ko DB se sync karna
      await fetchBookingsFromDb();
      await fetchNotificationsFromDb();
      if (_currentUserRole == UserRole.admin || _currentUserRole == UserRole.staff) {
        await fetchAnalyticsFromDb();
      }
      if (_currentUserRole == UserRole.admin) {
        await fetchAuditLogsFromDb();
      }
    } catch (e) {
      debugPrint("Error loading profile, logging out: $e");
      await logout();
    }
  }

  // Login handler (Login sambhalne wala)
  Future<void> login(String email, String password) async {
    setLoading(true);
    try {
      final response = await ApiService.login(email, password);
      _token = response['token'] ?? "";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token);

      await loadUserProfile();
    } catch (e) {
      setLoading(false);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Customer sign up handler
  Future<void> register(String fullName, String email, String phone, String password) async {
    setLoading(true);
    try {
      await ApiService.register(fullName, email, phone, password);
    } finally {
      setLoading(false);
    }
  }

  // Logout handler
  Future<void> logout() async {
    _token = "";
    _currentUserId = null;
    _currentUserRole = UserRole.guest;
    _userName = "Guest User";
    _userEmail = "";
    _userPhone = "";
    _bookings = [];
    _notifications = [];
    _auditLogs = [];
    _analytics = {};

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  // Guest mode ko explicitly shuru karna
  void enterGuestMode() {
    logout();
  }

  // Database se rooms ki list sync karna
  Future<void> fetchRoomsFromDb() async {
    try {
      final dbRooms = await ApiService.fetchRooms(
        search: _searchQuery,
        roomType: _selectedTypeFilter != null ? _mapRoomTypeToString(_selectedTypeFilter!) : null,
        minPrice: 0.0,
        maxPrice: _maxPriceFilter,
      );
      _rooms = dbRooms.map((json) => _mapJsonToRoom(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching rooms: $e");
    }
  }

  // Database se bookings sync karna (sirf unki ya sab ki)
  Future<void> fetchBookingsFromDb() async {
    if (_token.isEmpty || _currentUserRole == UserRole.guest) return;
    try {
      final forStaffOrAdmin = _currentUserRole == UserRole.admin || _currentUserRole == UserRole.staff;
      final dbBookings = await ApiService.fetchBookings(_token, forStaffOrAdmin: forStaffOrAdmin);
      _bookings = dbBookings.map((json) => _mapJsonToBooking(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
    }
  }

  // Notifications alerts fetch karna
  Future<void> fetchNotificationsFromDb() async {
    if (_token.isEmpty || _currentUserRole == UserRole.guest) return;
    try {
      _notifications = await ApiService.fetchNotifications(_token);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
  }

  // Notification ko read mark karna
  Future<void> markNotificationReadInDb(int notificationId) async {
    if (_token.isEmpty) return;
    try {
      await ApiService.markNotificationRead(notificationId, _token);
      await fetchNotificationsFromDb();
    } catch (e) {
      debugPrint("Error marking read: $e");
    }
  }

  // Sab notifications ko read mark karna
  Future<void> markAllNotificationsReadInDb() async {
    if (_token.isEmpty) return;
    try {
      await ApiService.markAllNotificationsRead(_token);
      await fetchNotificationsFromDb();
    } catch (e) {
      debugPrint("Error marking all read: $e");
    }
  }

  // Analytics metrics fetch karna
  Future<void> fetchAnalyticsFromDb() async {
    if (_token.isEmpty || (_currentUserRole != UserRole.admin && _currentUserRole != UserRole.staff)) return;
    try {
      _analytics = await ApiService.fetchAnalytics(_token);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching analytics metrics: $e");
    }
  }

  // Audit log registry fetch karna
  Future<void> fetchAuditLogsFromDb() async {
    if (_token.isEmpty || _currentUserRole != UserRole.admin) return;
    try {
      _auditLogs = await ApiService.fetchAuditLogs(_token);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching audit logs: $e");
    }
  }

  // Forgot password OTP request bhejna
  Future<String> requestForgotPasswordOTP(String email) async {
    final response = await ApiService.requestResetOTP(email);
    return response['otp'] ?? '';
  }

  // Password reset process poora karna
  Future<void> completeResetPassword(String email, String otp, String password) async {
    await ApiService.resetPassword(email, otp, password);
  }

  // Booking reservation banana
  Future<String> createBookingInDb({
    required int roomId,
    required String guestName,
    required String guestEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    if (_token.isEmpty || _currentUserRole == UserRole.guest) {
      throw Exception("Guest users cannot book rooms. Please log in.");
    }
    
    setLoading(true);
    try {
      final bookingData = {
        'room_id': roomId,
        'guest_name': guestName,
        'guest_email': guestEmail,
        'check_in': checkIn.toIso8601String().substring(0, 10),
        'check_out': checkOut.toIso8601String().substring(0, 10),
        'guest_count': guestCount,
        'total_price': totalPrice,
        'payment_method': paymentMethod
      };

      final response = await ApiService.createBooking(bookingData, _token);
      final String bookingId = response['booking_id'] ?? "";
      
      // Prepaid payment methods ki list check karna
      final prepaidMethods = ['Credit Card', 'SARTE Wallet', 'Mobile Wallet', 'Wallet', 'Card'];
      final isPrepaid = prepaidMethods.any((m) => paymentMethod.toLowerCase().contains(m.toLowerCase()));
      if (isPrepaid && bookingId.isNotEmpty) {
        await ApiService.processPayment(bookingId, totalPrice, paymentMethod, "5420 8890 1204 5671", _token);
      }

      await fetchBookingsFromDb();
      await fetchRoomsFromDb(); 
      await fetchNotificationsFromDb();
      if (_currentUserRole == UserRole.admin || _currentUserRole == UserRole.staff) {
        await fetchAnalyticsFromDb();
      }
      return bookingId;
    } finally {
      setLoading(false);
    }
  }

  // Reservation cancel karna
  Future<void> cancelBookingInDb(String bookingId) async {
    if (_token.isEmpty) return;
    try {
      await ApiService.updateBookingStatus(bookingId, 'cancelled', _token);
      await fetchBookingsFromDb();
      await fetchRoomsFromDb();
      await fetchNotificationsFromDb();
      if (_currentUserRole == UserRole.admin || _currentUserRole == UserRole.staff) {
        await fetchAnalyticsFromDb();
      }
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
      rethrow;
    }
  }

  // Staff/Admin: Check-in approve karna
  Future<void> approveBookingInDb(String bookingId) async {
    if (_token.isEmpty) return;
    try {
      await ApiService.updateBookingStatus(bookingId, 'completed', _token);
      await fetchBookingsFromDb();
      await fetchNotificationsFromDb();
      if (_currentUserRole == UserRole.admin || _currentUserRole == UserRole.staff) {
        await fetchAnalyticsFromDb();
      }
    } catch (e) {
      debugPrint("Error approving booking: $e");
      rethrow;
    }
  }

  // Admin: Naya Room register karna
  Future<void> addRoomInDb(HotelRoom room) async {
    if (_token.isEmpty || _currentUserRole != UserRole.admin) return;
    setLoading(true);
    try {
      final roomData = {
        'room_name': room.name,
        'room_type': _mapRoomTypeToString(room.type),
        'room_price': room.pricePerNight,
        'room_status': room.isAvailable ? 'available' : 'maintenance',
        'room_description': room.description,
        'amenities': room.amenities,
        'image_url': room.imageUrls.isNotEmpty ? room.imageUrls[0] : null
      };
      await ApiService.createRoom(roomData, _token);
      await fetchRoomsFromDb();
    } finally {
      setLoading(false);
    }
  }

  // Admin: Room delete karna
  Future<void> deleteRoomInDb(String id) async {
    if (_token.isEmpty || _currentUserRole != UserRole.admin) return;
    final intRoomId = int.tryParse(id);
    if (intRoomId == null) return;
    setLoading(true);
    try {
      await ApiService.deleteRoom(intRoomId, _token);
      await fetchRoomsFromDb();
    } finally {
      setLoading(false);
    }
  }

  // Admin/Staff: Availability toggle karna
  Future<void> toggleRoomAvailabilityInDb(String id) async {
    if (_token.isEmpty) return;
    final intRoomId = int.tryParse(id);
    if (intRoomId == null) return;
    final room = _rooms.firstWhere((r) => r.id == id);
    final newStatus = room.isAvailable ? 'maintenance' : 'available';

    try {
      await ApiService.updateRoom(intRoomId, {'room_status': newStatus}, _token);
      await fetchRoomsFromDb();
    } catch (e) {
      debugPrint("Error toggling room status: $e");
    }
  }

  // MAPPING HELPERS (Database row JSON se Flutter Models mein map karna)

  HotelRoom _mapJsonToRoom(Map<String, dynamic> json) {
    final int roomId = json['room_id'];
    final String typeStr = json['room_type'] ?? 'single';
    final RoomType mappedType = _mapStringToRoomType(typeStr);

    // Dynamic premium details set karna
    List<String> images = [json['image_url'] ?? "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&q=80&w=800"];
    List<dynamic> amenitiesList = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is String) {
        try {
          amenitiesList = jsonDecode(json['amenities']);
        } catch (_) {}
      } else if (json['amenities'] is List) {
        amenitiesList = json['amenities'];
      }
    }
    List<String> amenities = amenitiesList.map((a) => a.toString()).toList();

    if (amenities.isEmpty) {
      if (mappedType == RoomType.suite) {
        images = [
          "https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&q=80&w=800",
          "https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&q=80&w=800",
        ];
        amenities = ["King Bed", "Private Jacuzzi", "Mini Bar", "24/7 Butler", "High-speed WiFi", "OLED Lighting Automation", "Lakeside View"];
      } else if (mappedType == RoomType.family) {
        images = [
          "https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&q=80&w=800",
          "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&q=80&w=800",
        ];
        amenities = ["2 Queen Beds", "Spacious Lounge", "Mini Kitchenette", "Free Kids Area Access", "High-speed WiFi", "Garden View"];
      } else if (mappedType == RoomType.deluxe) {
        images = [
          "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&q=80&w=800",
          "https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&q=80&w=800",
        ];
        amenities = ["King Bed", "Workspace Desk", "Espresso Machine", "High-speed WiFi", "Smart TV", "Rain Shower"];
      } else if (mappedType == RoomType.double) {
        images = [
          "https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&q=80&w=800",
          "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&q=80&w=800",
        ];
        amenities = ["2 Double Beds", "Work Desk", "Mini Fridge", "High-speed WiFi", "Garden View"];
      } else {
        amenities = ["Single Bed", "High-speed WiFi", "Desk", "Rain Shower"];
      }
    }

    return HotelRoom(
      id: roomId.toString(),
      name: json['room_name'] ?? "Luxury Suite",
      roomNumber: roomId.toString(),
      type: mappedType,
      pricePerNight: double.tryParse(json['room_price']?.toString() ?? '100') ?? 100.0,
      rating: 4.8, 
      reviewsCount: 120,
      imageUrls: images,
      amenities: amenities,
      description: json['room_description'] ?? "",
      isAvailable: json['room_status'] == 'available',
    );
  }

  Booking _mapJsonToBooking(Map<String, dynamic> json) {
    final hotelRoom = _mapJsonToRoom(json);

    // Booking status map karna
    final statusStr = json['booking_status'] ?? 'pending';
    BookingStatus statusEnum = BookingStatus.upcoming;
    if (statusStr == 'completed') {
      statusEnum = BookingStatus.completed;
    } else if (statusStr == 'cancelled' || statusStr == 'rejected') {
      statusEnum = BookingStatus.cancelled;
    }

    return Booking(
      id: json['booking_id'] ?? "",
      room: hotelRoom,
      guestName: json['guest_name'] ?? "",
      guestEmail: json['guest_email'] ?? "",
      checkIn: json['check_in'] != null ? DateTime.parse(json['check_in']) : DateTime.now(),
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : DateTime.now(),
      guestCount: json['guest_count'] ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      bookingDate: json['booking_date'] != null ? DateTime.parse(json['booking_date']) : DateTime.now(),
      paymentMethod: json['payment_method'] ?? "",
      status: statusEnum,
    );
  }

  RoomType _mapStringToRoomType(String type) {
    switch (type.toLowerCase()) {
      case 'single':
        return RoomType.single;
      case 'double':
        return RoomType.double;
      case 'deluxe':
        return RoomType.deluxe;
      case 'suite':
        return RoomType.suite;
      case 'family':
        return RoomType.family;
      default:
        return RoomType.single;
    }
  }

  String _mapRoomTypeToString(RoomType type) {
    switch (type) {
      case RoomType.single:
        return 'single';
      case RoomType.double:
        return 'double';
      case RoomType.deluxe:
        return 'deluxe';
      case RoomType.suite:
        return 'suite';
      case RoomType.family:
        return 'family';
    }
  }

  // Pehle se bani hui Staff ki list (UI ke liye)
  final List<StaffMember> _staffList = [
    StaffMember(
      id: "st1",
      name: "Marcus Stone",
      email: "marcus.stone@sarte.hotel",
      role: StaffRole.manager,
      permissions: ["Manage Bookings", "Edit Rooms", "Full Admin access", "View customer details"],
      imageUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200",
      currentTask: "Review monthly corporate conference bookings",
    ),
    StaffMember(
      id: "st2",
      name: "Elena Rostova",
      email: "elena.r@sarte.hotel",
      role: StaffRole.receptionist,
      permissions: ["Manage Bookings", "View customer details"],
      imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200",
      currentTask: "Check-in VIP loyalty program guests",
    ),
    StaffMember(
      id: "st3",
      name: "David Kim",
      email: "david.k@sarte.hotel",
      role: StaffRole.roomService,
      permissions: ["Room Maintenance Services"],
      imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
      currentTask: "Sanitize Monarch Suite 504 post check-out",
    ),
  ];

  List<StaffMember> get staffList => _staffList;

  void addStaff(StaffMember staff) {
    _staffList.add(staff);
    notifyListeners();
  }

  void updateStaffPermissions(String id, List<String> newPerms) {
    final index = _staffList.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staffList[index] = _staffList[index].copyWith(permissions: newPerms);
      notifyListeners();
    }
  }

  void removeStaff(String id) {
    _staffList.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Active Booking ke states
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime get checkInDate => _checkInDate;
  
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  DateTime get checkOutDate => _checkOutDate;

  int _guestCount = 1;
  int get guestCount => _guestCount;

  void setDates(DateTime start, DateTime end) {
    _checkInDate = start;
    _checkOutDate = end;
    notifyListeners();
  }

  void setGuestCount(int count) {
    _guestCount = count;
    notifyListeners();
  }

  // Jo room abhi checkout ke liye select hua hai
  HotelRoom? _selectedRoomForBooking;
  HotelRoom? get selectedRoomForBooking => _selectedRoomForBooking;

  void selectRoomForBooking(HotelRoom room) {
    _selectedRoomForBooking = room;
    notifyListeners();
  }

  // Filter ki hui rooms ki list
  List<HotelRoom> get filteredRooms {
    if (_ratingFilter <= 0.0) return _rooms;
    return _rooms.where((room) => room.rating >= _ratingFilter).toList();
  }

  // Search aur Filtering ki States
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  RoomType? _selectedTypeFilter;
  RoomType? get selectedTypeFilter => _selectedTypeFilter;

  double _maxPriceFilter = 500.0;
  double get maxPriceFilter => _maxPriceFilter;

  double _ratingFilter = 0.0;
  double get ratingFilter => _ratingFilter;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchRoomsFromDb();
  }

  void updateTypeFilter(RoomType? type) {
    _selectedTypeFilter = type;
    fetchRoomsFromDb();
  }

  void updateMaxPrice(double price) {
    _maxPriceFilter = price;
    fetchRoomsFromDb();
  }

  void updateRatingFilter(double rating) {
    _ratingFilter = rating;
    fetchRoomsFromDb();
  }

  void resetFilters() {
    _searchQuery = "";
    _selectedTypeFilter = null;
    _maxPriceFilter = 500.0;
    _ratingFilter = 0.0;
    fetchRoomsFromDb();
  }

  void setUserRole(UserRole role) {
    _currentUserRole = role;
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String phone}) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();
  }
}
