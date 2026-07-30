import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class ApiService {
  ApiService._internal();

  static final ApiService _instance =
      ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio = Dio(
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
        'Content-Type':
            'application/json',
        'Accept':
            'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (options, handler) async {
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
        onError: (
          DioException error,
          handler,
        ) {
          handler.next(error);
        },
      ),
    );

  Dio get dio => _dio;

  //===========================
  // GET
  //===========================

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: query,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // POST
  //===========================

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: query,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // PUT
  //===========================

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: query,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // PATCH
  //===========================

  Future<Response> patch(
    String endpoint, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // DELETE
  //===========================

  Future<Response> delete(
    String endpoint, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // FILE UPLOAD
  //===========================

  Future<Response> uploadFile({
    required String endpoint,
    required File file,
    String fileField = 'file',
    Map<String, dynamic>? fields,
  }) async {
    try {
      final formData = FormData();

      formData.files.add(
        MapEntry(
          fileField,
          await MultipartFile.fromFile(
            file.path,
          ),
        ),
      );

      if (fields != null) {
        formData.fields.addAll(
          fields.entries.map(
            (e) => MapEntry(
              e.key,
              e.value.toString(),
            ),
          ),
        );
      }

      return await _dio.post(
        endpoint,
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // MULTIPLE FILES UPLOAD
  //===========================

  Future<Response> uploadFiles({
    required String endpoint,
    required List<File> files,
    String fileField = 'files',
    Map<String, dynamic>? fields,
  }) async {
    try {
      final formData = FormData();

      for (final file in files) {
        formData.files.add(
          MapEntry(
            fileField,
            await MultipartFile.fromFile(
              file.path,
            ),
          ),
        );
      }

      if (fields != null) {
        formData.fields.addAll(
          fields.entries.map(
            (e) => MapEntry(
              e.key,
              e.value.toString(),
            ),
          ),
        );
      }

      return await _dio.post(
        endpoint,
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // DOWNLOAD FILE
  //===========================

  Future<void> downloadFile({
    required String url,
    required String savePath,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //===========================
  // ERROR HANDLER
  //===========================

  String _handleError(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.sendTimeout:
        return 'Request timeout';

      case DioExceptionType.receiveTimeout:
        return 'Server timeout';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.badResponse:
        return error.response?.data?[
                'message'] ??
            'Something went wrong';

      default:
        return 'Unexpected error occurred';
    }
  }
}