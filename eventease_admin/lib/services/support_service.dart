import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class SupportService {
  SupportService._();

  static final SupportService _instance =
      SupportService._();

  factory SupportService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL SUPPORT TICKETS
  // =====================================================

  Future<Map<String, dynamic>> getTickets({
    int page = 1,
    int limit = 20,
    String? status,
    String? priority,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        '/admin/support/tickets',
        query: {
          'page': page,
          'limit': limit,
          'status': ?status,
          'priority': ?priority,
          'search': ?search,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET TICKET DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getTicketDetails(
    String ticketId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/support/tickets/$ticketId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ASSIGN TICKET
  // =====================================================

  Future<bool> assignTicket({
    required String ticketId,
    required String adminId,
  }) async {
    try {
      await _api.patch(
        '/admin/support/tickets/$ticketId/assign',
        data: {
          'adminId': adminId,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE TICKET STATUS
  // =====================================================

  Future<bool> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    try {
      await _api.patch(
        '/admin/support/tickets/$ticketId/status',
        data: {
          'status': status,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE PRIORITY
  // =====================================================

  Future<bool> updatePriority({
    required String ticketId,
    required String priority,
  }) async {
    try {
      await _api.patch(
        '/admin/support/tickets/$ticketId/priority',
        data: {
          'priority': priority,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REPLY TO TICKET
  // =====================================================

  Future<bool> replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/support/tickets/$ticketId/reply',
        data: {
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CLOSE TICKET
  // =====================================================

  Future<bool> closeTicket(
    String ticketId,
  ) async {
    try {
      await _api.patch(
        '/admin/support/tickets/$ticketId/close',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REOPEN TICKET
  // =====================================================

  Future<bool> reopenTicket(
    String ticketId,
  ) async {
    try {
      await _api.patch(
        '/admin/support/tickets/$ticketId/reopen',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE TICKET
  // =====================================================

  Future<bool> deleteTicket(
    String ticketId,
  ) async {
    try {
      await _api.delete(
        '/admin/support/tickets/$ticketId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET TICKET MESSAGES
  // =====================================================

  Future<List<dynamic>>
      getTicketMessages(
    String ticketId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/support/tickets/$ticketId/messages',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET CUSTOMER TICKETS
  // =====================================================

  Future<List<dynamic>>
      getCustomerTickets(
    String customerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/support/customers/$customerId/tickets',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER TICKETS
  // =====================================================

  Future<List<dynamic>>
      getProviderTickets(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/support/providers/$providerId/tickets',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SUPPORT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSupportAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/support/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SUPPORT STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSupportStatistics() async {
    try {
      final response = await _api.get(
        '/admin/support/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH TICKETS
  // =====================================================

  Future<List<dynamic>>
      searchTickets(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/support/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT TICKETS
  // =====================================================

  Future<Response<dynamic>>
      exportTickets({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/support/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK CLOSE TICKETS
  // =====================================================

  Future<bool> bulkCloseTickets(
    List<String> ticketIds,
  ) async {
    try {
      await _api.post(
        '/admin/support/bulk-close',
        data: {
          'ticketIds': ticketIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE TICKETS
  // =====================================================

  Future<bool> bulkDeleteTickets(
    List<String> ticketIds,
  ) async {
    try {
      await _api.post(
        '/admin/support/bulk-delete',
        data: {
          'ticketIds': ticketIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}