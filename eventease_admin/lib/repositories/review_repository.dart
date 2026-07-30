import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _reviewService;

  ReviewRepository({
    ReviewService? reviewService,
  }) : _reviewService =
            reviewService ??
                ReviewService();

  // =====================================================
  // GET REVIEWS
  // =====================================================

  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int limit = 20,
    String? search,
    String? providerId,
    String? serviceId,
    String? customerId,
    double? rating,
    bool? isApproved,
  }) async {
    try {
      return await _reviewService.getReviews(
        page: page,
        limit: limit,
        search: search,
        providerId: providerId,
        serviceId: serviceId,
        customerId: customerId,
        rating: rating,
        isApproved: isApproved,
      );
    } catch (e) {
      rethrow;
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
      return await _reviewService
          .getReviewDetails(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH REVIEWS
  // =====================================================

  Future<List<dynamic>> searchReviews(
    String keyword,
  ) async {
    try {
      return await _reviewService
          .searchReviews(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // APPROVE REVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      approveReview(
    String reviewId,
  ) async {
    try {
      return await _reviewService
          .approveReview(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REJECT REVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      rejectReview(
    String reviewId,
  ) async {
    try {
      return await _reviewService
          .rejectReview(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // HIDE REVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      hideReview(
    String reviewId,
  ) async {
    try {
      return await _reviewService
          .hideReview(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UNHIDE REVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      unHideReview(
    String reviewId,
  ) async {
    try {
      return await _reviewService
          .unHideReview(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REPLY TO REVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      return await _reviewService
          .replyToReview(
        reviewId: reviewId,
        reply: reply,
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
      return await _reviewService
          .getProviderReviews(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SERVICE REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getServiceReviews(
    String serviceId,
  ) async {
    try {
      return await _reviewService
          .getServiceReviews(
        serviceId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getCustomerReviews(
    String customerId,
  ) async {
    try {
      return await _reviewService
          .getCustomerReviews(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVIEW ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewAnalytics() async {
    try {
      return await _reviewService
          .getReviewAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RATING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRatingAnalytics({
    String? providerId,
    String? serviceId,
  }) async {
    try {
      return await _reviewService
          .getRatingAnalytics(
        providerId: providerId,
        serviceId: serviceId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REPORTED REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getReportedReviews() async {
    try {
      return await _reviewService
          .getReportedReviews();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE REVIEW
  // =====================================================

  Future<void> deleteReview(
    String reviewId,
  ) async {
    try {
      await _reviewService.deleteReview(
        reviewId,
      );
    } catch (e) {
      rethrow;
    }
  }
}