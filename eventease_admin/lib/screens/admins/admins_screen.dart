import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/admin_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({
    super.key,
  });

  @override
  State<AdminsScreen> createState() =>
      _AdminsScreenState();
}

class _AdminsScreenState
    extends State<AdminsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedRole;
  String? _selectedStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadAdmins();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD ADMINS
  // =====================================================

  Future<void> _loadAdmins({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<AdminProvider>()
        .getAdmins(
          page: _page,
          limit: _limit,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          role: _selectedRole,
          isActive: _statusToBool(
            _selectedStatus,
          ),
        );
  }

  // =====================================================
  // STATUS CONVERTER
  // =====================================================

  bool? _statusToBool(
    String? status,
  ) {
    if (status == null) return null;

    if (status == 'active') {
      return true;
    }

    if (status == 'inactive') {
      return false;
    }

    return null;
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadAdmins(
      page: 1,
    );
  }

  // =====================================================
  // ROLE FILTER
  // =====================================================

  Future<void> _onRoleChanged(
    String? value,
  ) async {
    setState(() {
      _selectedRole = value;
    });

    await _loadAdmins(
      page: 1,
    );
  }

  // =====================================================
  // STATUS FILTER
  // =====================================================

  Future<void> _onStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedStatus = value;
    });

    await _loadAdmins(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedRole = null;
      _selectedStatus = null;
      _page = 1;
    });

    await _loadAdmins(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadAdmins(
      page: _page,
    );
  }

  // =====================================================
  // ADD ADMIN
  // =====================================================

  void _addAdmin() {
    Navigator.pushNamed(
      context,
      AppRoutes.addAdmin,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // VIEW ADMIN
  // =====================================================

  void _viewAdmin(
    AdminModel admin,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.adminDetails,
      arguments: admin,
    );
  }

  // =====================================================
  // EDIT ADMIN
  // =====================================================

  void _editAdmin(
    AdminModel admin,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.editAdmin,
      arguments: admin,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // ACTIVATE ADMIN
  // =====================================================

  Future<void> _activateAdmin(
    AdminModel admin,
  ) async {
    final success =
        await context
            .read<AdminProvider>()
            .activateAdmin(
              admin.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin activated successfully',
      );

      await _refresh();
    } else {
      _showAdminError();
    }
  }

  // =====================================================
  // DEACTIVATE ADMIN
  // =====================================================

  Future<void> _deactivateAdmin(
    AdminModel admin,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Deactivate Admin',
          ),
          content: Text(
            'Are you sure you want to deactivate ${admin.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.warning,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<AdminProvider>()
            .deactivateAdmin(
              admin.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin deactivated successfully',
      );

      await _refresh();
    } else {
      _showAdminError();
    }
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<void> _resetPassword(
    AdminModel admin,
  ) async {
    final passwordController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reset Admin Password',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Enter new password for ${admin.fullName}.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText: 'New Password',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Reset',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    final newPassword =
        passwordController.text.trim();

    passwordController.dispose();

    if (newPassword.length < 8) {
      NavigationService.showWarning(
        'Password must be at least 8 characters',
      );
      return;
    }

    final success =
        await context
            .read<AdminProvider>()
            .resetAdminPassword(
              adminId: admin.id,
              newPassword: newPassword,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin password reset successfully',
      );
    } else {
      _showAdminError();
    }
  }

  // =====================================================
  // DELETE ADMIN
  // =====================================================

  Future<void> _deleteAdmin(
    AdminModel admin,
  ) async {
    final confirmed =
        await DeleteAdminDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<AdminProvider>()
            .deleteAdmin(
              admin.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Admin deleted successfully',
      );

      await _refresh();
    } else {
      _showAdminError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showAdminError() {
    final error =
        context
            .read<AdminProvider>()
            .errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _goToPreviousPage() async {
    if (_page <= 1) return;

    await _loadAdmins(
      page: _page - 1,
    );
  }

  Future<void> _goToNextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadAdmins(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadAdmins(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admins',
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (
            context,
            adminProvider,
            child,
          ) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.padding24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      adminProvider,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height:
                          AppDimensions.padding20,
                    ),

                    if (adminProvider
                            .errorMessage !=
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
                          onRetry: _refresh,
                        ),
                      ),

                    AdminsTable(
                      admins:
                          adminProvider.admins,
                      isLoading:
                          adminProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewAdmin,
                      onEdit: _editAdmin,
                      onActivate:
                          _activateAdmin,
                      onDeactivate:
                          _deactivateAdmin,
                      onResetPassword:
                          _resetPassword,
                      onDelete: _deleteAdmin,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          adminProvider.currentPage,
                      totalPages:
                          adminProvider.totalPages,
                      totalRecords:
                          adminProvider.totalAdmins,
                      pageSize: _limit,
                      onPrevious:
                          _goToPreviousPage,
                      onNext: () {
                        _goToNextPage(
                          adminProvider.totalPages,
                        );
                      },
                      onPageSelected:
                          _goToPage,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addAdmin,
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Admin',
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    AdminProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 900;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Admins',
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
                'Manage admin users, roles, permissions, account access, activation status, and password resets.',
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
        );

        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AdminSummaryCard(
              title: 'Total Admins',
              value:
                  provider.totalAdmins.toString(),
              icon:
                  Icons.admin_panel_settings_outlined,
              color: AppColors.primary,
            ),
            _AdminSummaryCard(
              title: 'Active',
              value:
                  provider.activeAdmins.toString(),
              icon:
                  Icons.verified_user_outlined,
              color: AppColors.success,
            ),
            _AdminSummaryCard(
              title: 'Inactive',
              value:
                  provider.inactiveAdmins.toString(),
              icon:
                  Icons.block_outlined,
              color: AppColors.warning,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  titleSection,
                ],
              ),

              const SizedBox(height: 16),

              summaryCards,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            titleSection,

            const SizedBox(width: 16),

            summaryCards,
          ],
        );
      },
    );
  }

  // =====================================================
  // FILTERS
  // =====================================================

  Widget _buildFilters() {
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
          AppDimensions.padding16,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 900;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search admins by name, email, phone or role...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final roleDropdown =
                CustomDropdown<String>(
              labelText: 'Role',
              hintText: 'All Roles',
              value: _selectedRole,
              items: RoleConstants.allRoles,
              itemLabelBuilder:
                  RoleConstants.getRoleLabel,
              onChanged: _onRoleChanged,
              prefixIcon: const Icon(
                Icons.manage_accounts_outlined,
              ),
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'active',
                'inactive',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged:
                  _onStatusChanged,
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
              ),
            );

            final clearButton =
                CustomButton(
              text: 'Clear',
              type: ButtonType.outline,
              icon: Icons.clear_rounded,
              onPressed: _clearFilters,
            );

            if (isMobile) {
              return Column(
                children: [
                  search,

                  const SizedBox(height: 12),

                  roleDropdown,

                  const SizedBox(height: 12),

                  statusDropdown,

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: clearButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: search,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 230,
                  child: roleDropdown,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 210,
                  child: statusDropdown,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 130,
                  child: clearButton,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// ADMINS TABLE
// =====================================================

class AdminsTable extends StatelessWidget {
  final List<AdminModel> admins;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(AdminModel admin)? onView;
  final Function(AdminModel admin)? onEdit;
  final Function(AdminModel admin)? onActivate;
  final Function(AdminModel admin)? onDeactivate;
  final Function(AdminModel admin)? onResetPassword;
  final Function(AdminModel admin)? onDelete;

  const AdminsTable({
    super.key,
    required this.admins,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onResetPassword,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading admins...',
      );
    }

    if (admins.isEmpty) {
      return EmptyWidget(
        icon: Icons.admin_panel_settings_outlined,
        title: 'No Admins Found',
        description:
            'Admin records will appear here once created.',
        buttonText: AppStrings.refresh,
        onButtonPressed: onRefresh,
      );
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight:
                AppDimensions.headingRowHeight,
            dataRowMinHeight:
                AppDimensions.dataRowHeight,
            dataRowMaxHeight:
                AppDimensions.dataRowHeight,
            headingRowColor:
                WidgetStateProperty.all(
              AppColors.background,
            ),
            columnSpacing: 28,
            horizontalMargin: 20,
            columns: const [
              DataColumn(
                label: _TableHeader(
                  title: 'Admin',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Contact',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Role',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Permissions',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Last Login',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Created',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: admins.map(
              (admin) {
                return DataRow(
                  cells: [
                    DataCell(
                      _AdminInfoCell(
                        admin: admin,
                      ),
                    ),
                    DataCell(
                      _ContactCell(
                        admin: admin,
                      ),
                    ),
                    DataCell(
                      _RoleBadge(
                        role: admin.role,
                      ),
                    ),
                    DataCell(
                      Text(
                        '${admin.permissions.length}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      _StatusBadge(
                        admin: admin,
                      ),
                    ),
                    DataCell(
                      Text(
                        admin.lastLoginAt != null
                            ? AppFormatters
                                .formatDateTime(
                                admin.lastLoginAt,
                              )
                            : '-',
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          admin.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _AdminActions(
                        admin: admin,
                        onView: onView,
                        onEdit: onEdit,
                        onActivate:
                            onActivate,
                        onDeactivate:
                            onDeactivate,
                        onResetPassword:
                            onResetPassword,
                        onDelete: onDelete,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TABLE HEADER
// =====================================================

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// =====================================================
// ADMIN INFO CELL
// =====================================================

class _AdminInfoCell extends StatelessWidget {
  final AdminModel admin;

  const _AdminInfoCell({
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        admin.profileImage != null &&
            admin.profileImage!.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              AppColors.primary.withOpacity(0.10),
          backgroundImage: hasImage
              ? NetworkImage(
                  admin.profileImage!,
                )
              : null,
          child: hasImage
              ? null
              : Text(
                  AppFormatters.getInitials(
                    admin.fullName,
                  ),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),

        const SizedBox(width: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 180,
            maxWidth: 240,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                admin.fullName.isNotEmpty
                    ? admin.fullName
                    : '-',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                admin.id,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
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
}

// =====================================================
// CONTACT CELL
// =====================================================

class _ContactCell extends StatelessWidget {
  final AdminModel admin;

  const _ContactCell({
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 190,
        maxWidth: 260,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            admin.email.isNotEmpty
                ? admin.email
                : '-',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            admin.phone.isNotEmpty
                ? AppFormatters.formatPhone(
                    admin.phone,
                  )
                : '-',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ROLE BADGE
// =====================================================

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrivileged =
        RoleConstants.isPrivilegedRole(
      role,
    );

    final color = isPrivileged
        ? AppColors.secondary
        : AppColors.primary;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Text(
        RoleConstants.getRoleLabel(
          role,
        ),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================================================
// STATUS BADGE
// =====================================================

class _StatusBadge extends StatelessWidget {
  final AdminModel admin;

  const _StatusBadge({
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    if (admin.isActive) {
      return const _StatusChip(
        label: 'Active',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'Inactive',
      color: AppColors.warning,
    );
  }
}

// =====================================================
// STATUS CHIP
// =====================================================

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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================================================
// ADMIN ACTIONS
// =====================================================

class _AdminActions extends StatelessWidget {
  final AdminModel admin;

  final Function(AdminModel admin)? onView;
  final Function(AdminModel admin)? onEdit;
  final Function(AdminModel admin)? onActivate;
  final Function(AdminModel admin)? onDeactivate;
  final Function(AdminModel admin)? onResetPassword;
  final Function(AdminModel admin)? onDelete;

  const _AdminActions({
    required this.admin,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onResetPassword,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(
        Icons.more_vert,
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call(admin);
            break;

          case 'edit':
            onEdit?.call(admin);
            break;

          case 'activate':
            onActivate?.call(admin);
            break;

          case 'deactivate':
            onDeactivate?.call(admin);
            break;

          case 'reset_password':
            onResetPassword?.call(admin);
            break;

          case 'delete':
            onDelete?.call(admin);
            break;
        }
      },
      itemBuilder: (context) {
        final items =
            <PopupMenuEntry<String>>[];

        if (onView != null) {
          items.add(
            const PopupMenuItem(
              value: 'view',
              child: _MenuItem(
                icon:
                    Icons.visibility_outlined,
                label: 'View',
              ),
            ),
          );
        }

        if (onEdit != null) {
          items.add(
            const PopupMenuItem(
              value: 'edit',
              child: _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
            ),
          );
        }

        if (!admin.isActive &&
            onActivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'activate',
              child: _MenuItem(
                icon:
                    Icons.check_circle_outline,
                label: 'Activate',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (admin.isActive &&
            onDeactivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'deactivate',
              child: _MenuItem(
                icon: Icons.block_outlined,
                label: 'Deactivate',
                color: AppColors.warning,
              ),
            ),
          );
        }

        if (onResetPassword != null) {
          items.add(
            const PopupMenuItem(
              value: 'reset_password',
              child: _MenuItem(
                icon: Icons.lock_reset_outlined,
                label: 'Reset Password',
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (onDelete != null) {
          items.add(
            const PopupMenuDivider(),
          );

          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: _MenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? AppColors.textPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: itemColor,
        ),

        const SizedBox(width: 10),

        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

class _AdminSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 170,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}