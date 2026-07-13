import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static const String _appTag = 'EventEase';

  // =====================================================
  // DEBUG
  // =====================================================

  static void debug(
    String message, {
    String tag = 'DEBUG',
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: '$_appTag/$tag',
      );
    }
  }

  // =====================================================
  // INFO
  // =====================================================

  static void info(
    String message, {
    String tag = 'INFO',
  }) {
    developer.log(
      message,
      name: '$_appTag/$tag',
    );
  }

  // =====================================================
  // WARNING
  // =====================================================

  static void warning(
    String message, {
    String tag = 'WARNING',
  }) {
    developer.log(
      message,
      level: 900,
      name: '$_appTag/$tag',
    );
  }

  // =====================================================
  // ERROR
  // =====================================================

  static void error(
    dynamic error, {
    String tag = 'ERROR',
    StackTrace? stackTrace,
  }) {
    developer.log(
      error.toString(),
      level: 1000,
      name: '$_appTag/$tag',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // =====================================================
  // EXCEPTION
  // =====================================================

  static void exception(
    Exception exception, {
    StackTrace? stackTrace,
  }) {
    developer.log(
      exception.toString(),
      level: 1000,
      name: '$_appTag/EXCEPTION',
      error: exception,
      stackTrace: stackTrace,
    );
  }

  // =====================================================
  // API REQUEST
  // =====================================================

  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    developer.log(
      '''
══════════ API REQUEST ══════════
METHOD : $method
URL    : $url

HEADERS:
$headers

BODY:
$body
═════════════════════════════════
''',
      name: '$_appTag/API_REQUEST',
    );
  }

  // =====================================================
  // API RESPONSE
  // =====================================================

  static void apiResponse({
    required String url,
    required int statusCode,
    dynamic response,
  }) {
    if (!kDebugMode) return;

    developer.log(
      '''
══════════ API RESPONSE ══════════
URL         : $url
STATUS CODE : $statusCode

RESPONSE:
$response
══════════════════════════════════
''',
      name: '$_appTag/API_RESPONSE',
    );
  }

  // =====================================================
  // API ERROR
  // =====================================================

  static void apiError({
    required String url,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '''
══════════ API ERROR ══════════
URL:
$url

ERROR:
$error
═══════════════════════════════
''',
      name: '$_appTag/API_ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  // =====================================================
  // AUTH LOG
  // =====================================================

  static void auth(String message) {
    info(
      message,
      tag: 'AUTH',
    );
  }

  // =====================================================
  // SOCKET LOG
  // =====================================================

  static void socket(String message) {
    debug(
      message,
      tag: 'SOCKET',
    );
  }

  // =====================================================
  // DATABASE LOG
  // =====================================================

  static void database(String message) {
    debug(
      message,
      tag: 'DATABASE',
    );
  }

  // =====================================================
  // USER ACTION LOG
  // =====================================================

  static void action(String message) {
    info(
      message,
      tag: 'USER_ACTION',
    );
  }

  // =====================================================
  // PERFORMANCE LOG
  // =====================================================

  static void performance(
    String operation,
    Duration duration,
  ) {
    developer.log(
      '$operation took ${duration.inMilliseconds}ms',
      name: '$_appTag/PERFORMANCE',
    );
  }

  // =====================================================
  // CRASH LOG
  // =====================================================

  static void crash(
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      error.toString(),
      name: '$_appTag/CRASH',
      error: error,
      stackTrace: stackTrace,
      level: 2000,
    );

    // Firebase Crashlytics Integration Example
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    // );
  }
}