import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/review_model.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService _instance =
      ReviewService._();

  static ReviewService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET ALL REVIEWS
  // =========================

  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => ReviewModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Reviews Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET REVIEW BY ID
  // =========================

  Future<ReviewModel> getReviewById(
    String reviewId,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/$reviewId',
      );

      return ReviewModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Review Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET SERVICE REVIEWS
  // =========================

  Future<List<ReviewModel>>
      getServiceReviews(
    String serviceId,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/service/$serviceId',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => ReviewModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Service Reviews Error: $e');
      return [];
    }
  }

  // =========================
  // GET REVIEWS BY RATING
  // =========================

  Future<List<ReviewModel>>
      getReviewsByRating(
    int rating,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/rating/$rating',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => ReviewModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Reviews By Rating Error: $e');
      return [];
    }
  }

  // =========================
  // SEARCH REVIEWS
  // =========================

  Future<List<ReviewModel>>
      searchReviews(
    String keyword,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/search?keyword=$keyword',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => ReviewModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Reviews Error: $e');
      return [];
    }
  }

  // =========================
  // PROVIDER REPLY
  // =========================

  Future<bool> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      await _apiService.post(
        '/provider/reviews/$reviewId/reply',
        body: {
          'reply': reply,
        },
      );

      return true;
    } catch (e) {
      log('Reply Review Error: $e');
      return false;
    }
  }

  // =========================
  // UPDATE REPLY
  // =========================

  Future<bool> updateReply({
    required String reviewId,
    required String reply,
  }) async {
    try {
      await _apiService.put(
        '/provider/reviews/$reviewId/reply',
        body: {
          'reply': reply,
        },
      );

      return true;
    } catch (e) {
      log('Update Reply Error: $e');
      return false;
    }
  }

  // =========================
  // DELETE REPLY
  // =========================

  Future<bool> deleteReply(
    String reviewId,
  ) async {
    try {
      await _apiService.delete(
        '/provider/reviews/$reviewId/reply',
      );

      return true;
    } catch (e) {
      log('Delete Reply Error: $e');
      return false;
    }
  }

  // =========================
  // REPORT REVIEW
  // =========================

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      await _apiService.post(
        '/provider/reviews/$reviewId/report',
        body: {
          'reason': reason,
        },
      );

      return true;
    } catch (e) {
      log('Report Review Error: $e');
      return false;
    }
  }

  // =========================
  // REVIEW ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getReviewAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/reviews/analytics',
      );
    } catch (e) {
      log('Review Analytics Error: $e');
      rethrow;
    }
  }

  // =========================
  // AVERAGE RATING
  // =========================

  Future<double> getAverageRating() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/average-rating',
      );

      return (response['rating'] ?? 0)
          .toDouble();
    } catch (e) {
      log('Average Rating Error: $e');
      return 0;
    }
  }

  // =========================
  // TOTAL REVIEW COUNT
  // =========================

  Future<int> getReviewCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log('Review Count Error: $e');
      return 0;
    }
  }

  // =========================
  // FIVE STAR COUNT
  // =========================

  Future<int> getFiveStarCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/five-star-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // FOUR STAR COUNT
  // =========================

  Future<int> getFourStarCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/four-star-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // THREE STAR COUNT
  // =========================

  Future<int> getThreeStarCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/three-star-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // TWO STAR COUNT
  // =========================

  Future<int> getTwoStarCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/two-star-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // ONE STAR COUNT
  // =========================

  Future<int> getOneStarCount() async {
    try {
      final response = await _apiService.get(
        '/provider/reviews/one-star-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}