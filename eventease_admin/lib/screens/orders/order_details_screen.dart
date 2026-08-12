import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  OrderModel? _order;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is OrderModel) {
      _order = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadOrderDetails();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final orderArg = args['order'];

      if (orderArg is OrderModel) {
        _order = orderArg;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadOrderDetails();
        },
      );
    }

    _initialized = true;
  }

  // =====================================================
  // LOAD ORDER DETAILS
  // =====================================================

  Future<void> _loadOrderDetails() async {
    if (_order == null) return;

    await context
        .read<OrderProvider>()
        .getOrderDetails(
          _order!.id,
        );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadOrderDetails();
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
    final confirmed =
        await showDialog<bool>(
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.success,
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
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Cancel Order',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter cancellation reason for order ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Cancellation reason',
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

    final reason =
        reasonController.text.trim();

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
    final paymentStatus =
        await showDialog<String>(
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
        await context
            .read<OrderProvider>()
            .updatePaymentStatus(
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
    final confirmed =
        await DeleteOrderDialog.show(
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

      Navigator.pop(
        context,
        true,
      );
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

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Order Details',
          ),
        ),
        body: const Center(
          child: Text(
            'Order data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Order Details',
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
        child: Consumer<OrderProvider>(
          builder: (
            context,
            orderProvider,
            child,
          ) {
            if (orderProvider.isLoading) {
              return const FullScreenLoadingWidget(
                message:
                    'Loading order details...',
              );
            }

            final order =
                orderProvider.selectedOrder ??
                    _order!;

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
                    if (orderProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: orderProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    _buildHeroCard(
                      order,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildOverviewGrid(
                      order,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    LayoutBuilder(
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
                              _buildCustomerCard(
                                order,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildProviderCard(
                                order,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildDeliveryCard(
                                order,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child:
                                  _buildCustomerCard(
                                order,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child:
                                  _buildProviderCard(
                                order,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child:
                                  _buildDeliveryCard(
                                order,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    LayoutBuilder(
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
                              _buildOrderInfoCard(
                                order,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildPaymentInfoCard(
                                order,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child:
                                  _buildOrderInfoCard(
                                order,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child:
                                  _buildPaymentInfoCard(
                                order,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildItemsCard(
                      order,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildActionsCard(
                      order,
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
  // HERO CARD
  // =====================================================

  Widget _buildHeroCard(
    OrderModel order,
  ) {
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
          AppDimensions.padding24,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 760;

            final iconBox = Container(
              height: isMobile ? 96 : 112,
              width: isMobile ? 96 : 112,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius20,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            );

            final content = Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber.isNotEmpty
                        ? order.orderNumber
                        : order.id,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textPrimary,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${order.totalItems} item(s) • ${order.customerName.isNotEmpty ? order.customerName : 'Customer'}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOrderStatusChip(
                        order,
                      ),
                      _buildPaymentStatusChip(
                        order,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _MiniInfoBox(
                        title: 'Total Amount',
                        value: AppFormatters
                            .formatCurrency(
                          order.totalAmount,
                        ),
                        icon:
                            Icons.currency_rupee_rounded,
                        color: AppColors.success,
                      ),
                      _MiniInfoBox(
                        title: 'Created',
                        value: AppFormatters
                            .formatDate(
                          order.createdAt,
                        ),
                        icon:
                            Icons.calendar_today_outlined,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      content,
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                iconBox,
                const SizedBox(width: 24),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // OVERVIEW GRID
  // =====================================================

  Widget _buildOverviewGrid(
    OrderModel order,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        int crossAxisCount = 4;

        if (constraints.maxWidth < 700) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              crossAxisCount == 1 ? 3.8 : 1.8,
          children: [
            _StatCard(
              title: 'Total Amount',
              value: AppFormatters
                  .formatCurrency(
                order.totalAmount,
              ),
              icon:
                  Icons.currency_rupee_rounded,
              color: AppColors.success,
            ),
            _StatCard(
              title: 'Items',
              value: AppFormatters.formatNumber(
                order.totalItems,
              ),
              icon: Icons.inventory_2_outlined,
              color: AppColors.primary,
            ),
            _StatCard(
              title: 'Delivery',
              value: AppFormatters
                  .formatCurrency(
                order.deliveryCharge,
              ),
              icon:
                  Icons.local_shipping_outlined,
              color: AppColors.info,
            ),
            _StatCard(
              title: 'Discount',
              value: AppFormatters
                  .formatCurrency(
                order.discountAmount,
              ),
              icon:
                  Icons.local_offer_outlined,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // CUSTOMER CARD
  // =====================================================

  Widget _buildCustomerCard(
    OrderModel order,
  ) {
    return _DetailsCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          label: 'Customer Name',
          value: order.customerName.isNotEmpty
              ? order.customerName
              : '-',
        ),
        _InfoRow(
          label: 'Phone',
          value: order.customerPhone.isNotEmpty
              ? AppFormatters.formatPhone(
                  order.customerPhone,
                )
              : '-',
        ),
      ],
    );
  }

  // =====================================================
  // PROVIDER CARD
  // =====================================================

  Widget _buildProviderCard(
    OrderModel order,
  ) {
    return _DetailsCard(
      title: 'Provider Information',
      icon: Icons.storefront_outlined,
      children: [
        _InfoRow(
          label: 'Provider',
          value: order.providerName.isNotEmpty
              ? order.providerName
              : '-',
        ),
      ],
    );
  }

  // =====================================================
  // DELIVERY CARD
  // =====================================================

  Widget _buildDeliveryCard(
    OrderModel order,
  ) {
    final location = [
      order.city,
      order.state,
      order.pincode,
    ]
        .where(
          (value) => value.toString().trim().isNotEmpty,
        )
        .join(', ');

    return _DetailsCard(
      title: 'Delivery Information',
      icon: Icons.location_on_outlined,
      children: [
        _InfoRow(
          label: 'Address',
          value: order.deliveryAddress.isNotEmpty
              ? order.deliveryAddress
              : '-',
        ),
        _InfoRow(
          label: 'Location',
          value: location.isNotEmpty ? location : '-',
        ),
      ],
    );
  }

  // =====================================================
  // ORDER INFO CARD
  // =====================================================

  Widget _buildOrderInfoCard(
    OrderModel order,
  ) {
    return _DetailsCard(
      title: 'Order Information',
      icon: Icons.receipt_long_outlined,
      children: [
        _InfoRow(
          label: 'Order ID',
          value: order.id,
        ),
        _InfoRow(
          label: 'Order No.',
          value: order.orderNumber.isNotEmpty
              ? order.orderNumber
              : '-',
        ),
        _InfoRow(
          label: 'Order Status',
          value: AppFormatters.formatStatus(
            order.orderStatus,
          ),
        ),
        _InfoRow(
          label: 'Created At',
          value: AppFormatters.formatDate(
            order.createdAt,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PAYMENT INFO CARD
  // =====================================================

  Widget _buildPaymentInfoCard(
    OrderModel order,
  ) {
    final subtotal = order.totalAmount -
        order.deliveryCharge +
        order.discountAmount;

    return _DetailsCard(
      title: 'Payment Information',
      icon: Icons.payments_outlined,
      action: TextButton(
        onPressed: () {
          _updatePaymentStatus(
            order,
          );
        },
        child: const Text(
          'Update',
        ),
      ),
      children: [
        _InfoRow(
          label: 'Payment',
          value: order.paymentStatus.isNotEmpty
              ? AppFormatters.formatStatus(
                  order.paymentStatus,
                )
              : '-',
        ),
        _InfoRow(
          label: 'Subtotal',
          value: AppFormatters.formatCurrency(
            subtotal,
          ),
        ),
        _InfoRow(
          label: 'Delivery',
          value: AppFormatters.formatCurrency(
            order.deliveryCharge,
          ),
        ),
        _InfoRow(
          label: 'Discount',
          value: AppFormatters.formatCurrency(
            order.discountAmount,
          ),
        ),
        _InfoRow(
          label: 'Total',
          value: AppFormatters.formatCurrency(
            order.totalAmount,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ITEMS CARD
  // =====================================================

  Widget _buildItemsCard(
    OrderModel order,
  ) {
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
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Order Items',
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

            const SizedBox(height: 18),

            if (order.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No items available',
                    style: TextStyle(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, _) {
                  return const Divider(
                    color: AppColors.border,
                  );
                },
                itemBuilder: (
                  context,
                  index,
                ) {
                  final item =
                      order.items[index];

                  return _OrderItemTile(
                    item: item,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ACTIONS CARD
  // =====================================================

  Widget _buildActionsCard(
    OrderModel order,
  ) {
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
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 850;

            final actions =
                <Widget>[
              if (order.isPending)
                CustomButton(
                  text: 'Process',
                  icon: Icons.sync_outlined,
                  onPressed: () {
                    _processOrder(
                      order,
                    );
                  },
                ),
              if (order.isProcessing)
                CustomButton(
                  text: 'Ship',
                  type: ButtonType.outline,
                  icon:
                      Icons.local_shipping_outlined,
                  onPressed: () {
                    _shipOrder(
                      order,
                    );
                  },
                ),
              if (!order.isDelivered &&
                  !order.isCancelled)
                CustomButton(
                  text: 'Deliver',
                  type: ButtonType.success,
                  icon:
                      Icons.task_alt_outlined,
                  onPressed: () {
                    _deliverOrder(
                      order,
                    );
                  },
                ),
              if (!order.isDelivered &&
                  !order.isCancelled)
                CustomButton(
                  text: 'Cancel',
                  type: ButtonType.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    _cancelOrder(
                      order,
                    );
                  },
                ),
              CustomButton(
                text: 'Payment',
                type: ButtonType.outline,
                icon: Icons.payments_outlined,
                onPressed: () {
                  _updatePaymentStatus(
                    order,
                  );
                },
              ),
              CustomButton(
                text: 'Delete',
                type: ButtonType.danger,
                icon: Icons.delete_outline,
                onPressed: () {
                  _deleteOrder(
                    order,
                  );
                },
              ),
            ];

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildActionHeader(),
                  const SizedBox(height: 16),
                  ...actions.map(
                    (action) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: action,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildActionHeader(),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actions
                      .map(
                        (action) => SizedBox(
                          width: 170,
                          child: action,
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionHeader() {
    return Row(
      children: [
        const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          'Admin Actions',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // =====================================================
  // STATUS HELPERS
  // =====================================================

  Widget _buildOrderStatusChip(
    OrderModel order,
  ) {
    if (order.isDelivered) {
      return const _StatusChip(
        label: 'Delivered',
        color: AppColors.orderDelivered,
      );
    }

    if (order.isCancelled) {
      return const _StatusChip(
        label: 'Cancelled',
        color: AppColors.orderCancelled,
      );
    }

    if (order.isProcessing) {
      return const _StatusChip(
        label: 'Processing',
        color: AppColors.orderProcessing,
      );
    }

    if (order.isShipped) {
      return const _StatusChip(
        label: 'Shipped',
        color: AppColors.orderShipped,
      );
    }

    return const _StatusChip(
      label: 'Placed',
      color: AppColors.orderPlaced,
    );
  }

  Widget _buildPaymentStatusChip(
    OrderModel order,
  ) {
    return _StatusChip(
      label: order.paymentStatus.isNotEmpty
          ? AppFormatters.formatStatus(
              order.paymentStatus,
            )
          : 'Pending',
      color: _paymentStatusColor(
        order.paymentStatus,
      ),
    );
  }

  Color _paymentStatusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return AppColors.paymentPaid;

      case 'failed':
        return AppColors.paymentFailed;

      case 'refunded':
        return AppColors.paymentRefunded;

      case 'pending':
      default:
        return AppColors.paymentPending;
    }
  }
}

// =====================================================
// ORDER ITEM TILE
// =====================================================

class _OrderItemTile extends StatelessWidget {
  final dynamic item;

  const _OrderItemTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final productName =
        _readString(
      item,
      [
        'productName',
        'name',
        'title',
      ],
      fallback: 'Item',
    );

    final productImage =
        _readString(
      item,
      [
        'productImage',
        'image',
        'imageUrl',
      ],
    );

    final quantity =
        _readInt(
      item,
      [
        'quantity',
        'qty',
      ],
      fallback: 1,
    );

    final price =
        _readDouble(
      item,
      [
        'price',
        'unitPrice',
      ],
    );

    final total =
        _readDouble(
      item,
      [
        'total',
        'totalPrice',
        'amount',
      ],
      fallback: price * quantity,
    );

    final hasImage =
        productImage.isNotEmpty;

    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: AppColors.primary
                .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(
              AppDimensions.radius12,
            ),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(
                      productImage,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? null
              : const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppFormatters.formatCurrency(price)} x $quantity',
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Text(
          AppFormatters.formatCurrency(
            total,
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  static Map<String, dynamic> _toMap(
    dynamic item,
  ) {
    if (item is Map<String, dynamic>) {
      return item;
    }

    try {
      final json = item.toJson();

      if (json is Map<String, dynamic>) {
        return json;
      }
    } catch (_) {
      //
    }

    return {};
  }

  static String _readString(
    dynamic item,
    List<String> keys, {
    String fallback = '',
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value != null &&
          value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  static int _readInt(
    dynamic item,
    List<String> keys, {
    int fallback = 0,
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value is int) return value;

      if (value is num) return value.toInt();

      final parsed =
          int.tryParse(value?.toString() ?? '');

      if (parsed != null) return parsed;
    }

    return fallback;
  }

  static double _readDouble(
    dynamic item,
    List<String> keys, {
    double fallback = 0,
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value is double) return value;

      if (value is num) return value.toDouble();

      final parsed =
          double.tryParse(value?.toString() ?? '');

      if (parsed != null) return parsed;
    }

    return fallback;
  }
}

// =====================================================
// DETAILS CARD
// =====================================================

class _DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;

  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.children,
    this.action,
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
                ?action,
              ],
            ),

            const SizedBox(height: 18),

            ...children,
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
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
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

// =====================================================
// STAT CARD
// =====================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          AppDimensions.padding16,
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color:
                    color.withValues(alpha: 0.10),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// MINI INFO BOX
// =====================================================

class _MiniInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniInfoBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 145,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius14,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
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
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
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