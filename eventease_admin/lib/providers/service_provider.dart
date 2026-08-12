import 'package:flutter/foundation.dart';

import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceService _serviceService =
      ServiceService();

  bool _isLoading = false;

  String? _errorMessage;

  List<ServiceModel> _services = [];

  ServiceModel? _selectedService;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalServices = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ServiceModel> get services =>
      _services;

  ServiceModel? get selectedService =>
      _selectedService;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalServices =>
      _totalServices;

  bool get hasServices =>
      _services.isNotEmpty;

  // =====================================================
  // GET SERVICES
  // =====================================================

  Future<void> getServices({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? providerId,
    String? status,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _serviceService.getServices(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
        providerId: providerId,
        status: status,
      );

      _services =
          (response['services'] as List? ??
                  [])
              .map(
                (e) =>
                    ServiceModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalServices =
          response['totalServices'] ??
              _services.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET SERVICE DETAILS
  // =====================================================

  Future<void> getServiceDetails(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _serviceService
              .getServiceDetails(
        serviceId,
      );

      _selectedService =
          ServiceModel.fromJson(
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
  // SEARCH SERVICES
  // =====================================================

  Future<void> searchServices(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _serviceService
              .searchServices(
        keyword,
      );

      _services =
          (response)
              .map(
                (e) =>
                    ServiceModel.fromJson(
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
  // APPROVE SERVICE
  // =====================================================

  Future<bool> approveService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .approveService(
        serviceId,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
          isApproved: true,
          status: 'approved',
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
  // REJECT SERVICE
  // =====================================================

  Future<bool> rejectService(
    String serviceId,
    String reason,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .rejectService(
        serviceId,
        reason,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
          isApproved: false,
          status: 'rejected',
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
  // FEATURE SERVICE
  // =====================================================

  Future<bool> featureService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .featureService(
        serviceId,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
          isFeatured: true,
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
  // UNFEATURE SERVICE
  // =====================================================

  Future<bool> unFeatureService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .unFeatureService(
        serviceId,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
          isFeatured: false,
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
  // ACTIVATE SERVICE
  // =====================================================

  Future<bool> activateService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .activateService(
        serviceId,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
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
  // DEACTIVATE SERVICE
  // =====================================================

  Future<bool> deactivateService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .deactivateService(
        serviceId,
      );

      final index =
          _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            _services[index].copyWith(
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
  // DELETE SERVICE
  // =====================================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      await _serviceService
          .deleteService(
        serviceId,
      );

      _services.removeWhere(
        (e) => e.id == serviceId,
      );

      if (_selectedService?.id ==
          serviceId) {
        _selectedService = null;
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
  // REFRESH SERVICES
  // =====================================================

  Future<void> refreshServices() async {
    await getServices(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED SERVICE
  // =====================================================

  void clearSelectedService() {
    _selectedService = null;
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