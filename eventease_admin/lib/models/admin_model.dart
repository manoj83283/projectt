class AdminModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String role;

  final bool isActive;
  final bool isVerified;

  final List<String> permissions;

  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.permissions,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      fullName:
          json['fullName']?.toString() ??
              '',

      email:
          json['email']?.toString() ?? '',

      phone:
          json['phone']?.toString() ?? '',

      profileImage:
          json['profileImage']
              ?.toString(),

      role:
          json['role']?.toString() ??
              'admin',

      isActive:
          json['isActive'] ?? true,

      isVerified:
          json['isVerified'] ?? false,

      permissions:
          (json['permissions']
                      as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.tryParse(
                  json['lastLoginAt'],
                )
              : null,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt'],
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt'],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'isActive': isActive,
      'isVerified': isVerified,
      'permissions': permissions,
      'lastLoginAt':
          lastLoginAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  AdminModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    bool? isActive,
    bool? isVerified,
    List<String>? permissions,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      fullName:
          fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
          profileImage ??
              this.profileImage,
      role: role ?? this.role,
      isActive:
          isActive ?? this.isActive,
      isVerified:
          isVerified ??
              this.isVerified,
      permissions:
          permissions ??
              this.permissions,
      lastLoginAt:
          lastLoginAt ??
              this.lastLoginAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isSuperAdmin =>
      role.toLowerCase() ==
      'super_admin';

  bool get isAdmin =>
      role.toLowerCase() == 'admin';

  String get displayName =>
      fullName.trim().isEmpty
          ? email
          : fullName;

  @override
  String toString() {
    return 'AdminModel('
        'id: $id, '
        'fullName: $fullName, '
        'email: $email, '
        'role: $role'
        ')';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is AdminModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}