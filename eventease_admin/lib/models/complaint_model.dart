class ComplaintModel {
  final String id;

  final String complaintNumber;

  final String customerId;
  final String customerName;

  final String? providerId;
  final String? providerName;

  final String complaintType;
  final String subject;
  final String description;

  final String priority;
  final String status;

  final String? assignedAdminId;
  final String? assignedAdminName;

  final String? resolution;
  final String? resolutionNote;
  final String? rejectionReason;

  final List<String> attachments;

  final bool isResolved;
  final bool isEscalated;

  final DateTime? resolvedAt;
  final DateTime? closedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.customerId,
    required this.customerName,
    this.providerId,
    this.providerName,
    required this.complaintType,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedAdminId,
    this.assignedAdminName,
    this.resolution,
    this.resolutionNote,
    this.rejectionReason,
    required this.attachments,
    required this.isResolved,
    required this.isEscalated,
    this.resolvedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ComplaintModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      complaintNumber:
          json['complaintNumber']
                  ?.toString() ??
              '',

      customerId:
          json['customerId']
                  ?.toString() ??
              '',

      customerName:
          json['customerName']
                  ?.toString() ??
              '',

      providerId:
          json['providerId']
              ?.toString(),

      providerName:
          json['providerName']
              ?.toString(),

      complaintType:
          json['complaintType']
                  ?.toString() ??
              'general',

      subject:
          json['subject']
                  ?.toString() ??
              '',

      description:
          json['description']
                  ?.toString() ??
              '',

      priority:
          json['priority']
                  ?.toString() ??
              'medium',

      status:
          json['status']
                  ?.toString() ??
              'open',

      assignedAdminId:
          json['assignedAdminId']
              ?.toString(),

      assignedAdminName:
          json['assignedAdminName']
              ?.toString(),

      resolution:
          json['resolution']
              ?.toString(),

      resolutionNote:
          json['resolutionNote']
              ?.toString(),

      rejectionReason:
          json['rejectionReason']
              ?.toString(),

      attachments:
          (json['attachments'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      isResolved:
          json['isResolved'] ?? false,

      isEscalated:
          json['isEscalated'] ?? false,

      resolvedAt:
          json['resolvedAt'] != null
              ? DateTime.tryParse(
                  json['resolvedAt']
                      .toString(),
                )
              : null,

      closedAt:
          json['closedAt'] != null
              ? DateTime.tryParse(
                  json['closedAt']
                      .toString(),
                )
              : null,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt']
                      .toString(),
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'complaintNumber':
          complaintNumber,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'providerName': providerName,
      'complaintType': complaintType,
      'subject': subject,
      'description': description,
      'priority': priority,
      'status': status,
      'assignedAdminId':
          assignedAdminId,
      'assignedAdminName':
          assignedAdminName,
      'resolution': resolution,
      'resolutionNote':
          resolutionNote,
      'rejectionReason':
          rejectionReason,
      'attachments': attachments,
      'isResolved': isResolved,
      'isEscalated': isEscalated,
      'resolvedAt':
          resolvedAt?.toIso8601String(),
      'closedAt':
          closedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? complaintNumber,
    String? customerId,
    String? customerName,
    String? providerId,
    String? providerName,
    String? complaintType,
    String? subject,
    String? description,
    String? priority,
    String? status,
    String? assignedAdminId,
    String? assignedAdminName,
    String? resolution,
    String? resolutionNote,
    String? rejectionReason,
    List<String>? attachments,
    bool? isResolved,
    bool? isEscalated,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      complaintNumber:
          complaintNumber ??
              this.complaintNumber,
      customerId:
          customerId ?? this.customerId,
      customerName:
          customerName ??
              this.customerName,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      complaintType:
          complaintType ??
              this.complaintType,
      subject: subject ?? this.subject,
      description:
          description ??
              this.description,
      priority:
          priority ?? this.priority,
      status: status ?? this.status,
      assignedAdminId:
          assignedAdminId ??
              this.assignedAdminId,
      assignedAdminName:
          assignedAdminName ??
              this.assignedAdminName,
      resolution:
          resolution ?? this.resolution,
      resolutionNote:
          resolutionNote ??
              this.resolutionNote,
      rejectionReason:
          rejectionReason ??
              this.rejectionReason,
      attachments:
          attachments ?? this.attachments,
      isResolved:
          isResolved ?? this.isResolved,
      isEscalated:
          isEscalated ??
              this.isEscalated,
      resolvedAt:
          resolvedAt ?? this.resolvedAt,
      closedAt:
          closedAt ?? this.closedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isOpen =>
      status.toLowerCase() == 'open';

  bool get isInProgress =>
      status.toLowerCase() ==
      'in_progress';

  bool get isResolvedStatus =>
      status.toLowerCase() ==
      'resolved';

  bool get isClosed =>
      status.toLowerCase() ==
      'closed';

  bool get isHighPriority =>
      priority.toLowerCase() ==
          'high' ||
      priority.toLowerCase() ==
          'critical';

  bool get hasAttachments =>
      attachments.isNotEmpty;

  bool get isAssigned =>
      assignedAdminId != null &&
      assignedAdminId!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ComplaintModel('
        'id: $id, '
        'complaintNumber: $complaintNumber, '
        'status: $status'
        ')';
  }
}