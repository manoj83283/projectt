import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  String? _token;

  // ==========================================
  // RESPONSE HELPERS
  // ==========================================

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
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractUserMap(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      final dynamic user = map['user'] ??
          map['data']?['user'] ??
          map['data'] ??
          map['customer'] ??
          map['profile'];

      return _asMap(user);
    }

    return <String, dynamic>{};
  }

  String? _extractToken(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      return map['token']?.toString() ??
          map['accessToken']?.toString() ??
          map['authToken']?.toString() ??
          map['data']?['token']?.toString() ??
          map['data']?['accessToken']?.toString();
    }

    return null;
  }

  String? _extractRefreshToken(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      return map['refreshToken']?.toString() ??
          map['data']?['refreshToken']?.toString();
    }

    return null;
  }

  void _setToken(String? token) {
    if (token == null || token.trim().isEmpty) {
      return;
    }

    _token = token;
    ApiService.instance.setAuthToken(token);
  }

  UserModel _setCurrentUser(Map<String, dynamic> userMap) {
    final UserModel user = UserModel.fromMap(userMap);
    _currentUser = user;
    return user;
  }

  // ==========================================
  // LOGIN
  // ==========================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final dynamic response = await ApiService.instance.post(
      '/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    _setToken(
      _extractToken(response),
    );

    return _setCurrentUser(
      _extractUserMap(response),
    );
  }

  // ==========================================
  // REGISTER
  // Supports both:
  // name / phone
  // fullName / mobile
  // ==========================================

  Future<UserModel> register({
    String? name,
    String? fullName,
    required String email,
    String? phone,
    String? mobile,
    required String password,
  }) async {
    final String resolvedName = (name ?? fullName ?? '').trim();
    final String resolvedPhone = (phone ?? mobile ?? '').trim();

    final dynamic response = await ApiService.instance.post(
      '/auth/register',
      data: {
        'name': resolvedName,
        'fullName': resolvedName,
        'email': email.trim(),
        'phone': resolvedPhone,
        'mobile': resolvedPhone,
        'password': password,
      },
    );

    _setToken(
      _extractToken(response),
    );

    return _setCurrentUser(
      _extractUserMap(response),
    );
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<UserModel> googleLogin({
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
  }) async {
    final dynamic response = await ApiService.instance.post(
      '/auth/google-login',
      data: {
        if (idToken != null && idToken.trim().isNotEmpty)
          'idToken': idToken.trim(),
        if (accessToken != null && accessToken.trim().isNotEmpty)
          'accessToken': accessToken.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      },
    );

    _setToken(
      _extractToken(response),
    );

    return _setCurrentUser(
      _extractUserMap(response),
    );
  }

  // ==========================================
  // GET PROFILE
  // ==========================================

  Future<UserModel> getProfile() async {
    final dynamic response = await ApiService.instance.get(
      '/auth/profile',
    );

    return _setCurrentUser(
      _extractUserMap(response),
    );
  }

  // ==========================================
  // UPDATE PROFILE
  // Supports direct data map and named fields.
  // ==========================================

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
    final Map<String, dynamic> payload = {
      ...?data,
      if (name != null) 'name': name.trim(),
      if (fullName != null) 'fullName': fullName.trim(),
      if (email != null) 'email': email.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (mobile != null) 'mobile': mobile.trim(),
      if (profileImage != null) 'profileImage': profileImage.trim(),
      if (gender != null) 'gender': gender.trim(),
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
    };

    final dynamic response = await ApiService.instance.put(
      '/auth/profile',
      data: payload,
    );

    return _setCurrentUser(
      _extractUserMap(response),
    );
  }

  // ==========================================
  // REFRESH TOKEN
  // Repository compatibility: returns bool.
  // ==========================================

  Future<bool> refreshToken() async {
    final dynamic response = await ApiService.instance.post(
      '/auth/refresh-token',
    );

    final String? token = _extractToken(response);

    if (token == null || token.trim().isEmpty) {
      return false;
    }

    _setToken(token);

    return true;
  }

  // ==========================================
  // REFRESH ACCESS TOKEN STRING
  // ==========================================

  Future<String?> refreshAccessToken() async {
    final dynamic response = await ApiService.instance.post(
      '/auth/refresh-token',
    );

    final String? token = _extractToken(response);

    if (token != null && token.trim().isNotEmpty) {
      _setToken(token);
    }

    return token;
  }

  // ==========================================
  // FORGOT PASSWORD
  // ==========================================

  Future<bool> forgotPassword(
    String email,
  ) async {
    await ApiService.instance.post(
      '/auth/forgot-password',
      data: {
        'email': email.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // RESET PASSWORD
  // ==========================================

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    await ApiService.instance.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
      },
    );

    return true;
  }

  // ==========================================
  // CHANGE PASSWORD
  // ==========================================

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiService.instance.post(
      '/auth/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    return true;
  }

  // ==========================================
  // SEND OTP
  // Supports positional value, email, phone, mobile.
  // This fixes repository calls like:
  // _authService.sendOtp(mobile)
  // ==========================================

  Future<bool> sendOtp(
    String value, {
    String? email,
    String? phone,
    String? mobile,
  }) async {
    final bool isEmail = value.contains('@');

    final String resolvedEmail =
        email ?? (isEmail ? value : '');

    final String resolvedPhone =
        phone ?? mobile ?? (!isEmail ? value : '');

    await ApiService.instance.post(
      '/auth/send-otp',
      data: {
        if (resolvedEmail.trim().isNotEmpty)
          'email': resolvedEmail.trim(),
        if (resolvedPhone.trim().isNotEmpty)
          'phone': resolvedPhone.trim(),
        if (resolvedPhone.trim().isNotEmpty)
          'mobile': resolvedPhone.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // VERIFY OTP
  // Returns UserModel because AuthRepository expects Future<UserModel>.
  // ==========================================

  Future<UserModel> verifyOtp({
    String? email,
    String? phone,
    String? mobile,
    required String otp,
  }) async {
    final String resolvedPhone = (phone ?? mobile ?? '').trim();

    final dynamic response = await ApiService.instance.post(
      '/auth/verify-otp',
      data: {
        if (email != null && email.trim().isNotEmpty)
          'email': email.trim(),
        if (resolvedPhone.isNotEmpty)
          'phone': resolvedPhone,
        if (resolvedPhone.isNotEmpty)
          'mobile': resolvedPhone,
        'otp': otp.trim(),
      },
    );

    final String? token = _extractToken(response);

    if (token != null && token.trim().isNotEmpty) {
      _setToken(token);
    }

    final Map<String, dynamic> userMap = _extractUserMap(response);

    if (userMap.isEmpty) {
      return UserModel.fromMap(
        <String, dynamic>{},
      );
    }

    return _setCurrentUser(userMap);
  }

  // ==========================================
  // VERIFY OTP BOOLEAN COMPATIBILITY
  // If any old screen only needs true/false.
  // ==========================================

  Future<bool> verifyOtpStatus({
    String? email,
    String? phone,
    String? mobile,
    required String otp,
  }) async {
    await verifyOtp(
      email: email,
      phone: phone,
      mobile: mobile,
      otp: otp,
    );

    return true;
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  Future<bool> resendOtp(
    String value,
  ) async {
    final bool isEmail = value.contains('@');

    await ApiService.instance.post(
      '/auth/resend-otp',
      data: {
        if (isEmail) 'email': value.trim(),
        if (!isEmail) 'phone': value.trim(),
        if (!isEmail) 'mobile': value.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // LOGOUT
  // Repository compatibility: returns bool.
  // ==========================================

  Future<bool> logout() async {
    try {
      await ApiService.instance.post(
        '/auth/logout',
      );
    } catch (_) {
      // Ignore logout API failure and clear local token.
    }

    _token = null;
    _currentUser = null;
    ApiService.instance.clearAuthToken();

    return true;
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<bool> deleteAccount() async {
    await ApiService.instance.delete(
      '/auth/delete-account',
    );

    _token = null;
    _currentUser = null;
    ApiService.instance.clearAuthToken();

    return true;
  }

  // ==========================================
  // TOKEN / SESSION HELPERS
  // ==========================================

  Future<bool> isLoggedIn() async {
    final String? token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  Future<String?> getToken() async {
    if (_token != null && _token!.trim().isNotEmpty) {
      return _token;
    }

    final String? apiToken = ApiService.instance.authToken;

    if (apiToken == null || apiToken.trim().isEmpty) {
      return null;
    }

    if (apiToken.startsWith('Bearer ')) {
      return apiToken.replaceFirst('Bearer ', '').trim();
    }

    return apiToken;
  }

  UserModel? get currentUser => _currentUser;

  bool get hasCurrentUser => _currentUser != null;

  void setLocalAuth({
    required String token,
    UserModel? user,
  }) {
    _setToken(token);

    if (user != null) {
      _currentUser = user;
    }
  }

  void clearLocalAuth() {
    _token = null;
    _currentUser = null;
    ApiService.instance.clearAuthToken();
  }

  // ==========================================
  // CHECK EMAIL / PHONE EXISTS
  // ==========================================

  Future<bool> checkEmailExists(
    String email,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/auth/check-email',
      queryParameters: {
        'email': email.trim(),
      },
    );

    final dynamic data = _responseData(response);

    if (data is Map) {
      return data['exists'] == true ||
          data['data']?['exists'] == true;
    }

    return false;
  }

  Future<bool> checkPhoneExists(
    String phone,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/auth/check-phone',
      queryParameters: {
        'phone': phone.trim(),
      },
    );

    final dynamic data = _responseData(response);

    if (data is Map) {
      return data['exists'] == true ||
          data['data']?['exists'] == true;
    }

    return false;
  }

  // ==========================================
  // UPDATE FCM TOKEN
  // ==========================================

  Future<bool> updateFcmToken({
    required String fcmToken,
  }) async {
    await ApiService.instance.post(
      '/auth/fcm-token',
      data: {
        'fcmToken': fcmToken,
      },
    );

    return true;
  }

  // ==========================================
  // REFRESH CURRENT USER
  // ==========================================

  Future<UserModel?> refreshCurrentUser() async {
    try {
      final UserModel user = await getProfile();
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // REFRESH TOKEN RESPONSE EXTRA
  // ==========================================

  Future<String?> getRefreshTokenFromServer() async {
    final dynamic response = await ApiService.instance.post(
      '/auth/refresh-token',
    );

    final String? token = _extractToken(response);
    final String? refreshToken = _extractRefreshToken(response);

    if (token != null && token.trim().isNotEmpty) {
      _setToken(token);
    }

    return refreshToken;
  }
}