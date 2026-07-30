import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  DioClient._internal() {
    _initialize();
  }

  static final DioClient _instance =
      DioClient._internal();

  factory DioClient() => _instance;

  late final Dio _dio;

  Dio get client => _dio;

  void _initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          seconds: 30,
        ),
        receiveTimeout: const Duration(
          seconds: 30,
        ),
        sendTimeout: const Duration(
          seconds: 30,
        ),
        headers: const {
          'Accept': 'application/json',
          'Content-Type':
              'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          options,
          handler,
        ) async {
          final token =
              await StorageService
                  .getAccessToken();

          if (token != null &&
              token.isNotEmpty) {
            options.headers[
                    'Authorization'] =
                'Bearer $token';
          }

          handler.next(options);
        },

        onResponse: (
          response,
          handler,
        ) {
          handler.next(response);
        },

        onError: (
          DioException error,
          handler,
        ) async {
          // ==========================
          // UNAUTHORIZED
          // ==========================

          if (error.response?.statusCode ==
              401) {
            try {
              final refreshToken =
                  await StorageService
                      .getRefreshToken();

              if (refreshToken != null &&
                  refreshToken
                      .isNotEmpty) {
                // Future Refresh Logic
              }
            } catch (_) {}
          }

          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  // ==========================
  // HEADER MANAGEMENT
  // ==========================

  void setAccessToken(
    String token,
  ) {
    _dio.options.headers[
            'Authorization'] =
        'Bearer $token';
  }

  void clearAccessToken() {
    _dio.options.headers
        .remove('Authorization');
  }

  void addHeader({
    required String key,
    required String value,
  }) {
    _dio.options.headers[key] =
        value;
  }

  void removeHeader(
    String key,
  ) {
    _dio.options.headers.remove(key);
  }

  // ==========================
  // REQUEST METHODS
  // ==========================

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get(
      path,
      queryParameters:
          queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters:
          queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters:
          queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters:
          queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters:
          queryParameters,
      options: options,
    );
  }

  // ==========================
  // FILE DOWNLOAD
  // ==========================

  Future<Response<dynamic>> download(
    String url,
    String savePath,
  ) async {
    return _dio.download(
      url,
      savePath,
    );
  }

  // ==========================
  // FILE UPLOAD
  // ==========================

  Future<Response<dynamic>> upload(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      onSendProgress:
          onSendProgress,
      options: Options(
        contentType:
            'multipart/form-data',
      ),
    );
  }

  // ==========================
  // ERROR PARSER
  // ==========================

  String getErrorMessage(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType
            .connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType
            .sendTimeout:
        return 'Request timeout';

      case DioExceptionType
            .receiveTimeout:
        return 'Server timeout';

      case DioExceptionType
            .connectionError:
        return 'No internet connection';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType
            .badResponse:
        return error
                .response
                ?.data['message'] ??
            'Something went wrong';

      default:
        return 'Unexpected error occurred';
    }
  }
}