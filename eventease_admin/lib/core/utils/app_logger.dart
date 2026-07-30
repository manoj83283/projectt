import 'dart:convert';
import 'dart:developer';

class AppLogger {
  AppLogger._();

  static const String _tag =
      'EVENTEASE_ADMIN';

  static bool enableLogs = true;

  // =====================================================
  // DEBUG
  // =====================================================

  static void debug(
    String message, {
    String tag = _tag,
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
🔹 DEBUG
TAG     : $tag
MESSAGE : $message
DATA    : ${_formatData(data)}
''',
      name: tag,
    );
  }

  // =====================================================
  // INFO
  // =====================================================

  static void info(
    String message, {
    String tag = _tag,
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
✅ INFO
TAG     : $tag
MESSAGE : $message
DATA    : ${_formatData(data)}
''',
      name: tag,
    );
  }

  // =====================================================
  // WARNING
  // =====================================================

  static void warning(
    String message, {
    String tag = _tag,
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
⚠️ WARNING
TAG     : $tag
MESSAGE : $message
DATA    : ${_formatData(data)}
''',
      name: tag,
    );
  }

  // =====================================================
  // ERROR
  // =====================================================

  static void error(
    String message, {
    String tag = _tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!enableLogs) return;

    log(
      '''
❌ ERROR
TAG     : $tag
MESSAGE : $message
ERROR   : ${_formatData(error)}
STACK   : $stackTrace
''',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // =====================================================
  // API REQUEST
  // =====================================================

  static void apiRequest({
    required String method,
    required String url,
    dynamic body,
    dynamic query,
    dynamic headers,
  }) {
    if (!enableLogs) return;

    log(
      '''
════════ API REQUEST ════════
METHOD  : $method
URL     : $url
QUERY   : ${_formatData(query)}
BODY    : ${_formatData(body)}
HEADERS : ${_formatData(headers)}
═════════════════════════════
''',
      name: 'API_REQUEST',
    );
  }

  // =====================================================
  // API RESPONSE
  // =====================================================

  static void apiResponse({
    required String url,
    required int? statusCode,
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
════════ API RESPONSE ═══════
URL        : $url
STATUS CODE: $statusCode
DATA       : ${_formatData(data)}
═════════════════════════════
''',
      name: 'API_RESPONSE',
    );
  }

  // =====================================================
  // API ERROR
  // =====================================================

  static void apiError({
    required String url,
    int? statusCode,
    dynamic error,
  }) {
    if (!enableLogs) return;

    log(
      '''
════════ API ERROR ══════════
URL        : $url
STATUS CODE: $statusCode
ERROR      : ${_formatData(error)}
═════════════════════════════
''',
      name: 'API_ERROR',
    );
  }

  // =====================================================
  // AUTH LOG
  // =====================================================

  static void auth(
    String action, {
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
🔐 AUTH
ACTION : $action
DATA   : ${_formatData(data)}
''',
      name: 'AUTH',
    );
  }

  // =====================================================
  // SOCKET LOG
  // =====================================================

  static void socket(
    String event, {
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
🔌 SOCKET
EVENT : $event
DATA  : ${_formatData(data)}
''',
      name: 'SOCKET',
    );
  }

  // =====================================================
  // NAVIGATION LOG
  // =====================================================

  static void navigation(
    String route, {
    dynamic arguments,
  }) {
    if (!enableLogs) return;

    log(
      '''
🧭 NAVIGATION
ROUTE     : $route
ARGUMENTS : ${_formatData(arguments)}
''',
      name: 'NAVIGATION',
    );
  }

  // =====================================================
  // PROVIDER LOG
  // =====================================================

  static void provider(
    String providerName, {
    String action = '',
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
📦 PROVIDER
NAME   : $providerName
ACTION : $action
DATA   : ${_formatData(data)}
''',
      name: 'PROVIDER',
    );
  }

  // =====================================================
  // REPOSITORY LOG
  // =====================================================

  static void repository(
    String repositoryName, {
    String action = '',
    dynamic data,
  }) {
    if (!enableLogs) return;

    log(
      '''
🗄 REPOSITORY
NAME   : $repositoryName
ACTION : $action
DATA   : ${_formatData(data)}
''',
      name: 'REPOSITORY',
    );
  }

  // =====================================================
  // JSON PRETTY PRINT
  // =====================================================

  static String prettyJson(
    dynamic jsonObject,
  ) {
    try {
      const encoder =
          JsonEncoder.withIndent('  ');

      return encoder.convert(
        jsonObject,
      );
    } catch (_) {
      return jsonObject.toString();
    }
  }

  // =====================================================
  // FORMAT DATA
  // =====================================================

  static String _formatData(
    dynamic data,
  ) {
    if (data == null) {
      return 'NULL';
    }

    try {
      if (data is Map ||
          data is List) {
        return prettyJson(data);
      }

      return data.toString();
    } catch (_) {
      return 'Unable to parse data';
    }
  }
}
