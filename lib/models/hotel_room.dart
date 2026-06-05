enum RoomType {
  single,
  double,
  deluxe,
  suite,
  family,
}

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Single Room';
      case RoomType.double:
        return 'Double Room';
      case RoomType.deluxe:
        return 'Deluxe Room';
      case RoomType.suite:
        return 'Suite Room';
      case RoomType.family:
        return 'Family Room';
    }
  }
}

class HotelRoom {
  final String id;
  final String name;
  final String roomNumber;
  final RoomType type;
  final double pricePerNight;
  final double rating;
  final int reviewsCount;
  final List<String> imageUrls;
  final List<String> amenities;
  final String description;
  bool isAvailable;

  HotelRoom({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.type,
    required this.pricePerNight,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrls,
    required this.amenities,
    required this.description,
    this.isAvailable = true,
  });

  HotelRoom copyWith({
    String? id,
    String? name,
    String? roomNumber,
    RoomType? type,
    double? pricePerNight,
    double? rating,
    int? reviewsCount,
    List<String>? imageUrls,
    List<String>? amenities,
    String? description,
    bool? isAvailable,
  }) {
    return HotelRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      type: type ?? this.type,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
