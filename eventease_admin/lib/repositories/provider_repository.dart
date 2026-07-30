import '../services/provider_service.dart';

class ProviderRepository {
  final ProviderService _providerService;

  ProviderRepository({
    ProviderService? providerService,
  }) : _providerService =
            providerService ??
                ProviderService();

  // =====================================================
  // GET PROVIDERS
  // =====================================================

  Future<Map<String, dynamic>> getProviders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? categoryId,
    bool? isVerified,
    bool? isBlocked,
  }) async {
    try {
      return await _providerService
          .getProviders(
        page: page,
        limit: limit,
        search: search,
        status: status,
        categoryId: categoryId,
        isVerified: isVerified,
        isBlocked: isBlocked,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET PROVIDER DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderDetails(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderDetails(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH PROVIDERS
  // =====================================================

  Future<List<dynamic>> searchProviders(
    String keyword,
  ) async {
    try {
      return await _providerService
          .searchProviders(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // APPROVE PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      approveProvider(
    String providerId,
  ) async {
    try {
      return await _providerService
          .approveProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REJECT PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      rejectProvider({
    required String providerId,
    required String reason,
  }) async {
    try {
      return await _providerService
          .rejectProvider(
        providerId,
        reason,
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
      return await _providerService
          .getProviderKyc(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER SERVICES
  // =====================================================

  Future<List<dynamic>>
      getProviderServices(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderServices(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getProviderBookings(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderBookings(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getProviderPayments(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderPayments(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getProviderReviews(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderReviews(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderAnalytics(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderAnalytics(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      activateProvider(
    String providerId,
  ) async {
    try {
      return await _providerService
          .activateProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateProvider(
    String providerId,
  ) async {
    try {
      return await _providerService
          .deactivateProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BLOCK PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      blockProvider(
    String providerId,
  ) async {
    try {
      return await _providerService
          .blockProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UNBLOCK PROVIDER
  // =====================================================

  Future<Map<String, dynamic>>
      unblockProvider(
    String providerId,
  ) async {
    try {
      return await _providerService
          .unblockProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE PROVIDER
  // =====================================================

  Future<void> deleteProvider(
    String providerId,
  ) async {
    try {
      await _providerService
          .deleteProvider(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER ACTIVITY LOGS
  // =====================================================

  Future<List<dynamic>>
      getProviderActivities(
    String providerId,
  ) async {
    try {
      return await _providerService
          .getProviderActivities(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }
}