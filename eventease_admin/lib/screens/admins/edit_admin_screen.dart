import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/app_validator.dart';
import '../../core/utils/formatters.dart';
import '../../models/admin_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class EditAdminScreen extends StatefulWidget {
  const EditAdminScreen({
    super.key,
  });

  @override
  State<EditAdminScreen> createState() =>
      _EditAdminScreenState();
}

class _EditAdminScreenState
    extends State<EditAdminScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  AdminModel? _admin;

  String? _selectedRole;

  bool _isActive = true;

  final Set<String> _selectedPermissions = {};

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is AdminModel) {
      _admin = args;
      _bindAdminData(args);
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // =====================================================
  // BIND DATA
  // =====================================================

  void _bindAdminData(
    AdminModel admin,
  ) {
    _nameController.text = admin.fullName;
    _emailController.text = admin.email;
    _phoneController.text = admin.phone;

    _selectedRole = admin.role;
    _isActive = admin.isActive;

    _selectedPermissions
      ..clear()
      ..addAll(admin.permissions);
  }

  // =====================================================
  // UPDATE ADMIN
  // =====================================================

  Future<void> _updateAdmin() async {
    FocusScope.of(context).unfocus();

    if (_admin == null) {
      NavigationService.showError(
        'Admin data not found',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null ||
        _selectedRole!.isEmpty) {
      NavigationService.showWarning(
        'Please select admin role',
      );
      return;
    }

    if (_selectedPermissions.isEmpty) {
      NavigationService.showWarning(
        'Please select at least one permission',
      );
      return;
    }

    final success =
        await context
            .read<AdminProvider>()
            .updateAdmin(
              adminId: _admin!.id,
              fullName:
                  _nameController.text.trim(),
              email:
                  _emailController.text.trim(),
              phone:
                  _phoneController.text.trim(),
              role: _selectedRole!,
              permissions:
                  _selectedPermissions.toList(),
              isActive: _isActive,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin updated successfully',
      );

      Navigator.pop(context, true);
    } else {
      final error =
          context
              .read<AdminProvider>()
              .errorMessage;

      NavigationService.showError(
        error ?? AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // ROLE CHANGE
  // =====================================================

  void _onRoleChanged(
    String? role,
  ) {
    setState(() {
      _selectedRole = role;
      _selectedPermissions.clear();

      if (role == RoleConstants.superAdmin) {
        _selectedPermissions.addAll(
          _allPermissions,
        );
      } else if (role == RoleConstants.admin) {
        _selectedPermissions.addAll([
          'dashboard.view',
          'customer.view',
          'provider.view',
          'provider.approve',
          'booking.view',
          'order.view',
          'payment.view',
          'report.view',
          'analytics.view',
        ]);
      } else if (role ==
          RoleConstants.supportManager) {
        _selectedPermissions.addAll([
          'dashboard.view',
          'customer.view',
          'provider.view',
          'support.view',
          'support.reply',
        ]);
      } else if (role ==
          RoleConstants.financeManager) {
        _selectedPermissions.addAll([
          'dashboard.view',
          'payment.view',
          'settlement.view',
          'settlement.manage',
          'report.view',
        ]);
      } else if (role ==
          RoleConstants.kycManager) {
        _selectedPermissions.addAll([
          'dashboard.view',
          'provider.view',
          'kyc.view',
          'kyc.approve',
          'kyc.reject',
        ]);
      } else {
        _selectedPermissions.add(
          'dashboard.view',
        );
      }
    });
  }

  // =====================================================
  // TOGGLE PERMISSION
  // =====================================================

  void _togglePermission(
    String permission,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedPermissions.add(
          permission,
        );
      } else {
        _selectedPermissions.remove(
          permission,
        );
      }
    });
  }

  // =====================================================
  // SELECT ALL
  // =====================================================

  void _selectAllPermissions() {
    setState(() {
      _selectedPermissions
        ..clear()
        ..addAll(_allPermissions);
    });
  }

  // =====================================================
  // CLEAR ALL
  // =====================================================

  void _clearAllPermissions() {
    setState(() {
      _selectedPermissions.clear();
    });
  }

  // =====================================================
  // RESET TO ORIGINAL
  // =====================================================

  void _resetToOriginal() {
    if (_admin == null) return;

    setState(() {
      _bindAdminData(_admin!);
    });

    NavigationService.showInfo(
      'Admin form reset to original values',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_admin == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Admin',
          ),
        ),
        body: const Center(
          child: Text(
            'Admin data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Admin',
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetToOriginal,
            icon: const Icon(
              Icons.restart_alt_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (
            context,
            adminProvider,
            child,
          ) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(
                    height: AppDimensions.padding24,
                  ),

                  if (adminProvider.errorMessage !=
                      null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom:
                            AppDimensions.padding16,
                      ),
                      child: ErrorCard(
                        message: adminProvider
                            .errorMessage!,
                      ),
                    ),

                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final bool isMobile =
                            constraints.maxWidth <
                                900;

                        if (isMobile) {
                          return Column(
                            children: [
                              _buildBasicInfoCard(),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildAccountStatusCard(),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildRolePermissionCard(),
                              const SizedBox(
                                height: 24,
                              ),
                              _buildActions(
                                adminProvider,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _buildBasicInfoCard(),
                                ),

                                const SizedBox(
                                  width: 16,
                                ),

                                Expanded(
                                  child:
                                      _buildAccountStatusCard(),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            _buildRolePermissionCard(),

                            const SizedBox(
                              height: 24,
                            ),

                            _buildActions(
                              adminProvider,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor:
              AppColors.primary.withOpacity(
            0.10,
          ),
          backgroundImage: _admin!
                          .profileImage !=
                      null &&
                  _admin!.profileImage!
                      .isNotEmpty
              ? NetworkImage(
                  _admin!.profileImage!,
                )
              : null,
          child: _admin!.profileImage ==
                      null ||
                  _admin!
                      .profileImage!
                      .isEmpty
              ? Text(
                  AppFormatters.getInitials(
                    _admin!.fullName,
                  ),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Admin',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Update admin profile, role, permissions, and account status.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Admin ID: ${_admin!.id}',
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BASIC INFO CARD
  // =====================================================

  Widget _buildBasicInfoCard() {
    return _SectionCard(
      title: 'Basic Information',
      icon: Icons.person_outline,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
            hintText: 'Enter full name',
            prefixIcon: const Icon(
              Icons.person_outline,
            ),
            validator: AppValidator.name,
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.email,
            hintText: 'Enter admin email',
            keyboardType:
                TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
            ),
            validator: AppValidator.email,
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _phoneController,
            labelText: AppStrings.phone,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            inputFormatters:
                AppFormatters.phoneInputFormatter(),
            prefixIcon: const Icon(
              Icons.phone_outlined,
            ),
            validator: AppValidator.phone,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACCOUNT STATUS CARD
  // =====================================================

  Widget _buildAccountStatusCard() {
    return _SectionCard(
      title: 'Account Status',
      icon: Icons.security_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: _isActive,
            contentPadding: EdgeInsets.zero,
            title: Text(
              _isActive
                  ? 'Active Account'
                  : 'Inactive Account',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              _isActive
                  ? 'Admin can login and access assigned modules.'
                  : 'Admin cannot login until account is activated.',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          _InfoRow(
            label: 'Current Role',
            value: RoleConstants.getRoleLabel(
              _admin!.role,
            ),
          ),

          _InfoRow(
            label: 'Created At',
            value: AppFormatters.formatDate(
              _admin!.createdAt,
            ),
          ),

          _InfoRow(
            label: 'Last Login',
            value: _admin!.lastLoginAt != null
                ? AppFormatters.formatDateTime(
                    _admin!.lastLoginAt,
                  )
                : '-',
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppDimensions.padding12,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning
                  .withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
              border: Border.all(
                color: AppColors.warning
                    .withOpacity(0.18),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Changing role or permissions will affect what this admin can access immediately after update.',
                    style: TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ROLE & PERMISSION CARD
  // =====================================================

  Widget _buildRolePermissionCard() {
    return _SectionCard(
      title: 'Role & Permissions',
      icon: Icons.manage_accounts_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CustomDropdown<String>(
            labelText: 'Admin Role',
            hintText: 'Select role',
            value: _selectedRole,
            items: RoleConstants.allRoles,
            itemLabelBuilder:
                RoleConstants.getRoleLabel,
            prefixIcon: const Icon(
              Icons.admin_panel_settings_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Role is required';
              }

              return null;
            },
            onChanged: _onRoleChanged,
          ),

          const SizedBox(
            height: AppDimensions.padding20,
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Permissions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ),

              TextButton(
                onPressed: _selectAllPermissions,
                child: const Text(
                  'Select All',
                ),
              ),

              TextButton(
                onPressed: _clearAllPermissions,
                child: const Text(
                  'Clear',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppDimensions.padding12,
          ),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _allPermissions.map(
              (permission) {
                final selected =
                    _selectedPermissions.contains(
                  permission,
                );

                return FilterChip(
                  label: Text(
                    _formatPermission(
                      permission,
                    ),
                  ),
                  selected: selected,
                  selectedColor: AppColors.primary
                      .withOpacity(0.16),
                  checkmarkColor:
                      AppColors.primary,
                  onSelected: (value) {
                    _togglePermission(
                      permission,
                      value,
                    );
                  },
                );
              },
            ).toList(),
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          Text(
            '${_selectedPermissions.length} permission(s) selected',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACTIONS
  // =====================================================

  Widget _buildActions(
    AdminProvider provider,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 150,
          child: CustomButton(
            text: AppStrings.cancel,
            type: ButtonType.outline,
            isEnabled: !provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
        ),

        const SizedBox(width: 16),

        SizedBox(
          width: 150,
          child: CustomButton(
            text: 'Reset',
            type: ButtonType.outline,
            icon: Icons.restart_alt_rounded,
            isEnabled: !provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : _resetToOriginal,
          ),
        ),

        const SizedBox(width: 16),

        SizedBox(
          width: 180,
          child: CustomButton(
            text: 'Update Admin',
            icon: Icons.save_outlined,
            isLoading: provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : _updateAdmin,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PERMISSIONS
  // =====================================================

  static const List<String> _allPermissions = [
    'dashboard.view',
    'analytics.view',
    'report.view',
    'report.export',

    'customer.view',
    'customer.create',
    'customer.edit',
    'customer.delete',

    'provider.view',
    'provider.approve',
    'provider.reject',
    'provider.block',

    'kyc.view',
    'kyc.approve',
    'kyc.reject',

    'category.view',
    'category.create',
    'category.edit',
    'category.delete',

    'service.view',
    'service.approve',
    'service.delete',

    'booking.view',
    'booking.manage',

    'order.view',
    'order.manage',

    'payment.view',
    'refund.manage',

    'settlement.view',
    'settlement.manage',

    'coupon.view',
    'coupon.create',
    'coupon.edit',
    'coupon.delete',

    'banner.view',
    'banner.create',
    'banner.edit',
    'banner.delete',

    'review.view',
    'review.moderate',
    'review.delete',

    'notification.view',
    'notification.send',

    'support.view',
    'support.reply',
    'support.close',

    'admin.view',
    'admin.manage',

    'role.view',
    'role.manage',

    'settings.manage',

    'activity_log.view',
    'audit_log.view',
  ];

  String _formatPermission(
    String permission,
  ) {
    return permission
        .replaceAll('_', ' ')
        .replaceAll('.', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() +
                  word.substring(1),
        )
        .join(' ');
  }
}

// =====================================================
// SECTION CARD
// =====================================================

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.padding20,
            ),

            child,
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}