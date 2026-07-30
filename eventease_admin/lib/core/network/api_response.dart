class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
    this.meta,
  });

  // =====================================================
  // SUCCESS RESPONSE
  // =====================================================

  factory ApiResponse.success({
    required T? data,
    String message = 'Success',
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
      meta: meta,
    );
  }

  // =====================================================
  // ERROR RESPONSE
  // =====================================================

  factory ApiResponse.error({
    required String message,
    dynamic errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  // =====================================================
  // FROM JSON
  // =====================================================

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic data)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString() ??
          '',
      data: fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      statusCode: json['statusCode'],
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(
              json['meta'],
            )
          : null,
    );
  }

  // =====================================================
  // TO JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'statusCode': statusCode,
      'meta': meta,
    };
  }

  // =====================================================
  // PAGINATION HELPERS
  // =====================================================

  int get currentPage =>
      meta?['currentPage'] ?? 1;

  int get totalPages =>
      meta?['totalPages'] ?? 1;

  int get totalRecords =>
      meta?['totalRecords'] ?? 0;

  int get limit =>
      meta?['limit'] ?? 20;

  bool get hasNextPage =>
      currentPage < totalPages;

  bool get hasPreviousPage =>
      currentPage > 1;

  // =====================================================
  // STATUS HELPERS
  // =====================================================

  bool get isSuccess => success;

  bool get isFailure => !success;

  bool get hasData => data != null;

  bool get hasErrors =>
      errors != null;

  // =====================================================
  // COPY WITH
  // =====================================================

  ApiResponse<T> copyWith({
    bool? success,
    String? message,
    T? data,
    dynamic errors,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      errors: errors ?? this.errors,
      statusCode:
          statusCode ?? this.statusCode,
      meta: meta ?? this.meta,
    );
  }

  // =====================================================
  // STRING
  // =====================================================

  @override
  String toString() {
    return '''
ApiResponse(
  success: $success,
  message: $message,
  statusCode: $statusCode,
  data: $data
)
''';
  }
}