import 'package:flutter/foundation.dart';

import '../models/admin_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService =
      AdminService();

  bool _isLoading = false;

  String? _errorMessage;

  List<AdminModel> _admins = [];

  AdminModel? _selectedAdmin;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalAdmins = 0;

  //=====================================================
  // GETTERS
  //=====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<AdminModel> get admins =>
      _admins;

  AdminModel? get selectedAdmin =>
      _selectedAdmin;

  int get currentPage =>
      _currentPage;

  int get totalPages =>
      _totalPages;

  int get totalAdmins =>
      _totalAdmins;

  bool get hasAdmins =>
      _admins.isNotEmpty;

  //=====================================================
  // GET ADMINS
  //=====================================================

  Future<void> getAdmins({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _adminService.getAdmins(
        page: page,
        limit: limit,
        search: search,
        role: role,
      );

      _admins =
          (response['admins'] as List? ??
                  [])
              .map(
                (e) =>
                    AdminModel.fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalAdmins =
          response['totalAdmins'] ??
              _admins.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  //=====================================================
  // GET ADMIN DETAILS
  //=====================================================

  Future<void> getAdminDetails(
    String adminId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _adminService
              .getAdminDetails(
        adminId,
      );

      _selectedAdmin =
          AdminModel.fromJson(response);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  //=====================================================
  // CREATE ADMIN
  //=====================================================

  Future<bool> createAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required List<String> permissions,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _adminService.createAdmin(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        permissions: permissions,
      );

      final admin =
          AdminModel.fromJson(response);

      _admins.insert(0, admin);

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

  //=====================================================
  // UPDATE ADMIN
  //=====================================================

  Future<bool> updateAdmin({
    required String adminId,
    required String fullName,
    required String phone,
    required String role,
    required List<String> permissions,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _adminService.updateAdmin(
        adminId: adminId,
        fullName: fullName,
        phone: phone,
        role: role,
        permissions: permissions,
      );

      final updatedAdmin =
          AdminModel.fromJson(response);

      final index =
          _admins.indexWhere(
        (e) => e.id == adminId,
      );

      if (index != -1) {
        _admins[index] = updatedAdmin;
      }

      if (_selectedAdmin?.id ==
          adminId) {
        _selectedAdmin =
            updatedAdmin;
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

  //=====================================================
  // ACTIVATE ADMIN
  //=====================================================

  Future<bool> activateAdmin(
    String adminId,
  ) async {
    try {
      _setLoading(true);

      await _adminService.activateAdmin(
        adminId,
      );

      final index =
          _admins.indexWhere(
        (e) => e.id == adminId,
      );

      if (index != -1) {
        _admins[index] =
            _admins[index].copyWith(
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

  //=====================================================
  // DEACTIVATE ADMIN
  //=====================================================

  Future<bool> deactivateAdmin(
    String adminId,
  ) async {
    try {
      _setLoading(true);

      await _adminService
          .deactivateAdmin(
        adminId,
      );

      final index =
          _admins.indexWhere(
        (e) => e.id == adminId,
      );

      if (index != -1) {
        _admins[index] =
            _admins[index].copyWith(
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

  //=====================================================
  // DELETE ADMIN
  //=====================================================

  Future<bool> deleteAdmin(
    String adminId,
  ) async {
    try {
      _setLoading(true);

      await _adminService.deleteAdmin(
        adminId,
      );

      _admins.removeWhere(
        (e) => e.id == adminId,
      );

      if (_selectedAdmin?.id ==
          adminId) {
        _selectedAdmin = null;
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

  //=====================================================
  // SEARCH ADMINS
  //=====================================================

  Future<void> searchAdmins(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _adminService.searchAdmins(
        keyword,
      );

      _admins =
          (response)
              .map(
                (e) =>
                    AdminModel.fromJson(e),
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

  //=====================================================
  // REFRESH
  //=====================================================

  Future<void> refreshAdmins() async {
    await getAdmins(
      page: _currentPage,
    );
  }

  //=====================================================
  // CLEAR SELECTED ADMIN
  //=====================================================

  void clearSelectedAdmin() {
    _selectedAdmin = null;
    notifyListeners();
  }

  //=====================================================
  // CLEAR ERROR
  //=====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  //=====================================================
  // LOADING
  //=====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}