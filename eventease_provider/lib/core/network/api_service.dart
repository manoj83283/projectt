import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/storage_helper.dart';

class ApiService {
  ApiService._internal();

  static final ApiService instance = ApiService._internal();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api';

      case TargetPlatform.iOS:
        return 'http://127.0.0.1:5000/api';

      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://192.168.1.40:5000/api';
    }
  }

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageHelper.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

  Dio get dio => _dio;

  // =============================================================
  // ✅ NORMALIZE RESPONSE
  // =============================================================
  dynamic _normalizeResponse(Response response) {
    final data = response.data;

    if (data == null) {
      return {};
    }

    return data;
  }

  // =============================================================
  // ✅ GET
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
  // ✅ POST
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
  // ✅ PUT
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
  // ✅ PATCH
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
  // ✅ DELETE
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
  // ✅ UPLOAD SINGLE FILE
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
          MapEntry(entry.key, entry.value.toString()),
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
  // ✅ UPLOAD MULTIPLE FILES
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
          MapEntry(entry.key, entry.value.toString()),
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
  // ✅ ERROR HANDLER
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

      default:
        return error.message ?? 'Network error';
    }
  }
}