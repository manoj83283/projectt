import 'package:flutter/foundation.dart';

import '../models/ticket_model.dart';
import '../services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService _supportService =
      SupportService();

  bool _isLoading = false;

  String? _errorMessage;

  List<TicketModel> _tickets = [];

  TicketModel? _selectedTicket;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalTickets = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<TicketModel> get tickets =>
      _tickets;

  TicketModel? get selectedTicket =>
      _selectedTicket;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalTickets => _totalTickets;

  bool get hasTickets =>
      _tickets.isNotEmpty;

  List<TicketModel> get openTickets =>
      _tickets
          .where((e) => e.isOpen)
          .toList();

  List<TicketModel> get closedTickets =>
      _tickets
          .where((e) => e.isClosed)
          .toList();

  List<TicketModel> get highPriorityTickets =>
      _tickets
          .where((e) => e.isHighPriority)
          .toList();

  // =====================================================
  // GET TICKETS
  // =====================================================

  Future<void> getTickets({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _supportService.getTickets(
        page: page,
        limit: limit,
        search: search,
        status: status,
        priority: priority,
      );

      _tickets =
          (response['tickets'] as List? ??
                  [])
              .map(
                (e) =>
                    TicketModel.fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalTickets =
          response['totalTickets'] ??
              _tickets.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET TICKET DETAILS
  // =====================================================

  Future<void> getTicketDetails(
    String ticketId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _supportService
              .getTicketDetails(
        ticketId,
      );

      _selectedTicket =
          TicketModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH TICKETS
  // =====================================================

  Future<void> searchTickets(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _supportService
              .searchTickets(
        keyword,
      );

      _tickets =
          (response)
              .map(
                (e) =>
                    TicketModel.fromJson(e),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
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
      _setLoading(true);

      await _supportService.assignTicket(
        ticketId: ticketId,
        adminId: adminId,
      );

      await getTicketDetails(ticketId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
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
      _setLoading(true);

      await _supportService.replyToTicket(
        ticketId: ticketId,
        message: message,
      );

      await getTicketDetails(ticketId);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // MARK IN PROGRESS
  // =====================================================

  Future<bool> markInProgress(
    String ticketId,
  ) async {
    try {
      _setLoading(true);

      await _supportService.markInProgress(
        ticketId,
      );

      final index =
          _tickets.indexWhere(
        (e) => e.id == ticketId,
      );

      if (index != -1) {
        _tickets[index] =
            _tickets[index].copyWith(
          status: 'in_progress',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RESOLVE TICKET
  // =====================================================

  Future<bool> resolveTicket(
    String ticketId,
  ) async {
    try {
      _setLoading(true);

      await _supportService.resolveTicket(
        ticketId,
      );

      final index =
          _tickets.indexWhere(
        (e) => e.id == ticketId,
      );

      if (index != -1) {
        _tickets[index] =
            _tickets[index].copyWith(
          status: 'resolved',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CLOSE TICKET
  // =====================================================

  Future<bool> closeTicket(
    String ticketId,
  ) async {
    try {
      _setLoading(true);

      await _supportService.closeTicket(
        ticketId,
      );

      final index =
          _tickets.indexWhere(
        (e) => e.id == ticketId,
      );

      if (index != -1) {
        _tickets[index] =
            _tickets[index].copyWith(
          status: 'closed',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE TICKET
  // =====================================================

  Future<bool> deleteTicket(
    String ticketId,
  ) async {
    try {
      _setLoading(true);

      await _supportService.deleteTicket(
        ticketId,
      );

      _tickets.removeWhere(
        (e) => e.id == ticketId,
      );

      if (_selectedTicket?.id ==
          ticketId) {
        _selectedTicket = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH TICKETS
  // =====================================================

  Future<void> refreshTickets() async {
    await getTickets(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED TICKET
  // =====================================================

  void clearSelectedTicket() {
    _selectedTicket = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}