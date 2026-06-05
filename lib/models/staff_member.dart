enum StaffRole {
  manager,
  receptionist,
  roomService,
  security,
}

extension StaffRoleExtension on StaffRole {
  String get displayName {
    switch (this) {
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.receptionist:
        return 'Receptionist';
      case StaffRole.roomService:
        return 'Room Service';
      case StaffRole.security:
        return 'Security';
    }
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final List<String> permissions;
  final String imageUrl;
  final String currentTask;
  bool isActive;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.imageUrl,
    required this.currentTask,
    this.isActive = true,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? email,
    StaffRole? role,
    List<String>? permissions,
    String? imageUrl,
    String? currentTask,
    bool? isActive,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      imageUrl: imageUrl ?? this.imageUrl,
      currentTask: currentTask ?? this.currentTask,
      isActive: isActive ?? this.isActive,
    );
  }
}
