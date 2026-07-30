import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        connectTimeout: Duration(
          milliseconds:
              ApiConstants.connectTimeout,
        ),

        receiveTimeout: Duration(
          milliseconds:
              ApiConstants.receiveTimeout,
        ),

        sendTimeout: Duration(
          milliseconds:
              ApiConstants.sendTimeout,
        ),

        responseType: ResponseType.json,

        contentType:
            ApiConstants.applicationJson,

        headers: {
          ApiConstants.accept:
              ApiConstants.applicationJson,
          ApiConstants.contentType:
              ApiConstants.applicationJson,
        },
      ),
    );

    dio.interceptors.add(
      ApiInterceptor(),
    );

    return dio;
  }

  // =====================================================
  // GET
  // =====================================================

  static Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await instance.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // =====================================================
  // POST
  // =====================================================

  static Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await instance.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // =====================================================
  // PUT
  // =====================================================

  static Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await instance.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // =====================================================
  // PATCH
  // =====================================================

  static Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await instance.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // =====================================================
  // DELETE
  // =====================================================

  static Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await instance.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // =====================================================
  // DOWNLOAD
  // =====================================================

  static Future<Response<dynamic>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return await instance.download(
      urlPath,
      savePath,
      onReceiveProgress:
          onReceiveProgress,
    );
  }

  // =====================================================
  // MULTIPART FORM DATA
  // =====================================================

  static Future<Response<dynamic>>
      uploadFile({
    required String path,
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    return await instance.post(
      path,
      data: formData,
      onSendProgress:
          onSendProgress,
      options: Options(
        contentType:
            ApiConstants.multipartFormData,
      ),
    );
  }

  // =====================================================
  // AUTH HEADER
  // =====================================================

  static void setAuthToken(
    String token,
  ) {
    instance.options.headers[
            ApiConstants.authorization] =
        '${ApiConstants.bearer} $token';
  }

  // =====================================================
  // REMOVE AUTH HEADER
  // =====================================================

  static void clearAuthToken() {
    instance.options.headers
        .remove(
      ApiConstants.authorization,
    );
  }

  // =====================================================
  // UPDATE HEADER
  // =====================================================

  static void updateHeader({
    required String key,
    required dynamic value,
  }) {
    instance.options.headers[key] =
        value;
  }

  // =====================================================
  // RESET HEADERS
  // =====================================================

  static void resetHeaders() {
    instance.options.headers.clear();

    instance.options.headers.addAll({
      ApiConstants.accept:
          ApiConstants.applicationJson,
      ApiConstants.contentType:
          ApiConstants.applicationJson,
    });
  }

  // =====================================================
  // REQUEST OPTIONS
  // =====================================================

  static Options authorizedOptions(
    String token,
  ) {
    return Options(
      headers: {
        ApiConstants.authorization:
            '${ApiConstants.bearer} $token',
      },
    );
  }
}