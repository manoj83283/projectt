import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class AdminService {
  AdminService._();

  static final AdminService _instance =
      AdminService._();

  factory AdminService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET CURRENT ADMIN PROFILE
  // =====================================================

  Future<Map<String, dynamic>>
      getProfile() async {
    try {
      final response = await _api.get(
        '/admin/profile',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.put(
        '/admin/profile',
        data: {
          'fullName': fullName,
          'phone': phone,
          'profileImage': profileImage,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      await _api.put(
        '/admin/change-password',
        data: {
          'currentPassword':
              currentPassword,
          'newPassword': newPassword,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET ALL ADMINS
  // =====================================================

  Future<Map<String, dynamic>>
      getAdmins({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      final response = await _api.get(
        '/admin/users',
        query: {
          'page': page,
          'limit': limit,
          if (search != null)
            'search': search,
          if (role != null)
            'role': role,
          if (isActive != null)
            'isActive': isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/users/$adminId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
    required String role,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/admin/users',
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'role': role,
          'password': password,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE ADMIN
  // =====================================================

  Future<Map<String, dynamic>>
      updateAdmin({
    required String adminId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
  }) async {
    try {
      final response = await _api.put(
        '/admin/users/$adminId',
        data: {
          if (fullName != null)
            'fullName': fullName,
          if (email != null)
            'email': email,
          if (phone != null)
            'phone': phone,
          if (role != null)
            'role': role,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE ADMIN
  // =====================================================

  Future<bool> deleteAdmin(
    String adminId,
  ) async {
    try {
      await _api.delete(
        '/admin/users/$adminId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ACTIVATE ADMIN
  // =====================================================

  Future<bool> activateAdmin(
    String adminId,
  ) async {
    try {
      await _api.patch(
        '/admin/users/$adminId/activate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DEACTIVATE ADMIN
  // =====================================================

  Future<bool> deactivateAdmin(
    String adminId,
  ) async {
    try {
      await _api.patch(
        '/admin/users/$adminId/deactivate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE ROLE
  // =====================================================

  Future<bool> updateRole({
    required String adminId,
    required String role,
  }) async {
    try {
      await _api.patch(
        '/admin/users/$adminId/role',
        data: {
          'role': role,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET ROLES
  // =====================================================

  Future<List<dynamic>> getRoles() async {
    try {
      final response = await _api.get(
        '/admin/roles',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PERMISSIONS
  // =====================================================

  Future<List<dynamic>>
      getPermissions() async {
    try {
      final response = await _api.get(
        '/admin/permissions',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ASSIGN PERMISSIONS
  // =====================================================

  Future<bool> assignPermissions({
    required String adminId,
    required List<String> permissions,
  }) async {
    try {
      await _api.put(
        '/admin/users/$adminId/permissions',
        data: {
          'permissions':
              permissions,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ADMIN ACTIVITY LOGS
  // =====================================================

  Future<List<dynamic>>
      getAdminActivityLogs(
    String adminId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/users/$adminId/activity-logs',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH ADMINS
  // =====================================================

  Future<List<dynamic>> searchAdmins(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/users/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ADMIN STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getAdminStatistics() async {
    try {
      final response = await _api.get(
        '/admin/users/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}