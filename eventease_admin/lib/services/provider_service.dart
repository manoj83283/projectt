import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class ProviderService {
  ProviderService._();

  static final ProviderService _instance =
      ProviderService._();

  factory ProviderService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL PROVIDERS
  // =====================================================

  Future<Map<String, dynamic>> getProviders({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? category,
    String? verificationStatus,
  }) async {
    try {
      final response = await _api.get(
        '/admin/providers',
        query: {
          'page': page,
          'limit': limit,
          if (search != null &&
              search.isNotEmpty)
            'search': search,
          'status': ?status,
          'category': ?category,
          'verificationStatus':
                ?verificationStatus,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/providers/$providerId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // VERIFY PROVIDER
  // =====================================================

  Future<bool> verifyProvider(
    String providerId,
  ) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/verify',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT VERIFICATION
  // =====================================================

  Future<bool>
      rejectProviderVerification({
    required String providerId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/reject',
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
  // BLOCK PROVIDER
  // =====================================================

  Future<bool> blockProvider({
    required String providerId,
    String? reason,
  }) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/block',
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
  // UNBLOCK PROVIDER
  // =====================================================

  Future<bool> unblockProvider(
    String providerId,
  ) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/unblock',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE PROVIDER
  // =====================================================

  Future<bool> deleteProvider(
    String providerId,
  ) async {
    try {
      await _api.delete(
        '/admin/providers/$providerId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER SERVICES
  // =====================================================

  Future<List<dynamic>>
      getProviderServices(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/services',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getProviderBookings(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/bookings',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER EARNINGS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderEarnings(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/earnings',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PROVIDER REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getProviderReviews(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/reviews',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PROVIDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/providers/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PROVIDER DOCUMENTS
  // =====================================================

  Future<List<dynamic>>
      getProviderDocuments(
    String providerId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/$providerId/documents',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE DOCUMENT
  // =====================================================

  Future<bool> approveDocument({
    required String providerId,
    required String documentId,
  }) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/documents/$documentId/approve',
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
    required String providerId,
    required String documentId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/providers/$providerId/documents/$documentId/reject',
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
  // SEND NOTIFICATION
  // =====================================================

  Future<bool> sendNotification({
    required String providerId,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/providers/$providerId/notify',
        data: {
          'title': title,
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET TOP PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      getTopProviders() async {
    try {
      final response = await _api.get(
        '/admin/providers/top',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT PROVIDERS
  // =====================================================

  Future<Response<dynamic>>
      exportProviders({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/providers/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      searchProviders(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/providers/search',
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
  // PROVIDER STATS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderStats() async {
    try {
      final response = await _api.get(
        '/admin/providers/stats',
      );

      return response.data['data']
          as Map<String, dynamic>;
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