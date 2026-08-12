import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class KycService {
  KycService._();

  static final KycService _instance =
      KycService._();

  factory KycService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL KYC REQUESTS
  // =====================================================

  Future<Map<String, dynamic>> getKycRequests({
    int page = 1,
    int limit = 20,
    String? status,
    String? providerId,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        '/admin/kyc',
        query: {
          'page': page,
          'limit': limit,
          'status': ?status,
          'providerId': ?providerId,
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
  // GET KYC DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getKycDetails(
    String kycId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/kyc/$kycId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER KYC
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderKyc(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/kyc',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE KYC
  // =====================================================

  Future<bool> approveKyc({
    required String kycId,
    String? remarks,
  }) async {
    try {
      await _api.patch(
        '/admin/kyc/$kycId/approve',
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
  // REJECT KYC
  // =====================================================

  Future<bool> rejectKyc({
    required String kycId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/kyc/$kycId/reject',
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
  // REQUEST RE-SUBMISSION
  // =====================================================

  Future<bool> requestResubmission({
    required String kycId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/kyc/$kycId/resubmit',
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
  // VERIFY DOCUMENT
  // =====================================================

  Future<bool> verifyDocument({
    required String kycId,
    required String documentId,
  }) async {
    try {
      await _api.patch(
        '/admin/kyc/$kycId/documents/$documentId/verify',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT DOCUMENT
  // =====================================================

  Future<bool> rejectDocument({
    required String kycId,
    required String documentId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/kyc/$kycId/documents/$documentId/reject',
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
  // GET PENDING KYC
  // =====================================================

  Future<List<dynamic>>
      getPendingKycRequests() async {
    try {
      final response = await _api.get(
        '/admin/kyc/pending',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET APPROVED KYC
  // =====================================================

  Future<List<dynamic>>
      getApprovedKycRequests() async {
    try {
      final response = await _api.get(
        '/admin/kyc/approved',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET REJECTED KYC
  // =====================================================

  Future<List<dynamic>>
      getRejectedKycRequests() async {
    try {
      final response = await _api.get(
        '/admin/kyc/rejected',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // KYC ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getKycAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/kyc/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // KYC STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getKycStatistics() async {
    try {
      final response = await _api.get(
        '/admin/kyc/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH KYC
  // =====================================================

  Future<List<dynamic>>
      searchKyc(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/kyc/search',
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
  // EXPORT KYC REPORT
  // =====================================================

  Future<Response<dynamic>>
      exportKyc({
    String format = 'excel',
    String? status,
  }) async {
    try {
      return await _api.get(
        '/admin/kyc/export',
        query: {
          'format': format,
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK APPROVE KYC
  // =====================================================

  Future<bool> bulkApproveKyc(
    List<String> kycIds,
  ) async {
    try {
      await _api.post(
        '/admin/kyc/bulk-approve',
        data: {
          'kycIds': kycIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK REJECT KYC
  // =====================================================

  Future<bool> bulkRejectKyc({
    required List<String> kycIds,
    required String reason,
  }) async {
    try {
      await _api.post(
        '/admin/kyc/bulk-reject',
        data: {
          'kycIds': kycIds,
          'reason': reason,
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