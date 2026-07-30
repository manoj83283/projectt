import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../storage/storage_helper.dart';
import '../../routes/navigation_service.dart';
import '../../routes/app_routes.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor();

  // =====================================================
  // REQUEST
  // =====================================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token =
          StorageHelper.getString(
        StorageKeys.accessToken,
      );

      if (token != null &&
          token.isNotEmpty) {
        options.headers[
                ApiConstants.authorization] =
            '${ApiConstants.bearer} $token';
      }

      log('''
================ REQUEST ================
METHOD : ${options.method}
URL    : ${options.baseUrl}${options.path}
QUERY  : ${options.queryParameters}
BODY   : ${options.data}
HEADERS: ${options.headers}
=========================================
''');

      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  // =====================================================
  // RESPONSE
  // =====================================================

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    log('''
================ RESPONSE =================
STATUS : ${response.statusCode}
URL    : ${response.requestOptions.uri}
DATA   : ${jsonEncode(response.data)}
============================================
''');

    handler.next(response);
  }

  // =====================================================
  // ERROR
  // =====================================================

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    log('''
================ ERROR ====================
STATUS : ${err.response?.statusCode}
TYPE   : ${err.type}
URL    : ${err.requestOptions.uri}
ERROR  : ${err.message}
DATA   : ${err.response?.data}
============================================
''');

    final statusCode =
        err.response?.statusCode;

    switch (statusCode) {
      case 401:
        await _handleUnauthorized();
        break;

      case 403:
        _handleForbidden();
        break;

      case 500:
        log(
          'Internal Server Error',
        );
        break;

      default:
        break;
    }

    handler.next(err);
  }

  // =====================================================
  // HANDLE UNAUTHORIZED
  // =====================================================

  Future<void>
      _handleUnauthorized() async {
    try {
      await StorageHelper.clearKeys([
        StorageKeys.accessToken,
        StorageKeys.refreshToken,
        StorageKeys.isLoggedIn,
        StorageKeys.adminProfile,
      ]);

      NavigationService.pushAndRemoveUntil(
        AppRoutes.login,
      );

      NavigationService.showError(
        'Session expired. Please login again.',
      );
    } catch (e) {
      log(
        'Unauthorized handling failed: $e',
      );
    }
  }

  // =====================================================
  // HANDLE FORBIDDEN
  // =====================================================

  void _handleForbidden() {
    try {
      NavigationService.showError(
        'Access denied.',
      );

      NavigationService.push(
        AppRoutes.unauthorized,
      );
    } catch (e) {
      log(
        'Forbidden handling failed: $e',
      );
    }
  }
}