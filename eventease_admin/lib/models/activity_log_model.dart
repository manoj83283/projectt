class ActivityLogModel {
  final String id;

  final String userId;
  final String userName;
  final String userRole;

  final String action;
  final String module;

  final String description;

  final String? entityId;
  final String? entityType;

  final String? oldValue;
  final String? newValue;

  final String? ipAddress;
  final String? deviceInfo;

  final String status;

  final DateTime? createdAt;

  const ActivityLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.module,
    required this.description,
    this.entityId,
    this.entityType,
    this.oldValue,
    this.newValue,
    this.ipAddress,
    this.deviceInfo,
    required this.status,
    this.createdAt,
  });

  factory ActivityLogModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActivityLogModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      userId:
          json['userId']?.toString() ?? '',

      userName:
          json['userName']?.toString() ??
              '',

      userRole:
          json['userRole']?.toString() ??
              'admin',

      action:
          json['action']?.toString() ?? '',

      module:
          json['module']?.toString() ?? '',

      description:
          json['description']
                  ?.toString() ??
              '',

      entityId:
          json['entityId']?.toString(),

      entityType:
          json['entityType']?.toString(),

      oldValue:
          json['oldValue']?.toString(),

      newValue:
          json['newValue']?.toString(),

      ipAddress:
          json['ipAddress']?.toString(),

      deviceInfo:
          json['deviceInfo']?.toString(),

      status:
          json['status']?.toString() ??
              'success',

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action,
      'module': module,
      'description': description,
      'entityId': entityId,
      'entityType': entityType,
      'oldValue': oldValue,
      'newValue': newValue,
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
      'status': status,
      'createdAt':
          createdAt?.toIso8601String(),
    };
  }

  ActivityLogModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? action,
    String? module,
    String? description,
    String? entityId,
    String? entityType,
    String? oldValue,
    String? newValue,
    String? ipAddress,
    String? deviceInfo,
    String? status,
    DateTime? createdAt,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName:
          userName ?? this.userName,
      userRole:
          userRole ?? this.userRole,
      action: action ?? this.action,
      module: module ?? this.module,
      description:
          description ?? this.description,
      entityId:
          entityId ?? this.entityId,
      entityType:
          entityType ?? this.entityType,
      oldValue:
          oldValue ?? this.oldValue,
      newValue:
          newValue ?? this.newValue,
      ipAddress:
          ipAddress ?? this.ipAddress,
      deviceInfo:
          deviceInfo ?? this.deviceInfo,
      status: status ?? this.status,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }

  bool get isSuccess =>
      status.toLowerCase() == 'success';

  bool get isFailed =>
      status.toLowerCase() == 'failed';

  bool get isCreateAction =>
      action.toLowerCase() == 'create';

  bool get isUpdateAction =>
      action.toLowerCase() == 'update';

  bool get isDeleteAction =>
      action.toLowerCase() == 'delete';

  bool get hasEntity =>
      entityId != null &&
      entityId!.isNotEmpty;

  bool get hasChanges =>
      oldValue != null &&
      newValue != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ActivityLogModel('
        'id: $id, '
        'userName: $userName, '
        'action: $action, '
        'module: $module'
        ')';
  }
}