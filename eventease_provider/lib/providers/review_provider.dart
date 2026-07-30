import 'package:flutter/foundation.dart';

import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository =
      ReviewRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<ReviewModel> _reviews = [];

  List<ReviewModel> _serviceReviews = [];

  ReviewModel? _selectedReview;

  Map<String, dynamic> _analytics = {};

  double _averageRating = 0;

  int _totalReviews = 0;

  int _fiveStarCount = 0;
  int _fourStarCount = 0;
  int _threeStarCount = 0;
  int _twoStarCount = 0;
  int _oneStarCount = 0;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ReviewModel> get reviews =>
      _reviews;

  List<ReviewModel> get serviceReviews =>
      _serviceReviews;

  ReviewModel? get selectedReview =>
      _selectedReview;

  Map<String, dynamic> get analytics =>
      _analytics;

  double get averageRating =>
      _averageRating;

  int get totalReviews =>
      _totalReviews;

  int get fiveStarCount =>
      _fiveStarCount;

  int get fourStarCount =>
      _fourStarCount;

  int get threeStarCount =>
      _threeStarCount;

  int get twoStarCount =>
      _twoStarCount;

  int get oneStarCount =>
      _oneStarCount;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // GET ALL REVIEWS
  // =========================

  Future<void> getReviews() async {
    try {
      _setLoading(true);

      _reviews =
          await _repository.getReviews();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET REVIEW BY ID
  // =========================

  Future<ReviewModel?> getReviewById(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      _selectedReview =
          await _repository.getReviewById(
        reviewId,
      );

      notifyListeners();

      return _selectedReview;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET SERVICE REVIEWS
  // =========================

  Future<void> getServiceReviews(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      _serviceReviews =
          await _repository
              .getServiceReviews(
        serviceId,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REVIEWS BY RATING
  // =========================

  Future<List<ReviewModel>>
      getReviewsByRating(
    int rating,
  ) async {
    try {
      return await _repository
          .getReviewsByRating(rating);
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository
          .searchReviews(keyword);
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.replyToReview(
        reviewId: reviewId,
        reply: reply,
      );

      if (success &&
          _selectedReview?.id ==
              reviewId) {
        await getReviewById(reviewId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository.updateReply(
        reviewId: reviewId,
        reply: reply,
      );
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository.deleteReply(
        reviewId,
      );
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository
          .reportReview(
        reviewId: reviewId,
        reason: reason,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // REVIEW ANALYTICS
  // =========================

  Future<void>
      getReviewAnalytics() async {
    try {
      _analytics =
          await _repository
              .getReviewAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // AVERAGE RATING
  // =========================

  Future<void>
      getAverageRating() async {
    try {
      _averageRating =
          await _repository
              .getAverageRating();

      notifyListeners();
    } catch (e) {
      _averageRating = 0;
    }
  }

  // =========================
  // REVIEW COUNT
  // =========================

  Future<void> getReviewCount() async {
    try {
      _totalReviews =
          await _repository
              .getReviewCount();

      notifyListeners();
    } catch (e) {
      _totalReviews = 0;
    }
  }

  // =========================
  // RATING DISTRIBUTION
  // =========================

  Future<void>
      getRatingDistribution() async {
    try {
      final results = await Future.wait([
        _repository.getFiveStarCount(),
        _repository.getFourStarCount(),
        _repository.getThreeStarCount(),
        _repository.getTwoStarCount(),
        _repository.getOneStarCount(),
      ]);

      _fiveStarCount = results[0];
      _fourStarCount = results[1];
      _threeStarCount = results[2];
      _twoStarCount = results[3];
      _oneStarCount = results[4];

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // REFRESH METRICS
  // =========================

  Future<void>
      refreshReviewMetrics() async {
    await Future.wait([
      getAverageRating(),
      getReviewCount(),
      getRatingDistribution(),
    ]);
  }

  // =========================
  // REFRESH ALL DATA
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getReviews(),
      getReviewAnalytics(),
      refreshReviewMetrics(),
    ]);
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _reviews = [];
    _serviceReviews = [];
    _selectedReview = null;

    _analytics = {};

    _averageRating = 0;
    _totalReviews = 0;

    _fiveStarCount = 0;
    _fourStarCount = 0;
    _threeStarCount = 0;
    _twoStarCount = 0;
    _oneStarCount = 0;

    _errorMessage = null;

    notifyListeners();
  }
}