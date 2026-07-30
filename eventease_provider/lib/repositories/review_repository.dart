import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  ReviewRepository._();

  static final ReviewRepository _instance =
      ReviewRepository._();

  static ReviewRepository get instance =>
      _instance;

  final ReviewService _reviewService =
      ReviewService.instance;

  // =========================
  // GET ALL REVIEWS
  // =========================

  Future<List<ReviewModel>>
      getReviews() async {
    try {
      return await _reviewService
          .getReviews();
    } catch (e) {
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
      return await _reviewService
          .getReviewById(reviewId);
    } catch (e) {
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
      return await _reviewService
          .getServiceReviews(serviceId);
    } catch (e) {
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
      return await _reviewService
          .getReviewsByRating(rating);
    } catch (e) {
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
      return await _reviewService
          .searchReviews(keyword);
    } catch (e) {
      return [];
    }
  }

  // =========================
  // REPLY TO REVIEW
  // =========================

  Future<bool> replyToReview({
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
      return false;
    }
  }

  // =========================
  // UPDATE REVIEW REPLY
  // =========================

  Future<bool> updateReply({
    required String reviewId,
    required String reply,
  }) async {
    try {
      return await _reviewService
          .updateReply(
        reviewId: reviewId,
        reply: reply,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE REVIEW REPLY
  // =========================

  Future<bool> deleteReply(
    String reviewId,
  ) async {
    try {
      return await _reviewService
          .deleteReply(reviewId);
    } catch (e) {
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
      return await _reviewService
          .reportReview(
        reviewId: reviewId,
        reason: reason,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // REVIEW ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getReviewAnalytics() async {
    try {
      return await _reviewService
          .getReviewAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET AVERAGE RATING
  // =========================

  Future<double>
      getAverageRating() async {
    try {
      return await _reviewService
          .getAverageRating();
    } catch (e) {
      return 0.0;
    }
  }

  // =========================
  // GET TOTAL REVIEW COUNT
  // =========================

  Future<int> getReviewCount() async {
    try {
      return await _reviewService
          .getReviewCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // FIVE STAR COUNT
  // =========================

  Future<int> getFiveStarCount() async {
    try {
      return await _reviewService
          .getFiveStarCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // FOUR STAR COUNT
  // =========================

  Future<int> getFourStarCount() async {
    try {
      return await _reviewService
          .getFourStarCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // THREE STAR COUNT
  // =========================

  Future<int> getThreeStarCount() async {
    try {
      return await _reviewService
          .getThreeStarCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // TWO STAR COUNT
  // =========================

  Future<int> getTwoStarCount() async {
    try {
      return await _reviewService
          .getTwoStarCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // ONE STAR COUNT
  // =========================

  Future<int> getOneStarCount() async {
    try {
      return await _reviewService
          .getOneStarCount();
    } catch (e) {
      return 0;
    }
  }
}