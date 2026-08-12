import 'package:flutter/foundation.dart';

import '../models/settlement_model.dart';
import '../services/settlement_service.dart';

class SettlementProvider extends ChangeNotifier {
  final SettlementService _settlementService =
      SettlementService();

  bool _isLoading = false;

  String? _errorMessage;

  List<SettlementModel> _settlements = [];

  SettlementModel? _selectedSettlement;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalSettlements = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<SettlementModel> get settlements =>
      _settlements;

  SettlementModel? get selectedSettlement =>
      _selectedSettlement;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalSettlements =>
      _totalSettlements;

  bool get hasSettlements =>
      _settlements.isNotEmpty;

  double get totalSettlementAmount =>
      _settlements.fold(
        0,
        (sum, settlement) =>
            sum + settlement.netAmount,
      );

  // =====================================================
  // GET SETTLEMENTS
  // =====================================================

  Future<void> getSettlements({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? providerId,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _settlementService
              .getSettlements(
        page: page,
        limit: limit,
        search: search,
        status: status,
        providerId: providerId,
      );

      _settlements =
          (response['settlements'] as List? ??
                  [])
              .map(
                (e) =>
                    SettlementModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalSettlements =
          response['totalSettlements'] ??
              _settlements.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET SETTLEMENT DETAILS
  // =====================================================

  Future<void> getSettlementDetails(
    String settlementId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _settlementService
              .getSettlementDetails(
        settlementId,
      );

      _selectedSettlement =
          SettlementModel.fromJson(
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
  // SEARCH SETTLEMENTS
  // =====================================================

  Future<void> searchSettlements(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _settlementService
              .searchSettlements(
        keyword,
      );

      _settlements =
          (response)
              .map(
                (e) =>
                    SettlementModel.fromJson(
                  e,
                ),
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
  // APPROVE SETTLEMENT
  // =====================================================

  Future<bool> approveSettlement(
    String settlementId,
  ) async {
    try {
      _setLoading(true);

      await _settlementService
          .approveSettlement(
        settlementId,
      );

      final index =
          _settlements.indexWhere(
        (e) => e.id == settlementId,
      );

      if (index != -1) {
        _settlements[index] =
            _settlements[index].copyWith(
          status: 'approved',
          approvedAt: DateTime.now(),
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
  // MARK AS PAID
  // =====================================================

  Future<bool> markSettlementPaid(
    String settlementId,
  ) async {
    try {
      _setLoading(true);

      await _settlementService
          .markSettlementPaid(
        settlementId,
      );

      final index =
          _settlements.indexWhere(
        (e) => e.id == settlementId,
      );

      if (index != -1) {
        _settlements[index] =
            _settlements[index].copyWith(
          status: 'paid',
          paidAt: DateTime.now(),
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
  // REJECT SETTLEMENT
  // =====================================================

  Future<bool> rejectSettlement({
    required String settlementId,
    required String reason,
  }) async {
    try {
      _setLoading(true);

      await _settlementService
          .rejectSettlement(
        settlementId: settlementId,
        reason: reason,
      );

      final index =
          _settlements.indexWhere(
        (e) => e.id == settlementId,
      );

      if (index != -1) {
        _settlements[index] =
            _settlements[index].copyWith(
          status: 'rejected',
          rejectionReason: reason,
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
  // DELETE SETTLEMENT
  // =====================================================

  Future<bool> deleteSettlement(
    String settlementId,
  ) async {
    try {
      _setLoading(true);

      await _settlementService
          .deleteSettlement(
        settlementId,
      );

      _settlements.removeWhere(
        (e) => e.id == settlementId,
      );

      if (_selectedSettlement?.id ==
          settlementId) {
        _selectedSettlement = null;
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
  // REFRESH SETTLEMENTS
  // =====================================================

  Future<void> refreshSettlements() async {
    await getSettlements(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED SETTLEMENT
  // =====================================================

  void clearSelectedSettlement() {
    _selectedSettlement = null;
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