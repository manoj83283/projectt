import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/app_validator.dart';
import '../../core/utils/formatters.dart';
import '../../providers/admin_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({
    super.key,
  });

  @override
  State<AddAdminScreen> createState() =>
      _AddAdminScreenState();
}

class _AddAdminScreenState
    extends State<AddAdminScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedRole;

  bool _isActive = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Set<String> _selectedPermissions = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // =====================================================
  // CREATE ADMIN
  // =====================================================

  Future<void> _createAdmin() async {
    FocusScope.of(context).unfocus();

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
            .createAdmin(
              fullName:
                  _nameController.text.trim(),
              email:
                  _emailController.text.trim(),
              phone:
                  _phoneController.text.trim(),
              password:
                  _passwordController.text.trim(),
              role: _selectedRole!,
              permissions:
                  _selectedPermissions.toList(),
              isActive: _isActive,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin created successfully',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Admin',
        ),
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
                              _buildSecurityCard(),
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
                                      _buildSecurityCard(),
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
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color:
                AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.radius16,
            ),
          ),
          child: const Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.primary,
            size: 30,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Admin',
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
                'Add a new admin user and assign role-based permissions.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
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

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          SwitchListTile(
            value: _isActive,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Account Active',
            ),
            subtitle: Text(
              _isActive
                  ? 'Admin can login after creation'
                  : 'Admin account will be inactive',
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
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY CARD
  // =====================================================

  Widget _buildSecurityCard() {
    return _SectionCard(
      title: 'Security',
      icon: Icons.lock_outline,
      child: Column(
        children: [
          CustomTextField(
            controller: _passwordController,
            labelText: AppStrings.password,
            hintText: 'Enter password',
            obscureText: _obscurePassword,
            prefixIcon: const Icon(
              Icons.lock_outline,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword =
                      !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            validator: AppValidator.password,
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller:
                _confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            hintText: 'Confirm password',
            obscureText:
                _obscureConfirmPassword,
            prefixIcon: const Icon(
              Icons.lock_outline,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            validator: (value) {
              return AppValidator.confirmPassword(
                password:
                    _passwordController.text,
                confirmPassword: value,
              );
            },
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
              color: AppColors.info.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
              border: Border.all(
                color: AppColors.info
                    .withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security_outlined,
                  color: AppColors.info,
                  size: 20,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Use a strong password. Admin accounts have sensitive platform access.',
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
                      .withValues(alpha: 0.16),
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
          width: 160,
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
          width: 180,
          child: CustomButton(
            text: 'Create Admin',
            icon: Icons.add_rounded,
            isLoading: provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : _createAdmin,
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