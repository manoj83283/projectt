import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService _instance =
      ReviewService._();

  factory ReviewService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL REVIEWS
  // =====================================================

  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int limit = 20,
    String? search,
    String? providerId,
    String? customerId,
    String? serviceId,
    String? rating,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reviews',
        query: {
          'page': page,
          'limit': limit,
          'search': ?search,
          'providerId': ?providerId,
          'customerId': ?customerId,
          'serviceId': ?serviceId,
          'rating': ?rating,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET REVIEW DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewDetails(
    String reviewId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/reviews/$reviewId',
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
  // GET SERVICE REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getServiceReviews(
    String serviceId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/services/$serviceId/reviews',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE REVIEW
  // =====================================================

  Future<bool> approveReview(
    String reviewId,
  ) async {
    try {
      await _api.patch(
        '/admin/reviews/$reviewId/approve',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT REVIEW
  // =====================================================

  Future<bool> rejectReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/reviews/$reviewId/reject',
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
  // HIDE REVIEW
  // =====================================================

  Future<bool> hideReview(
    String reviewId,
  ) async {
    try {
      await _api.patch(
        '/admin/reviews/$reviewId/hide',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UNHIDE REVIEW
  // =====================================================

  Future<bool> unhideReview(
    String reviewId,
  ) async {
    try {
      await _api.patch(
        '/admin/reviews/$reviewId/unhide',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE REVIEW
  // =====================================================

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    try {
      await _api.delete(
        '/admin/reviews/$reviewId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ADMIN REPLY TO REVIEW
  // =====================================================

  Future<bool> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      await _api.post(
        '/admin/reviews/$reviewId/reply',
        data: {
          'reply': reply,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE REVIEW REPLY
  // =====================================================

  Future<bool> updateReply({
    required String reviewId,
    required String reply,
  }) async {
    try {
      await _api.put(
        '/admin/reviews/$reviewId/reply',
        data: {
          'reply': reply,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REVIEW REPORTS
  // =====================================================

  Future<List<dynamic>>
      getReportedReviews() async {
    try {
      final response = await _api.get(
        '/admin/reviews/reported',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REVIEW ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/reviews/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REVIEW STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewStatistics() async {
    try {
      final response = await _api.get(
        '/admin/reviews/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RATING DISTRIBUTION
  // =====================================================

  Future<Map<String, dynamic>>
      getRatingDistribution() async {
    try {
      final response = await _api.get(
        '/admin/reviews/rating-distribution',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH REVIEWS
  // =====================================================

  Future<List<dynamic>>
      searchReviews(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/reviews/search',
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
  // EXPORT REVIEWS
  // =====================================================

  Future<Response<dynamic>>
      exportReviews({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/reviews/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE REVIEWS
  // =====================================================

  Future<bool> bulkDeleteReviews(
    List<String> reviewIds,
  ) async {
    try {
      await _api.post(
        '/admin/reviews/bulk-delete',
        data: {
          'reviewIds': reviewIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK HIDE REVIEWS
  // =====================================================

  Future<bool> bulkHideReviews(
    List<String> reviewIds,
  ) async {
    try {
      await _api.post(
        '/admin/reviews/bulk-hide',
        data: {
          'reviewIds': reviewIds,
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