import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class SettlementService {
  SettlementService._();

  static final SettlementService _instance =
      SettlementService._();

  factory SettlementService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL SETTLEMENTS
  // =====================================================

  Future<Map<String, dynamic>> getSettlements({
    int page = 1,
    int limit = 20,
    String? status,
    String? providerId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/settlements',
        query: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (providerId != null)
            'providerId': providerId,
          if (startDate != null)
            'startDate': startDate,
          if (endDate != null)
            'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/settlements/$settlementId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER SETTLEMENTS
  // =====================================================

  Future<List<dynamic>>
      getProviderSettlements(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/settlements',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE SETTLEMENT
  // =====================================================

  Future<bool> approveSettlement({
    required String settlementId,
    String? remarks,
  }) async {
    try {
      await _api.patch(
        '/admin/settlements/$settlementId/approve',
        data: {
          'remarks': remarks,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      await _api.patch(
        '/admin/settlements/$settlementId/reject',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // MARK AS PAID
  // =====================================================

  Future<bool> markSettlementPaid({
    required String settlementId,
    required String transactionId,
    String? remarks,
  }) async {
    try {
      await _api.patch(
        '/admin/settlements/$settlementId/paid',
        data: {
          'transactionId':
              transactionId,
          'remarks': remarks,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE MANUAL SETTLEMENT
  // =====================================================

  Future<Map<String, dynamic>>
      createSettlement({
    required String providerId,
    required double amount,
    String? notes,
  }) async {
    try {
      final response = await _api.post(
        '/admin/settlements',
        data: {
          'providerId': providerId,
          'amount': amount,
          'notes': notes,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GENERATE SETTLEMENTS
  // =====================================================

  Future<bool> generateSettlements() async {
    try {
      await _api.post(
        '/admin/settlements/generate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SETTLEMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/settlements/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SETTLEMENT STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementStatistics() async {
    try {
      final response = await _api.get(
        '/admin/settlements/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PENDING SETTLEMENTS
  // =====================================================

  Future<List<dynamic>>
      getPendingSettlements() async {
    try {
      final response = await _api.get(
        '/admin/settlements/pending',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COMPLETED SETTLEMENTS
  // =====================================================

  Future<List<dynamic>>
      getCompletedSettlements() async {
    try {
      final response = await _api.get(
        '/admin/settlements/completed',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/settlements/search',
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
  // EXPORT SETTLEMENTS
  // =====================================================

  Future<Response<dynamic>>
      exportSettlements({
    String format = 'excel',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/settlements/export',
        query: {
          'format': format,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DOWNLOAD INVOICE
  // =====================================================

  Future<Response<dynamic>>
      downloadSettlementInvoice(
    String settlementId,
  ) async {
    try {
      return await _api.get(
        '/admin/settlements/$settlementId/invoice',
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK APPROVE
  // =====================================================

  Future<bool> bulkApprove(
    List<String> settlementIds,
  ) async {
    try {
      await _api.post(
        '/admin/settlements/bulk-approve',
        data: {
          'settlementIds':
              settlementIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK MARK PAID
  // =====================================================

  Future<bool> bulkMarkPaid({
    required List<String> settlementIds,
  }) async {
    try {
      await _api.post(
        '/admin/settlements/bulk-paid',
        data: {
          'settlementIds':
              settlementIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR PARSER
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