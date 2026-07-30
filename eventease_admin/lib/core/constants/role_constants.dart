class RoleConstants {
  RoleConstants._();

  // =====================================================
  // SYSTEM ROLES
  // =====================================================

  static const String superAdmin =
      'super_admin';

  static const String admin =
      'admin';

  static const String moderator =
      'moderator';

  static const String supportManager =
      'support_manager';

  static const String financeManager =
      'finance_manager';

  static const String operationsManager =
      'operations_manager';

  static const String contentManager =
      'content_manager';

  static const String kycManager =
      'kyc_manager';

  static const String customerSupport =
      'customer_support';

  static const String reportAnalyst =
      'report_analyst';

  static const String marketingManager =
      'marketing_manager';

  static const String viewer =
      'viewer';

  // =====================================================
  // ROLE DISPLAY NAMES
  // =====================================================

  static const String superAdminLabel =
      'Super Admin';

  static const String adminLabel =
      'Admin';

  static const String moderatorLabel =
      'Moderator';

  static const String supportManagerLabel =
      'Support Manager';

  static const String financeManagerLabel =
      'Finance Manager';

  static const String operationsManagerLabel =
      'Operations Manager';

  static const String contentManagerLabel =
      'Content Manager';

  static const String kycManagerLabel =
      'KYC Manager';

  static const String customerSupportLabel =
      'Customer Support';

  static const String reportAnalystLabel =
      'Report Analyst';

  static const String marketingManagerLabel =
      'Marketing Manager';

  static const String viewerLabel =
      'Viewer';

  // =====================================================
  // ROLE LIST
  // =====================================================

  static const List<String> allRoles = [
    superAdmin,
    admin,
    moderator,
    supportManager,
    financeManager,
    operationsManager,
    contentManager,
    kycManager,
    customerSupport,
    reportAnalyst,
    marketingManager,
    viewer,
  ];

  // =====================================================
  // HIGH PRIVILEGE ROLES
  // =====================================================

  static const List<String>
      privilegedRoles = [
    superAdmin,
    admin,
  ];

  // =====================================================
  // KYC ACCESS ROLES
  // =====================================================

  static const List<String> kycRoles = [
    superAdmin,
    admin,
    kycManager,
  ];

  // =====================================================
  // FINANCE ACCESS ROLES
  // =====================================================

  static const List<String>
      financeRoles = [
    superAdmin,
    admin,
    financeManager,
  ];

  // =====================================================
  // SUPPORT ACCESS ROLES
  // =====================================================

  static const List<String>
      supportRoles = [
    superAdmin,
    admin,
    supportManager,
    customerSupport,
  ];

  // =====================================================
  // REPORT ACCESS ROLES
  // =====================================================

  static const List<String>
      reportRoles = [
    superAdmin,
    admin,
    reportAnalyst,
  ];

  // =====================================================
  // CONTENT ACCESS ROLES
  // =====================================================

  static const List<String>
      contentRoles = [
    superAdmin,
    admin,
    contentManager,
    marketingManager,
  ];

  // =====================================================
  // ROLE HELPERS
  // =====================================================

  static bool isSuperAdmin(
    String role,
  ) {
    return role == superAdmin;
  }

  static bool isAdmin(
    String role,
  ) {
    return role == admin;
  }

  static bool isPrivilegedRole(
    String role,
  ) {
    return privilegedRoles.contains(
      role,
    );
  }

  static bool canManageFinance(
    String role,
  ) {
    return financeRoles.contains(
      role,
    );
  }

  static bool canManageKyc(
    String role,
  ) {
    return kycRoles.contains(
      role,
    );
  }

  static bool canManageSupport(
    String role,
  ) {
    return supportRoles.contains(
      role,
    );
  }

  static bool canAccessReports(
    String role,
  ) {
    return reportRoles.contains(
      role,
    );
  }

  static bool canManageContent(
    String role,
  ) {
    return contentRoles.contains(
      role,
    );
  }

  // =====================================================
  // DISPLAY NAME
  // =====================================================

  static String getRoleLabel(
    String role,
  ) {
    switch (role) {
      case superAdmin:
        return superAdminLabel;

      case admin:
        return adminLabel;

      case moderator:
        return moderatorLabel;

      case supportManager:
        return supportManagerLabel;

      case financeManager:
        return financeManagerLabel;

      case operationsManager:
        return operationsManagerLabel;

      case contentManager:
        return contentManagerLabel;

      case kycManager:
        return kycManagerLabel;

      case customerSupport:
        return customerSupportLabel;

      case reportAnalyst:
        return reportAnalystLabel;

      case marketingManager:
        return marketingManagerLabel;

      case viewer:
        return viewerLabel;

      default:
        return 'Unknown Role';
    }
  }
}