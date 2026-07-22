import '../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance =
      ReviewService._();

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
    final response =
        await ApiService.instance.post(
      '/reviews',
      data: {
        'providerId': providerId,
        'bookingId': bookingId,
        'rating': rating,
        'review': review,
        'images': images,
      },
    );

    return ReviewModel.fromMap(
      response.data['data'] ??
          response.data['review'],
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
    final response =
        await ApiService.instance.get(
      '/reviews/provider/$providerId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List reviews =
        response.data['data'] ??
            response.data['reviews'] ??
            [];

    return reviews
        .map(
          (e) => ReviewModel.fromMap(e),
        )
        .toList();
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
    final response =
        await ApiService.instance.get(
      '/reviews/service/$serviceId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List reviews =
        response.data['data'] ??
            response.data['reviews'] ??
            [];

    return reviews
        .map(
          (e) => ReviewModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // MY REVIEWS
  // ==========================================

  Future<List<ReviewModel>> getMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/reviews/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List reviews =
        response.data['data'] ??
            response.data['reviews'] ??
            [];

    return reviews
        .map(
          (e) => ReviewModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET REVIEW BY ID
  // ==========================================

  Future<ReviewModel> getReviewById(
    String reviewId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/reviews/$reviewId',
    );

    return ReviewModel.fromMap(
      response.data['data'] ??
          response.data['review'],
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
    final response =
        await ApiService.instance.patch(
      '/reviews/$reviewId',
      data: {
        'rating': rating,
        'review': review,
        'images': images,
      },
    );

    return ReviewModel.fromMap(
      response.data['data'] ??
          response.data['review'],
    );
  }

  // ==========================================
  // DELETE REVIEW
  // ==========================================

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    await ApiService.instance.delete(
      '/reviews/$reviewId',
    );

    return true;
  }

  // ==========================================
  // LIKE REVIEW
  // ==========================================

  Future<bool> likeReview(
    String reviewId,
  ) async {
    await ApiService.instance.post(
      '/reviews/$reviewId/like',
    );

    return true;
  }

  // ==========================================
  // UNLIKE REVIEW
  // ==========================================

  Future<bool> unlikeReview(
    String reviewId,
  ) async {
    await ApiService.instance.post(
      '/reviews/$reviewId/unlike',
    );

    return true;
  }

  // ==========================================
  // REPORT REVIEW
  // ==========================================

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    await ApiService.instance.post(
      '/reviews/$reviewId/report',
      data: {
        'reason': reason,
      },
    );

    return true;
  }

  // ==========================================
  // REVIEW ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getReviewAnalytics(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/reviews/provider/$providerId/analytics',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // PROVIDER RATING SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getProviderRatingSummary(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/reviews/provider/$providerId/summary',
    );

    return response.data['data'] ??
        response.data;
  }
}