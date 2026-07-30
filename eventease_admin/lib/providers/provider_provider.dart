import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../services/provider_service.dart';

class ProviderProvider extends ChangeNotifier {
  final ProviderService _providerService =
      ProviderService();

  bool _isLoading = false;

  String? _errorMessage;

  List<ProviderModel> _providers = [];

  ProviderModel? _selectedProvider;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalProviders = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ProviderModel> get providers =>
      _providers;

  ProviderModel? get selectedProvider =>
      _selectedProvider;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalProviders =>
      _totalProviders;

  bool get hasProviders =>
      _providers.isNotEmpty;

  // =====================================================
  // GET PROVIDERS
  // =====================================================

  Future<void> getProviders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? categoryId,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _providerService
              .getProviders(
        page: page,
        limit: limit,
        search: search,
        status: status,
        categoryId: categoryId,
      );

      _providers =
          (response['providers'] as List? ??
                  [])
              .map(
                (e) => ProviderModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalProviders =
          response['totalProviders'] ??
              _providers.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // PROVIDER DETAILS
  // =====================================================

  Future<void> getProviderDetails(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _providerService
              .getProviderDetails(
        providerId,
      );

      _selectedProvider =
          ProviderModel.fromJson(
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
  // SEARCH PROVIDERS
  // =====================================================

  Future<void> searchProviders(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _providerService
              .searchProviders(
        keyword,
      );

      _providers =
          (response as List)
              .map(
                (e) => ProviderModel.fromJson(
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
  // APPROVE PROVIDER
  // =====================================================

  Future<bool> approveProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .approveProvider(
        providerId,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          verificationStatus: 'approved',
          isVerified: true,
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
  // REJECT PROVIDER
  // =====================================================

  Future<bool> rejectProvider(
    String providerId,
    String reason,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .rejectProvider(
        providerId,
        reason,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          verificationStatus: 'rejected',
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
  // BLOCK PROVIDER
  // =====================================================

  Future<bool> blockProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .blockProvider(
        providerId,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          isBlocked: true,
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
  // UNBLOCK PROVIDER
  // =====================================================

  Future<bool> unblockProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .unblockProvider(
        providerId,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          isBlocked: false,
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
  // ACTIVATE PROVIDER
  // =====================================================

  Future<bool> activateProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .activateProvider(
        providerId,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          isActive: true,
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
  // DEACTIVATE PROVIDER
  // =====================================================

  Future<bool> deactivateProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .deactivateProvider(
        providerId,
      );

      final index = _providers.indexWhere(
        (e) => e.id == providerId,
      );

      if (index != -1) {
        _providers[index] =
            _providers[index].copyWith(
          isActive: false,
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
  // DELETE PROVIDER
  // =====================================================

  Future<bool> deleteProvider(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      await _providerService
          .deleteProvider(
        providerId,
      );

      _providers.removeWhere(
        (e) => e.id == providerId,
      );

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
  // REFRESH
  // =====================================================

  Future<void> refreshProviders() async {
    await getProviders(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED PROVIDER
  // =====================================================

  void clearSelectedProvider() {
    _selectedProvider = null;
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
  // LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}