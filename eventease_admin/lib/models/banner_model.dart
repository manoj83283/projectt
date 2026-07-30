class BannerModel {
  final String id;

  final String title;
  final String? description;

  final String imageUrl;
  final String? mobileImageUrl;

  final String bannerType;

  final String? redirectType;
  final String? redirectId;
  final String? redirectUrl;

  final int priority;

  final bool isActive;
  final bool isFeatured;

  final int totalClicks;
  final int totalViews;

  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.mobileImageUrl,
    required this.bannerType,
    this.redirectType,
    this.redirectId,
    this.redirectUrl,
    required this.priority,
    required this.isActive,
    required this.isFeatured,
    required this.totalClicks,
    required this.totalViews,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BannerModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      title:
          json['title']?.toString() ?? '',

      description:
          json['description']
              ?.toString(),

      imageUrl:
          json['imageUrl']
                  ?.toString() ??
              json['image']
                      ?.toString() ??
              '',

      mobileImageUrl:
          json['mobileImageUrl']
              ?.toString(),

      bannerType:
          json['bannerType']
                  ?.toString() ??
              'homepage',

      redirectType:
          json['redirectType']
              ?.toString(),

      redirectId:
          json['redirectId']
              ?.toString(),

      redirectUrl:
          json['redirectUrl']
              ?.toString(),

      priority:
          json['priority'] ?? 0,

      isActive:
          json['isActive'] ?? true,

      isFeatured:
          json['isFeatured'] ?? false,

      totalClicks:
          json['totalClicks'] ?? 0,

      totalViews:
          json['totalViews'] ?? 0,

      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(
                  json['startDate']
                      .toString(),
                )
              : null,

      endDate:
          json['endDate'] != null
              ? DateTime.tryParse(
                  json['endDate']
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
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'mobileImageUrl':
          mobileImageUrl,
      'bannerType': bannerType,
      'redirectType': redirectType,
      'redirectId': redirectId,
      'redirectUrl': redirectUrl,
      'priority': priority,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'totalClicks': totalClicks,
      'totalViews': totalViews,
      'startDate':
          startDate
              ?.toIso8601String(),
      'endDate':
          endDate?.toIso8601String(),
      'createdAt':
          createdAt
              ?.toIso8601String(),
      'updatedAt':
          updatedAt
              ?.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? mobileImageUrl,
    String? bannerType,
    String? redirectType,
    String? redirectId,
    String? redirectUrl,
    int? priority,
    bool? isActive,
    bool? isFeatured,
    int? totalClicks,
    int? totalViews,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          description ??
              this.description,
      imageUrl:
          imageUrl ?? this.imageUrl,
      mobileImageUrl:
          mobileImageUrl ??
              this.mobileImageUrl,
      bannerType:
          bannerType ??
              this.bannerType,
      redirectType:
          redirectType ??
              this.redirectType,
      redirectId:
          redirectId ??
              this.redirectId,
      redirectUrl:
          redirectUrl ??
              this.redirectUrl,
      priority:
          priority ?? this.priority,
      isActive:
          isActive ?? this.isActive,
      isFeatured:
          isFeatured ??
              this.isFeatured,
      totalClicks:
          totalClicks ??
              this.totalClicks,
      totalViews:
          totalViews ??
              this.totalViews,
      startDate:
          startDate ??
              this.startDate,
      endDate:
          endDate ?? this.endDate,
      createdAt:
          createdAt ??
              this.createdAt,
      updatedAt:
          updatedAt ??
              this.updatedAt,
    );
  }

  bool get isHomepageBanner =>
      bannerType.toLowerCase() ==
      'homepage';

  bool get isCategoryBanner =>
      bannerType.toLowerCase() ==
      'category';

  bool get isServiceBanner =>
      bannerType.toLowerCase() ==
      'service';

  bool get isExpired =>
      endDate != null &&
      DateTime.now().isAfter(
        endDate!,
      );

  bool get isScheduled =>
      startDate != null &&
      DateTime.now().isBefore(
        startDate!,
      );

  bool get isLive =>
      isActive &&
      !isExpired &&
      !isScheduled;

  double get clickThroughRate {
    if (totalViews == 0) return 0;

    return (totalClicks /
            totalViews) *
        100;
  }

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is BannerModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  String toString() {
    return 'BannerModel('
        'id: $id, '
        'title: $title, '
        'bannerType: $bannerType'
        ')';
  }
}