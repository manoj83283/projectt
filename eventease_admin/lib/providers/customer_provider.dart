import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService =
      CustomerService();

  bool _isLoading = false;

  String? _errorMessage;

  List<CustomerModel> _customers = [];

  CustomerModel? _selectedCustomer;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCustomers = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<CustomerModel> get customers =>
      _customers;

  CustomerModel? get selectedCustomer =>
      _selectedCustomer;

  int get currentPage =>
      _currentPage;

  int get totalPages =>
      _totalPages;

  int get totalCustomers =>
      _totalCustomers;

  bool get hasCustomers =>
      _customers.isNotEmpty;

  // =====================================================
  // GET ALL CUSTOMERS
  // =====================================================

  Future<void> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _customerService
              .getCustomers(
        page: page,
        limit: limit,
        search: search,
        status: status,
      );

      _customers =
          (response['customers'] as List? ?? [])
              .map(
                (e) =>
                    CustomerModel.fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalCustomers =
          response['totalCustomers'] ??
              _customers.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CUSTOMER DETAILS
  // =====================================================

  Future<void> getCustomerDetails(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _customerService
              .getCustomerDetails(
        customerId,
      );

      _selectedCustomer =
          CustomerModel.fromJson(
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
  // SEARCH CUSTOMERS
  // =====================================================

  Future<void> searchCustomers(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _customerService
              .searchCustomers(
        keyword,
      );

      _customers =
          (response)
              .map(
                (e) =>
                    CustomerModel.fromJson(e),
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
  // BLOCK CUSTOMER
  // =====================================================

  Future<bool> blockCustomer(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      await _customerService.blockCustomer(
        customerId,
      );

      final index = _customers.indexWhere(
        (e) => e.id == customerId,
      );

      if (index != -1) {
        _customers[index] =
            _customers[index].copyWith(
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
  // UNBLOCK CUSTOMER
  // =====================================================

  Future<bool> unblockCustomer(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      await _customerService
          .unblockCustomer(
        customerId,
      );

      final index = _customers.indexWhere(
        (e) => e.id == customerId,
      );

      if (index != -1) {
        _customers[index] =
            _customers[index].copyWith(
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
  // ACTIVATE CUSTOMER
  // =====================================================

  Future<bool> activateCustomer(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      await _customerService
          .activateCustomer(
        customerId,
      );

      final index = _customers.indexWhere(
        (e) => e.id == customerId,
      );

      if (index != -1) {
        _customers[index] =
            _customers[index].copyWith(
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
  // DEACTIVATE CUSTOMER
  // =====================================================

  Future<bool> deactivateCustomer(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      await _customerService
          .deactivateCustomer(
        customerId,
      );

      final index = _customers.indexWhere(
        (e) => e.id == customerId,
      );

      if (index != -1) {
        _customers[index] =
            _customers[index].copyWith(
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
  // DELETE CUSTOMER
  // =====================================================

  Future<bool> deleteCustomer(
    String customerId,
  ) async {
    try {
      _setLoading(true);

      await _customerService.deleteCustomer(
        customerId,
      );

      _customers.removeWhere(
        (e) => e.id == customerId,
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

  Future<void> refreshCustomers() async {
    await getCustomers(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED CUSTOMER
  // =====================================================

  void clearSelectedCustomer() {
    _selectedCustomer = null;
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