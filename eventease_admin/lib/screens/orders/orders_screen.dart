import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';
import '../../widgets/tables/order_table.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
  });

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedOrderStatus;
  String? _selectedPaymentStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadOrders();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD ORDERS
  // =====================================================

  Future<void> _loadOrders({
    int page = 1,
  }) async {
    _page = page;

    await context.read<OrderProvider>().getOrders(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          orderStatus: _selectedOrderStatus,
          paymentStatus: _selectedPaymentStatus,
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadOrders(
      page: 1,
    );
  }

  // =====================================================
  // ORDER STATUS FILTER
  // =====================================================

  Future<void> _onOrderStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedOrderStatus = value;
    });

    await _loadOrders(
      page: 1,
    );
  }

  // =====================================================
  // PAYMENT STATUS FILTER
  // =====================================================

  Future<void> _onPaymentStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedPaymentStatus = value;
    });

    await _loadOrders(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedOrderStatus = null;
      _selectedPaymentStatus = null;
      _page = 1;
    });

    await _loadOrders(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadOrders(
      page: _page,
    );
  }

  // =====================================================
  // VIEW ORDER
  // =====================================================

  void _viewOrder(
    OrderModel order,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetails,
      arguments: order,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // PROCESS ORDER
  // =====================================================

  Future<void> _processOrder(
    OrderModel order,
  ) async {
    final success =
        await context.read<OrderProvider>().processOrder(
              order.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Order moved to processing successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // SHIP ORDER
  // =====================================================

  Future<void> _shipOrder(
    OrderModel order,
  ) async {
    final success =
        await context.read<OrderProvider>().shipOrder(
              order.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Order shipped successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // DELIVER ORDER
  // =====================================================

  Future<void> _deliverOrder(
    OrderModel order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Mark Order Delivered',
          ),
          content: Text(
            'Are you sure you want to mark order ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id} as delivered?',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Deliver',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context.read<OrderProvider>().deliverOrder(
              order.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Order delivered successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // CANCEL ORDER
  // =====================================================

  Future<void> _cancelOrder(
    OrderModel order,
  ) async {
    final TextEditingController reasonController =
        TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Cancel Order',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter cancellation reason for order ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Cancellation reason',
                  border: OutlineInputBorder(),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Cancel Order',
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

    final reason = reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Cancellation reason is required',
      );
      return;
    }

    final success =
        await context.read<OrderProvider>().cancelOrder(
              orderId: order.id,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Order cancelled successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<void> _updatePaymentStatus(
    OrderModel order,
  ) async {
    final paymentStatus = await showDialog<String>(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: const Text(
            'Update Payment Status',
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'paid',
                );
              },
              child: const Text('Paid'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'pending',
                );
              },
              child: const Text('Pending'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'failed',
                );
              },
              child: const Text('Failed'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'refunded',
                );
              },
              child: const Text('Refunded'),
            ),
          ],
        );
      },
    );

    if (paymentStatus == null) return;

    final success =
        await context.read<OrderProvider>().updatePaymentStatus(
              orderId: order.id,
              paymentStatus: paymentStatus,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Payment status updated successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // DELETE ORDER
  // =====================================================

  Future<void> _deleteOrder(
    OrderModel order,
  ) async {
    final confirmed = await DeleteOrderDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context.read<OrderProvider>().deleteOrder(
              order.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Order deleted successfully',
      );

      await _refresh();
    } else {
      _showOrderError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showOrderError() {
    final error =
        context.read<OrderProvider>().errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _previousPage() async {
    if (_page <= 1) return;

    await _loadOrders(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadOrders(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadOrders(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.orders,
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
        child: Consumer<OrderProvider>(
          builder: (
            context,
            orderProvider,
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
                      orderProvider,
                    ),

                    const SizedBox(
                      height: AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height: AppDimensions.padding20,
                    ),

                    if (orderProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: orderProvider.errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    OrderTable(
                      orders: orderProvider.orders,
                      isLoading: orderProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewOrder,
                      onProcess: _processOrder,
                      onShip: _shipOrder,
                      onDeliver: _deliverOrder,
                      onCancel: _cancelOrder,
                      onUpdatePayment:
                          _updatePaymentStatus,
                      onDelete: _deleteOrder,
                    ),

                    const SizedBox(
                      height: AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          orderProvider.currentPage,
                      totalPages:
                          orderProvider.totalPages,
                      totalRecords:
                          orderProvider.totalOrders,
                      pageSize: _limit,
                      onPrevious: _previousPage,
                      onNext: () {
                        _nextPage(
                          orderProvider.totalPages,
                        );
                      },
                      onPageSelected: _goToPage,
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
    OrderProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 950;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.orders,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage marketplace product orders, delivery lifecycle, payment status, cancellations, and customer order activity.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );

        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _OrderSummaryCard(
              title: 'Total Orders',
              value: provider.totalOrders.toString(),
              icon: Icons.shopping_bag_outlined,
              color: AppColors.primary,
            ),
            _OrderSummaryCard(
              title: 'Placed',
              value: provider.placedOrders.toString(),
              icon: Icons.receipt_long_outlined,
              color: AppColors.info,
            ),
            _OrderSummaryCard(
              title: 'Processing',
              value:
                  provider.processingOrders.toString(),
              icon: Icons.sync_outlined,
              color: AppColors.warning,
            ),
            _OrderSummaryCard(
              title: 'Delivered',
              value:
                  provider.deliveredOrders.toString(),
              icon: Icons.task_alt_outlined,
              color: AppColors.success,
            ),
            _OrderSummaryCard(
              title: 'Cancelled',
              value:
                  provider.cancelledOrders.toString(),
              icon: Icons.cancel_outlined,
              color: AppColors.error,
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
                  'Search orders by order number, customer, provider, item or phone...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final orderStatusDropdown =
                CustomDropdown<String>(
              labelText: 'Order Status',
              hintText: 'All Orders',
              value: _selectedOrderStatus,
              items: const [
                'placed',
                'pending',
                'processing',
                'shipped',
                'delivered',
                'cancelled',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged: _onOrderStatusChanged,
              prefixIcon: const Icon(
                Icons.local_shipping_outlined,
              ),
            );

            final paymentStatusDropdown =
                CustomDropdown<String>(
              labelText: 'Payment Status',
              hintText: 'All Payments',
              value: _selectedPaymentStatus,
              items: const [
                'pending',
                'paid',
                'success',
                'failed',
                'refunded',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged: _onPaymentStatusChanged,
              prefixIcon: const Icon(
                Icons.payments_outlined,
              ),
            );

            final clearButton = CustomButton(
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
                  orderStatusDropdown,
                  const SizedBox(height: 12),
                  paymentStatusDropdown,
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
                  child: orderStatusDropdown,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: paymentStatusDropdown,
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

class _OrderSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OrderSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 155,
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
              borderRadius: BorderRadius.circular(
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
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}