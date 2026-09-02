class ProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String,
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}