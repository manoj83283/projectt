import 'package:dio/dio.dart';

import 'dio_client.dart';
import 'api_exception.dart';

class ApiService {
  ApiService._();

  // =====================================================
  // GET
  // =====================================================

  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await DioClient.get(
        endpoint,
        queryParameters:
            queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // POST
  // =====================================================

  static Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await DioClient.post(
        endpoint,
        data: data,
        queryParameters:
            queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // PUT
  // =====================================================

  static Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await DioClient.put(
        endpoint,
        data: data,
        queryParameters:
            queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // PATCH
  // =====================================================

  static Future<dynamic> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await DioClient.patch(
        endpoint,
        data: data,
        queryParameters:
            queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  static Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await DioClient.delete(
        endpoint,
        data: data,
        queryParameters:
            queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // FILE UPLOAD
  // =====================================================

  static Future<dynamic> uploadFile({
    required String endpoint,
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response =
          await DioClient.uploadFile(
        path: endpoint,
        formData: formData,
        onSendProgress:
            onSendProgress,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // FILE DOWNLOAD
  // =====================================================

  static Future<void> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await DioClient.download(
        url,
        savePath,
        onReceiveProgress:
            onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // =====================================================
  // AUTH TOKEN
  // =====================================================

  static void setAccessToken(
    String token,
  ) {
    DioClient.setAuthToken(token);
  }

  // =====================================================
  // CLEAR TOKEN
  // =====================================================

  static void clearSession() {
    DioClient.clearAuthToken();
  }

  // =====================================================
  // UPDATE HEADER
  // =====================================================

  static void updateHeader({
    required String key,
    required String value,
  }) {
    DioClient.updateHeader(
      key: key,
      value: value,
    );
  }

  // =====================================================
  // RESET HEADERS
  // =====================================================

  static void resetHeaders() {
    DioClient.resetHeaders();
  }
}