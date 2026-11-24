import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() {
    return _OrderDetailsScreenState();
  }
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  late OrderModel order;

  bool _isProcessing = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    order = widget.order;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadLatestOrder();
      },
    );
  }

  // =====================================================
  // FORMATTERS
  // =====================================================

  String _formatText(
    String? value, {
    String fallback = 'N/A',
  }) {
    final cleanValue =
        value?.trim() ?? '';

    return cleanValue.isEmpty
        ? fallback
        : cleanValue;
  }

  String _formatAmount(
    dynamic amount,
  ) {
    if (amount == null) {
      return '₹0.00';
    }

    if (amount is num) {
      return '₹${amount.toStringAsFixed(2)}';
    }

    final parsedAmount =
        double.tryParse(
      amount.toString(),
    );

    if (parsedAmount == null) {
      return '₹0.00';
    }

    return '₹${parsedAmount.toStringAsFixed(2)}';
  }

  // =====================================================
  // STATUS UI
  // =====================================================

  String _statusLabel() {
    if (order.isAccepted &&
        order.providerArrived) {
      return 'PROVIDER ARRIVED';
    }

    return order.statusText.toUpperCase();
  }

  Color _statusColor() {
    if (order.isAccepted &&
        order.providerArrived) {
      return Colors.teal;
    }

    if (order.isAccepted) {
      return Colors.blue;
    }

    if (order.isOtpVerified) {
      return Colors.deepPurple;
    }

    if (order.isInProgress) {
      return Colors.orange;
    }

    if (order.isCompleted) {
      return Colors.green;
    }

    if (order.isCancelled) {
      return Colors.red;
    }

    if (order.isRejected) {
      return Colors.redAccent;
    }

    return Colors.orange;
  }

  IconData _statusIcon() {
    if (order.isAccepted &&
        order.providerArrived) {
      return Icons.location_on_outlined;
    }

    if (order.isAccepted) {
      return Icons.check_circle_outline;
    }

    if (order.isOtpVerified) {
      return Icons.verified_outlined;
    }

    if (order.isInProgress) {
      return Icons.play_circle_outline;
    }

    if (order.isCompleted) {
      return Icons.task_alt;
    }

    if (order.isCancelled) {
      return Icons.cancel_outlined;
    }

    if (order.isRejected) {
      return Icons.block_outlined;
    }

    return Icons.schedule;
  }

  String _statusDescription() {
    if (order.isPending) {
      return 'This booking is waiting for your acceptance.';
    }

    if (order.isAccepted &&
        !order.providerArrived) {
      return 'The booking is accepted. Travel to the Customer location and mark yourself as arrived.';
    }

    if (order.isAccepted &&
        order.providerArrived &&
        !order.otpVerified) {
      return 'Arrival is recorded. Ask the Customer for the 4-digit service OTP.';
    }

    if (order.isOtpVerified &&
        !order.isInProgress) {
      return 'The Customer service OTP is verified. You can start the service.';
    }

    if (order.isInProgress) {
      return 'The service is in progress. Complete the booking after the requested service is finished.';
    }

    if (order.isCompleted) {
      return 'This service has been completed. Chat history remains available in read-only mode.';
    }

    if (order.isCancelled) {
      return 'This booking has been cancelled. Chat history remains available in read-only mode.';
    }

    if (order.isRejected) {
      return 'This booking was rejected. Chat history remains available in read-only mode.';
    }

    return 'Order status is unavailable.';
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _loadLatestOrder() async {
    if (!mounted ||
        _isRefreshing) {
      return;
    }

    final orderId =
        order.id.trim();

    if (orderId.isEmpty) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final latestOrder =
          await context
              .read<OrderProvider>()
              .getOrderById(
                orderId,
                showLoading: false,
              );

      if (!mounted ||
          latestOrder == null) {
        return;
      }

      setState(() {
        order = latestOrder;
      });
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          'Unable to refresh order details: $error',
        );
      }
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

    final bookingProvider =
        context.read<BookingProvider>();

    final orderProvider =
        context.read<OrderProvider>();

    await Future.wait<void>(
      <Future<void>>[
        bookingProvider.refreshData(
          showLoading: false,
        ),
        orderProvider.refreshData(
          showLoading: false,
        ),
      ],
    );

    if (!mounted) {
      return;
    }

    final latestOrder =
        await orderProvider.getOrderById(
      order.id,
      showLoading: false,
    );

    if (!mounted ||
        latestOrder == null) {
      return;
    }

    setState(() {
      order = latestOrder;
    });
  }

  // =====================================================
  // STATE / SNACKBARS
  // =====================================================

  void _setProcessing(
    bool value,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = value;
    });
  }

  void _showSuccessMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void _showErrorMessage(
    String fallbackMessage,
  ) {
    if (!mounted) {
      return;
    }

    final providerError =
        context
            .read<OrderProvider>()
            .errorMessage
            ?.trim();

    final message =
        providerError != null &&
                providerError.isNotEmpty
            ? providerError
            : fallbackMessage;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          backgroundColor:
              Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // ACCEPT
  // =====================================================

  Future<void> _confirmOrder() async {
    if (_isProcessing ||
        !order.canAccept) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final success =
          await context
              .read<OrderProvider>()
              .confirmOrder(
                order.id,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'Unable to accept the order.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'Order accepted successfully.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  // =====================================================
  // CURRENT LOCATION
  // =====================================================

  Future<Position?> _getCurrentPosition() async {
    var locationEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!locationEnabled) {
      final openSettings =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (
          BuildContext dialogContext,
        ) {
          return AlertDialog(
            title: const Text(
              'Location Required',
            ),
            content: const Text(
              'Enable device location before marking yourself as arrived.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(
                    false,
                  );
                },
                child: const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(
                    true,
                  );
                },
                child: const Text(
                  'Open Settings',
                ),
              ),
            ],
          );
        },
      );

      if (openSettings != true) {
        return null;
      }

      await Geolocator
          .openLocationSettings();

      locationEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!locationEnabled) {
        return null;
      }
    }

    var permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator
              .requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      if (permission ==
          LocationPermission.deniedForever) {
        await Geolocator
            .openAppSettings();
      }

      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy:
            LocationAccuracy.high,
      ),
    );
  }

  // =====================================================
  // PROVIDER ARRIVED
  // =====================================================

  Future<void> _markProviderArrived() async {
    if (_isProcessing ||
        !order.canProviderMarkArrived) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Confirm Arrival',
          ),
          content: const Text(
            'Confirm that you have reached the Customer service location.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'Back',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              child: const Text(
                'I Have Arrived',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final position =
          await _getCurrentPosition();

      if (!mounted) {
        return;
      }

      if (position == null) {
        _showErrorMessage(
          'Current location is required to mark arrival.',
        );

        return;
      }

      final success =
          await context
              .read<OrderProvider>()
              .markProviderArrived(
                orderId:
                    order.id,
                latitude:
                    position.latitude,
                longitude:
                    position.longitude,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'Unable to mark Provider arrival.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'Arrival confirmed. Ask the Customer for the service OTP.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  // =====================================================
  // VERIFY OTP
  // =====================================================

  Future<void> _showOtpDialog() async {
    if (_isProcessing ||
        !order.canVerifyOtp) {
      return;
    }

    final controller =
        TextEditingController();

    String? validationMessage;

    final otp =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Verify Service OTP',
              ),
              content: TextField(
                controller:
                    controller,
                keyboardType:
                    TextInputType.number,
                maxLength: 4,
                autofocus: true,
                decoration:
                    InputDecoration(
                  labelText:
                      'Customer OTP',
                  hintText:
                      'Enter 4-digit OTP',
                  errorText:
                      validationMessage,
                  border:
                      const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final enteredOtp =
                        controller.text
                            .trim();

                    if (!RegExp(
                      r'^\d{4}$',
                    ).hasMatch(
                      enteredOtp,
                    )) {
                      setDialogState(
                        () {
                          validationMessage =
                              'Enter a valid 4-digit OTP.';
                        },
                      );

                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(
                      enteredOtp,
                    );
                  },
                  child: const Text(
                    'Verify',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (otp == null ||
        otp.isEmpty ||
        !mounted) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final success =
          await context
              .read<OrderProvider>()
              .verifyServiceOtp(
                orderId:
                    order.id,
                otp:
                    otp,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'OTP verification failed.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'OTP verified successfully.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error.toString(),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  // =====================================================
  // START SERVICE
  // =====================================================

  Future<void> _startOrder() async {
    if (_isProcessing ||
        !order.canStart) {
      return;
    }

    final shouldStart =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Start Service',
          ),
          content: const Text(
            'Confirm that the Customer OTP has been verified and you are ready to start this service.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'Back',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              child: const Text(
                'Start',
              ),
            ),
          ],
        );
      },
    );

    if (shouldStart != true ||
        !mounted) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final success =
          await context
              .read<OrderProvider>()
              .startOrder(
                order.id,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'Unable to start the service.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'Service started successfully.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error.toString(),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  // =====================================================
  // COMPLETE SERVICE
  // =====================================================

  Future<void> _completeOrder() async {
    if (_isProcessing ||
        !order.canComplete) {
      return;
    }

    final shouldComplete =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Complete Service',
          ),
          content: const Text(
            'Confirm that the requested service has been completed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'Back',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              child: const Text(
                'Complete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldComplete != true ||
        !mounted) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final success =
          await context
              .read<OrderProvider>()
              .completeOrder(
                order.id,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'Unable to complete the service.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'Service completed successfully.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error.toString(),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  // =====================================================
  // CANCEL
  // =====================================================

  Future<void> _cancelOrder() async {
    if (_isProcessing ||
        !order.canCancel) {
      return;
    }

    final reason =
        await _showReasonDialog(
      title:
          'Cancel Booking',
      hintText:
          'Enter the cancellation reason',
      actionText:
          'Cancel Booking',
    );

    if (reason == null ||
        !mounted) {
      return;
    }

    _setProcessing(
      true,
    );

    try {
      final success =
          await context
              .read<OrderProvider>()
              .cancelOrder(
                orderId:
                    order.id,
                reason:
                    reason,
              );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showErrorMessage(
          'Unable to cancel the booking.',
        );

        return;
      }

      await _refreshAllProviderData();

      if (!mounted) {
        return;
      }

      _showSuccessMessage(
        'Booking cancelled successfully.',
      );
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          error.toString(),
        );
      }
    } finally {
      if (mounted) {
        _setProcessing(
          false,
        );
      }
    }
  }

  Future<String?> _showReasonDialog({
    required String title,
    required String hintText,
    required String actionText,
  }) async {
    final controller =
        TextEditingController();

    String? validationMessage;

    final result =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title:
                  Text(title),
              content:
                  TextField(
                controller:
                    controller,
                maxLines: 4,
                maxLength: 500,
                autofocus: true,
                decoration:
                    InputDecoration(
                  hintText:
                      hintText,
                  errorText:
                      validationMessage,
                  border:
                      const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                      const Text(
                    'Back',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reason =
                        controller.text
                            .trim();

                    if (reason.isEmpty) {
                      setDialogState(
                        () {
                          validationMessage =
                              'Cancellation reason is required.';
                        },
                      );

                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(
                      reason,
                    );
                  },
                  child:
                      Text(
                    actionText,
                  ),
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

  // =====================================================
  // BOOKING CHAT
  // =====================================================

  Future<void> _openChat() async {
    final roomId =
        order.effectiveChatRoomId;

    if (roomId.isEmpty ||
        order.customerId
            .trim()
            .isEmpty) {
      _showErrorMessage(
        'Booking chat information is unavailable.',
      );

      return;
    }

    /*
     * IMPORTANT:
     *
     * Chat does NOT depend on OTP.
     *
     * pending / accepted / arrived / otp_verified /
     * in_progress may have writable Booking Chat.
     *
     * terminal bookings can still display history.
     */
    if (!order.canOpenChat &&
        !order.canViewChatHistory) {
      _showErrorMessage(
        'Chat is currently unavailable for this booking.',
      );

      return;
    }

    /*
     * Provider application must have /chat configured
     * to open its Chat screen.
     *
     * No provider-specific HTTP send endpoint is used.
     * Actual sending uses the common room-based Chat API.
     */
    await Navigator.pushNamed(
      context,
      '/chat',
      arguments:
          <String, dynamic>{
        'chatType':
            'booking',

        'negotiationMode':
            false,

        'bookingId':
            order.bookingId.isNotEmpty
                ? order.bookingId
                : order.id,

        'roomId':
            roomId,

        'chatRoomId':
            roomId,

        'customerId':
            order.customerId,

        'receiverId':
            order.customerId,

        'customerName':
            order.customerName,

        'receiverName':
            order.customerName,

        'receiverPhone':
            order.canCallCustomer
                ? order.customerPhone
                : '',

        'customerPhone':
            order.canCallCustomer
                ? order.customerPhone
                : '',

        'chatEnabled':
            order.canOpenChat,

        'readOnly':
            order.canViewChatHistory,

        'canCall':
            order.canCallCustomer,

        'phoneVisible':
            order.phoneVisible,
      },
    );

    if (!mounted) {
      return;
    }

    await _loadLatestOrder();
  }

  // =====================================================
  // CALL CUSTOMER
  // =====================================================

  Future<void> _callCustomer() async {
    if (!order.canCallCustomer) {
      _showErrorMessage(
        order.isTerminal
            ? 'Calling is unavailable for this closed booking.'
            : 'Customer calling is available after the booking is accepted.',
      );

      return;
    }

    final phone =
        order.customerPhone.replaceAll(
      RegExp(
        r'[^0-9+]',
      ),
      '',
    );

    if (phone.isEmpty) {
      _showErrorMessage(
        'Customer phone number is unavailable.',
      );

      return;
    }

    final uri =
        Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!mounted) {
        return;
      }

      if (!launched) {
        _showErrorMessage(
          'Unable to open the phone application.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
          'Unable to call the Customer.',
        );
      }
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final provider =
        context.watch<OrderProvider>();

    final showLoading =
        _isProcessing ||
            _isRefreshing ||
            provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Order Details',
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh',
            onPressed:
                showLoading
                    ? null
                    : _loadLatestOrder,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh:
                _refreshAllProviderData,
            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  _buildStatusCard(
                    theme,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _sectionTitle(
                    'Customer Information',
                  ),

                  _buildCustomerCard(),

                  const SizedBox(
                    height: 16,
                  ),

                  _sectionTitle(
                    'Order Information',
                  ),

                  _infoCard(
                    children: [
                      _infoTile(
                        Icons
                            .receipt_long_outlined,
                        'Order ID',
                        _formatText(
                          order.id,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .confirmation_number_outlined,
                        'Booking Number',
                        _formatText(
                          order.bookingNumber,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .calendar_today_outlined,
                        'Order Date',
                        _formatText(
                          order.orderDate,
                        ),
                      ),
                      _infoTile(
                        Icons.event_outlined,
                        'Event Date',
                        _formatText(
                          order.eventDate,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .schedule_outlined,
                        'Time',
                        _formatText(
                          order.bookingTime,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .location_on_outlined,
                        'Location',
                        _formatText(
                          order
                              .effectiveAddress,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _sectionTitle(
                    'Service Information',
                  ),

                  _infoCard(
                    children: [
                      _infoTile(
                        Icons
                            .business_center_outlined,
                        'Service',
                        _formatText(
                          order.serviceName,
                          fallback:
                              'Service',
                        ),
                      ),
                      _infoTile(
                        Icons
                            .timer_outlined,
                        'Duration',
                        order
                            .formattedDuration,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _sectionTitle(
                    'Payment Information',
                  ),

                  _infoCard(
                    children: [
                      _infoTile(
                        Icons
                            .currency_rupee,
                        'Order Amount',
                        _formatAmount(
                          order.totalAmount,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .account_balance_wallet_outlined,
                        'Provider Amount',
                        _formatAmount(
                          order.netAmount,
                        ),
                      ),
                      _infoTile(
                        Icons
                            .payment_outlined,
                        'Payment Status',
                        _formatText(
                          order.paymentStatus,
                          fallback:
                              'Pending',
                        ),
                      ),
                      _infoTile(
                        Icons
                            .receipt_outlined,
                        'Transaction ID',
                        _formatText(
                          order.transactionId,
                        ),
                      ),
                    ],
                  ),

                  if (order.providerArrived) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    _buildArrivalCard(),
                  ],

                  const SizedBox(
                    height: 16,
                  ),

                  _sectionTitle(
                    'Notes',
                  ),

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child:
                          SizedBox(
                        width:
                            double.infinity,
                        child: Text(
                          _formatText(
                            order.notes,
                            fallback:
                                'No notes available',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _buildActionButtons(),

                  const SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
          ),

          if (showLoading)
            Positioned.fill(
              child:
                  IgnorePointer(
                child:
                    ColoredBox(
                  color:
                      Colors.black
                          .withValues(
                    alpha: 0.08,
                  ),
                  child:
                      const Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // STATUS CARD
  // =====================================================

  Widget _buildStatusCard(
    ThemeData theme,
  ) {
    final color =
        _statusColor();

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: SizedBox(
          width:
              double.infinity,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(
                    30,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(),
                      color:
                          Colors.white,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      _statusLabel(),
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _formatText(
                  order.serviceName,
                  fallback:
                      'Service Order',
                ),
                textAlign:
                    TextAlign.center,
                style:
                    theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                _statusDescription(),
                textAlign:
                    TextAlign.center,
                style:
                    theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                  color:
                      theme
                          .colorScheme
                          .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CUSTOMER CARD
  // =====================================================

  Widget _buildCustomerCard() {
    return _infoCard(
      children: [
        _infoTile(
          Icons.person_outline,
          'Customer Name',
          _formatText(
            order.customerName,
          ),
        ),

        if (order.canCallCustomer)
          _infoTile(
            Icons.phone_outlined,
            'Phone',
            _formatText(
              order.customerPhone,
            ),
          )
        else if (!order.isTerminal)
          const ListTile(
            dense: true,
            leading: Icon(
              Icons
                  .phone_locked_outlined,
            ),
            title: Text(
              'Customer Phone',
            ),
            subtitle: Text(
              'Phone number is available after booking acceptance.',
            ),
          ),

        _infoTile(
          Icons.email_outlined,
          'Email',
          _formatText(
            order.customerEmail,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ARRIVAL CARD
  // =====================================================

  Widget _buildArrivalCard() {
    return Card(
      color:
          Colors.teal.shade50,
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on,
              color:
                  Colors.teal,
              size: 32,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provider Arrival Recorded',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    order.providerArrivalVerified
                        ? 'Arrival location was verified.'
                        : 'Arrival was recorded.',
                  ),
                  if (order
                          .providerArrivalDistanceMeters !=
                      null)
                    Text(
                      'Distance from service location: '
                      '${order.providerArrivalDistanceMeters!.toStringAsFixed(0)} m',
                      style:
                          TextStyle(
                        color:
                            Colors.grey
                                .shade700,
                        fontSize: 12,
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

  // =====================================================
  // ACTION BUTTONS
  // =====================================================

  Widget _buildActionButtons() {
    final hasActions =
        order.canAccept ||
            order
                .canProviderMarkArrived ||
            order.canVerifyOtp ||
            order.canStart ||
            order.canComplete ||
            order.canOpenChat ||
            order
                .canViewChatHistory ||
            order.canCallCustomer ||
            order.canCancel;

    if (!hasActions) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        // =================================================
        // PENDING
        // =================================================

        if (order.canAccept)
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _confirmOrder,
            icon:
                const Icon(
              Icons
                  .check_circle_outline,
            ),
            label:
                const Text(
              'ACCEPT',
            ),
          ),

        // =================================================
        // ACCEPTED -> ARRIVED
        // =================================================

        if (order
            .canProviderMarkArrived) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _markProviderArrived,
            icon:
                const Icon(
              Icons.location_on,
            ),
            label:
                const Text(
              'I HAVE ARRIVED',
            ),
          ),
        ],

        // =================================================
        // ARRIVED -> VERIFY OTP
        // =================================================

        if (order.canVerifyOtp) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _showOtpDialog,
            icon:
                const Icon(
              Icons.password,
            ),
            label:
                const Text(
              'VERIFY OTP',
            ),
          ),
        ],

        // =================================================
        // OTP VERIFIED -> START
        // =================================================

        if (order.canStart) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _startOrder,
            icon:
                const Icon(
              Icons.play_arrow,
            ),
            label:
                const Text(
              'START SERVICE',
            ),
          ),
        ],

        // =================================================
        // IN PROGRESS -> COMPLETE
        // =================================================

        if (order.canComplete) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _completeOrder,
            icon:
                const Icon(
              Icons.done_all,
            ),
            label:
                const Text(
              'COMPLETE',
            ),
          ),
        ],

        // =================================================
        // BOOKING CHAT
        //
        // No OTP requirement.
        // =================================================

        if (order.canOpenChat) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _openChat,
            icon:
                const Icon(
              Icons
                  .chat_bubble_outline,
            ),
            label:
                const Text(
              'CHAT',
            ),
          ),
        ],

        // =================================================
        // PHONE
        // =================================================

        if (order.canCallCustomer) ...[
          const SizedBox(
            height: 12,
          ),
          ElevatedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _callCustomer,
            icon:
                const Icon(
              Icons.call,
            ),
            label:
                const Text(
              'CALL CUSTOMER',
            ),
          ),
        ],

        // =================================================
        // TERMINAL CHAT HISTORY
        //
        // Completed / Cancelled / Rejected:
        // messages remain visible but cannot be sent.
        // =================================================

        if (order
            .canViewChatHistory) ...[
          const SizedBox(
            height: 12,
          ),
          OutlinedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _openChat,
            icon:
                const Icon(
              Icons.history,
            ),
            label:
                const Text(
              'VIEW CHAT HISTORY',
            ),
          ),
        ],

        // =================================================
        // CANCEL
        // =================================================

        if (order.canCancel) ...[
          const SizedBox(
            height: 12,
          ),
          OutlinedButton.icon(
            onPressed:
                _isProcessing
                    ? null
                    : _cancelOrder,
            icon:
                const Icon(
              Icons
                  .cancel_outlined,
            ),
            label:
                const Text(
              'CANCEL BOOKING',
            ),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // =====================================================
  // INFO CARD
  // =====================================================

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Column(
          children:
              children,
        ),
      ),
    );
  }

  // =====================================================
  // INFO TILE
  // =====================================================

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      dense: true,
      leading:
          Icon(icon),
      title:
          Text(title),
      subtitle: Text(
        value.trim().isEmpty
            ? 'N/A'
            : value,
      ),
    );
  }
}