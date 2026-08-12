import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/settings_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({
    super.key,
  });

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _sessionTimeoutController =
      TextEditingController();
  final TextEditingController _maxLoginAttemptsController =
      TextEditingController();
  final TextEditingController _lockoutDurationController =
      TextEditingController();
  final TextEditingController _passwordMinLengthController =
      TextEditingController();
  final TextEditingController _passwordExpiryDaysController =
      TextEditingController();
  final TextEditingController _allowedIpAddressesController =
      TextEditingController();
  final TextEditingController _adminEmailAlertController =
      TextEditingController();

  String _securityLevel = 'high';
  String _otpProvider = 'email';
  String _adminAccessMode = 'role_based';

  bool _twoFactorEnabled = true;
  bool _emailOtpEnabled = true;
  bool _smsOtpEnabled = false;
  bool _loginAlertsEnabled = true;
  bool _suspiciousActivityAlertsEnabled = true;
  bool _ipWhitelistEnabled = false;
  bool _deviceTrackingEnabled = true;
  bool _passwordExpiryEnabled = false;
  bool _strongPasswordRequired = true;
  bool _adminSessionRestrictionEnabled = true;
  bool _auditLogsEnabled = true;
  bool _dataExportRestrictionEnabled = true;
  bool _maintenanceLockEnabled = false;

  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _securityLevels = const [
    'low',
    'medium',
    'high',
    'strict',
  ];

  final List<String> _otpProviders = const [
    'email',
    'sms',
    'email_sms',
    'authenticator',
  ];

  final List<String> _adminAccessModes = const [
    'role_based',
    'permission_based',
    'super_admin_only',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSecuritySettings();
    });
  }

  @override
  void dispose() {
    _sessionTimeoutController.dispose();
    _maxLoginAttemptsController.dispose();
    _lockoutDurationController.dispose();
    _passwordMinLengthController.dispose();
    _passwordExpiryDaysController.dispose();
    _allowedIpAddressesController.dispose();
    _adminEmailAlertController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() {
      _isLoading = true;
    });

    final SettingsProvider provider = context.read<SettingsProvider>();

    await provider.getSecuritySettings();

    if (!mounted) return;

    _securityLevel =
        provider.securityLevel.isEmpty ? 'high' : provider.securityLevel;
    _otpProvider = provider.otpProvider.isEmpty ? 'email' : provider.otpProvider;
    _adminAccessMode =
        provider.adminAccessMode.isEmpty ? 'role_based' : provider.adminAccessMode;

    _sessionTimeoutController.text = provider.sessionTimeoutMinutes.toString();
    _maxLoginAttemptsController.text = provider.maxLoginAttempts.toString();
    _lockoutDurationController.text = provider.lockoutDurationMinutes.toString();
    _passwordMinLengthController.text = provider.passwordMinLength.toString();
    _passwordExpiryDaysController.text = provider.passwordExpiryDays.toString();
    _allowedIpAddressesController.text = provider.allowedIpAddresses;
    _adminEmailAlertController.text = provider.adminSecurityAlertEmail;

    _twoFactorEnabled = provider.twoFactorEnabled;
    _emailOtpEnabled = provider.emailOtpEnabled;
    _smsOtpEnabled = provider.smsOtpEnabled;
    _loginAlertsEnabled = provider.loginAlertsEnabled;
    _suspiciousActivityAlertsEnabled =
        provider.suspiciousActivityAlertsEnabled;
    _ipWhitelistEnabled = provider.ipWhitelistEnabled;
    _deviceTrackingEnabled = provider.deviceTrackingEnabled;
    _passwordExpiryEnabled = provider.passwordExpiryEnabled;
    _strongPasswordRequired = provider.strongPasswordRequired;
    _adminSessionRestrictionEnabled = provider.adminSessionRestrictionEnabled;
    _auditLogsEnabled = provider.auditLogsEnabled;
    _dataExportRestrictionEnabled = provider.dataExportRestrictionEnabled;
    _maintenanceLockEnabled = provider.maintenanceLockEnabled;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadSecuritySettings();
  }

  void _resetSettings() {
    FocusScope.of(context).unfocus();

    final SettingsProvider provider = context.read<SettingsProvider>();

    setState(() {
      _securityLevel =
          provider.securityLevel.isEmpty ? 'high' : provider.securityLevel;
      _otpProvider =
          provider.otpProvider.isEmpty ? 'email' : provider.otpProvider;
      _adminAccessMode = provider.adminAccessMode.isEmpty
          ? 'role_based'
          : provider.adminAccessMode;

      _sessionTimeoutController.text =
          provider.sessionTimeoutMinutes.toString();
      _maxLoginAttemptsController.text =
          provider.maxLoginAttempts.toString();
      _lockoutDurationController.text =
          provider.lockoutDurationMinutes.toString();
      _passwordMinLengthController.text =
          provider.passwordMinLength.toString();
      _passwordExpiryDaysController.text =
          provider.passwordExpiryDays.toString();
      _allowedIpAddressesController.text = provider.allowedIpAddresses;
      _adminEmailAlertController.text = provider.adminSecurityAlertEmail;

      _twoFactorEnabled = provider.twoFactorEnabled;
      _emailOtpEnabled = provider.emailOtpEnabled;
      _smsOtpEnabled = provider.smsOtpEnabled;
      _loginAlertsEnabled = provider.loginAlertsEnabled;
      _suspiciousActivityAlertsEnabled =
          provider.suspiciousActivityAlertsEnabled;
      _ipWhitelistEnabled = provider.ipWhitelistEnabled;
      _deviceTrackingEnabled = provider.deviceTrackingEnabled;
      _passwordExpiryEnabled = provider.passwordExpiryEnabled;
      _strongPasswordRequired = provider.strongPasswordRequired;
      _adminSessionRestrictionEnabled = provider.adminSessionRestrictionEnabled;
      _auditLogsEnabled = provider.auditLogsEnabled;
      _dataExportRestrictionEnabled = provider.dataExportRestrictionEnabled;
      _maintenanceLockEnabled = provider.maintenanceLockEnabled;
    });
  }

  Future<void> _saveSecuritySettings() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int sessionTimeout =
        int.tryParse(_sessionTimeoutController.text.trim()) ?? 0;
    final int maxLoginAttempts =
        int.tryParse(_maxLoginAttemptsController.text.trim()) ?? 0;
    final int lockoutDuration =
        int.tryParse(_lockoutDurationController.text.trim()) ?? 0;
    final int passwordMinLength =
        int.tryParse(_passwordMinLengthController.text.trim()) ?? 0;
    final int passwordExpiryDays =
        int.tryParse(_passwordExpiryDaysController.text.trim()) ?? 0;

    if (_twoFactorEnabled && !_emailOtpEnabled && !_smsOtpEnabled) {
      NavigationService.showWarning(
        'Enable at least one OTP channel when two-factor authentication is enabled',
      );
      return;
    }

    if (_ipWhitelistEnabled &&
        _allowedIpAddressesController.text.trim().isEmpty) {
      NavigationService.showWarning(
        'Allowed IP addresses are required when IP whitelist is enabled',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().updateSecuritySettings(
              securityLevel: _securityLevel,
              otpProvider: _otpProvider,
              adminAccessMode: _adminAccessMode,
              sessionTimeoutMinutes: sessionTimeout,
              maxLoginAttempts: maxLoginAttempts,
              lockoutDurationMinutes: lockoutDuration,
              passwordMinLength: passwordMinLength,
              passwordExpiryDays: passwordExpiryDays,
              allowedIpAddresses: _allowedIpAddressesController.text.trim(),
              adminSecurityAlertEmail:
                  _adminEmailAlertController.text.trim(),
              twoFactorEnabled: _twoFactorEnabled,
              emailOtpEnabled: _emailOtpEnabled,
              smsOtpEnabled: _smsOtpEnabled,
              loginAlertsEnabled: _loginAlertsEnabled,
              suspiciousActivityAlertsEnabled:
                  _suspiciousActivityAlertsEnabled,
              ipWhitelistEnabled: _ipWhitelistEnabled,
              deviceTrackingEnabled: _deviceTrackingEnabled,
              passwordExpiryEnabled: _passwordExpiryEnabled,
              strongPasswordRequired: _strongPasswordRequired,
              adminSessionRestrictionEnabled:
                  _adminSessionRestrictionEnabled,
              auditLogsEnabled: _auditLogsEnabled,
              dataExportRestrictionEnabled: _dataExportRestrictionEnabled,
              maintenanceLockEnabled: _maintenanceLockEnabled,
            );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Security settings updated successfully',
      );

      await _loadSecuritySettings();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to update security settings',
    );
  }

  Future<void> _runSecurityCheck() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Run Security Check',
      message:
          'Do you want to run a security configuration check for the admin panel?',
      confirmText: 'Run Check',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().runSecurityCheck();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Security check completed successfully',
      );
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Security check failed',
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _previewSettings() {
    FocusScope.of(context).unfocus();

    showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.security_outlined,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Security Settings Preview',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _PreviewRow(
                    label: 'Security Level',
                    value: AppFormatters.formatStatus(_securityLevel),
                  ),
                  _PreviewRow(
                    label: 'Admin Access',
                    value: AppFormatters.formatStatus(_adminAccessMode),
                  ),
                  _PreviewRow(
                    label: 'OTP Provider',
                    value: AppFormatters.formatStatus(_otpProvider),
                  ),
                  _PreviewRow(
                    label: 'Session Timeout',
                    value: '${_sessionTimeoutController.text.trim()} minutes',
                  ),
                  _PreviewRow(
                    label: 'Login Attempts',
                    value: _maxLoginAttemptsController.text.trim(),
                  ),
                  _PreviewRow(
                    label: 'Lockout Duration',
                    value: '${_lockoutDurationController.text.trim()} minutes',
                  ),
                  _PreviewRow(
                    label: 'Password Min Length',
                    value: _passwordMinLengthController.text.trim(),
                  ),
                  _PreviewRow(
                    label: 'Password Expiry',
                    value: _passwordExpiryEnabled
                        ? '${_passwordExpiryDaysController.text.trim()} days'
                        : 'Disabled',
                  ),
                  _PreviewRow(
                    label: 'IP Whitelist',
                    value: _ipWhitelistEnabled ? 'Enabled' : 'Disabled',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: _twoFactorEnabled ? '2FA On' : '2FA Off',
                        color: _twoFactorEnabled
                            ? AppColors.success
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _auditLogsEnabled
                            ? 'Audit Logs On'
                            : 'Audit Logs Off',
                        color: _auditLogsEnabled
                            ? AppColors.primary
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _deviceTrackingEnabled
                            ? 'Device Tracking On'
                            : 'Device Tracking Off',
                        color: _deviceTrackingEnabled
                            ? Colors.purple
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _dataExportRestrictionEnabled
                            ? 'Export Restricted'
                            : 'Export Open',
                        color: _dataExportRestrictionEnabled
                            ? AppColors.warning
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      text: 'Close',
                      type: ButtonType.outline,
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return PageHeader(
      title: 'Security Settings',
      subtitle:
          'Configure admin access, two-factor authentication, password policy, sessions, login protection, IP whitelist, audit logs and security alerts.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewSettings,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Run Check',
          type: ButtonType.outline,
          icon: Icons.verified_user_outlined,
          onPressed: _isLoading || _isSaving ? null : _runSecurityCheck,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Refresh',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading || _isSaving ? null : _refresh,
        ),
      ],
    );
  }

  Widget _buildSummaryCards(SettingsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth < 1100;
        final bool isMobile = constraints.maxWidth < 650;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile
                ? 1
                : isTablet
                    ? 2
                    : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile
                ? 3.8
                : isTablet
                    ? 2.2
                    : 1.85,
          ),
          children: [
            _SecuritySummaryCard(
              title: 'Security Level',
              value: AppFormatters.formatStatus(provider.securityLevel),
              icon: Icons.security_outlined,
              color: AppColors.error,
            ),
            _SecuritySummaryCard(
              title: '2FA',
              value: provider.twoFactorEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.verified_user_outlined,
              color: provider.twoFactorEnabled
                  ? AppColors.success
                  : Colors.blueGrey,
            ),
            _SecuritySummaryCard(
              title: 'Audit Logs',
              value: provider.auditLogsEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.receipt_long_outlined,
              color: provider.auditLogsEnabled
                  ? AppColors.primary
                  : Colors.blueGrey,
            ),
            _SecuritySummaryCard(
              title: 'IP Whitelist',
              value: provider.ipWhitelistEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.public_off_outlined,
              color: provider.ipWhitelistEnabled
                  ? AppColors.warning
                  : Colors.blueGrey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccessPolicySection() {
    return _SectionCard(
      title: 'Access Policy',
      icon: Icons.admin_panel_settings_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 900;

              if (isCompact) {
                return Column(
                  children: [
                    _buildSecurityLevelDropdown(),
                    const SizedBox(height: 16),
                    _buildOtpProviderDropdown(),
                    const SizedBox(height: 16),
                    _buildAdminAccessModeDropdown(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildSecurityLevelDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOtpProviderDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAdminAccessModeDropdown()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Enable Two-Factor Authentication',
            subtitle: 'Require second factor verification for admin login',
            icon: Icons.verified_user_outlined,
            color: AppColors.success,
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Email OTP',
            subtitle: 'Send OTP to admin registered email',
            icon: Icons.email_outlined,
            color: AppColors.primary,
            value: _emailOtpEnabled,
            onChanged: _twoFactorEnabled
                ? (value) {
                    setState(() {
                      _emailOtpEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable SMS OTP',
            subtitle: 'Send OTP to admin registered mobile number',
            icon: Icons.sms_outlined,
            color: AppColors.warning,
            value: _smsOtpEnabled,
            onChanged: _twoFactorEnabled
                ? (value) {
                    setState(() {
                      _smsOtpEnabled = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityLevelDropdown() {
    return CustomDropdown<String>(
      labelText: 'Security Level',
      value: _securityLevel,
      items: _securityLevels,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _securityLevel = value;
        });
      },
    );
  }

  Widget _buildOtpProviderDropdown() {
    return CustomDropdown<String>(
      labelText: 'OTP Provider',
      value: _otpProvider,
      items: _otpProviders,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _otpProvider = value;
        });
      },
    );
  }

  Widget _buildAdminAccessModeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Admin Access Mode',
      value: _adminAccessMode,
      items: _adminAccessModes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _adminAccessMode = value;
        });
      },
    );
  }

  Widget _buildLoginProtectionSection() {
    return _SectionCard(
      title: 'Login Protection',
      icon: Icons.login_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 900;

              if (isCompact) {
                return Column(
                  children: [
                    _buildSessionTimeoutField(),
                    const SizedBox(height: 16),
                    _buildMaxLoginAttemptsField(),
                    const SizedBox(height: 16),
                    _buildLockoutDurationField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildSessionTimeoutField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMaxLoginAttemptsField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLockoutDurationField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Enable Login Alerts',
            subtitle: 'Send alert when admin logs in from a device',
            icon: Icons.notifications_active_outlined,
            color: AppColors.primary,
            value: _loginAlertsEnabled,
            onChanged: (value) {
              setState(() {
                _loginAlertsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Suspicious Activity Alerts',
            subtitle: 'Notify admins about unusual login attempts or access patterns',
            icon: Icons.warning_amber_outlined,
            color: AppColors.error,
            value: _suspiciousActivityAlertsEnabled,
            onChanged: (value) {
              setState(() {
                _suspiciousActivityAlertsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Device Tracking',
            subtitle: 'Track admin devices for access visibility and audit',
            icon: Icons.devices_outlined,
            color: Colors.purple,
            value: _deviceTrackingEnabled,
            onChanged: (value) {
              setState(() {
                _deviceTrackingEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTimeoutField() {
    return _IntegerTextField(
      controller: _sessionTimeoutController,
      labelText: 'Session Timeout Minutes',
      hintText: 'Example: 30',
      prefixIcon: Icons.timer_outlined,
      validator: _integerValidator(
        fieldName: 'Session timeout',
        allowZero: false,
      ),
    );
  }

  Widget _buildMaxLoginAttemptsField() {
    return _IntegerTextField(
      controller: _maxLoginAttemptsController,
      labelText: 'Max Login Attempts',
      hintText: 'Example: 5',
      prefixIcon: Icons.lock_person_outlined,
      validator: _integerValidator(
        fieldName: 'Max login attempts',
        allowZero: false,
      ),
    );
  }

  Widget _buildLockoutDurationField() {
    return _IntegerTextField(
      controller: _lockoutDurationController,
      labelText: 'Lockout Duration Minutes',
      hintText: 'Example: 15',
      prefixIcon: Icons.lock_clock_outlined,
      validator: _integerValidator(
        fieldName: 'Lockout duration',
        allowZero: false,
      ),
    );
  }

  Widget _buildPasswordPolicySection() {
    return _SectionCard(
      title: 'Password Policy',
      icon: Icons.password_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildPasswordMinLengthField(),
                    const SizedBox(height: 16),
                    _buildPasswordExpiryField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildPasswordMinLengthField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPasswordExpiryField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Require Strong Password',
            subtitle:
                'Require uppercase, lowercase, number and special character',
            icon: Icons.password_outlined,
            color: AppColors.success,
            value: _strongPasswordRequired,
            onChanged: (value) {
              setState(() {
                _strongPasswordRequired = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Password Expiry',
            subtitle: 'Force admins to update password after configured days',
            icon: Icons.update_outlined,
            color: AppColors.warning,
            value: _passwordExpiryEnabled,
            onChanged: (value) {
              setState(() {
                _passwordExpiryEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMinLengthField() {
    return _IntegerTextField(
      controller: _passwordMinLengthController,
      labelText: 'Password Minimum Length',
      hintText: 'Example: 8',
      prefixIcon: Icons.format_size_outlined,
      validator: _integerValidator(
        fieldName: 'Password minimum length',
        allowZero: false,
      ),
    );
  }

  Widget _buildPasswordExpiryField() {
    return _IntegerTextField(
      controller: _passwordExpiryDaysController,
      labelText: 'Password Expiry Days',
      hintText: 'Example: 90',
      prefixIcon: Icons.calendar_month_outlined,
      enabled: _passwordExpiryEnabled,
      validator: _integerValidator(
        fieldName: 'Password expiry days',
        allowZero: false,
      ),
    );
  }

  Widget _buildIpAccessSection() {
    return _SectionCard(
      title: 'IP and Admin Restrictions',
      icon: Icons.public_off_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable IP Whitelist',
            subtitle: 'Allow admin access only from configured IP addresses',
            icon: Icons.public_off_outlined,
            color: AppColors.warning,
            value: _ipWhitelistEnabled,
            onChanged: (value) {
              setState(() {
                _ipWhitelistEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _TextFieldWrapper(
            controller: _allowedIpAddressesController,
            labelText: 'Allowed IP Addresses',
            hintText: 'Example: 103.10.10.1, 103.10.10.2',
            prefixIcon: Icons.list_alt_outlined,
            enabled: _ipWhitelistEnabled,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Admin Session Restriction',
            subtitle: 'Restrict simultaneous admin sessions',
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.primary,
            value: _adminSessionRestrictionEnabled,
            onChanged: (value) {
              setState(() {
                _adminSessionRestrictionEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _TextFieldWrapper(
            controller: _adminEmailAlertController,
            labelText: 'Admin Security Alert Email',
            hintText: 'security@eventease.com',
            prefixIcon: Icons.alternate_email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final String email = value?.trim() ?? '';

              if (email.isEmpty) return null;

              final bool valid = RegExp(
                r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
              ).hasMatch(email);

              if (!valid) {
                return 'Enter valid email address';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditAndDataSection() {
    return _SectionCard(
      title: 'Audit and Data Protection',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable Audit Logs',
            subtitle: 'Track admin activities, setting changes and sensitive actions',
            icon: Icons.receipt_long_outlined,
            color: AppColors.primary,
            value: _auditLogsEnabled,
            onChanged: (value) {
              setState(() {
                _auditLogsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Restrict Data Export',
            subtitle: 'Limit sensitive data exports to authorized admins only',
            icon: Icons.file_download_off_outlined,
            color: AppColors.error,
            value: _dataExportRestrictionEnabled,
            onChanged: (value) {
              setState(() {
                _dataExportRestrictionEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Maintenance Lock',
            subtitle: 'Restrict admin actions during maintenance mode',
            icon: Icons.construction_outlined,
            color: Colors.deepOrange,
            value: _maintenanceLockEnabled,
            onChanged: (value) {
              setState(() {
                _maintenanceLockEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 760;

        final List<Widget> actions = [
          CustomButton(
            text: 'Reset',
            type: ButtonType.outline,
            icon: Icons.refresh,
            onPressed: _isSaving ? null : _resetSettings,
          ),
          CustomButton(
            text: 'Preview',
            type: ButtonType.outline,
            icon: Icons.visibility_outlined,
            onPressed: _isSaving ? null : _previewSettings,
          ),
          CustomButton(
            text: 'Run Check',
            type: ButtonType.outline,
            icon: Icons.verified_user_outlined,
            onPressed: _isSaving ? null : _runSecurityCheck,
          ),
          CustomButton(
            text: 'Save Settings',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveSecuritySettings,
          ),
        ];

        if (isCompact) {
          return Column(
            children: actions
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: action,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            Expanded(child: actions[0]),
            const SizedBox(width: 12),
            Expanded(child: actions[1]),
            const SizedBox(width: 12),
            Expanded(child: actions[2]),
            const SizedBox(width: 12),
            Expanded(child: actions[3]),
          ],
        );
      },
    );
  }

  String? Function(String?) _integerValidator({
    required String fieldName,
    bool allowZero = false,
  }) {
    return (value) {
      final String raw = value?.trim() ?? '';

      if (raw.isEmpty) {
        return '$fieldName is required';
      }

      final int? number = int.tryParse(raw);

      if (number == null) {
        return 'Enter valid number';
      }

      if (!allowZero && number <= 0) {
        return '$fieldName must be greater than zero';
      }

      if (allowZero && number < 0) {
        return '$fieldName cannot be negative';
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(
                      AppDimensions.padding24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          if (provider.errorMessage != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          _buildSummaryCards(provider),
                          const SizedBox(height: 20),
                          _buildAccessPolicySection(),
                          const SizedBox(height: 20),
                          _buildLoginProtectionSection(),
                          const SizedBox(height: 20),
                          _buildPasswordPolicySection(),
                          const SizedBox(height: 20),
                          _buildIpAccessSection(),
                          const SizedBox(height: 20),
                          _buildAuditAndDataSection(),
                          const SizedBox(height: 28),
                          _buildActions(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading || provider.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.04),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SecuritySummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SecuritySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;

  const _IntegerTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _TextFieldWrapper(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      enabled: enabled,
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}

class _TextFieldWrapper extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;

  const _TextFieldWrapper({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
  }) : suffixIcon = null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class _SwitchOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: color,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
      secondary: Icon(
        icon,
        color: onChanged == null ? Colors.grey : color,
      ),
      onChanged: onChanged,
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}