import '../services/settlement_service.dart';

class SettlementRepository {
  final SettlementService _settlementService;

  SettlementRepository({
    SettlementService? settlementService,
  }) : _settlementService =
            settlementService ??
                SettlementService();

  // =====================================================
  // GET SETTLEMENTS
  // =====================================================

  Future<Map<String, dynamic>> getSettlements({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _settlementService
          .getSettlements(
        page: page,
        limit: limit,
        search: search,
        status: status,
        providerId: providerId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET SETTLEMENT DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementDetails(
    String settlementId,
  ) async {
    try {
      return await _settlementService
          .getSettlementDetails(
        settlementId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH SETTLEMENTS
  // =====================================================

  Future<List<dynamic>>
      searchSettlements(
    String keyword,
  ) async {
    try {
      return await _settlementService
          .searchSettlements(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CREATE SETTLEMENT
  // =====================================================

  Future<Map<String, dynamic>>
      createSettlement({
    required String providerId,
    required double grossAmount,
    required double commissionAmount,
    required double netAmount,
    required DateTime settlementDate,
    String? notes,
  }) async {
    try {
      return await _settlementService
          .createSettlement(
        providerId: providerId,
        grossAmount: grossAmount,
        commissionAmount:
            commissionAmount,
        netAmount: netAmount,
        settlementDate:
            settlementDate,
        notes: notes,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // APPROVE SETTLEMENT
  // =====================================================

  Future<Map<String, dynamic>>
      approveSettlement(
    String settlementId,
  ) async {
    try {
      return await _settlementService
          .approveSettlement(
        settlementId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REJECT SETTLEMENT
  // =====================================================

  Future<Map<String, dynamic>>
      rejectSettlement({
    required String settlementId,
    required String reason,
  }) async {
    try {
      return await _settlementService
          .rejectSettlement(
        settlementId: settlementId,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MARK SETTLEMENT PAID
  // =====================================================

  Future<Map<String, dynamic>>
      markSettlementPaid({
    required String settlementId,
    required String transactionId,
    String? paymentMethod,
  }) async {
    try {
      return await _settlementService
          .markSettlementPaid(
        settlementId: settlementId,
        transactionId:
            transactionId,
        paymentMethod:
            paymentMethod,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SETTLEMENT HISTORY
  // =====================================================

  Future<List<dynamic>>
      getSettlementHistory(
    String providerId,
  ) async {
    try {
      return await _settlementService
          .getSettlementHistory(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER SETTLEMENT# `eventease_admin/lib/repositories/settlement_repository.dart` — Production-Ready Complete Code