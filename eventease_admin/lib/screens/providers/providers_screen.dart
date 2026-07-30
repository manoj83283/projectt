import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
import '../../providers/provider_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/approve_dialog.dart';
import '../../widgets/dialogs/delete_dialog.dart';
import '../../widgets/tables/provider_table.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({
    super.key,
  });

  @override
  State<ProvidersScreen> createState() =>
      _ProvidersScreenState();
}

class _ProvidersScreenState
    extends State<ProvidersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedStatus;
  String? _selectedVerification;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadProviders();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOAD PROVIDERS
  // =====================================================

  Future<void> _loadProviders({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<ProviderProvider>()
        .getProviders(
          page: _page,
          limit: _limit,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          status: _selectedStatus,
          isVerified:
              _selectedVerification == null
                  ? null
                  : _selectedVerification == 'verified',
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadProviders(
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

    await _loadProviders(
      page: 1,
    );
  }

  // =====================================================
  // VERIFICATION FILTER
  // =====================================================

  Future<void> _onVerificationChanged(
    String? value,
  ) async {
    setState(() {
      _selectedVerification = value;
    });

    await _loadProviders(
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
      _selectedVerification = null;
      _page = 1;
    });

    await _loadProviders(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadProviders(
      page: _page,
    );
  }

  // =====================================================
  // VIEW PROVIDER
  // =====================================================

  void _viewProvider(
    ProviderModel provider,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.providerDetails,
      arguments: provider,
    );
  }

  // =====================================================
  // VIEW KYC
  // =====================================================

  void _viewKyc(
    ProviderModel provider,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.providerKyc,
      arguments: provider,
    );
  }

  // =====================================================
  // EDIT PROVIDER
  // =====================================================

  void _editProvider(
    ProviderModel provider,
  ) {
    NavigationService.showInfo(
      'Edit provider screen will be available soon.',
    );
  }

  // =====================================================
  // APPROVE PROVIDER
  // =====================================================

  Future<void> _approveProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await ApproveProviderDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ProviderProvider>()
            .approveProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider approved successfully',
      );
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // REJECT PROVIDER
  // =====================================================

  Future<void> _rejectProvider(
    ProviderModel provider,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject Provider',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter rejection reason for ${provider.displayName}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Rejection reason',
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason =
        reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Rejection reason is required',
      );
      return;
    }

    final success =
        await context
            .read<ProviderProvider>()
            .rejectProvider(
              providerId: provider.id,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider rejected successfully',
      );
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // BLOCK PROVIDER
  // =====================================================

  Future<void> _blockProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Block Provider',
          ),
          content: Text(
            'Are you sure you want to block ${provider.displayName}?',
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
            .read<ProviderProvider>()
            .blockProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider blocked successfully',
      );
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // UNBLOCK PROVIDER
  // =====================================================

  Future<void> _unblockProvider(
    ProviderModel provider,
  ) async {
    final success =
        await context
            .read<ProviderProvider>()
            .unblockProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider unblocked successfully',
      );
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // DELETE PROVIDER
  // =====================================================

  Future<void> _deleteProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await DeleteProviderDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ProviderProvider>()
            .deleteProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider deleted successfully',
      );
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showProviderError() {
    final error =
        context
            .read<ProviderProvider>()
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

    await _loadProviders(
      page: _page - 1,
    );
  }

  Future<void> _goToNextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadProviders(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadProviders(
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
          AppStrings.providers,
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
        child: Consumer<ProviderProvider>(
          builder: (
            context,
            providerProvider,
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
                      providerProvider,
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

                    if (providerProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: providerProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    ProviderTable(
                      providers:
                          providerProvider.providers,
                      isLoading:
                          providerProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewProvider,
                      onEdit: _editProvider,
                      onApprove: _approveProvider,
                      onReject: _rejectProvider,
                      onBlock: _blockProvider,
                      onUnblock:
                          _unblockProvider,
                      onDelete: _deleteProvider,
                      onViewKyc: _viewKyc,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          providerProvider.currentPage,
                      totalPages:
                          providerProvider.totalPages,
                      totalRecords:
                          providerProvider
                              .totalProviders,
                      pageSize: _limit,
                      onPrevious:
                          _goToPreviousPage,
                      onNext: () {
                        _goToNextPage(
                          providerProvider
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
    ProviderProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isMobile =
            constraints.maxWidth < 800;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.providers,
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
                'Manage provider onboarding, KYC verification, approvals, blocking, and service partner performance.',
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
            _ProviderSummaryCard(
              title: 'Total Providers',
              value: provider.totalProviders
                  .toString(),
              icon:
                  Icons.business_center_outlined,
              color: AppColors.primary,
            ),
            _ProviderSummaryCard(
              title: 'Pending',
              value: provider.pendingProviders
                  .toString(),
              icon:
                  Icons.pending_actions_outlined,
              color: AppColors.warning,
            ),
            _ProviderSummaryCard(
              title: 'Verified',
              value: provider.verifiedProviders
                  .toString(),
              icon:
                  Icons.verified_user_outlined,
              color: AppColors.success,
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
                constraints.maxWidth < 850;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search providers by name, business, email or phone...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'pending',
                'approved',
                'rejected',
                'suspended',
                'blocked',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged:
                  _onStatusChanged,
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
              ),
            );

            final verificationDropdown =
                CustomDropdown<String>(
              labelText: 'KYC',
              hintText: 'All KYC',
              value: _selectedVerification,
              items: const [
                'verified',
                'unverified',
              ],
              itemLabelBuilder: (item) {
                switch (item) {
                  case 'verified':
                    return 'Verified';
                  case 'unverified':
                    return 'Unverified';
                  default:
                    return item;
                }
              },
              onChanged:
                  _onVerificationChanged,
              prefixIcon: const Icon(
                Icons.verified_user_outlined,
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

                  verificationDropdown,

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
                  width: 220,
                  child:
                      verificationDropdown,
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

class _ProviderSummaryCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProviderSummaryCard({
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