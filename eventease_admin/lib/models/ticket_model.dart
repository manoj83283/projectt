class TicketModel {
  final String id;

  final String ticketNumber;

  final String customerId;
  final String customerName;

  final String? providerId;
  final String? providerName;

  final String subject;
  final String description;

  final String category;
  final String priority;
  final String status;

  final String? assignedAdminId;
  final String? assignedAdminName;

  final List<String> attachments;

  final int totalReplies;

  final String? lastMessage;

  final DateTime? lastReplyAt;
  final DateTime? closedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.customerName,
    this.providerId,
    this.providerName,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedAdminId,
    this.assignedAdminName,
    required this.attachments,
    required this.totalReplies,
    this.lastMessage,
    this.lastReplyAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TicketModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      ticketNumber:
          json['ticketNumber']
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

      subject:
          json['subject']
                  ?.toString() ??
              '',

      description:
          json['description']
                  ?.toString() ??
              '',

      category:
          json['category']
                  ?.toString() ??
              'general',

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

      attachments:
          (json['attachments'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      totalReplies:
          json['totalReplies'] ?? 0,

      lastMessage:
          json['lastMessage']
              ?.toString(),

      lastReplyAt:
          json['lastReplyAt'] != null
              ? DateTime.tryParse(
                  json['lastReplyAt']
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
      'ticketNumber': ticketNumber,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'providerName': providerName,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedAdminId':
          assignedAdminId,
      'assignedAdminName':
          assignedAdminName,
      'attachments': attachments,
      'totalReplies': totalReplies,
      'lastMessage': lastMessage,
      'lastReplyAt':
          lastReplyAt?.toIso8601String(),
      'closedAt':
          closedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  TicketModel copyWith({
    String? id,
    String? ticketNumber,
    String? customerId,
    String? customerName,
    String? providerId,
    String? providerName,
    String? subject,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedAdminId,
    String? assignedAdminName,
    List<String>? attachments,
    int? totalReplies,
    String? lastMessage,
    DateTime? lastReplyAt,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketNumber:
          ticketNumber ??
              this.ticketNumber,
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
      subject: subject ?? this.subject,
      description:
          description ??
              this.description,
      category:
          category ?? this.category,
      priority:
          priority ?? this.priority,
      status: status ?? this.status,
      assignedAdminId:
          assignedAdminId ??
              this.assignedAdminId,
      assignedAdminName:
          assignedAdminName ??
              this.assignedAdminName,
      attachments:
          attachments ?? this.attachments,
      totalReplies:
          totalReplies ??
              this.totalReplies,
      lastMessage:
          lastMessage ?? this.lastMessage,
      lastReplyAt:
          lastReplyAt ??
              this.lastReplyAt,
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

  bool get isResolved =>
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

  bool get hasReplies =>
      totalReplies > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TicketModel('
        'id: $id, '
        'ticketNumber: $ticketNumber, '
        'status: $status'
        ')';
  }
}