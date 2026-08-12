import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';
import '../../widgets/tables/customer_table.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({
    super.key,
  });

  @override
  State<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState
    extends State<CustomersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadCustomers();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOAD CUSTOMERS
  // =====================================================

  Future<void> _loadCustomers({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<CustomerProvider>()
        .getCustomers(
          page: _page,
          limit: _limit,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    _page = 1;

    await _loadCustomers(
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

    await _loadCustomers(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _page = 1;
    });

    await _loadCustomers(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadCustomers(
      page: _page,
    );
  }

  // =====================================================
  // VIEW CUSTOMER
  // =====================================================

  void _viewCustomer(
    CustomerModel customer,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.customerDetails,
      arguments: customer,
    );
  }

  // =====================================================
  // EDIT CUSTOMER
  // =====================================================

  void _editCustomer(
    CustomerModel customer,
  ) {
    NavigationService.showInfo(
      'Edit customer screen will be available soon.',
    );
  }

  // =====================================================
  // BLOCK CUSTOMER
  // =====================================================

  Future<void> _blockCustomer(
    CustomerModel customer,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Block Customer',
          ),
          content: Text(
            'Are you sure you want to block ${customer.displayName}?',
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.warning,
              ),
              child: const Text(
                'Block',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<CustomerProvider>()
            .blockCustomer(
              customer.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Customer blocked successfully',
      );
    } else {
      NavigationService.showError(
        context
                .read<CustomerProvider>()
                .errorMessage ??
            AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // UNBLOCK CUSTOMER
  // =====================================================

  Future<void> _unblockCustomer(
    CustomerModel customer,
  ) async {
    final success =
        await context
            .read<CustomerProvider>()
            .unblockCustomer(
              customer.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Customer unblocked successfully',
      );
    } else {
      NavigationService.showError(
        context
                .read<CustomerProvider>()
                .errorMessage ??
            AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // DELETE CUSTOMER
  // =====================================================

  Future<void> _deleteCustomer(
    CustomerModel customer,
  ) async {
    final confirmed =
        await DeleteCustomerDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<CustomerProvider>()
            .deleteCustomer(
              customer.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Customer deleted successfully',
      );
    } else {
      NavigationService.showError(
        context
                .read<CustomerProvider>()
                .errorMessage ??
            AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _goToPreviousPage() async {
    if (_page <= 1) return;

    await _loadCustomers(
      page: _page - 1,
    );
  }

  Future<void> _goToNextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadCustomers(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadCustomers(
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
          AppStrings.customers,
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CustomerProvider>(
          builder: (
            context,
            customerProvider,
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
                      customerProvider,
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

                    if (customerProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: customerProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    CustomerTable(
                      customers:
                          customerProvider.customers,
                      isLoading:
                          customerProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewCustomer,
                      onEdit: _editCustomer,
                      onBlock: _blockCustomer,
                      onUnblock: _unblockCustomer,
                      onDelete: _deleteCustomer,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          customerProvider.currentPage,
                      totalPages:
                          customerProvider.totalPages,
                      totalRecords:
                          customerProvider
                              .totalCustomers,
                      pageSize: _limit,
                      onPrevious:
                          _goToPreviousPage,
                      onNext: () {
                        _goToNextPage(
                          customerProvider
                              .totalPages,
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
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    CustomerProvider provider,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.customers,
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
                'Manage customers, view activity, block suspicious accounts, and monitor customer growth.',
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

        const SizedBox(width: 16),

        _CustomerSummaryCard(
          title: 'Total Customers',
          value: provider.totalCustomers
              .toString(),
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
      ],
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
                constraints.maxWidth < 700;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search customers by name, email or phone...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'active',
                'inactive',
                'blocked',
              ],
              itemLabelBuilder: (item) {
                switch (item) {
                  case 'active':
                    return 'Active';
                  case 'inactive':
                    return 'Inactive';
                  case 'blocked':
                    return 'Blocked';
                  default:
                    return item;
                }
              },
              onChanged: _onStatusChanged,
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
                  width: 220,
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
// SUMMARY CARD
// =====================================================

class _CustomerSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CustomerSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 180,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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