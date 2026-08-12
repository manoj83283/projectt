import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/coupon_model.dart';
import '../../providers/coupon_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/pagination_widget.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({
    super.key,
  });

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedDiscountType;
  String? _selectedCategoryId;

  final List<String> _couponStatuses = const [
    'active',
    'inactive',
    'expired',
    'scheduled',
  ];

  final List<String> _discountTypes = const [
    'percentage',
    'fixed',
    'free_delivery',
    'cashback',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCoupons();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCoupons() async {
    await context.read<CouponProvider>().getCoupons(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          discountType: _selectedDiscountType,
          categoryId: _selectedCategoryId,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchCoupons();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchCoupons();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchCoupons();
  }

  void _onDiscountTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedDiscountType = value;
    });

    _fetchCoupons();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedCategoryId = value;
    });

    _fetchCoupons();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedDiscountType = null;
      _selectedCategoryId = null;
      _searchController.clear();
    });

    _fetchCoupons();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchCoupons();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchCoupons();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchCoupons();
  }

  Future<void> _createCoupon() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.addCoupon,
    );

    if (!mounted) return;

    _fetchCoupons();
  }

  Future<void> _viewCoupon(CouponModel coupon) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.couponDetails,
      arguments: coupon,
    );

    if (!mounted) return;

    _fetchCoupons();
  }

  Future<void> _editCoupon(CouponModel coupon) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.editCoupon,
      arguments: coupon,
    );

    if (!mounted) return;

    _fetchCoupons();
  }

  Future<void> _activateCoupon(CouponModel coupon) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Activate Coupon',
      message: 'Are you sure you want to activate coupon ${coupon.code}?',
      confirmText: 'Activate',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<CouponProvider>().activateCoupon(coupon.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Coupon activated successfully',
      errorMessage: 'Failed to activate coupon',
    );
  }

  Future<void> _deactivateCoupon(CouponModel coupon) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Deactivate Coupon',
      message: 'Are you sure you want to deactivate coupon ${coupon.code}?',
      confirmText: 'Deactivate',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<CouponProvider>().deactivateCoupon(coupon.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Coupon deactivated successfully',
      errorMessage: 'Failed to deactivate coupon',
    );
  }

  Future<void> _deleteCoupon(CouponModel coupon) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Coupon',
      message:
          'This action cannot be undone. Are you sure you want to delete coupon ${coupon.code}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<CouponProvider>().deleteCoupon(coupon.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Coupon deleted successfully',
      errorMessage: 'Failed to delete coupon',
    );
  }

  Future<void> _cloneCoupon(CouponModel coupon) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Clone Coupon',
      message: 'Do you want to create a copy of coupon ${coupon.code}?',
      confirmText: 'Clone',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<CouponProvider>().cloneCoupon(coupon.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Coupon cloned successfully',
      errorMessage: 'Failed to clone coupon',
    );
  }

  Future<void> _exportCoupons() async {
    await context.read<CouponProvider>().exportCoupons();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupons export started successfully'),
        backgroundColor: AppColors.success,
      ),
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

  void _handleMutationResult({
    required bool success,
    required String successMessage,
    required String errorMessage,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : errorMessage),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) {
      _fetchCoupons();
    }
  }

  Widget _buildHeader(CouponProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupons',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create, monitor, activate, deactivate, and manage promotional coupons.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _exportCoupons,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
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
                        : 6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile
                    ? 3.6
                    : isTablet
                        ? 2.15
                        : 1.45,
              ),
              children: [
                _CouponSummaryCard(
                  title: 'Total Coupons',
                  value: provider.totalCoupons.toString(),
                  icon: Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                ),
                _CouponSummaryCard(
                  title: 'Active',
                  value: provider.activeCoupons.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _CouponSummaryCard(
                  title: 'Inactive',
                  value: provider.inactiveCoupons.toString(),
                  icon: Icons.pause_circle_outline,
                  color: AppColors.warning,
                ),
                _CouponSummaryCard(
                  title: 'Expired',
                  value: provider.expiredCoupons.toString(),
                  icon: Icons.timer_off_outlined,
                  color: AppColors.error,
                ),
                _CouponSummaryCard(
                  title: 'Redemptions',
                  value: provider.totalRedemptions.toString(),
                  icon: Icons.redeem_outlined,
                  color: AppColors.info,
                ),
                _CouponSummaryCard(
                  title: 'Discount Given',
                  value: AppFormatters.formatCurrency(
                    provider.totalDiscountAmount,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(CouponProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search coupon code, title, category...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 900;

              if (isCompact) {
                return Column(
                  children: [
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildDiscountTypeDropdown(),
                    const SizedBox(height: 14),
                    _buildCategoryDropdown(provider),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildDiscountTypeDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildCategoryDropdown(provider)),
                  const SizedBox(width: 14),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Clear'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _couponStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Discount Type',
      value: _selectedDiscountType,
      items: _discountTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onDiscountTypeChanged,
    );
  }

  Widget _buildCategoryDropdown(CouponProvider provider) {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _selectedCategoryId,
      items: provider.categories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onCategoryChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createCoupon,
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Create Coupon',
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  _buildFilters(provider),
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
                  CouponsTable(
                    coupons: provider.coupons,
                    isLoading: provider.isLoading,
                    onView: _viewCoupon,
                    onEdit: _editCoupon,
                    onDelete: _deleteCoupon,
                    onActivate: _activateCoupon,
                    onDeactivate: _deactivateCoupon,
                    onClone: _cloneCoupon,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalCoupons,
                    pageSize: _limit,
                    onPrevious: _previousPage,
                    onNext: () {
                      _nextPage(
                        provider.totalPages,
                      );
                    },
                    onPageSelected: _goToPage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDate(dateTime);
  }

  static String _formatDiscount(CouponModel coupon) {
    switch (coupon.discountType) {
      case 'percentage':
        return '${coupon.discountValue.toStringAsFixed(0)}% OFF';
      case 'fixed':
        return '${AppFormatters.formatCurrency(coupon.discountValue)} OFF';
      case 'free_delivery':
        return 'Free Delivery';
      case 'cashback':
        return '${AppFormatters.formatCurrency(coupon.discountValue)} Cashback';
      default:
        return AppFormatters.formatStatus(coupon.discountType);
    }
  }
}

class CouponsTable extends StatelessWidget {
  final List<CouponModel> coupons;
  final bool isLoading;
  final ValueChanged<CouponModel> onView;
  final ValueChanged<CouponModel> onEdit;
  final ValueChanged<CouponModel> onDelete;
  final ValueChanged<CouponModel> onActivate;
  final ValueChanged<CouponModel> onDeactivate;
  final ValueChanged<CouponModel> onClone;

  const CouponsTable({
    super.key,
    required this.coupons,
    required this.isLoading,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onActivate,
    required this.onDeactivate,
    required this.onClone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          const _TableHeader(),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(44),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (coupons.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No coupons found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Coupons matching your filters will appear here.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 66,
                dataRowMaxHeight: 80,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Coupon Code')),
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Usage')),
                  DataColumn(label: Text('Valid Till')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created By')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: coupons.map(
                  (coupon) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _CouponCodeCell(
                            coupon: coupon,
                          ),
                        ),
                        DataCell(
                          _CouponTitleCell(
                            coupon: coupon,
                          ),
                        ),
                        DataCell(
                          _DiscountCell(
                            coupon: coupon,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              coupon.categoryName.isEmpty
                                  ? 'All Categories'
                                  : coupon.categoryName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          _UsageCell(
                            coupon: coupon,
                          ),
                        ),
                        DataCell(
                          Text(
                            _CouponsScreenState._formatDate(
                              coupon.endDate,
                            ),
                          ),
                        ),
                        DataCell(
                          _CouponStatusBadge(
                            status: coupon.status,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 145,
                            child: Text(
                              coupon.createdBy.isEmpty
                                  ? 'Admin'
                                  : coupon.createdBy,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          _CouponActions(
                            coupon: coupon,
                            onView: onView,
                            onEdit: onEdit,
                            onDelete: onDelete,
                            onActivate: onActivate,
                            onDeactivate: onDeactivate,
                            onClone: onClone,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CouponCodeCell extends StatelessWidget {
  final CouponModel coupon;

  const _CouponCodeCell({
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              coupon.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponTitleCell extends StatelessWidget {
  final CouponModel coupon;

  const _CouponTitleCell({
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coupon.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coupon.description.isEmpty
                ? 'No description available'
                : coupon.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountCell extends StatelessWidget {
  final CouponModel coupon;

  const _DiscountCell({
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _CouponsScreenState._formatDiscount(coupon),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Min: ${AppFormatters.formatCurrency(coupon.minimumOrderAmount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageCell extends StatelessWidget {
  final CouponModel coupon;

  const _UsageCell({
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final int usageLimit = coupon.usageLimit;
    final int usedCount = coupon.usedCount;

    final double progress = usageLimit <= 0
        ? 0
        : (usedCount / usageLimit).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: 145,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            usageLimit <= 0 ? '$usedCount / Unlimited' : '$usedCount / $usageLimit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usageLimit <= 0 ? null : progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.9 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponStatusBadge extends StatelessWidget {
  final String status;

  const _CouponStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'active':
        color = AppColors.success;
        break;
      case 'inactive':
        color = AppColors.warning;
        break;
      case 'expired':
        color = AppColors.error;
        break;
      case 'scheduled':
        color = AppColors.info;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(status),
      color: color,
    );
  }
}

class _CouponActions extends StatelessWidget {
  final CouponModel coupon;
  final ValueChanged<CouponModel> onView;
  final ValueChanged<CouponModel> onEdit;
  final ValueChanged<CouponModel> onDelete;
  final ValueChanged<CouponModel> onActivate;
  final ValueChanged<CouponModel> onDeactivate;
  final ValueChanged<CouponModel> onClone;

  const _CouponActions({
    required this.coupon,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onActivate,
    required this.onDeactivate,
    required this.onClone,
  });

  @override
  Widget build(BuildContext context) {
    final bool canActivate =
        coupon.status == 'inactive' || coupon.status == 'scheduled';

    final bool canDeactivate = coupon.status == 'active';

    return PopupMenuButton<String>(
      tooltip: 'Coupon Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(coupon);
            break;
          case 'edit':
            onEdit(coupon);
            break;
          case 'activate':
            onActivate(coupon);
            break;
          case 'deactivate':
            onDeactivate(coupon);
            break;
          case 'clone':
            onClone(coupon);
            break;
          case 'delete':
            onDelete(coupon);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuItem(
            icon: Icons.visibility_outlined,
            label: 'View Details',
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit Coupon',
          ),
        ),
        PopupMenuItem(
          value: 'activate',
          enabled: canActivate,
          child: _MenuItem(
            icon: Icons.check_circle_outline,
            label: 'Activate',
            color: canActivate ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'deactivate',
          enabled: canDeactivate,
          child: _MenuItem(
            icon: Icons.pause_circle_outline,
            label: 'Deactivate',
            color: canDeactivate ? AppColors.warning : Colors.grey,
          ),
        ),
        const PopupMenuItem(
          value: 'clone',
          child: _MenuItem(
            icon: Icons.copy_outlined,
            label: 'Clone Coupon',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: AppColors.error,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 20,
        ),
      ),
    );
  }
}

class _CouponSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CouponSummaryCard({
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
        borderRadius: BorderRadius.circular(18),
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Coupon Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Promotions and discount configuration',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
    final Color effectiveColor = color ?? Colors.black87;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: effectiveColor,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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