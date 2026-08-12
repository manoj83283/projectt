import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../storage/storage_helper.dart';

class ApiService {
  ApiService._internal();

  static final ApiService instance = ApiService._internal();

  // =============================================================
  // BASE URL
  // =============================================================

  static String get baseUrl => ApiConfig.baseUrl;

  // =============================================================
  // DIO INSTANCE
  // =============================================================

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageHelper.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (ApiConfig.enableApiLogs) {
            final fullUrl = '${options.baseUrl}${options.path}';

            // ignore: avoid_print
            print('➡️ API REQUEST: ${options.method} $fullUrl');

            if (options.queryParameters.isNotEmpty) {
              // ignore: avoid_print
              print('➡️ QUERY: ${options.queryParameters}');
            }

            if (options.data != null) {
              // ignore: avoid_print
              print('➡️ BODY: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (ApiConfig.enableApiLogs) {
            // ignore: avoid_print
            print(
              '✅ API RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
            );

            // ignore: avoid_print
            print('✅ DATA: ${response.data}');
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          if (ApiConfig.enableApiLogs) {
            // ignore: avoid_print
            print(
              '❌ API ERROR: ${error.response?.statusCode} ${error.requestOptions.path}',
            );

            // ignore: avoid_print
            print('❌ ERROR DATA: ${error.response?.data}');

            // ignore: avoid_print
            print('❌ ERROR MESSAGE: ${error.message}');
          }

          return handler.next(error);
        },
      ),
    );

  Dio get dio => _dio;

  // =============================================================
  // NORMALIZE RESPONSE
  // =============================================================

  dynamic _normalizeResponse(Response response) {
    final data = response.data;

    if (data == null) {
      return {};
    }

    return data;
  }

  // =============================================================
  // GET
  // =============================================================

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // POST
  // =============================================================

  Future<dynamic> post(
    String path, {
    dynamic body,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body ?? data,
        queryParameters: queryParameters,
        options: options,
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // PUT
  // =============================================================

  Future<dynamic> put(
    String path, {
    dynamic body,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body ?? data,
        queryParameters: queryParameters,
        options: options,
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // PATCH
  // =============================================================

  Future<dynamic> patch(
    String path, {
    dynamic body,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: body ?? data,
        queryParameters: queryParameters,
        options: options,
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // DELETE
  // =============================================================

  Future<dynamic> delete(
    String path, {
    dynamic body,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: body ?? data,
        queryParameters: queryParameters,
        options: options,
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // UPLOAD SINGLE FILE
  // =============================================================

  Future<dynamic> uploadFile({
    required String path,
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? body,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData();

      formData.files.add(
        MapEntry(
          fileKey,
          await MultipartFile.fromFile(filePath),
        ),
      );

      final fields = body ?? extraFields ?? {};

      for (final entry in fields.entries) {
        formData.fields.add(
          MapEntry(
            entry.key,
            entry.value.toString(),
          ),
        );
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // UPLOAD MULTIPLE FILES
  // =============================================================

  Future<dynamic> uploadFiles({
    required String path,
    required List<String> filePaths,
    String fileKey = 'files',
    Map<String, dynamic>? body,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData();

      for (final filePath in filePaths) {
        formData.files.add(
          MapEntry(
            fileKey,
            await MultipartFile.fromFile(filePath),
          ),
        );
      }

      final fields = body ?? extraFields ?? {};

      for (final entry in fields.entries) {
        formData.fields.add(
          MapEntry(
            entry.key,
            entry.value.toString(),
          ),
        );
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // =============================================================
  // ERROR HANDLER
  // =============================================================

  String _handleDioError(DioException error) {
    if (error.response?.data is Map) {
      final data = error.response?.data as Map;

      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Something went wrong';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.sendTimeout:
        return 'Send timeout';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';

      case DioExceptionType.connectionError:
        return 'Connection error. Please check internet or backend server.';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';

      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate';

      case DioExceptionType.unknown:
        return error.message ?? 'Unknown network error';

      case DioExceptionType.transformTimeout:
        return 'Transform timeout';

      default:
        return error.message ?? 'Network error';
    }
  }
}