import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance =
      AuthRepository._();

  final AuthService _authService =
      AuthService.instance;

  // =====================================================
  // AUTHENTICATION STATE
  // =====================================================

  UserModel? get currentUser =>
      _authService.currentUser;

  bool get hasCurrentUser =>
      _authService.hasCurrentUser;

  bool get hasToken =>
      _authService.hasToken;

  bool get isAuthenticated =>
      _authService.isAuthenticated;

  String? get accessToken =>
      _authService.accessToken;

  String? get savedRefreshToken =>
      _authService.savedRefreshToken;

  // =====================================================
  // RESTORE SESSION
  // =====================================================

  Future<bool> restoreSession() {
    return _authService.restoreSession();
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return _authService.login(
      email: email,
      password: password,
    );
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) {
    return _authService.register(
      fullName: fullName,
      email: email,
      mobile: mobile,
      password: password,
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
  }) {
    return _authService.googleLogin(
      idToken: idToken,
      accessToken: accessToken,
      email: email,
      name: name,
    );
  }

  // =====================================================
  // SEND OTP
  // =====================================================

  Future<bool> sendOtp(
    String value, {
    String? email,
    String? phone,
    String? mobile,
  }) {
    return _authService.sendOtp(
      value,
      email: email,
      phone: phone,
      mobile: mobile,
    );
  }

  // =====================================================
  // VERIFY OTP
  // =====================================================

  Future<UserModel> verifyOtp({
    required String mobile,
    required String otp,
    String? email,
  }) {
    return _authService.verifyOtp(
      otp: otp,
      email: email,
      mobile: mobile,
    );
  }

  Future<bool> verifyOtpStatus({
    required String mobile,
    required String otp,
    String? email,
  }) {
    return _authService.verifyOtpStatus(
      otp: otp,
      email: email,
      mobile: mobile,
    );
  }

  // =====================================================
  // RESEND OTP
  // =====================================================

  Future<bool> resendOtp(
    String value,
  ) {
    return _authService.resendOtp(
      value,
    );
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<bool> forgotPassword(
    String email,
  ) {
    return _authService.forgotPassword(
      email,
    );
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) {
    return _authService.resetPassword(
      token: token,
      password: password,
    );
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _authService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  // =====================================================
  // GET PROFILE
  // =====================================================

  Future<UserModel> getProfile() {
    return _authService.getProfile();
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<UserModel> updateProfile({
    required Map<String, dynamic> data,
  }) {
    return _authService.updateProfile(
      data: data,
    );
  }

  // =====================================================
  // REFRESH CURRENT USER
  // =====================================================

  Future<UserModel?> refreshCurrentUser() {
    return _authService.refreshCurrentUser();
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  Future<bool> refreshToken() {
    return _authService.refreshToken();
  }

  Future<String?> refreshAccessToken() {
    return _authService.refreshAccessToken();
  }

  Future<String?>
      getRefreshTokenFromServer() {
    return _authService
        .getRefreshTokenFromServer();
  }

  // =====================================================
  // AUTHENTICATION CHECK
  // =====================================================

  Future<bool> isLoggedIn() {
    return _authService.isLoggedIn();
  }

  Future<String> ensureAuthenticated() {
    return _authService
        .ensureAuthenticated();
  }

  // =====================================================
  // GET TOKEN
  // =====================================================

  Future<String?> getToken() {
    return _authService.getToken();
  }

  // =====================================================
  // SET LOCAL AUTH
  // =====================================================

  Future<void> setLocalAuth({
    required String token,
    UserModel? user,
    String? refreshToken,
  }) {
    return _authService.setLocalAuth(
      token: token,
      user: user,
      refreshToken: refreshToken,
    );
  }

  // =====================================================
  // CHECK EMAIL
  // =====================================================

  Future<bool> checkEmailExists(
    String email,
  ) {
    return _authService.checkEmailExists(
      email,
    );
  }

  // =====================================================
  // CHECK PHONE
  // =====================================================

  Future<bool> checkPhoneExists(
    String phone,
  ) {
    return _authService.checkPhoneExists(
      phone,
    );
  }

  // =====================================================
  // UPDATE FCM TOKEN
  // =====================================================

  Future<bool> updateFcmToken({
    required String fcmToken,
  }) {
    return _authService.updateFcmToken(
      fcmToken: fcmToken,
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<bool> logout() {
    return _authService.logout();
  }

  // =====================================================
  // DELETE ACCOUNT
  // =====================================================

  Future<bool> deleteAccount() {
    return _authService.deleteAccount();
  }

  // =====================================================
  // CLEAR LOCAL AUTH
  // =====================================================

  Future<void> clearLocalAuth() {
    return _authService.clearLocalAuth();
  }
}