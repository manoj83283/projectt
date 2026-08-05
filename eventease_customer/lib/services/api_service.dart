import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  // ==========================================
  // CONFIGURATION
  // ==========================================

  static const String baseUrl =
      'https://your-api-domain.com/api';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) {
          print(
            '➡️ ${options.method} ${options.baseUrl}${options.path}',
          );

          if (options.data != null) {
            print('📤 DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (
          Response response,
          ResponseInterceptorHandler handler,
        ) {
          print(
            '✅ ${response.statusCode} ${response.requestOptions.path}',
          );

          handler.next(response);
        },
        onError: (
          DioException error,
          ErrorInterceptorHandler handler,
        ) {
          print(
            '❌ ${error.requestOptions.path}',
          );

          print(error.message);

          handler.next(error);
        },
      ),
    );

  Dio get dio => _dio;

  // ==========================================
  // AUTH TOKEN
  // ==========================================

  void setAuthToken(
    String? token,
  ) {
    if (token == null || token.isEmpty) {
      clearAuthToken();
      return;
    }

    _dio.options.headers['Authorization'] =
        'Bearer $token';
  }

  String? get authToken {
    final value =
        _dio.options.headers['Authorization'];

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  void clearAuthToken() {
    _dio.options.headers.remove(
      'Authorization',
    );
  }

  // ==========================================
  // GET
  // ==========================================

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // POST
  // ==========================================

  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // PUT
  // ==========================================

  Future<Response<dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // PATCH
  // ==========================================

  Future<Response<dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // DELETE
  // ==========================================

  Future<Response<dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // DOWNLOAD FILE
  // ==========================================

  Future<Response<dynamic>> downloadFile(
    String url,
    String savePath,
  ) async {
    try {
      return await _dio.download(
        url,
        savePath,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // SINGLE FILE UPLOAD
  // ==========================================

  Future<Response<dynamic>> uploadFile(
    String endpoint, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      final FormData formData =
          FormData.fromMap({
        ...?data,
        fieldName:
            await MultipartFile.fromFile(
          file.path,
          filename:
              file.path.split('/').last,
        ),
      });

      return await _dio.post(
        endpoint,
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // MULTIPLE FILES UPLOAD
  // ==========================================

  Future<Response<dynamic>> uploadFiles(
    String endpoint, {
    required List<File> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
  }) async {
    try {
      final List<MultipartFile>
          multipartFiles =
          await Future.wait(
        files.map(
          (file) =>
              MultipartFile.fromFile(
            file.path,
            filename:
                file.path.split('/').last,
          ),
        ),
      );

      final FormData formData =
          FormData.fromMap({
        ...?data,
        fieldName: multipartFiles,
      });

      return await _dio.post(
        endpoint,
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception(
        _handleError(e),
      );
    }
  }

  // ==========================================
  // UPDATE BASE URL
  // ==========================================

  void updateBaseUrl(
    String url,
  ) {
    _dio.options.baseUrl = url;
  }

  // ==========================================
  // ERROR HANDLER
  // ==========================================

  String _handleError(
    DioException exception,
  ) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.sendTimeout:
        return 'Send timeout';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';

      case DioExceptionType.badResponse:
        return exception
                .response
                ?.data?['message']
                ?.toString() ??
            exception.response
                ?.statusMessage ??
            'Server error';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.badCertificate:
        return 'Bad certificate';

      case DioExceptionType.unknown:
        return exception.message ??
            'Unknown error';

      default:
        return 'Something went wrong';
    }
  }
}