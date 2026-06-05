import 'hotel_room.dart';

enum BookingStatus {
  upcoming,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Booking {
  final String id;
  final HotelRoom room;
  final String guestName;
  final String guestEmail;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final double totalPrice;
  final DateTime bookingDate;
  final String paymentMethod;
  BookingStatus status;

  Booking({
    required this.id,
    required this.room,
    required this.guestName,
    required this.guestEmail,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalPrice,
    required this.bookingDate,
    required this.paymentMethod,
    this.status = BookingStatus.upcoming,
  });

  Booking copyWith({
    String? id,
    HotelRoom? room,
    String? guestName,
    String? guestEmail,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestCount,
    double? totalPrice,
    DateTime? bookingDate,
    String? paymentMethod,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      room: room ?? this.room,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guestCount: guestCount ?? this.guestCount,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingDate: bookingDate ?? this.bookingDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }
}
