import 'package:flutter/foundation.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService =
      ReviewService();

  bool _isLoading = false;

  String? _errorMessage;

  List<ReviewModel> _reviews = [];

  ReviewModel? _selectedReview;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalReviews = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ReviewModel> get reviews =>
      _reviews;

  ReviewModel? get selectedReview =>
      _selectedReview;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalReviews => _totalReviews;

  bool get hasReviews =>
      _reviews.isNotEmpty;

  List<ReviewModel> get approvedReviews =>
      _reviews
          .where(
            (review) => review.isApproved,
          )
          .toList();

  List<ReviewModel> get pendingReviews =>
      _reviews
          .where(
            (review) => !review.isApproved,
          )
          .toList();

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;

    final total = _reviews.fold<double>(
      0,
      (sum, review) =>
          sum + review.rating,
    );

    return total / _reviews.length;
  }

  // =====================================================
  // GET REVIEWS
  // =====================================================

  Future<void> getReviews({
    int page = 1,
    int limit = 20,
    String? search,
    String? providerId,
    String? serviceId,
    double? rating,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _reviewService.getReviews(
        page: page,
        limit: limit,
        search: search,
        providerId: providerId,
        serviceId: serviceId,
        rating: rating,
      );

      _reviews =
          (response['reviews'] as List? ??
                  [])
              .map(
                (e) =>
                    ReviewModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalReviews =
          response['totalReviews'] ??
              _reviews.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET REVIEW DETAILS
  // =====================================================

  Future<void> getReviewDetails(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _reviewService
              .getReviewDetails(
        reviewId,
      );

      _selectedReview =
          ReviewModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH REVIEWS
  // =====================================================

  Future<void> searchReviews(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _reviewService
              .searchReviews(
        keyword,
      );

      _reviews =
          (response)
              .map(
                (e) =>
                    ReviewModel.fromJson(
                  e,
                ),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // APPROVE REVIEW
  // =====================================================

  Future<bool> approveReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      await _reviewService
          .approveReview(reviewId);

      final index =
          _reviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _reviews[index] =
            _reviews[index].copyWith(
          isApproved: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REJECT REVIEW
  // =====================================================

  Future<bool> rejectReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      await _reviewService
          .rejectReview(reviewId);

      final index =
          _reviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _reviews[index] =
            _reviews[index].copyWith(
          isApproved: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // HIDE REVIEW
  // =====================================================

  Future<bool> hideReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      await _reviewService.hideReview(
        reviewId,
      );

      final index =
          _reviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _reviews[index] =
            _reviews[index].copyWith(
          isHidden: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UNHIDE REVIEW
  // =====================================================

  Future<bool> unHideReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      await _reviewService.unHideReview(
        reviewId,
      );

      final index =
          _reviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _reviews[index] =
            _reviews[index].copyWith(
          isHidden: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // ADMIN REPLY
  // =====================================================

  Future<bool> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _reviewService.replyToReview(
        reviewId: reviewId,
        reply: reply,
      );

      final updatedReview =
          ReviewModel.fromJson(
        response,
      );

      final index =
          _reviews.indexWhere(
        (e) => e.id == reviewId,
      );

      if (index != -1) {
        _reviews[index] =
            updatedReview;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE REVIEW
  // =====================================================

  Future<bool> deleteReview(
    String reviewId,
  ) async {
    try {
      _setLoading(true);

      await _reviewService
          .deleteReview(reviewId);

      _reviews.removeWhere(
        (e) => e.id == reviewId,
      );

      if (_selectedReview?.id ==
          reviewId) {
        _selectedReview = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH REVIEWS
  // =====================================================

  Future<void> refreshReviews() async {
    await getReviews(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED REVIEW
  // =====================================================

  void clearSelectedReview() {
    _selectedReview = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}