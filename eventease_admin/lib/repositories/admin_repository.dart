import '../services/admin_service.dart';

class AdminRepository {
  final AdminService _adminService;

  AdminRepository({
    AdminService? adminService,
  }) : _adminService =
            adminService ??
                AdminService();

  // =====================================================
  // GET ADMINS
  // =====================================================

  Future<Map<String, dynamic>> getAdmins({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      return await _adminService.getAdmins(
        page: page,
        limit: limit,
        search: search,
        role: role,
        isActive: isActive,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET ADMIN DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getAdminDetails(
    String adminId,
  ) async {
    try {
      return await _adminService
          .getAdminDetails(adminId);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CREATE ADMIN
  // =====================================================

  Future<Map<String, dynamic>>
      createAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required List<String> permissions,
    String? profileImage,
  }) async {
    try {
      return await _adminService.createAdmin(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        permissions: permissions,
        profileImage: profileImage,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE ADMIN
  // =====================================================

  Future<Map<String, dynamic>>
      updateAdmin({
    required String adminId,
    required String fullName,
    required String phone,
    required String role,
    required List<String> permissions,
    String? profileImage,
  }) async {
    try {
      return await _adminService.updateAdmin(
        adminId: adminId,
        fullName: fullName,
        phone: phone,
        role: role,
        permissions: permissions,
        profileImage: profileImage,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE ADMIN PERMISSIONS
  // =====================================================

  Future<Map<String, dynamic>>
      updatePermissions({
    required String adminId,
    required List<String> permissions,
  }) async {
    try {
      return await _adminService
          .updatePermissions(
        adminId: adminId,
        permissions: permissions,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE ADMIN
  // =====================================================

  Future<Map<String, dynamic>>
      activateAdmin(
    String adminId,
  ) async {
    try {
      return await _adminService
          .activateAdmin(adminId);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE ADMIN
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateAdmin(
    String adminId,
  ) async {
    try {
      return await _adminService
          .deactivateAdmin(adminId);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH ADMINS
  // =====================================================

  Future<List<dynamic>> searchAdmins(
    String keyword,
  ) async {
    try {
      return await _adminService
          .searchAdmins(keyword);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ADMIN ACTIVITY LOGS
  // =====================================================

  Future<List<dynamic>>
      getAdminActivities(
    String adminId,
  ) async {
    try {
      return await _adminService
          .getAdminActivities(adminId);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ADMIN LOGIN HISTORY
  // =====================================================

  Future<List<dynamic>>
      getLoginHistory(
    String adminId,
  ) async {
    try {
      return await _adminService
          .getLoginHistory(adminId);
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RESET ADMIN PASSWORD
  // =====================================================

  Future<Map<String, dynamic>>
      resetAdminPassword({
    required String adminId,
    required String newPassword,
  }) async {
    try {
      return await _adminService
          .resetAdminPassword(
        adminId: adminId,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE ADMIN
  // =====================================================

  Future<void> deleteAdmin(
    String adminId,
  ) async {
    try {
      await _adminService.deleteAdmin(
        adminId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ADMIN ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getAdminAnalytics() async {
    try {
      return await _adminService
          .getAdminAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ROLES LIST
  // =====================================================

  Future<List<dynamic>> getRoles() async {
    try {
      return await _adminService.getRoles();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PERMISSIONS LIST
  // =====================================================

  Future<List<dynamic>>
      getPermissions() async {
    try {
      return await _adminService
          .getPermissions();
    } catch (e) {
      rethrow;
    }
  }
}