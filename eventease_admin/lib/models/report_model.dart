class ReportModel {
  final String id;

  final String reportName;
  final String reportType;

  final String generatedBy;
  final String generatedById;

  final String format;

  final String status;

  final String? fileUrl;
  final String? fileName;

  final Map<String, dynamic> filters;

  final DateTime reportStartDate;
  final DateTime reportEndDate;

  final int totalRecords;

  final double? totalRevenue;
  final double? totalCommission;
  final double? totalSettlement;

  final String? remarks;

  final DateTime? generatedAt;
  final DateTime? downloadedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReportModel({
    required this.id,
    required this.reportName,
    required this.reportType,
    required this.generatedBy,
    required this.generatedById,
    required this.format,
    required this.status,
    this.fileUrl,
    this.fileName,
    required this.filters,
    required this.reportStartDate,
    required this.reportEndDate,
    required this.totalRecords,
    this.totalRevenue,
    this.totalCommission,
    this.totalSettlement,
    this.remarks,
    this.generatedAt,
    this.downloadedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      reportName:
          json['reportName']
                  ?.toString() ??
              '',

      reportType:
          json['reportType']
                  ?.toString() ??
              'general',

      generatedBy:
          json['generatedBy']
                  ?.toString() ??
              '',

      generatedById:
          json['generatedById']
                  ?.toString() ??
              '',

      format:
          json['format']
                  ?.toString() ??
              'pdf',

      status:
          json['status']
                  ?.toString() ??
              'generated',

      fileUrl:
          json['fileUrl']?.toString(),

      fileName:
          json['fileName']?.toString(),

      filters:
          Map<String, dynamic>.from(
        json['filters'] ?? {},
      ),

      reportStartDate:
          DateTime.tryParse(
                json['reportStartDate']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      reportEndDate:
          DateTime.tryParse(
                json['reportEndDate']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      totalRecords:
          json['totalRecords'] ?? 0,

      totalRevenue:
          json['totalRevenue'] != null
              ? (json['totalRevenue']
                      as num)
                  .toDouble()
              : null,

      totalCommission:
          json['totalCommission'] !=
                  null
              ? (json['totalCommission']
                      as num)
                  .toDouble()
              : null,

      totalSettlement:
          json['totalSettlement'] !=
                  null
              ? (json['totalSettlement']
                      as num)
                  .toDouble()
              : null,

      remarks:
          json['remarks']?.toString(),

      generatedAt:
          json['generatedAt'] != null
              ? DateTime.tryParse(
                  json['generatedAt']
                      .toString(),
                )
              : null,

      downloadedAt:
          json['downloadedAt'] != null
              ? DateTime.tryParse(
                  json['downloadedAt']
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
      'reportName': reportName,
      'reportType': reportType,
      'generatedBy': generatedBy,
      'generatedById': generatedById,
      'format': format,
      'status': status,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'filters': filters,
      'reportStartDate':
          reportStartDate.toIso8601String(),
      'reportEndDate':
          reportEndDate.toIso8601String(),
      'totalRecords': totalRecords,
      'totalRevenue': totalRevenue,
      'totalCommission':
          totalCommission,
      'totalSettlement':
          totalSettlement,
      'remarks': remarks,
      'generatedAt':
          generatedAt?.toIso8601String(),
      'downloadedAt':
          downloadedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ReportModel copyWith({
    String? id,
    String? reportName,
    String? reportType,
    String? generatedBy,
    String? generatedById,
    String? format,
    String? status,
    String? fileUrl,
    String? fileName,
    Map<String, dynamic>? filters,
    DateTime? reportStartDate,
    DateTime? reportEndDate,
    int? totalRecords,
    double? totalRevenue,
    double? totalCommission,
    double? totalSettlement,
    String? remarks,
    DateTime? generatedAt,
    DateTime? downloadedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportName:
          reportName ?? this.reportName,
      reportType:
          reportType ?? this.reportType,
      generatedBy:
          generatedBy ?? this.generatedBy,
      generatedById:
          generatedById ??
              this.generatedById,
      format: format ?? this.format,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName:
          fileName ?? this.fileName,
      filters: filters ?? this.filters,
      reportStartDate:
          reportStartDate ??
              this.reportStartDate,
      reportEndDate:
          reportEndDate ??
              this.reportEndDate,
      totalRecords:
          totalRecords ??
              this.totalRecords,
      totalRevenue:
          totalRevenue ??
              this.totalRevenue,
      totalCommission:
          totalCommission ??
              this.totalCommission,
      totalSettlement:
          totalSettlement ??
              this.totalSettlement,
      remarks: remarks ?? this.remarks,
      generatedAt:
          generatedAt ?? this.generatedAt,
      downloadedAt:
          downloadedAt ??
              this.downloadedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isGenerated =>
      status.toLowerCase() ==
      'generated';

  bool get isProcessing =>
      status.toLowerCase() ==
      'processing';

  bool get isFailed =>
      status.toLowerCase() ==
      'failed';

  bool get isPdf =>
      format.toLowerCase() == 'pdf';

  bool get isExcel =>
      format.toLowerCase() == 'excel' ||
      format.toLowerCase() == 'xlsx';

  bool get isCsv =>
      format.toLowerCase() == 'csv';

  bool get isDownloaded =>
      downloadedAt != null;

  int get reportDurationDays =>
      reportEndDate
          .difference(reportStartDate)
          .inDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReportModel('
        'id: $id, '
        'reportName: $reportName, '
        'reportType: $reportType'
        ')';
  }
}