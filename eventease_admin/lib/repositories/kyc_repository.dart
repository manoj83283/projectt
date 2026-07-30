import '../services/kyc_service.dart';

class KycRepository {
  final KycService _kycService;

  KycRepository({
    KycService? kycService,
  }) : _kycService =
            kycService ??
                KycService();

  // =====================================================
  // GET KYC REQUESTS
  // =====================================================

  Future<Map<String, dynamic>> getKycRequests({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _kycService
          .getKycRequests(
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
  // GET KYC DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getKycDetails(
    String kycId,
  ) async {
    try {
      return await _kycService
          .getKycDetails(
        kycId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH KYC REQUESTS
  // =====================================================

  Future<List<dynamic>>
      searchKycRequests(
    String keyword,
  ) async {
    try {
      return await _kycService
          .searchKycRequests(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // APPROVE KYC
  // =====================================================

  Future<Map<String, dynamic>>
      approveKyc({
    required String kycId,
    String? remarks,
  }) async {
    try {
      return await _kycService.approveKyc(
        kycId: kycId,
        remarks: remarks,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REJECT KYC
  // =====================================================

  Future<Map<String, dynamic>>
      rejectKyc({
    required String kycId,
    required String reason,
  }) async {
    try {
      return await _kycService.rejectKyc(
        kycId: kycId,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REQUEST RESUBMISSION
  // =====================================================

  Future<Map<String, dynamic>>
      requestResubmission({
    required String kycId,
    required String reason,
  }) async {
    try {
      return await _kycService
          .requestResubmission(
        kycId: kycId,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // VERIFY DOCUMENT
  // =====================================================

  Future<Map<String, dynamic>>
      verifyDocument({
    required String kycId,
    required String documentType,
  }) async {
    try {
      return await _kycService
          .verifyDocument(
        kycId: kycId,
        documentType: documentType,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER KYC
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderKyc(
    String providerId,
  ) async {
    try {
      return await _kycService
          .getProviderKyc(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PENDING KYC REQUESTS
  // =====================================================

  Future<List<dynamic>>
      getPendingKycRequests() async {
    try {
      return await _kycService
          .getPendingKycRequests();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // APPROVED KYC REQUESTS
  // =====================================================

  Future<List<dynamic>>
      getApprovedKycRequests() async {
    try {
      return await _kycService
          .getApprovedKycRequests();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REJECTED KYC REQUESTS
  // =====================================================

  Future<List<dynamic>>
      getRejectedKycRequests() async {
    try {
      return await _kycService
          .getRejectedKycRequests();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // KYC ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getKycAnalytics() async {
    try {
      return await _kycService
          .getKycAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // KYC REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateKycReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _kycService
          .generateKycReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE KYC RECORD
  // =====================================================

  Future<void> deleteKyc(
    String kycId,
  ) async {
    try {
      await _kycService.deleteKyc(
        kycId,
      );
    } catch (e) {
      rethrow;
    }
  }
}