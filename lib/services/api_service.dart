import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Sahi base URL khud select karein:
  // Android Emulator ke liye 10.0.2.2, iOS/Windows/Desktop ke liye localhost
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {
      // Agar platform detect na ho, toh localhost use karein
    }
    return 'http://localhost:3000/api';
  }

  // Headers banane ka helper
  static Map<String, String> _headers(String? token) {
    final Map<String, String> headerMap = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null && token.isNotEmpty) {
      headerMap['Authorization'] = 'Bearer $token';
    }
    return headerMap;
  }

  // 1. User Registration (Naya account banana)
  static Future<Map<String, dynamic>> register(
      String fullName, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers(null),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'user'
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to register account');
    }
  }

  // 2. User Login (Account mein dakhil hona)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: _headers(null),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Invalid email or password');
    }
  }

  // 3. User Profile le kar aana (Token ke zariye)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load user profile');
    }
  }

  // 4. Rooms ki list lana (filters ke sath)
  static Future<List<dynamic>> fetchRooms({
    String? search,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  }) async {
    final List<String> params = [];
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }
    if (roomType != null && roomType.isNotEmpty && roomType != 'all') {
      params.add('room_type=${Uri.encodeComponent(roomType)}');
    }
    if (minPrice != null) {
      params.add('min_price=$minPrice');
    }
    if (maxPrice != null) {
      params.add('max_price=$maxPrice');
    }

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/rooms$queryString'),
      headers: _headers(null),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to retrieve hotel rooms');
    }
  }

  // 5. User/Staff/Admin ke liye Bookings lana
  static Future<List<dynamic>> fetchBookings(String token, {bool forStaffOrAdmin = false}) async {
    final endpoint = forStaffOrAdmin ? '$baseUrl/bookings' : '$baseUrl/bookings/my';
    final response = await http.get(
      Uri.parse(endpoint),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load bookings log');
    }
  }

  // 6. Nayi Booking Reservation banana
  static Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers(token),
      body: jsonEncode(bookingData),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create reservation');
    }
  }

  // 7. Booking ka Status update karna (jaise cancel, approve)
  static Future<void> updateBookingStatus(
      String bookingId, String status, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update reservation status');
    }
  }

  // 8. Admin/Staff: Naya room inventory mein add karna
  static Future<Map<String, dynamic>> createRoom(
      Map<String, dynamic> roomData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms'),
      headers: _headers(token),
      body: jsonEncode(roomData),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to add room suite');
    }
  }

  // 9. Admin/Staff: Room inventory ko update karna
  static Future<void> updateRoom(
      int roomId, Map<String, dynamic> roomData, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: _headers(token),
      body: jsonEncode(roomData),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update room suite');
    }
  }

  // 10. Admin/Staff: Room inventory se delete karna
  static Future<void> deleteRoom(int roomId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete room suite');
    }
  }

  // 11. Admin: Staff account banana
  static Future<Map<String, dynamic>> createStaffAccount(
      Map<String, dynamic> staffData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/staff'),
      headers: _headers(token),
      body: jsonEncode(staffData),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create staff account');
    }
  }

  // 12. Admin: Database se tamam staff members ko lana
  static Future<List<dynamic>> fetchStaff(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/staff'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load staff directory');
    }
  }

  // 13. Password Reset: OTP ki request karna
  static Future<Map<String, dynamic>> requestResetOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/forgot-password'),
      headers: _headers(null),
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to request reset OTP');
    }
  }

  // 14. Password Reset: Reset process poora karna
  static Future<void> resetPassword(String email, String otp, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/reset-password'),
      headers: _headers(null),
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to reset password');
    }
  }

  // 15. Dummy Payment: Payment logs process karna
  static Future<Map<String, dynamic>> processPayment(
      String bookingId, double amount, String paymentMethod, String? cardNumber, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: _headers(token),
      body: jsonEncode({
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        'card_number': cardNumber
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to process transaction');
    }
  }

  // 16. User Notifications: Alerts lana
  static Future<List<dynamic>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load notifications');
    }
  }

  // 17. User Notifications: Read mark karna
  static Future<void> markNotificationRead(int notificationId, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to mark notification as read');
    }
  }

  // 18. User Notifications: Sab ko read mark karna
  static Future<void> markAllNotificationsRead(String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to mark all notifications as read');
    }
  }

  // 19. Analytics: Dashboard metrics lana
  static Future<Map<String, dynamic>> fetchAnalytics(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load analytics metrics');
    }
  }

  // 20. Audit Logs: Logs lana
  static Future<List<dynamic>> fetchAuditLogs(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/audit-logs'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to retrieve audit log archives');
    }
  }
}
