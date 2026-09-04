import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;

  Future<bool>? _sessionRestoreFuture;

  // =====================================================
  // GETTERS
  // =====================================================

  UserModel? get currentUser => _currentUser;

  bool get hasCurrentUser => _currentUser != null;

  bool get hasToken {
    return _token != null && _token!.trim().isNotEmpty;
  }

  bool get isAuthenticated {
    return hasToken && ApiService.instance.hasAuthToken;
  }

  String? get accessToken => _token;

  String? get savedRefreshToken => _refreshToken;

  // =====================================================
  // RESPONSE HELPERS
  // =====================================================

  dynamic _responseData(dynamic response) {
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map<String, dynamic>(
        (dynamic key, dynamic item) {
          return MapEntry<String, dynamic>(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  bool _looksLikeUserMap(Map<String, dynamic> map) {
    return map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('email') ||
        map.containsKey('phone') ||
        map.containsKey('mobile');
  }

  Map<String, dynamic> _extractUserMap(dynamic response) {
    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return <String, dynamic>{};
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);

    final dynamic directUser = responseMap['user'] ??
        responseMap['customer'] ??
        responseMap['profile'];

    if (directUser is Map) {
      return _asMap(directUser);
    }

    final dynamic data = responseMap['data'];

    if (data is Map) {
      final Map<String, dynamic> dataMap = _asMap(data);

      final dynamic nestedUser =
          dataMap['user'] ?? dataMap['customer'] ?? dataMap['profile'];

      if (nestedUser is Map) {
        return _asMap(nestedUser);
      }

      if (_looksLikeUserMap(dataMap)) {
        return dataMap;
      }
    }

    if (_looksLikeUserMap(responseMap)) {
      return responseMap;
    }

    return <String, dynamic>{};
  }

  String? _extractToken(dynamic response) {
    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return null;
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);

    final dynamic directToken = responseMap['token'] ??
        responseMap['accessToken'] ??
        responseMap['access_token'] ??
        responseMap['authToken'] ??
        responseMap['jwt'];

    if (directToken != null &&
        directToken.toString().trim().isNotEmpty) {
      return _normalizeToken(directToken.toString());
    }

    final dynamic data = responseMap['data'];

    if (data is Map) {
      final Map<String, dynamic> dataMap = _asMap(data);

      final dynamic nestedToken = dataMap['token'] ??
          dataMap['accessToken'] ??
          dataMap['access_token'] ??
          dataMap['authToken'] ??
          dataMap['jwt'];

      if (nestedToken != null &&
          nestedToken.toString().trim().isNotEmpty) {
        return _normalizeToken(nestedToken.toString());
      }
    }

    return null;
  }

  String? _extractRefreshToken(dynamic response) {
    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return null;
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);

    final dynamic directToken =
        responseMap['refreshToken'] ?? responseMap['refresh_token'];

    if (directToken != null &&
        directToken.toString().trim().isNotEmpty) {
      return directToken.toString().trim();
    }

    final dynamic data = responseMap['data'];

    if (data is Map) {
      final Map<String, dynamic> dataMap = _asMap(data);

      final dynamic nestedToken =
          dataMap['refreshToken'] ?? dataMap['refresh_token'];

      if (nestedToken != null &&
          nestedToken.toString().trim().isNotEmpty) {
        return nestedToken.toString().trim();
      }
    }

    return null;
  }

  bool _extractSuccess(
    dynamic response, {
    bool fallback = true,
  }) {
    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return fallback;
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);
    final dynamic value = responseMap['success'];

    if (value is bool) {
      return value;
    }

    return fallback;
  }

  // =====================================================
  // TOKEN HELPERS
  // =====================================================

  String _normalizeToken(String token) {
    String normalizedToken = token.trim();

    if (normalizedToken.toLowerCase().startsWith('bearer ')) {
      normalizedToken = normalizedToken.substring(7).trim();
    }

    return normalizedToken;
  }

  String _extractRole(Map<String, dynamic> userMap) {
    return userMap['role']?.toString().trim().toLowerCase() ?? '';
  }

  bool _isCustomerRole(String role) {
    return role == 'user' || role == 'customer';
  }

  void _validateCustomerRole(Map<String, dynamic> userMap) {
    final String role = _extractRole(userMap);

    if (role.isEmpty) {
      return;
    }

    if (!_isCustomerRole(role)) {
      throw Exception(
        'This account is not a Customer account. '
        'Please sign in using a Customer account.',
      );
    }
  }

  // =====================================================
  // SHARED PREFERENCES
  // =====================================================

  Future<SharedPreferences> _preferences() {
    return SharedPreferences.getInstance();
  }

  Future<void> _saveToken({
    required String token,
    String? refreshToken,
  }) async {
    final String normalizedToken = _normalizeToken(token);

    if (normalizedToken.isEmpty) {
      throw Exception('Authentication token is empty.');
    }

    final SharedPreferences preferences = await _preferences();

    final bool tokenSaved = await preferences.setString(
      AppConfig.tokenKey,
      normalizedToken,
    );

    if (!tokenSaved) {
      throw Exception('Unable to save the authentication token.');
    }

    _token = normalizedToken;

    ApiService.instance.setAuthToken(normalizedToken);

    final String normalizedRefreshToken = refreshToken?.trim() ?? '';

    if (normalizedRefreshToken.isNotEmpty) {
      _refreshToken = normalizedRefreshToken;

      await preferences.setString(
        AppConfig.refreshTokenKey,
        normalizedRefreshToken,
      );
    } else {
      _refreshToken = null;

      await preferences.remove(
        AppConfig.refreshTokenKey,
      );
    }

    debugPrint('AUTH TOKEN SAVED SUCCESSFULLY');
    debugPrint('TOKEN LENGTH: ${normalizedToken.length}');
    debugPrint(
      'AUTH HEADER AVAILABLE: ${ApiService.instance.hasAuthToken}',
    );
  }

  Future<void> _saveCurrentUser(
    Map<String, dynamic> userMap,
  ) async {
    if (userMap.isEmpty) {
      return;
    }

    final SharedPreferences preferences = await _preferences();

    await preferences.setString(
      AppConfig.userKey,
      jsonEncode(userMap),
    );
  }

  Future<UserModel?> _loadSavedUser() async {
    try {
      final SharedPreferences preferences = await _preferences();

      final String? savedUser = preferences.getString(
        AppConfig.userKey,
      );

      if (savedUser == null || savedUser.trim().isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(savedUser);

      if (decoded is! Map) {
        return null;
      }

      final Map<String, dynamic> userMap = _asMap(decoded);

      _validateCustomerRole(userMap);

      return UserModel.fromMap(userMap);
    } catch (error) {
      debugPrint('SAVED CUSTOMER RESTORE ERROR: $error');
      return null;
    }
  }

  Future<void> _clearStoredAuth() async {
    final SharedPreferences preferences = await _preferences();

    await preferences.remove(AppConfig.tokenKey);
    await preferences.remove(AppConfig.refreshTokenKey);
    await preferences.remove(AppConfig.userKey);
  }

  // =====================================================
  // CURRENT USER
  // =====================================================

  UserModel _setCurrentUser(
    Map<String, dynamic> userMap,
  ) {
    if (userMap.isEmpty) {
      throw Exception(
        'The backend did not return Customer information.',
      );
    }

    _validateCustomerRole(userMap);

    final UserModel user = UserModel.fromMap(userMap);

    _currentUser = user;

    return user;
  }

  Future<UserModel> _storeCurrentUser(
    Map<String, dynamic> userMap,
  ) async {
    final UserModel user = _setCurrentUser(userMap);

    await _saveCurrentUser(userMap);

    return user;
  }

  // =====================================================
  // PROCESS AUTH RESPONSE
  // =====================================================

  Future<UserModel> _processAuthResponse(
    dynamic response, {
    required String operation,
  }) async {
    if (!_extractSuccess(response)) {
      throw Exception('$operation failed.');
    }

    final String? token = _extractToken(response);

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        '$operation succeeded, but the backend did not '
        'return an authentication token.',
      );
    }

    final Map<String, dynamic> userMap = _extractUserMap(response);

    if (userMap.isEmpty) {
      throw Exception(
        '$operation succeeded, but the backend did not '
        'return Customer information.',
      );
    }

    _validateCustomerRole(userMap);

    try {
      await _saveToken(
        token: token,
        refreshToken: _extractRefreshToken(response),
      );

      final UserModel user = await _storeCurrentUser(userMap);

      debugPrint('$operation COMPLETED SUCCESSFULLY');
      debugPrint('CUSTOMER ROLE: ${_extractRole(userMap)}');

      return user;
    } catch (error) {
      debugPrint('$operation LOCAL SAVE ERROR: $error');

      await clearLocalAuth();

      rethrow;
    }
  }

  // =====================================================
  // RESTORE SESSION
  // =====================================================

  Future<bool> restoreSession() {
    final Future<bool>? activeRestore = _sessionRestoreFuture;

    if (activeRestore != null) {
      return activeRestore;
    }

    final Future<bool> restoreFuture = _restoreSessionInternal();

    _sessionRestoreFuture = restoreFuture;

    return restoreFuture.whenComplete(() {
      _sessionRestoreFuture = null;
    });
  }

  Future<bool> _restoreSessionInternal() async {
    try {
      final SharedPreferences preferences = await _preferences();

      final String? savedToken = preferences.getString(
        AppConfig.tokenKey,
      );

      if (savedToken == null || savedToken.trim().isEmpty) {
        _token = null;
        _refreshToken = null;
        _currentUser = null;

        ApiService.instance.clearAuthToken();

        debugPrint('NO SAVED CUSTOMER SESSION');

        return false;
      }

      final String normalizedToken = _normalizeToken(savedToken);

      if (normalizedToken.isEmpty) {
        await clearLocalAuth();
        return false;
      }

      _token = normalizedToken;

      _refreshToken = preferences.getString(
        AppConfig.refreshTokenKey,
      );

      ApiService.instance.setAuthToken(normalizedToken);

      _currentUser = await _loadSavedUser();

      debugPrint('CUSTOMER TOKEN RESTORED');
      debugPrint('RESTORED TOKEN LENGTH: ${normalizedToken.length}');
      debugPrint(
        'AUTH HEADER AVAILABLE: ${ApiService.instance.hasAuthToken}',
      );

      /*
       * Important:
       *
       * Do not call /auth/profile here.
       *
       * Previously, a temporary network failure, backend restart,
       * incorrect profile route, CORS issue, or server error caused
       * the app to clear a valid saved token and redirect to Sign In.
       *
       * Protected API requests will still be validated by the backend.
       */
      return ApiService.instance.hasAuthToken;
    } catch (error) {
      debugPrint('RESTORE SESSION ERROR: $error');

      _token = null;
      _refreshToken = null;
      _currentUser = null;

      ApiService.instance.clearAuthToken();

      /*
       * Do not delete saved authentication here because the failure
       * may be caused by temporary SharedPreferences initialization
       * or browser storage availability.
       */
      return false;
    }
  }

  // =====================================================
  // LOGIN
  // POST /api/auth/signin
  // =====================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    if (password.trim().isEmpty) {
      throw ArgumentError('Password is required.');
    }

    debugPrint('STARTING CUSTOMER SIGNIN');

    /*
     * Do not clear the current session before the login API succeeds.
     * Clearing first can leave the user signed out if there is a
     * temporary network or backend error.
     */
    final dynamic response = await ApiService.instance.post(
      '/auth/signin',
      data: <String, dynamic>{
        'email': normalizedEmail,
        'password': password,
      },
    );

    return _processAuthResponse(
      response,
      operation: 'Login',
    );
  }

  // =====================================================
  // REGISTER
  // POST /api/auth/register
  // =====================================================

  Future<UserModel> register({
    required String email,
    required String password,
    String? name,
    String? fullName,
    String? phone,
    String? mobile,
  }) async {
    final String resolvedName = (name ?? fullName ?? '').trim();
    final String resolvedPhone = (phone ?? mobile ?? '').trim();
    final String normalizedEmail = email.trim().toLowerCase();

    if (resolvedName.isEmpty) {
      throw ArgumentError('Customer name is required.');
    }

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    if (password.trim().isEmpty) {
      throw ArgumentError('Password is required.');
    }

    final dynamic response = await ApiService.instance.post(
      '/auth/register',
      data: <String, dynamic>{
        'name': resolvedName,
        'fullName': resolvedName,
        'firstName': resolvedName,
        'email': normalizedEmail,
        'phone': resolvedPhone,
        'mobile': resolvedPhone,
        'password': password,
        'role': 'user',
      },
    );

    return _processAuthResponse(
      response,
      operation: 'Registration',
    );
  }

  // =====================================================
  // GOOGLE LOGIN
  // =====================================================

  Future<UserModel> googleLogin({
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
  }) async {
    final dynamic response = await ApiService.instance.post(
      '/auth/google-login',
      data: <String, dynamic>{
        if (idToken != null && idToken.trim().isNotEmpty)
          'idToken': idToken.trim(),
        if (accessToken != null && accessToken.trim().isNotEmpty)
          'accessToken': accessToken.trim(),
        if (email != null && email.trim().isNotEmpty)
          'email': email.trim().toLowerCase(),
        if (name != null && name.trim().isNotEmpty)
          'name': name.trim(),
        'role': 'user',
      },
    );

    return _processAuthResponse(
      response,
      operation: 'Google login',
    );
  }

  // =====================================================
  // GET PROFILE
  // =====================================================

  Future<UserModel> getProfile() async {
    await ensureAuthenticated();

    final dynamic response = await ApiService.instance.get(
      '/auth/profile',
    );

    final Map<String, dynamic> userMap = _extractUserMap(response);

    if (userMap.isEmpty) {
      throw Exception(
        'The backend did not return Customer profile data.',
      );
    }

    return _storeCurrentUser(userMap);
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<UserModel> updateProfile({
    Map<String, dynamic>? data,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    String? mobile,
    String? profileImage,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    await ensureAuthenticated();

    final Map<String, dynamic> payload = <String, dynamic>{
      ...?data,
      if (name != null) 'name': name.trim(),
      if (fullName != null) 'fullName': fullName.trim(),
      if (email != null) 'email': email.trim().toLowerCase(),
      if (phone != null) 'phone': phone.trim(),
      if (mobile != null) 'mobile': mobile.trim(),
      if (profileImage != null) 'profileImage': profileImage.trim(),
      if (gender != null) 'gender': gender.trim(),
      if (dateOfBirth != null)
        'dateOfBirth': dateOfBirth.toIso8601String(),
    };

    final dynamic response = await ApiService.instance.put(
      '/auth/profile',
      data: payload,
    );

    final Map<String, dynamic> userMap = _extractUserMap(response);

    if (userMap.isEmpty) {
      throw Exception(
        'The backend did not return the updated profile.',
      );
    }

    return _storeCurrentUser(userMap);
  }

  // =====================================================
  // TOKEN AND SESSION
  // =====================================================

  Future<String?> getToken() async {
    if (_token != null && _token!.trim().isNotEmpty) {
      final String normalizedToken = _normalizeToken(_token!);

      if (normalizedToken.isEmpty) {
        return null;
      }

      _token = normalizedToken;

      ApiService.instance.setAuthToken(normalizedToken);

      return normalizedToken;
    }

    try {
      final SharedPreferences preferences = await _preferences();

      final String? savedToken = preferences.getString(
        AppConfig.tokenKey,
      );

      if (savedToken == null || savedToken.trim().isEmpty) {
        debugPrint('CUSTOMER TOKEN NOT FOUND IN LOCAL STORAGE');
        return null;
      }

      final String normalizedToken = _normalizeToken(savedToken);

      if (normalizedToken.isEmpty) {
        debugPrint('SAVED CUSTOMER TOKEN IS EMPTY');
        return null;
      }

      _token = normalizedToken;

      _refreshToken ??= preferences.getString(
        AppConfig.refreshTokenKey,
      );

      ApiService.instance.setAuthToken(normalizedToken);

      debugPrint('CUSTOMER TOKEN LOADED FROM LOCAL STORAGE');

      return normalizedToken;
    } catch (error) {
      debugPrint('CUSTOMER TOKEN LOAD ERROR: $error');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final String? token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  Future<String> ensureAuthenticated() async {
    String? token = await getToken();

    if (token == null || token.trim().isEmpty) {
      /*
       * Retry session restoration once. This handles application
       * startup timing issues where booking opens before the initial
       * AuthProvider restoration has completed.
       */
      await restoreSession();

      token = await getToken();
    }

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Please sign in before continuing.',
      );
    }

    final String normalizedToken = _normalizeToken(token);

    if (normalizedToken.isEmpty) {
      throw Exception(
        'Customer authentication token is invalid. '
        'Please sign in again.',
      );
    }

    _token = normalizedToken;

    ApiService.instance.setAuthToken(normalizedToken);

    if (!ApiService.instance.hasAuthToken) {
      throw Exception(
        'Unable to attach Customer authentication. '
        'Please sign in again.',
      );
    }

    debugPrint('CUSTOMER AUTHENTICATION AVAILABLE');
    debugPrint('AUTH TOKEN LENGTH: ${normalizedToken.length}');

    return normalizedToken;
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  Future<bool> refreshToken() async {
    try {
      final String? token = await refreshAccessToken();

      return token != null && token.trim().isNotEmpty;
    } catch (error) {
      debugPrint('REFRESH TOKEN ERROR: $error');
      return false;
    }
  }

  Future<String?> refreshAccessToken() async {
    final SharedPreferences preferences = await _preferences();

    final String? refreshTokenValue = _refreshToken ??
        preferences.getString(
          AppConfig.refreshTokenKey,
        );

    if (refreshTokenValue == null ||
        refreshTokenValue.trim().isEmpty) {
      debugPrint('NO REFRESH TOKEN AVAILABLE');
      return null;
    }

    final dynamic response = await ApiService.instance.post(
      '/auth/refresh-token',
      data: <String, dynamic>{
        'refreshToken': refreshTokenValue.trim(),
      },
    );

    final String? token = _extractToken(response);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    await _saveToken(
      token: token,
      refreshToken:
          _extractRefreshToken(response) ?? refreshTokenValue,
    );

    return token;
  }

  Future<String?> getRefreshTokenFromServer() async {
    final SharedPreferences preferences = await _preferences();

    final String? refreshTokenValue = _refreshToken ??
        preferences.getString(
          AppConfig.refreshTokenKey,
        );

    if (refreshTokenValue == null ||
        refreshTokenValue.trim().isEmpty) {
      return null;
    }

    final dynamic response = await ApiService.instance.post(
      '/auth/refresh-token',
      data: <String, dynamic>{
        'refreshToken': refreshTokenValue.trim(),
      },
    );

    final String? accessToken = _extractToken(response);

    final String returnedRefreshToken =
        _extractRefreshToken(response) ?? refreshTokenValue;

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      await _saveToken(
        token: accessToken,
        refreshToken: returnedRefreshToken,
      );
    }

    return returnedRefreshToken;
  }

  // =====================================================
  // FORGOT AND RESET PASSWORD
  // =====================================================

  Future<bool> forgotPassword(String email) async {
    final String normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    await ApiService.instance.post(
      '/auth/forgot-password',
      data: <String, dynamic>{
        'email': normalizedEmail,
      },
    );

    return true;
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    if (token.trim().isEmpty) {
      throw ArgumentError('Reset token is required.');
    }

    if (password.trim().isEmpty) {
      throw ArgumentError('Password is required.');
    }

    await ApiService.instance.post(
      '/auth/reset-password',
      data: <String, dynamic>{
        'token': token.trim(),
        'password': password,
      },
    );

    return true;
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ensureAuthenticated();

    await ApiService.instance.post(
      '/auth/change-password',
      data: <String, dynamic>{
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    return true;
  }

  // =====================================================
  // OTP
  // =====================================================

  Future<bool> sendOtp(
    String value, {
    String? email,
    String? phone,
    String? mobile,
  }) async {
    final String normalizedValue = value.trim();
    final bool isEmail = normalizedValue.contains('@');

    final String resolvedEmail = (email ??
            (isEmail ? normalizedValue : ''))
        .trim()
        .toLowerCase();

    final String resolvedPhone = (phone ??
            mobile ??
            (!isEmail ? normalizedValue : ''))
        .trim();

    await ApiService.instance.post(
      '/auth/send-otp',
      data: <String, dynamic>{
        if (resolvedEmail.isNotEmpty) 'email': resolvedEmail,
        if (resolvedPhone.isNotEmpty) 'phone': resolvedPhone,
        if (resolvedPhone.isNotEmpty) 'mobile': resolvedPhone,
      },
    );

    return true;
  }

  Future<UserModel> verifyOtp({
    required String otp,
    String? email,
    String? phone,
    String? mobile,
  }) async {
    final String resolvedEmail =
        email?.trim().toLowerCase() ?? '';

    final String resolvedPhone = (phone ?? mobile ?? '').trim();

    final dynamic response = await ApiService.instance.post(
      '/auth/verify-otp',
      data: <String, dynamic>{
        if (resolvedEmail.isNotEmpty) 'email': resolvedEmail,
        if (resolvedPhone.isNotEmpty) 'phone': resolvedPhone,
        if (resolvedPhone.isNotEmpty) 'mobile': resolvedPhone,
        'otp': otp.trim(),
      },
    );

    return _processAuthResponse(
      response,
      operation: 'OTP verification',
    );
  }

  Future<bool> verifyOtpStatus({
    required String otp,
    String? email,
    String? phone,
    String? mobile,
  }) async {
    await verifyOtp(
      otp: otp,
      email: email,
      phone: phone,
      mobile: mobile,
    );

    return true;
  }

  Future<bool> resendOtp(String value) async {
    final String normalizedValue = value.trim();
    final bool isEmail = normalizedValue.contains('@');

    await ApiService.instance.post(
      '/auth/resend-otp',
      data: <String, dynamic>{
        if (isEmail) 'email': normalizedValue.toLowerCase(),
        if (!isEmail) 'phone': normalizedValue,
        if (!isEmail) 'mobile': normalizedValue,
      },
    );

    return true;
  }

  // =====================================================
  // EMAIL AND PHONE CHECKS
  // =====================================================

  Future<bool> checkEmailExists(String email) async {
    final dynamic response = await ApiService.instance.get(
      '/auth/check-email',
      queryParameters: <String, dynamic>{
        'email': email.trim().toLowerCase(),
      },
    );

    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return false;
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);

    if (responseMap['exists'] == true) {
      return true;
    }

    final dynamic data = responseMap['data'];

    if (data is Map) {
      return _asMap(data)['exists'] == true;
    }

    return false;
  }

  Future<bool> checkPhoneExists(String phone) async {
    final dynamic response = await ApiService.instance.get(
      '/auth/check-phone',
      queryParameters: <String, dynamic>{
        'phone': phone.trim(),
      },
    );

    final dynamic responseData = _responseData(response);

    if (responseData is! Map) {
      return false;
    }

    final Map<String, dynamic> responseMap = _asMap(responseData);

    if (responseMap['exists'] == true) {
      return true;
    }

    final dynamic data = responseMap['data'];

    if (data is Map) {
      return _asMap(data)['exists'] == true;
    }

    return false;
  }

  // =====================================================
  // FCM TOKEN
  // =====================================================

  Future<bool> updateFcmToken({
    required String fcmToken,
  }) async {
    await ensureAuthenticated();

    final String normalizedFcmToken = fcmToken.trim();

    if (normalizedFcmToken.isEmpty) {
      return false;
    }

    await ApiService.instance.post(
      '/auth/fcm-token',
      data: <String, dynamic>{
        'fcmToken': normalizedFcmToken,
      },
    );

    return true;
  }

  // =====================================================
  // SET LOCAL AUTH
  // =====================================================

  Future<void> setLocalAuth({
    required String token,
    UserModel? user,
    String? refreshToken,
  }) async {
    await _saveToken(
      token: token,
      refreshToken: refreshToken,
    );

    if (user == null) {
      return;
    }

    _currentUser = user;

    try {
      final dynamic dynamicUser = user;
      final dynamic userMap = dynamicUser.toMap();

      if (userMap is Map) {
        final Map<String, dynamic> normalizedUserMap = _asMap(userMap);

        _validateCustomerRole(normalizedUserMap);

        await _saveCurrentUser(normalizedUserMap);
      }
    } catch (error) {
      debugPrint('CUSTOMER SAVE ERROR: $error');
    }
  }

  // =====================================================
  // REFRESH CURRENT USER
  // =====================================================

  Future<UserModel?> refreshCurrentUser() async {
    try {
      return await getProfile();
    } catch (error) {
      /*
       * Profile refresh errors must not log out the customer.
       */
      debugPrint('REFRESH CUSTOMER ERROR: $error');
      return _currentUser;
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<bool> logout() async {
    try {
      final String? token = await getToken();

      if (token != null && token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(token);

        await ApiService.instance.post(
          '/auth/logout',
        );
      }
    } catch (error) {
      debugPrint('BACKEND LOGOUT ERROR: $error');
    } finally {
      await clearLocalAuth();
    }

    return true;
  }

  // =====================================================
  // DELETE ACCOUNT
  // =====================================================

  Future<bool> deleteAccount() async {
    await ensureAuthenticated();

    await ApiService.instance.delete(
      '/auth/delete-account',
    );

    await clearLocalAuth();

    return true;
  }

  // =====================================================
  // CLEAR LOCAL AUTH
  // =====================================================

  Future<void> clearLocalAuth() async {
    _token = null;
    _refreshToken = null;
    _currentUser = null;

    ApiService.instance.clearAuthToken();

    await _clearStoredAuth();

    debugPrint('LOCAL CUSTOMER AUTH CLEARED');
  }
}