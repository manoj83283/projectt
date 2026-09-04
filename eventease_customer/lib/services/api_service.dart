import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class ApiService {
  ApiService._() {
    _configureInterceptors();
  }

  static final ApiService instance =
      ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(
        seconds: AppConfig.apiTimeoutSeconds,
      ),
      receiveTimeout: const Duration(
        seconds: AppConfig.apiTimeoutSeconds,
      ),
      sendTimeout: const Duration(
        seconds: AppConfig.apiTimeoutSeconds,
      ),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Dio get dio => _dio;

  String get baseUrl =>
      _dio.options.baseUrl;

  bool get hasAuthToken {
    final authorization =
        _dio.options.headers['Authorization'];

    return authorization != null &&
        authorization
            .toString()
            .trim()
            .isNotEmpty;
  }

  String? get authToken {
    final authorization =
        _dio.options.headers['Authorization'];

    if (authorization == null) {
      return null;
    }

    final value =
        authorization.toString().trim();

    return value.isEmpty ? null : value;
  }

  String? get rawAuthToken {
    final authorization = authToken;

    if (authorization == null ||
        authorization.isEmpty) {
      return null;
    }

    if (authorization
        .toLowerCase()
        .startsWith('bearer ')) {
      return authorization
          .substring(7)
          .trim();
    }

    return authorization;
  }

  // =====================================================
  // INTERCEPTORS
  // =====================================================

  void _configureInterceptors() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) {
          debugPrint(
            '➡️ API REQUEST: '
            '${options.method} ${options.uri}',
          );

          debugPrint(
            '🔐 AUTH HEADER: '
            '${options.headers['Authorization'] != null ? 'AVAILABLE' : 'MISSING'}',
          );

          if (options.queryParameters.isNotEmpty) {
            debugPrint(
              '➡️ QUERY: '
              '${options.queryParameters}',
            );
          }

          if (options.data != null) {
            if (options.data is FormData) {
              debugPrint(
                '➡️ BODY: Multipart FormData',
              );
            } else {
              debugPrint(
                '➡️ BODY: ${options.data}',
              );
            }
          }

          handler.next(options);
        },
        onResponse: (
          Response<dynamic> response,
          ResponseInterceptorHandler handler,
        ) {
          debugPrint(
            '✅ API RESPONSE: '
            '${response.statusCode} '
            '${response.requestOptions.path}',
          );

          debugPrint(
            '✅ DATA: ${response.data}',
          );

          handler.next(response);
        },
        onError: (
          DioException error,
          ErrorInterceptorHandler handler,
        ) {
          debugPrint(
            '❌ API ERROR: '
            '${error.response?.statusCode} '
            '${error.requestOptions.path}',
          );

          debugPrint(
            '❌ ERROR DATA: '
            '${error.response?.data}',
          );

          debugPrint(
            '❌ ERROR MESSAGE: '
            '${error.message}',
          );

          debugPrint(
            '🔐 FAILED REQUEST AUTH: '
            '${error.requestOptions.headers['Authorization'] != null ? 'AVAILABLE' : 'MISSING'}',
          );

          handler.next(error);
        },
      ),
    );
  }

  // =====================================================
  // AUTH TOKEN
  // =====================================================

  void setAuthToken(
    String? token,
  ) {
    var normalizedToken =
        token?.trim() ?? '';

    if (normalizedToken
        .toLowerCase()
        .startsWith('bearer ')) {
      normalizedToken =
          normalizedToken
              .substring(7)
              .trim();
    }

    if (normalizedToken.isEmpty) {
      clearAuthToken();
      return;
    }

    _dio.options.headers['Authorization'] =
        'Bearer $normalizedToken';

    debugPrint(
      '✅ AUTH TOKEN ATTACHED TO API SERVICE',
    );
  }

  void clearAuthToken() {
    _dio.options.headers.remove(
      'Authorization',
    );

    debugPrint(
      'ℹ️ AUTH TOKEN CLEARED',
    );
  }

  // =====================================================
  // BASE URL MANAGEMENT
  // =====================================================

  void updateBaseUrl(
    String url,
  ) {
    var normalizedUrl = url.trim();

    if (normalizedUrl.isEmpty) {
      throw ArgumentError(
        'Base URL cannot be empty.',
      );
    }

    if (!normalizedUrl.startsWith(
          'http://',
        ) &&
        !normalizedUrl.startsWith(
          'https://',
        )) {
      throw ArgumentError(
        'Base URL must begin with http:// or https://.',
      );
    }

    while (normalizedUrl.endsWith('/')) {
      normalizedUrl =
          normalizedUrl.substring(
        0,
        normalizedUrl.length - 1,
      );
    }

    _dio.options.baseUrl =
        normalizedUrl;

    debugPrint(
      '✅ API BASE URL: '
      '${_dio.options.baseUrl}',
    );
  }

  void useDevelopmentUrl() {
    updateBaseUrl(
      AppConfig.developmentUrl,
    );
  }

  void useStagingUrl() {
    updateBaseUrl(
      AppConfig.stagingUrl,
    );
  }

  void useProductionUrl() {
    updateBaseUrl(
      AppConfig.productionUrl,
    );
  }

  // =====================================================
  // GET
  // =====================================================

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.get<dynamic>(
        _normalizeEndpoint(endpoint),
        queryParameters:
            _removeNullValues(
          queryParameters,
        ),
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // POST
  // Supports both data and body.
  // =====================================================

  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.post<dynamic>(
        _normalizeEndpoint(endpoint),
        data: body ?? data,
        queryParameters:
            _removeNullValues(
          queryParameters,
        ),
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // PUT
  // Supports both data and body.
  // =====================================================

  Future<Response<dynamic>> put(
    String endpoint, {
    dynamic data,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.put<dynamic>(
        _normalizeEndpoint(endpoint),
        data: body ?? data,
        queryParameters:
            _removeNullValues(
          queryParameters,
        ),
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // PATCH
  // Supports both data and body.
  // =====================================================

  Future<Response<dynamic>> patch(
    String endpoint, {
    dynamic data,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.patch<dynamic>(
        _normalizeEndpoint(endpoint),
        data: body ?? data,
        queryParameters:
            _removeNullValues(
          queryParameters,
        ),
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // DELETE
  // Supports both data and body.
  // =====================================================

  Future<Response<dynamic>> delete(
    String endpoint, {
    dynamic data,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.delete<dynamic>(
        _normalizeEndpoint(endpoint),
        data: body ?? data,
        queryParameters:
            _removeNullValues(
          queryParameters,
        ),
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // DOWNLOAD FILE
  // =====================================================

  Future<Response<dynamic>> downloadFile(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Direct file-path downloads are not supported on Flutter Web.',
      );
    }

    try {
      return await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress:
            onReceiveProgress,
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // SINGLE FILE UPLOAD
  // Mobile and desktop only.
  // =====================================================

  Future<Response<dynamic>> uploadFile(
    String endpoint, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'File-path upload is not supported on Flutter Web. '
        'Use uploadBytes instead.',
      );
    }

    try {
      final fileName = file.path
          .split(
            Platform.pathSeparator,
          )
          .last;

      final formData =
          FormData.fromMap({
        ...?data,
        fieldName:
            await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      return await _dio.post<dynamic>(
        _normalizeEndpoint(endpoint),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          contentType:
              Headers.multipartFormDataContentType,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // MULTIPLE FILE UPLOAD
  // Mobile and desktop only.
  // =====================================================

  Future<Response<dynamic>> uploadFiles(
    String endpoint, {
    required List<File> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'File-path upload is not supported on Flutter Web. '
        'Use uploadMultipleBytes instead.',
      );
    }

    if (files.isEmpty) {
      throw ArgumentError(
        'At least one file is required.',
      );
    }

    try {
      final multipartFiles =
          await Future.wait(
        files.map(
          (file) async {
            final fileName = file.path
                .split(
                  Platform.pathSeparator,
                )
                .last;

            return MultipartFile.fromFile(
              file.path,
              filename: fileName,
            );
          },
        ),
      );

      final formData =
          FormData.fromMap({
        ...?data,
        fieldName: multipartFiles,
      });

      return await _dio.post<dynamic>(
        _normalizeEndpoint(endpoint),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          contentType:
              Headers.multipartFormDataContentType,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // BYTE FILE UPLOAD
  // Supports Flutter Web.
  // =====================================================

  Future<Response<dynamic>> uploadBytes(
    String endpoint, {
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError(
        'File bytes cannot be empty.',
      );
    }

    final normalizedFileName =
        fileName.trim();

    if (normalizedFileName.isEmpty) {
      throw ArgumentError(
        'File name is required.',
      );
    }

    try {
      final formData =
          FormData.fromMap({
        ...?data,
        fieldName:
            MultipartFile.fromBytes(
          bytes,
          filename:
              normalizedFileName,
        ),
      });

      return await _dio.post<dynamic>(
        _normalizeEndpoint(endpoint),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          contentType:
              Headers.multipartFormDataContentType,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // MULTIPLE BYTE FILE UPLOAD
  // Supports Flutter Web.
  // =====================================================

  Future<Response<dynamic>>
      uploadMultipleBytes(
    String endpoint, {
    required List<List<int>> files,
    required List<String> fileNames,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    if (files.isEmpty) {
      throw ArgumentError(
        'At least one file is required.',
      );
    }

    if (files.length !=
        fileNames.length) {
      throw ArgumentError(
        'Files and fileNames must have the same length.',
      );
    }

    try {
      final multipartFiles =
          <MultipartFile>[];

      for (
        var index = 0;
        index < files.length;
        index++
      ) {
        final bytes =
            files[index];

        final fileName =
            fileNames[index].trim();

        if (bytes.isEmpty) {
          throw ArgumentError(
            'File bytes at index $index are empty.',
          );
        }

        if (fileName.isEmpty) {
          throw ArgumentError(
            'File name at index $index is empty.',
          );
        }

        multipartFiles.add(
          MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        );
      }

      final formData =
          FormData.fromMap({
        ...?data,
        fieldName: multipartFiles,
      });

      return await _dio.post<dynamic>(
        _normalizeEndpoint(endpoint),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          contentType:
              Headers.multipartFormDataContentType,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _handleError(error),
      );
    }
  }

  // =====================================================
  // ENDPOINT HELPERS
  // =====================================================

  String _normalizeEndpoint(
    String endpoint,
  ) {
    final normalizedEndpoint =
        endpoint.trim();

    if (normalizedEndpoint.isEmpty) {
      throw ArgumentError(
        'API endpoint cannot be empty.',
      );
    }

    if (normalizedEndpoint.startsWith(
          'http://',
        ) ||
        normalizedEndpoint.startsWith(
          'https://',
        )) {
      return normalizedEndpoint;
    }

    return normalizedEndpoint
            .startsWith('/')
        ? normalizedEndpoint
        : '/$normalizedEndpoint';
  }

  Map<String, dynamic>?
      _removeNullValues(
    Map<String, dynamic>? values,
  ) {
    if (values == null) {
      return null;
    }

    final result =
        <String, dynamic>{};

    values.forEach(
      (key, value) {
        if (value != null) {
          result[key] = value;
        }
      },
    );

    return result.isEmpty
        ? null
        : result;
  }

  // =====================================================
  // ERROR HANDLING
  // Dio 5.11.0 compatible.
  // =====================================================

  String _handleError(
    DioException exception,
  ) {
    final backendMessage =
        _extractBackendErrorMessage(
      exception.response?.data,
    );

    if (backendMessage != null &&
        backendMessage.isNotEmpty) {
      return backendMessage;
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. '
            'Check whether the backend is running.';

      case DioExceptionType.sendTimeout:
        return 'Request upload timed out.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timed out.';

      case DioExceptionType.transformTimeout:
        return 'Response processing timed out.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(
          exception,
        );

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to '
            '${_dio.options.baseUrl}. '
            'Ensure the backend is running on port 5000.';

      case DioExceptionType.badCertificate:
        return 'The server security certificate is invalid.';

      case DioExceptionType.unknown:
        return exception.message ??
            'An unknown network error occurred.';
    }
  }

  String? _extractBackendErrorMessage(
    dynamic responseData,
  ) {
    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    if (responseData is Map) {
      final dynamic message =
          responseData['message'] ??
          responseData['msg'] ??
          responseData['error'];

      if (message is String &&
          message.trim().isNotEmpty) {
        return message.trim();
      }

      if (message is Map) {
        final dynamic nestedMessage =
            message['message'] ??
            message['msg'];

        if (nestedMessage != null &&
            nestedMessage
                .toString()
                .trim()
                .isNotEmpty) {
          return nestedMessage
              .toString()
              .trim();
        }
      }

      final dynamic errors =
          responseData['errors'];

      if (errors is List &&
          errors.isNotEmpty) {
        final dynamic firstError =
            errors.first;

        if (firstError is Map) {
          final dynamic value =
              firstError['message'] ??
              firstError['msg'] ??
              firstError['error'];

          if (value != null &&
              value
                  .toString()
                  .trim()
                  .isNotEmpty) {
            return value
                .toString()
                .trim();
          }
        }

        final normalizedError =
            firstError
                .toString()
                .trim();

        if (normalizedError.isNotEmpty) {
          return normalizedError;
        }
      }
    }

    return null;
  }

  String _handleBadResponse(
    DioException exception,
  ) {
    final statusCode =
        exception.response?.statusCode;

    switch (statusCode) {
      case 400:
        return 'Invalid request data.';

      case 401:
        // The persisted token is cleared separately by
        // AuthService when the user signs out or when the
        // session is explicitly invalidated.
        return 'Authentication required. '
            'Please sign in again.';

      case 403:
        return 'You do not have permission '
            'to perform this action.';

      case 404:
        return 'Requested API route was not found.';

      case 405:
        return 'The API does not support this request method.';

      case 409:
        return 'The requested record already exists.';

      case 422:
        return 'The submitted data could not be processed.';

      case 429:
        return 'Too many requests. '
            'Please try again shortly.';

      default:
        if (statusCode != null &&
            statusCode >= 500) {
          return 'Backend server error. '
              'Please try again.';
        }

        return exception.response
                ?.statusMessage ??
            'Server request failed.';
    }
  }
}