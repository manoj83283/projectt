import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  // =====================================================
  // DIO EXCEPTION MAPPER
  // =====================================================

  factory ApiException.fromDio(
    DioException exception,
  ) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message:
              'Connection timeout. Please try again.',
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message:
              'Request timeout while sending data.',
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message:
              'Server took too long to respond.',
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message:
              'SSL certificate validation failed.',
        );

      case DioExceptionType.cancel:
        return ApiException(
          message:
              'Request was cancelled.',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message:
              'No internet connection available.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(
          exception.response,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message:
              'Unexpected error occurred. Please try again.',
        );
    }
  }

  // =====================================================
  // RESPONSE ERROR HANDLER
  // =====================================================

  static ApiException
      _handleResponseError(
    Response? response,
  ) {
    final statusCode =
        response?.statusCode;

    final data = response?.data;

    String message =
        'Something went wrong';

    if (data is Map<String, dynamic>) {
      message =
          data['message']?.toString() ??
              message;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Bad request.',
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Unauthorized access.',
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Access forbidden.',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Resource not found.',
          statusCode: statusCode,
          data: data,
        );

      case 409:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Conflict detected.',
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Validation failed.',
          statusCode: statusCode,
          data: data,
        );

      case 429:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Too many requests.',
          statusCode: statusCode,
          data: data,
        );

      case 500:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Internal server error.',
          statusCode: statusCode,
          data: data,
        );

      case 502:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Bad gateway.',
          statusCode: statusCode,
          data: data,
        );

      case 503:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Service unavailable.',
          statusCode: statusCode,
          data: data,
        );

      case 504:
        return ApiException(
          message:
              message.isNotEmpty
                  ? message
                  : 'Gateway timeout.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  // =====================================================
  // VALIDATION ERRORS
  // =====================================================

  List<String> get validationErrors {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is List) {
        return errors
            .map((e) => e.toString())
            .toList();
      }

      if (errors is Map) {
        final result = <String>[];

        errors.forEach((key, value) {
          if (value is List) {
            result.addAll(
              value
                  .map((e) => e.toString())
                  .toList(),
            );
          } else {
            result.add(value.toString());
          }
        });

        return result;
      }
    }

    return [];
  }

  // =====================================================
  // HELPER FLAGS
  // =====================================================

  bool get isUnauthorized =>
      statusCode == 401;

  bool get isForbidden =>
      statusCode == 403;

  bool get isNotFound =>
      statusCode == 404;

  bool get isValidationError =>
      statusCode == 422;

  bool get isServerError =>
      statusCode != null &&
      statusCode! >= 500;

  // =====================================================
  // TO STRING
  // =====================================================

  @override
  String toString() {
    return message;
  }
}