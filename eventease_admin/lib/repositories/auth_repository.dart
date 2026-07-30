import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({
    AuthService? authService,
  }) : _authService =
            authService ?? AuthService();

  // =====================================================
  // LOGIN
  // =====================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await _authService.login(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET PROFILE
  // =====================================================

  Future<Map<String, dynamic>>
      getProfile() async {
    try {
      return await _authService.getProfile();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<Map<String, dynamic>>
      updateProfile({
    required String fullName,
    required String phone,
    String? profileImage,
  }) async {
    try {
      return await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        profileImage: profileImage,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<Map<String, dynamic>>
      changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _authService
          .changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<Map<String, dynamic>>
      forgotPassword({
    required String email,
  }) async {
    try {
      return await _authService
          .forgotPassword(
        email: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // VERIFY OTP
  // =====================================================

  Future<Map<String, dynamic>>
      verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return await _authService.verifyOtp(
        email: email,
        otp: otp,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<Map<String, dynamic>>
      resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      return await _authService
          .resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  Future<Map<String, dynamic>>
      refreshToken() async {
    try {
      return await _authService
          .refreshToken();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TOKEN
  // =====================================================

  Future<String?> getToken() async {
    try {
      return await _authService.getToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEVICE TOKEN
  // =====================================================

  Future<void> updateFcmToken(
    String fcmToken,
  ) async {
    try {
      await _authService.updateFcmToken(
        fcmToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SESSION
  // =====================================================

  Future<void>
      invalidateAllSessions() async {
    try {
      await _authService
          .invalidateAllSessions();
    } catch (e) {
      rethrow;
    }
  }
}