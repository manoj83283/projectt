import '../constants/permissions.dart';
import '../constants/role_constants.dart';
import '../constants/storage_keys.dart';
import '../storage/storage_helper.dart';

class RoleGuard {
  RoleGuard._();

  // =====================================================
  // CURRENT ROLE
  // =====================================================

  static String get currentRole {
    return StorageHelper.getString(
          StorageKeys.userRole,
        ) ??
        '';
  }

  // =====================================================
  // CURRENT PERMISSIONS
  // =====================================================

  static List<String> get currentPermissions {
    return StorageHelper.getStringList(
      StorageKeys.userPermissions,
    );
  }

  // =====================================================
  // AUTH CHECK
  // =====================================================

  static bool get isLoggedIn {
    return StorageHelper.getBool(
      StorageKeys.isLoggedIn,
    );
  }

  // =====================================================
  // ROLE CHECK
  // =====================================================

  static bool hasRole(
    String role,
  ) {
    return currentRole == role;
  }

  // =====================================================
  // MULTIPLE ROLES
  // =====================================================

  static bool hasAnyRole(
    List<String> roles,
  ) {
    return roles.contains(
      currentRole,
    );
  }

  // =====================================================
  // PERMISSION CHECK
  // =====================================================

  static bool hasPermission(
    String permission,
  ) {
    return currentPermissions
        .contains(permission);
  }

  // =====================================================
  // MULTIPLE PERMISSIONS
  // =====================================================

  static bool hasAnyPermission(
    List<String> permissions,
  ) {
    return permissions.any(
      currentPermissions.contains,
    );
  }

  // =====================================================
  // ALL PERMISSIONS
  // =====================================================

  static bool hasAllPermissions(
    List<String> permissions,
  ) {
    return permissions.every(
      currentPermissions.contains,
    );
  }

  // =====================================================
  // SUPER ADMIN
  // =====================================================

  static bool get isSuperAdmin {
    return currentRole ==
        RoleConstants.superAdmin;
  }

  // =====================================================
  // ADMIN
  // =====================================================

  static bool get isAdmin {
    return currentRole ==
        RoleConstants.admin;
  }

  // =====================================================
  // PRIVILEGED USER
  // =====================================================

  static bool get isPrivilegedUser {
    return RoleConstants
        .privilegedRoles
        .contains(currentRole);
  }

  // =====================================================
  // FINANCE ACCESS
  // =====================================================

  static bool get canManageFinance {
    return RoleConstants.financeRoles
        .contains(currentRole);
  }

  // =====================================================
  // KYC ACCESS
  // =====================================================

  static bool get canManageKyc {
    return RoleConstants.kycRoles
        .contains(currentRole);
  }

  // =====================================================
  // SUPPORT ACCESS
  // =====================================================

  static bool get canManageSupport {
    return RoleConstants.supportRoles
        .contains(currentRole);
  }

  // =====================================================
  // REPORT ACCESS
  // =====================================================

  static bool get canAccessReports {
    return RoleConstants.reportRoles
        .contains(currentRole);
  }

  // =====================================================
  // CONTENT ACCESS
  // =====================================================

  static bool get canManageContent {
    return RoleConstants.contentRoles
        .contains(currentRole);
  }

  // =====================================================
  // FEATURE ACCESS HELPERS
  // =====================================================

  static bool get canViewDashboard {
    return hasPermission(
      Permissions.dashboardView,
    );
  }

  static bool get canManageCustomers {
    return hasAnyPermission([
      Permissions.customerView,
      Permissions.customerEdit,
      Permissions.customerDelete,
    ]);
  }

  static bool get canManageProviders {
    return hasAnyPermission([
      Permissions.providerView,
      Permissions.providerApprove,
      Permissions.providerReject,
    ]);
  }

  static bool get canManageBookings {
    return hasAnyPermission([
      Permissions.bookingView,
      Permissions.bookingManage,
    ]);
  }

  static bool get canManageOrders {
    return hasAnyPermission([
      Permissions.orderView,
      Permissions.orderManage,
    ]);
  }

  static bool get canManagePayments {
    return hasAnyPermission([
      Permissions.paymentView,
      Permissions.refundManage,
    ]);
  }

  static bool get canSendNotifications {
    return hasPermission(
      Permissions.notificationSend,
    );
  }

  static bool get canManageAdmins {
    return hasPermission(
      Permissions.adminManage,
    );
  }

  static bool get canManageRoles {
    return hasPermission(
      Permissions.roleManage,
    );
  }

  static bool get canManageSettings {
    return hasPermission(
      Permissions.settingsManage,
    );
  }

  // =====================================================
  // MENU VISIBILITY
  // =====================================================

  static bool canShowMenu(
    String permission,
  ) {
    return hasPermission(
      permission,
    );
  }

  // =====================================================
  // SCREEN ACCESS
  // =====================================================

  static bool canAccessScreen({
    required List<String> roles,
    List<String>? permissions,
  }) {
    final roleAllowed =
        roles.contains(currentRole);

    if (!roleAllowed) {
      return false;
    }

    if (permissions == null ||
        permissions.isEmpty) {
      return true;
    }

    return hasAnyPermission(
      permissions,
    );
  }

  // =====================================================
  // ROLE SUMMARY
  // =====================================================

  static Map<String, dynamic>
      roleSummary() {
    return {
      'role': currentRole,
      'isSuperAdmin': isSuperAdmin,
      'isAdmin': isAdmin,
      'permissions': currentPermissions,
      'financeAccess':
          canManageFinance,
      'kycAccess':
          canManageKyc,
      'reportAccess':
          canAccessReports,
      'supportAccess':
          canManageSupport,
    };
  }
}