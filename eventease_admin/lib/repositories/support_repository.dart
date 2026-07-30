import '../services/support_service.dart';

class SupportRepository {
  final SupportService _supportService;

  SupportRepository({
    SupportService? supportService,
  }) : _supportService =
            supportService ??
                SupportService();

  // =====================================================
  // GET SUPPORT TICKETS
  // =====================================================

  Future<Map<String, dynamic>> getTickets({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
    String? ticketType,
    String? assignedTo,
  }) async {
    try {
      return await _supportService.getTickets(
        page: page,
        limit: limit,
        search: search,
        status: status,
        priority: priority,
        ticketType: ticketType,
        assignedTo: assignedTo,
      );
    } catch (e) {
      rethrow;
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
      return await _supportService
          .getTicketDetails(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH TICKETS
  // =====================================================

  Future<List<dynamic>> searchTickets(
    String keyword,
  ) async {
    try {
      return await _supportService
          .searchTickets(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ASSIGN TICKET
  // =====================================================

  Future<Map<String, dynamic>>
      assignTicket({
    required String ticketId,
    required String adminId,
  }) async {
    try {
      return await _supportService
          .assignTicket(
        ticketId: ticketId,
        adminId: adminId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REPLY TO TICKET
  // =====================================================

  Future<Map<String, dynamic>>
      replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    try {
      return await _supportService
          .replyToTicket(
        ticketId: ticketId,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MARK IN PROGRESS
  // =====================================================

  Future<Map<String, dynamic>>
      markInProgress(
    String ticketId,
  ) async {
    try {
      return await _supportService
          .markInProgress(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RESOLVE TICKET
  // =====================================================

  Future<Map<String, dynamic>>
      resolveTicket(
    String ticketId,
  ) async {
    try {
      return await _supportService
          .resolveTicket(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CLOSE TICKET
  // =====================================================

  Future<Map<String, dynamic>>
      closeTicket(
    String ticketId,
  ) async {
    try {
      return await _supportService
          .closeTicket(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REOPEN TICKET
  // =====================================================

  Future<Map<String, dynamic>>
      reopenTicket(
    String ticketId,
  ) async {
    try {
      return await _supportService
          .reopenTicket(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TICKET CONVERSATIONS
  // =====================================================

  Future<List<dynamic>>
      getTicketMessages(
    String ticketId,
  ) async {
    try {
      return await _supportService
          .getTicketMessages(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER TICKETS
  // =====================================================

  Future<List<dynamic>>
      getCustomerTickets(
    String customerId,
  ) async {
    try {
      return await _supportService
          .getCustomerTickets(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER TICKETS
  // =====================================================

  Future<List<dynamic>>
      getProviderTickets(
    String providerId,
  ) async {
    try {
      return await _supportService
          .getProviderTickets(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TICKET ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSupportAnalytics() async {
    try {
      return await _supportService
          .getSupportAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SLA REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getSlaReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _supportService
          .getSlaReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE TICKET
  // =====================================================

  Future<void> deleteTicket(
    String ticketId,
  ) async {
    try {
      await _supportService.deleteTicket(
        ticketId,
      );
    } catch (e) {
      rethrow;
    }
  }
}