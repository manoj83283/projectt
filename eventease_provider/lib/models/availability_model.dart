enum AvailabilityStatus {
  available,
  busy,
  blocked,
  holiday,
}

class AvailabilityModel {
  final String id;

  final String providerId;

  final DateTime date;

  final String startTime;
  final String endTime;

  final AvailabilityStatus status;

  final bool isFullDay;

  final int maxBookings;
  final int bookedSlots;

  final String notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AvailabilityModel({
    required this.id,
    required this.providerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isFullDay,
    required this.maxBookings,
    required this.bookedSlots,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory AvailabilityModel.empty() {
    return AvailabilityModel(
      id: '',
      providerId: '',
      date: DateTime.now(),
      startTime: '09:00',
      endTime: '18:00',
      status: AvailabilityStatus.available,
      isFullDay: false,
      maxBookings: 1,
      bookedSlots: 0,
      notes: '',
    );
  }

  factory AvailabilityModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvailabilityModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      providerId:
          json['providerId']?.toString() ??
              '',
      date: json['date'] != null
          ? DateTime.parse(
              json['date'].toString(),
            )
          : DateTime.now(),
      startTime:
          json['startTime']?.toString() ??
              '09:00',
      endTime:
          json['endTime']?.toString() ??
              '18:00',
      status: _parseStatus(
        json['status'],
      ),
      isFullDay:
          json['isFullDay'] ?? false,
      maxBookings:
          json['maxBookings'] ?? 1,
      bookedSlots:
          json['bookedSlots'] ?? 0,
      notes:
          json['notes']?.toString() ?? '',
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
      'providerId': providerId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'isFullDay': isFullDay,
      'maxBookings': maxBookings,
      'bookedSlots': bookedSlots,
      'notes': notes,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static AvailabilityStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'busy':
        return AvailabilityStatus.busy;

      case 'blocked':
        return AvailabilityStatus.blocked;

      case 'holiday':
        return AvailabilityStatus.holiday;

      default:
        return AvailabilityStatus.available;
    }
  }

  String get statusText {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';

      case AvailabilityStatus.busy:
        return 'Busy';

      case AvailabilityStatus.blocked:
        return 'Blocked';

      case AvailabilityStatus.holiday:
        return 'Holiday';
    }
  }

  bool get isAvailable =>
      status == AvailabilityStatus.available;

  bool get isBusy =>
      status == AvailabilityStatus.busy;

  bool get isBlocked =>
      status == AvailabilityStatus.blocked;

  bool get isHoliday =>
      status == AvailabilityStatus.holiday;

  bool get hasCapacity =>
      bookedSlots < maxBookings;

  int get remainingSlots =>
      maxBookings - bookedSlots;

  double get bookingPercentage {
    if (maxBookings == 0) {
      return 0;
    }

    return (bookedSlots / maxBookings) *
        100;
  }

  AvailabilityModel copyWith({
    String? id,
    String? providerId,
    DateTime? date,
    String? startTime,
    String? endTime,
    AvailabilityStatus? status,
    bool? isFullDay,
    int? maxBookings,
    int? bookedSlots,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      providerId:
          providerId ?? this.providerId,
      date: date ?? this.date,
      startTime:
          startTime ?? this.startTime,
      endTime:
          endTime ?? this.endTime,
      status: status ?? this.status,
      isFullDay:
          isFullDay ?? this.isFullDay,
      maxBookings:
          maxBookings ?? this.maxBookings,
      bookedSlots:
          bookedSlots ?? this.bookedSlots,
      notes: notes ?? this.notes,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AvailabilityModel('
        'id: $id, '
        'date: $date, '
        'status: ${status.name}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AvailabilityModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}