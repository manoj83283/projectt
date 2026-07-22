import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider();

  final ReviewRepository _repository =
      ReviewRepository.instance;

  List<ReviewModel> _providerReviews = [];
  List<ReviewModel> _serviceReviews = [];
  List<ReviewModel> _myReviews = [];

  ReviewModel? _selectedReview;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<ReviewModel> get providerReviews =>
      _providerReviews;

  List<ReviewModel> get serviceReviews =>
      _serviceReviews;

  List<ReviewModel> get myReviews =>
      _myReviews;

  ReviewModel? get selectedReview =>
      _selectedReview;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // CREATE REVIEW
  // ==========================================

  Future<bool> createReview({
    required String providerId,
    required String bookingId,
    required double rating,
    required String review,
    List<String>? images,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final data =
          await _repository.createReview(
        providerId: providerId,
        bookingId: bookingId,
        rating: rating,
        review: review,
        images: images,
      );

      _myReviews.insert(0, data);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PROVIDER REVIEWS
  // ==========================================

  Future<void> getProviderReviews(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _providerReviews =
          await _repository.getProviderReviews(
        providerId,
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SERVICE REVIEWS
  // ==========================================

  Future<void> getServiceReviews(
    String serviceId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _serviceReviews =
          await _repository.getServiceReviews(
        serviceId,
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // MY REVIEWS
  // ==========================================

  Future<void> getMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _myReviews =
          await _repository.getMyReviews(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // REVIEW DETAILS
  // ==========================================

  Future<void> getReviewById(
    String reviewId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedReview =
          await _repository.getReviewById(
        reviewId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPDATE REVIEW
  // ==========================================

  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String review,
    List<String>? images,
  }) async {
    try {
      _setLoading(true);

      final updated =
          await _repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        review: review,
        images: images,
      );

      _selectedReview = updated;

      final index = _myReviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _myReviews[index] = updated;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DELETE REVIEW
  // ==========================================

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteReview(
        reviewId,
      );

      if (success) {
        _myReviews.removeWhere(
          (e) => e.id == reviewId,
        );

        _providerReviews.removeWhere(
          (e) => e.id == reviewId,
        );

        _serviceReviews.removeWhere(
          (e) => e.id == reviewId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // LIKE REVIEW
  // ==========================================

  Future<bool> likeReview(
    String reviewId,
  ) async {
    try {
      return await _repository.likeReview(
        reviewId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // UNLIKE REVIEW
  // ==========================================

  Future<bool> unlikeReview(
    String reviewId,
  ) async {
    try {
      return await _repository.unlikeReview(
        reviewId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // REPORT REVIEW
  // ==========================================

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      return await _repository.reportReview(
        reviewId: reviewId,
        reason: reason,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // REVIEW ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getReviewAnalytics(
    String providerId,
  ) async {
    try {
      return await _repository
          .getReviewAnalytics(
        providerId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // RATING SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getProviderRatingSummary(
    String providerId,
  ) async {
    try {
      return await _repository
          .getProviderRatingSummary(
        providerId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // SELECT REVIEW
  // ==========================================

  void setSelectedReview(
    ReviewModel review,
  ) {
    _selectedReview = review;
    notifyListeners();
  }

  // ==========================================
  // CLEAR REVIEW
  // ==========================================

  void clearSelectedReview() {
    _selectedReview = null;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _providerReviews.clear();
    _serviceReviews.clear();
    _myReviews.clear();

    _selectedReview = null;
    _error = null;

    notifyListeners();
  }
}