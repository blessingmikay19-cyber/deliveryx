class MerchantModel {
  final String id;
  final String profileId;
  final String businessName;
  final String? businessDescription;
  final String? phone;
  final String? address;
  final String approvalStatus;
  final bool isOpen;
  final int preparationTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantModel({
    required this.id,
    required this.profileId,
    required this.businessName,
    this.businessDescription,
    this.phone,
    this.address,
    required this.approvalStatus,
    required this.isOpen,
    required this.preparationTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantModel.fromMap(Map<String, dynamic> map) {
    return MerchantModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      businessName: map['business_name'] as String,
      businessDescription:
          map['business_description'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      approvalStatus: map['approval_status'] as String,
      isOpen: map['is_open'] as bool,
      preparationTimeMinutes:
          map['preparation_time_minutes'] as int,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'business_name': businessName,
      'business_description': businessDescription,
      'phone': phone,
      'address': address,
      'approval_status': approvalStatus,
      'is_open': isOpen,
      'preparation_time_minutes':
          preparationTimeMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}