import 'package:flutter/foundation.dart';

import '../models/admin_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  String? _token;
  String? _errorMessage;

  AdminModel? _admin;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _isLoggedIn;

  bool get isInitialized => _isInitialized;

  String? get token => _token;

  String? get errorMessage => _errorMessage;

  AdminModel? get admin => _admin;

  String get adminName =>
      _admin?.fullName ?? '';

  String get adminEmail =>
      _admin?.email ?? '';

  String get adminRole =>
      _admin?.role ?? '';

  bool get isSuperAdmin =>
      _admin?.role.toLowerCase() ==
      'super_admin';

  bool get isAdmin =>
      _admin?.role.toLowerCase() ==
      'admin';

  // =====================================================
  // INITIALIZE AUTH
  // =====================================================

  Future<void> initialize() async {
    try {
      _setLoading(true);

      final isLoggedIn =
          await _authService.isLoggedIn();

      if (!isLoggedIn) {
        _isLoggedIn = false;
        _isInitialized = true;
        notifyListeners();
        return;
      }

      _token =
          await _authService.getToken();

      final adminData =
          await _authService.getProfile();

      _admin = AdminModel.fromJson(
        adminData,
      );

      _isLoggedIn = true;
      _isInitialized = true;
    } catch (e) {
      _isLoggedIn = false;
      _admin = null;
      _token = null;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _authService.login(
        email: email,
        password: password,
      );

      _token =
          response['token']?.toString();

      final adminJson =
          response['admin'] ??
              response['user'] ??
              {};

      _admin = AdminModel.fromJson(
        adminJson,
      );

      _isLoggedIn = true;

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
  // GET PROFILE
  // =====================================================

  Future<void> getProfile() async {
    try {
      _setLoading(true);

      final response =
          await _authService.getProfile();

      _admin = AdminModel.fromJson(
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
  // UPDATE PROFILE
  // =====================================================

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    String? profileImage,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        profileImage: profileImage,
      );

      _admin = AdminModel.fromJson(
        response,
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
  // CHANGE PASSWORD
  // =====================================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

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
  // REFRESH PROFILE
  // =====================================================

  Future<void> refreshProfile() async {
    await getProfile();
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      _setLoading(true);

      await _authService.logout();
    } catch (_) {
      //
    } finally {
      _admin = null;
      _token = null;
      _isLoggedIn = false;
      _errorMessage = null;

      _setLoading(false);

      notifyListeners();
    }
  }

  // =====================================================
  // CHECK PERMISSION
  // =====================================================

  bool hasPermission(
    String permission,
  ) {
    return _admin?.permissions
            .contains(permission) ??
        false;
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