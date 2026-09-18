import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() {
    return _OrderDetailsScreenState();
  }
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderModel order;

  bool _isProcessing = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    order = widget.order;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestOrder();
    });
  }

  String _normalizeStatus(String? status) {
    final normalizedStatus = (status ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalizedStatus) {
      case 'confirm':
      case 'confirmed':
        return 'accepted';

      case 'inprogress':
      case 'processing':
        return 'in_progress';

      case 'canceled':
        return 'cancelled';

      default:
        return normalizedStatus;
    }
  }

  String get _currentStatus {
    return _normalizeStatus(order.status);
  }

  bool get _canAccept {
    return _currentStatus == 'pending';
  }

  bool get _canStart {
    return _currentStatus == 'accepted';
  }

  bool get _canComplete {
    return _currentStatus == 'in_progress';
  }

  bool get _canCancel {
    return _currentStatus == 'accepted' || _currentStatus == 'in_progress';
  }

  bool get _isTerminalStatus {
    return _currentStatus == 'completed' ||
        _currentStatus == 'cancelled' ||
        _currentStatus == 'rejected';
  }

  String _statusLabel(String? status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return 'PENDING';

      case 'accepted':
        return 'ACCEPTED';

      case 'in_progress':
        return 'IN PROGRESS';

      case 'completed':
        return 'COMPLETED';

      case 'cancelled':
        return 'CANCELLED';

      case 'rejected':
        return 'REJECTED';

      default:
        return 'PENDING';
    }
  }

  Color _statusColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'accepted':
        return Colors.blue;

      case 'in_progress':
        return Colors.deepPurple;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'rejected':
        return Colors.redAccent;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String? status) {
    switch (_normalizeStatus(status)) {
      case 'accepted':
        return Icons.check_circle_outline;

      case 'in_progress':
        return Icons.play_circle_outline;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
        return Icons.cancel_outlined;

      case 'rejected':
        return Icons.block_outlined;

      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  String _statusDescription() {
    switch (_currentStatus) {
      case 'pending':
        return 'This order is waiting for provider acceptance.';

      case 'accepted':
        return 'This order has been accepted and can now be started.';

      case 'in_progress':
        return 'The service is currently in progress.';

      case 'completed':
        return 'This service order has been completed.';

      case 'cancelled':
        return 'This service order has been cancelled.';

      case 'rejected':
        return 'This service order has been rejected.';

      default:
        return 'Order status is unavailable.';
    }
  }

  String _formatText(String? value, {String fallback = 'N/A'}) {
    final cleanValue = value?.trim() ?? '';

    if (cleanValue.isEmpty) {
      return fallback;
    }

    return cleanValue;
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) {
      return '₹0.00';
    }

    if (amount is num) {
      return '₹${amount.toStringAsFixed(2)}';
    }

    final parsedAmount = double.tryParse(amount.toString());

    if (parsedAmount == null) {
      return '₹0.00';
    }

    return '₹${parsedAmount.toStringAsFixed(2)}';
  }

  Future<void> _loadLatestOrder() async {
    if (!mounted || _isRefreshing) {
      return;
    }

    final orderId = order.id.trim();

    if (orderId.isEmpty) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final latestOrder = await context.read<OrderProvider>().getOrderById(
        orderId,
        showLoading: false,
      );

      if (!mounted || latestOrder == null) {
        return;
      }

      setState(() {
        order = latestOrder;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshAllProviderData() async {
    if (!mounted) {
      return;
    }

    final bookingProvider = context.read<BookingProvider>();
    final orderProvider = context.read<OrderProvider>();

    ///final dashboardProvider = context.read<DashboardProvider>();

    await Future.wait<void>([
      bookingProvider.refreshData(showLoading: false),
      orderProvider.refreshData(showLoading: false),
    ]);

    if (!mounted) {
      return;
    }

    final latestOrder = await orderProvider.getOrderById(
      order.id,
      showLoading: false,
    );

    if (!mounted || latestOrder == null) {
      return;
    }

    setState(() {
      order = latestOrder;
    });
  }

  void _setProcessing(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = value;
    });
  }

  void _showSuccessMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showErrorMessage(String fallbackMessage) {
    if (!mounted) {
      return;
    }

    final providerError = context.read<OrderProvider>().errorMessage?.trim();

    final message = providerError != null && providerError.isNotEmpty
        ? providerError
        : fallbackMessage;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _confirmOrder() async {
    if (_isProcessing || !_canAccept) {
      return;
    }

    _setProcessing(true);

    try {
      final success = await context.read<OrderProvider>().confirmOrder(
        order.id,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage('Unable to accept the order.');

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage('Order accepted successfully.');
    } catch (error) {
      _showErrorMessage(error.toString());
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _startOrder() async {
    if (_isProcessing || !_canStart) {
      return;
    }

    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Start Order'),
          content: const Text(
            'Confirm that you are ready to start this service.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );

    if (shouldStart != true || !mounted) {
      return;
    }

    _setProcessing(true);

    try {
      final success = await context.read<OrderProvider>().startOrder(order.id);

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage('Unable to start the order.');

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage('Order started successfully.');
    } catch (error) {
      _showErrorMessage(error.toString());
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _completeOrder() async {
    if (_isProcessing || !_canComplete) {
      return;
    }

    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Complete Order'),
          content: const Text(
            'Confirm that the requested service has been completed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (shouldComplete != true || !mounted) {
      return;
    }

    _setProcessing(true);

    try {
      final success = await context.read<OrderProvider>().completeOrder(
        order.id,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage('Unable to complete the order.');

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage('Order completed successfully.');
    } catch (error) {
      _showErrorMessage(error.toString());
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> _cancelOrder() async {
    if (_isProcessing || !_canCancel) {
      return;
    }

    final reason = await _showReasonDialog(
      title: 'Cancel Order',
      hintText: 'Enter the cancellation reason',
      actionText: 'Cancel Order',
    );

    if (reason == null || !mounted) {
      return;
    }

    _setProcessing(true);

    try {
      final success = await context.read<OrderProvider>().cancelOrder(
        orderId: order.id,
        reason: reason,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage('Unable to cancel the order.');

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage('Order cancelled successfully.');
    } catch (error) {
      _showErrorMessage(error.toString());
    } finally {
      _setProcessing(false);
    }
  }

  Future<String?> _showReasonDialog({
    required String title,
    required String hintText,
    required String actionText,
  }) async {
    final controller = TextEditingController();

    String? validationMessage;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                maxLines: 4,
                maxLength: 500,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText,
                  errorText: validationMessage,
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reason = controller.text.trim();

                    if (reason.isEmpty) {
                      setDialogState(() {
                        validationMessage = 'Cancellation reason is required.';
                      });

                      return;
                    }

                    Navigator.of(dialogContext).pop(reason);
                  },
                  child: Text(actionText),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = context.watch<OrderProvider>();

    final showLoading = _isProcessing || _isRefreshing || provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: showLoading ? null : _loadLatestOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAllProviderData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(theme),
                  const SizedBox(height: 16),
                  _sectionTitle('Customer Information'),
                  _infoCard(
                    children: [
                      _infoTile(
                        Icons.person_outline,
                        'Customer Name',
                        _formatText(order.customerName),
                      ),
                      _infoTile(
                        Icons.phone_outlined,
                        'Phone',
                        _formatText(order.customerPhone),
                      ),
                      _infoTile(
                        Icons.email_outlined,
                        'Email',
                        _formatText(order.customerEmail),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Order Information'),
                  _infoCard(
                    children: [
                      _infoTile(
                        Icons.receipt_long_outlined,
                        'Order ID',
                        _formatText(order.id),
                      ),
                      _infoTile(
                        Icons.calendar_today_outlined,
                        'Order Date',
                        _formatText(order.orderDate),
                      ),
                      _infoTile(
                        Icons.event_outlined,
                        'Event Date',
                        _formatText(order.eventDate),
                      ),
                      _infoTile(
                        Icons.location_on_outlined,
                        'Location',
                        _formatText(order.location),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Payment Information'),
                  _infoCard(
                    children: [
                      _infoTile(
                        Icons.currency_rupee,
                        'Order Amount',
                        _formatAmount(order.totalAmount),
                      ),
                      _infoTile(
                        Icons.payment_outlined,
                        'Payment Status',
                        _formatText(order.paymentStatus, fallback: 'Pending'),
                      ),
                      _infoTile(
                        Icons.receipt_outlined,
                        'Transaction ID',
                        _formatText(order.transactionId),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Notes'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _formatText(
                            order.notes,
                            fallback: 'No notes available',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (showLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final color = _statusColor(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(order.status),
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _formatText(order.serviceName, fallback: 'Service Order'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusDescription(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isTerminalStatus) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_canAccept)
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _confirmOrder,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('ACCEPT ORDER'),
          ),
        if (_canStart)
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _startOrder,
            icon: const Icon(Icons.play_arrow),
            label: const Text('START ORDER'),
          ),
        if (_canComplete)
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _completeOrder,
            icon: const Icon(Icons.done_all),
            label: const Text('COMPLETE ORDER'),
          ),
        if (_canCancel) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : _cancelOrder,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('CANCEL ORDER'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value.trim().isEmpty ? 'N/A' : value),
    );
  }
}
