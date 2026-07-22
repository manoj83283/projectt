import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  ReviewRepository._();

  static final ReviewRepository instance =
      ReviewRepository._();

  final ReviewService _reviewService =
      ReviewService.instance;

  // ==========================================
  // CREATE REVIEW
  // ==========================================

  Future<ReviewModel> createReview({
    required String providerId,
    required String bookingId,
    required double rating,
    required String review,
    List<String>? images,
  }) async {
    return await _reviewService.createReview(
      providerId: providerId,
      bookingId: bookingId,
      rating: rating,
      review: review,
      images: images,
    );
  }

  // ==========================================
  // GET PROVIDER REVIEWS
  // ==========================================

  Future<List<ReviewModel>>
      getProviderReviews(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _reviewService
        .getProviderReviews(
      providerId,
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET SERVICE REVIEWS
  // ==========================================

  Future<List<ReviewModel>>
      getServiceReviews(
    String serviceId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _reviewService
        .getServiceReviews(
      serviceId,
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // MY REVIEWS
  // ==========================================

  Future<List<ReviewModel>> getMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    return await _reviewService.getMyReviews(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET REVIEW BY ID
  // ==========================================

  Future<ReviewModel> getReviewById(
    String reviewId,
  ) async {
    return await _reviewService.getReviewById(
      reviewId,
    );
  }

  // ==========================================
  // UPDATE REVIEW
  // ==========================================

  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    required String review,
    List<String>? images,
  }) async {
    return await _reviewService.updateReview(
      reviewId: reviewId,
      rating: rating,
      review: review,
      images: images,
    );
  }

  // ==========================================
  // DELETE REVIEW
  // ==========================================

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    return await _reviewService.deleteReview(
      reviewId,
    );
  }

  // ==========================================
  // LIKE REVIEW
  // ==========================================

  Future<bool> likeReview(
    String reviewId,
  ) async {
    return await _reviewService.likeReview(
      reviewId,
    );
  }

  // ==========================================
  // UNLIKE REVIEW
  // ==========================================

  Future<bool> unlikeReview(
    String reviewId,
  ) async {
    return await _reviewService.unlikeReview(
      reviewId,
    );
  }

  // ==========================================
  // REPORT REVIEW
  // ==========================================

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    return await _reviewService.reportReview(
      reviewId: reviewId,
      reason: reason,
    );
  }

  // ==========================================
  // REVIEW ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getReviewAnalytics(
    String providerId,
  ) async {
    return await _reviewService
        .getReviewAnalytics(
      providerId,
    );
  }

  // ==========================================
  // PROVIDER RATING SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getProviderRatingSummary(
    String providerId,
  ) async {
    return await _reviewService
        .getProviderRatingSummary(
      providerId,
    );
  }
}