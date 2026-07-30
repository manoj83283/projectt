import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class RouteGuards {
  RouteGuards._();

  static final AuthService _authService =
      AuthService();

  // =====================================================
  // AUTHENTICATION GUARD
  // =====================================================

  static Future<bool> isAuthenticated() async {
    try {
      return await _authService
          .isLoggedIn();
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ROUTE ACCESS CHECK
  // =====================================================

  static Future<bool> canAccessRoute(
    BuildContext context,
  ) async {
    final isLoggedIn =
        await isAuthenticated();

    if (!isLoggedIn) {
      _redirectToLogin(context);
      return false;
    }

    return true;
  }

  // =====================================================
  // ROLE BASED ACCESS
  // =====================================================

  static Future<bool> hasRole({
    required String requiredRole,
  }) async {
    try {
      final profile =
          await _authService.getProfile();

      final userRole =
          profile['role']?.toString() ?? '';

      return userRole == requiredRole;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // PERMISSION CHECK
  // =====================================================

  static Future<bool> hasPermission(
    String permission,
  ) async {
    try {
      final profile =
          await _authService.getProfile();

      final permissions =
          List<String>.from(
        profile['permissions'] ?? [],
      );

      return permissions.contains(
        permission,
      );
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ROLE GUARD
  // =====================================================

  static Future<bool> checkRole({
    required BuildContext context,
    required String role,
  }) async {
    final allowed =
        await hasRole(
      requiredRole: role,
    );

    if (!allowed) {
      _redirectUnauthorized(context);
    }

    return allowed;
  }

  // =====================================================
  // PERMISSION GUARD
  // =====================================================

  static Future<bool> checkPermission({
    required BuildContext context,
    required String permission,
  }) async {
    final allowed =
        await hasPermission(
      permission,
    );

    if (!allowed) {
      _redirectUnauthorized(context);
    }

    return allowed;
  }

  // =====================================================
  // MULTIPLE PERMISSION CHECK
  // =====================================================

  static Future<bool>
      hasAnyPermission(
    List<String> permissions,
  ) async {
    try {
      final profile =
          await _authService.getProfile();

      final userPermissions =
          List<String>.from(
        profile['permissions'] ?? [],
      );

      return permissions.any(
        userPermissions.contains,
      );
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ALL PERMISSION CHECK
  // =====================================================

  static Future<bool>
      hasAllPermissions(
    List<String> permissions,
  ) async {
    try {
      final profile =
          await _authService.getProfile();

      final userPermissions =
          List<String>.from(
        profile['permissions'] ?? [],
      );

      return permissions.every(
        userPermissions.contains,
      );
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ADMIN CHECK
  // =====================================================

  static Future<bool> isSuperAdmin()
      async {
    try {
      final profile =
          await _authService.getProfile();

      return profile['role'] ==
          'super_admin';
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // REDIRECT LOGIN
  // =====================================================

  static void _redirectToLogin(
    BuildContext context,
  ) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  // =====================================================
  // REDIRECT UNAUTHORIZED
  // =====================================================

  static void _redirectUnauthorized(
    BuildContext context,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.unauthorized,
    );
  }
}