import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/route_config.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({
    super.key,
  });

  @override
  State<BookingDetailsScreen> createState() {
    return _BookingDetailsScreenState();
  }
}

class _BookingDetailsScreenState
    extends State<BookingDetailsScreen>
    with WidgetsBindingObserver {
  BookingModel? _initialBooking;

  Timer? _refreshTimer;

  bool _argumentsLoaded = false;
  bool _isRefreshing = false;
  bool _isCancelling = false;
  bool _isOtpLoading = false;
  bool _isInvoiceLoading = false;

  String? _serviceOtp;

  // =====================================================
  // LIFECYCLE
  // =====================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentsLoaded) {
      return;
    }

    _argumentsLoaded = true;

    final arguments =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    try {
      _initialBooking =
          _extractBookingFromArguments(
        arguments,
      );
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        'BOOKING DETAILS ARGUMENT ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      _initialBooking = null;
    }

    final booking =
        _initialBooking;

    if (booking == null ||
        booking.id.trim().isEmpty) {
      return;
    }

    context
        .read<BookingProvider>()
        .setSelectedBooking(
          booking,
        );

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {
        if (!mounted) {
          return;
        }

        await _refreshBooking(
          showIndicator: true,
        );

        if (!mounted) {
          return;
        }

        _startAutomaticRefresh();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state ==
        AppLifecycleState.resumed) {
      _refreshBooking(
        showIndicator: false,
      );

      _startAutomaticRefresh();
      return;
    }

    if (state ==
            AppLifecycleState.paused ||
        state ==
            AppLifecycleState.inactive ||
        state ==
            AppLifecycleState.detached) {
      _refreshTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _refreshTimer?.cancel();

    super.dispose();
  }

  // =====================================================
  // ARGUMENT PARSING
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, dynamic item) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  BookingModel? _extractBookingFromArguments(
    dynamic arguments,
  ) {
    if (arguments is BookingModel) {
      return arguments;
    }

    if (arguments is! Map) {
      return null;
    }

    final argumentMap =
        _asMap(arguments);

    final dynamic nestedPayload =
        argumentMap['booking'] ??
        argumentMap['data'] ??
        argumentMap['bookingData'] ??
        argumentMap['order'];

    if (nestedPayload is BookingModel) {
      return nestedPayload;
    }

    if (nestedPayload is Map) {
      return BookingModel.fromMap(
        _asMap(
          nestedPayload,
        ),
      );
    }

    final hasBookingFields =
        argumentMap.containsKey('_id') ||
        argumentMap.containsKey('id') ||
        argumentMap.containsKey(
          'bookingId',
        ) ||
        argumentMap.containsKey(
          'bookingNumber',
        );

    if (hasBookingFields) {
      return BookingModel.fromMap(
        argumentMap,
      );
    }

    return null;
  }

  // =====================================================
  // BOOKING RESOLUTION
  // =====================================================

  BookingModel? _currentBooking(
    BookingProvider provider,
  ) {
    final bookingId =
        _initialBooking?.id.trim() ?? '';

    final selected =
        provider.selectedBooking;

    if (selected != null &&
        bookingId.isNotEmpty &&
        selected.id == bookingId) {
      return selected;
    }

    if (bookingId.isNotEmpty) {
      for (
        final booking
        in provider.myBookings
      ) {
        if (booking.id == bookingId) {
          return booking;
        }
      }
    }

    return _initialBooking;
  }

  // =====================================================
  // AUTOMATIC REFRESH
  // =====================================================

  void _startAutomaticRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(
        seconds: 8,
      ),
      (_) {
        if (!mounted ||
            _isRefreshing) {
          return;
        }

        _refreshBooking(
          showIndicator: false,
        );
      },
    );
  }

  Future<void> _refreshBooking({
    required bool showIndicator,
  }) async {
    if (!mounted ||
        _isRefreshing) {
      return;
    }

    final bookingId =
        _initialBooking?.id.trim() ?? '';

    if (bookingId.isEmpty) {
      return;
    }

    if (showIndicator) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      _isRefreshing = true;
    }

    try {
      await context
          .read<BookingProvider>()
          .getBookingById(
            bookingId,
          );

      if (!mounted) {
        return;
      }

      final updatedBooking =
          context
              .read<BookingProvider>()
              .selectedBooking;

      if (updatedBooking != null &&
          updatedBooking.id ==
              bookingId) {
        _initialBooking =
            updatedBooking;
      }

      if (updatedBooking != null &&
          updatedBooking.isAccepted &&
          !updatedBooking.otpVerified &&
          _serviceOtp == null) {
        await _loadOtpSilently(
          updatedBooking,
        );
      }

      if (updatedBooking != null &&
          updatedBooking.otpVerified &&
          _serviceOtp != null) {
        setState(() {
          _serviceOtp = null;
        });
      }
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        'BOOKING REFRESH ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      } else {
        _isRefreshing = false;
      }
    }
  }

  Future<void> _loadOtpSilently(
    BookingModel booking,
  ) async {
    if (!booking.shouldFetchServiceOtp ||
        _isOtpLoading ||
        !mounted) {
      return;
    }

    _isOtpLoading = true;

    try {
      final otp = await context
          .read<BookingProvider>()
          .getServiceOtp(
            booking.id,
          );

      if (!mounted) {
        return;
      }

      if (otp != null &&
          otp.trim().isNotEmpty) {
        setState(() {
          _serviceOtp =
              otp.trim();
        });
      }
    } catch (error) {
      debugPrint(
        'SILENT OTP LOAD ERROR: $error',
      );
    } finally {
      _isOtpLoading = false;
    }
  }

  // =====================================================
  // FORMATTING
  // =====================================================

  String _formatDate(
    DateTime date,
  ) {
    final localDate =
        date.toLocal();

    final day = localDate.day
        .toString()
        .padLeft(
          2,
          '0',
        );

    final month = localDate.month
        .toString()
        .padLeft(
          2,
          '0',
        );

    return '$day-$month-${localDate.year}';
  }

  String _formatDateTime(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Not available';
    }

    final localDate =
        date.toLocal();

    final day = localDate.day
        .toString()
        .padLeft(
          2,
          '0',
        );

    final month = localDate.month
        .toString()
        .padLeft(
          2,
          '0',
        );

    final hour = localDate.hour
        .toString()
        .padLeft(
          2,
          '0',
        );

    final minute = localDate.minute
        .toString()
        .padLeft(
          2,
          '0',
        );

    return '$day-$month-${localDate.year} '
        '$hour:$minute';
  }

  String _formatAmount(
    double amount,
  ) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDuration(
    int minutes,
  ) {
    if (minutes <= 0) {
      return 'Not available';
    }

    final hours =
        minutes ~/ 60;

    final remainingMinutes =
        minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes minutes';
    }

    if (remainingMinutes == 0) {
      return hours == 1
          ? '1 hour'
          : '$hours hours';
    }

    return '$hours hr '
        '$remainingMinutes min';
  }

  String _textOrFallback(
    String? value, {
    String fallback = 'Not available',
  }) {
    final text =
        value?.trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  // =====================================================
  // STATUS PRESENTATION
  // =====================================================

  String _statusLabel(
    BookingModel booking,
  ) {
    return booking.statusText
        .toUpperCase();
  }

  String _statusDescription(
    BookingModel booking,
  ) {
    return booking.statusDescription;
  }

  Color _statusColor(
    BookingModel booking,
  ) {
    if (booking.isAccepted) {
      return booking.providerArrived
          ? Colors.teal
          : Colors.blue;
    }

    if (booking.isOtpVerified) {
      return Colors.deepPurple;
    }

    if (booking.isInProgress) {
      return Colors.orange;
    }

    if (booking.isCompleted) {
      return Colors.green;
    }

    if (booking.isCancelled) {
      return Colors.red;
    }

    if (booking.isRejected) {
      return Colors.redAccent;
    }

    return Colors.amber.shade800;
  }

  IconData _statusIcon(
    BookingModel booking,
  ) {
    if (booking.isAccepted &&
        booking.providerArrived) {
      return Icons.location_on_outlined;
    }

    if (booking.isAccepted) {
      return Icons.check_circle_outline;
    }

    if (booking.isOtpVerified) {
      return Icons.verified_outlined;
    }

    if (booking.isInProgress) {
      return Icons.play_circle_outline;
    }

    if (booking.isCompleted) {
      return Icons.task_alt;
    }

    if (booking.isCancelled) {
      return Icons.cancel_outlined;
    }

    if (booking.isRejected) {
      return Icons.block_outlined;
    }

    return Icons.schedule;
  }

  // =====================================================
  // MESSAGES
  // =====================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
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
              isError
              ? Colors.red
              : Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // OTP
  // =====================================================

  Future<void> _showServiceOtp(
    BookingModel booking,
  ) async {
    if (_isOtpLoading) {
      return;
    }

    if (!booking.isAccepted) {
      _showMessage(
        'The service OTP becomes available '
        'after the Provider accepts the booking.',
        isError: true,
      );

      return;
    }

    if (booking.otpVerified) {
      _showMessage(
        'The service OTP has already been verified.',
      );

      return;
    }

    setState(() {
      _isOtpLoading = true;
    });

    try {
      String? otp =
          _serviceOtp;

      if (otp == null ||
          otp.trim().isEmpty) {
        otp = await context
            .read<BookingProvider>()
            .getServiceOtp(
              booking.id,
            );
      }

      if (!mounted) {
        return;
      }

      if (otp == null ||
          otp.trim().isEmpty) {
        _showMessage(
          context
                  .read<BookingProvider>()
                  .error ??
              'Service OTP is not available.',
          isError: true,
        );

        return;
      }

      final normalizedOtp =
          otp.trim();

      setState(() {
        _serviceOtp =
            normalizedOtp;
      });

      await showDialog<void>(
        context: context,
        builder: (
          dialogContext,
        ) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.password,
                  color:
                      Colors.deepPurple,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Service OTP',
                ),
              ],
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  booking.providerArrived
                      ? 'The Provider has arrived. '
                          'Confirm the Provider identity '
                          'before sharing this OTP.'
                      : 'Do not share this OTP until '
                          'the Provider arrives at your location.',
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .deepPurple
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color: Colors
                          .deepPurple
                          .withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Text(
                    normalizedOtp,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 12,
                      color:
                          Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'This OTP remains valid until '
                  'the assigned Provider verifies it.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'Close',
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      _showMessage(
        error.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOtpLoading =
              false;
        });
      }
    }
  }

  // =====================================================
  // CALL
  // =====================================================

  Future<void> _callProvider(
    BookingModel booking,
  ) async {
    final phoneNumber =
        booking.providerPhone.replaceAll(
      RegExp(
        r'[^0-9+]',
      ),
      '',
    );

    if (phoneNumber.isEmpty) {
      _showMessage(
        'Provider phone number is unavailable.',
        isError: true,
      );

      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      final launched =
          await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open the phone application.',
          isError: true,
        );
      }
    } catch (_) {
      _showMessage(
        'Unable to open the phone application.',
        isError: true,
      );
    }
  }

  // =====================================================
  // MAPS
  // =====================================================

  Future<void> _openMaps(
    BookingModel booking,
  ) async {
    Uri? mapsUri;

    if (booking.hasLocation) {
      mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/'
        '?api=1'
        '&destination='
        '${booking.latitude},'
        '${booking.longitude}',
      );
    } else if (
      booking.address
          .trim()
          .isNotEmpty
    ) {
      final encodedAddress =
          Uri.encodeComponent(
        booking.address.trim(),
      );

      mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/'
        '?api=1'
        '&destination=$encodedAddress',
      );
    }

    if (mapsUri == null) {
      _showMessage(
        'Service location is unavailable.',
        isError: true,
      );

      return;
    }

    try {
      final launched =
          await launchUrl(
        mapsUri,
        mode: LaunchMode
            .externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open maps.',
          isError: true,
        );
      }
    } catch (_) {
      _showMessage(
        'Unable to open maps.',
        isError: true,
      );
    }
  }

  // =====================================================
  // CHAT
  // =====================================================

  void _openChat(
    BookingModel booking,
  ) {
    if (booking.providerId
            .trim()
            .isEmpty ||
        booking.id
            .trim()
            .isEmpty) {
      _showMessage(
        'Chat details are unavailable.',
        isError: true,
      );

      return;
    }

    final roomId =
        booking.effectiveChatRoomId;

    Navigator.pushNamed(
      context,
      RouteConfig.chat,
      arguments: {
        'bookingId':
            booking.id,
        'roomId':
            roomId,
        'chatRoomId':
            roomId,
        'receiverId':
            booking.providerId,
        'providerId':
            booking.providerId,
        'receiverName':
            booking.displayProviderName,
        'providerName':
            booking.displayProviderName,
        'userName':
            booking.displayProviderName,
      },
    );
  }

  // =====================================================
  // INVOICE
  // =====================================================

  Future<void> _showInvoice(
    BookingModel booking,
  ) async {
    if (_isInvoiceLoading) {
      return;
    }

    setState(() {
      _isInvoiceLoading =
          true;
    });

    try {
      final invoice = await context
          .read<BookingProvider>()
          .getInvoice(
            booking.id,
          );

      if (!mounted) {
        return;
      }

      if (invoice == null ||
          invoice.isEmpty) {
        _showMessage(
          context
                  .read<BookingProvider>()
                  .error ??
              'Invoice is unavailable.',
          isError: true,
        );

        return;
      }

      final invoiceNumber =
          invoice['invoiceNumber']
                  ?.toString() ??
              booking.invoiceNumber ??
              'Not available';

      final duration =
          int.tryParse(
            invoice['durationMinutes']
                    ?.toString() ??
                '',
          ) ??
          booking.durationMinutes;

      final totalAmount =
          double.tryParse(
            invoice['totalAmount']
                    ?.toString() ??
                '',
          ) ??
          booking.totalAmount;

      final subtotal =
          double.tryParse(
            invoice['subtotal']
                    ?.toString() ??
                '',
          ) ??
          booking.amount;

      final platformFee =
          double.tryParse(
            invoice['platformFee']
                    ?.toString() ??
                '',
          ) ??
          booking.serviceFee;

      final taxAmount =
          double.tryParse(
            invoice['taxAmount']
                    ?.toString() ??
                '',
          ) ??
          booking.gst;

      final discountAmount =
          double.tryParse(
            invoice['discountAmount']
                    ?.toString() ??
                '',
          ) ??
          booking.discount;

      await showDialog<void>(
        context: context,
        builder: (
          dialogContext,
        ) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.receipt_long,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Booking Invoice',
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child:
                  SingleChildScrollView(
                child: Column(
                  children: [
                    _dialogInfoRow(
                      'Invoice Number',
                      invoiceNumber,
                    ),
                    _dialogInfoRow(
                      'Booking Number',
                      booking
                          .displayBookingNumber,
                    ),
                    _dialogInfoRow(
                      'Service',
                      booking
                          .displayServiceName,
                    ),
                    _dialogInfoRow(
                      'Provider',
                      booking
                          .displayProviderName,
                    ),
                    _dialogInfoRow(
                      'Started',
                      _formatDateTime(
                        booking.startedAt,
                      ),
                    ),
                    _dialogInfoRow(
                      'Completed',
                      _formatDateTime(
                        booking.completedAt,
                      ),
                    ),
                    _dialogInfoRow(
                      'Duration',
                      _formatDuration(
                        duration,
                      ),
                    ),
                    const Divider(),
                    _dialogInfoRow(
                      'Subtotal',
                      _formatAmount(
                        subtotal,
                      ),
                    ),
                    _dialogInfoRow(
                      'Platform Fee',
                      _formatAmount(
                        platformFee,
                      ),
                    ),
                    _dialogInfoRow(
                      'Tax',
                      _formatAmount(
                        taxAmount,
                      ),
                    ),
                    _dialogInfoRow(
                      'Discount',
                      '-${_formatAmount(discountAmount)}',
                    ),
                    const Divider(),
                    _dialogInfoRow(
                      'Total',
                      _formatAmount(
                        totalAmount,
                      ),
                      isTotal: true,
                    ),
                    _dialogInfoRow(
                      'Payment Status',
                      booking
                          .paymentStatus
                          .toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'Close',
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      _showMessage(
        error.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInvoiceLoading =
              false;
        });
      }
    }
  }

  // =====================================================
  // CANCEL BOOKING
  // =====================================================

  Future<void> _cancelBooking(
    BookingModel booking,
  ) async {
    if (_isCancelling) {
      return;
    }

    final controller =
        TextEditingController();

    String? validationMessage;

    final reason =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Cancel Booking',
              ),
              content: TextField(
                controller:
                    controller,
                maxLines: 4,
                maxLength: 500,
                decoration:
                    InputDecoration(
                  hintText:
                      'Enter cancellation reason',
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
                    final value =
                        controller.text
                            .trim();

                    if (value.isEmpty) {
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
                      value,
                    );
                  },
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        Colors.red,
                    foregroundColor:
                        Colors.white,
                  ),
                  child: const Text(
                    'Cancel Booking',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (reason == null ||
        reason.trim().isEmpty ||
        !mounted) {
      return;
    }

    setState(() {
      _isCancelling =
          true;
    });

    try {
      final success = await context
          .read<BookingProvider>()
          .cancelBooking(
            bookingId:
                booking.id,
            reason:
                reason.trim(),
          );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showMessage(
          context
                  .read<BookingProvider>()
                  .error ??
              'Unable to cancel the booking.',
          isError: true,
        );

        return;
      }

      _serviceOtp = null;

      await _refreshBooking(
        showIndicator: false,
      );

      _showMessage(
        'Booking cancelled successfully.',
      );
    } catch (error) {
      _showMessage(
        error.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling =
              false;
        });
      }
    }
  }

  // =====================================================
  // REBOOK
  // =====================================================

  void _rebook(
    BookingModel booking,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.booking,
      arguments: {
        'serviceId':
            booking.serviceId,
        'serviceName':
            booking.serviceName,
        'providerId':
            booking.providerId,
      },
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<BookingProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final booking =
            _currentBooking(
          provider,
        );

        if (booking == null) {
          return Scaffold(
            backgroundColor:
                const Color(
              0xFFF8F9FC,
            ),
            appBar: AppBar(
              title: const Text(
                'Booking Details',
              ),
            ),
            body: const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(
                  24,
                ),
                child: Text(
                  'Booking information is unavailable.',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            ),
          );
        }

        final isBusy =
            _isRefreshing ||
            _isCancelling ||
            _isOtpLoading ||
            _isInvoiceLoading;

        return Scaffold(
          backgroundColor:
              const Color(
            0xFFF8F9FC,
          ),
          appBar: AppBar(
            title: const Text(
              'Booking Details',
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: isBusy
                    ? null
                    : () {
                        _refreshBooking(
                          showIndicator:
                              true,
                        );
                      },
                icon: const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  return _refreshBooking(
                    showIndicator:
                        false,
                  );
                },
                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    130,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      _buildStatusCard(
                        booking,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildServiceCard(
                        booking,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildProviderCard(
                        booking,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildBookingInformationCard(
                        booking,
                      ),
                      if (booking
                          .canDisplayServiceOtp) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildOtpCard(
                          booking,
                        ),
                      ],
                      if (booking
                          .isOtpVerified) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildOtpVerifiedCard(
                          booking,
                        ),
                      ],
                      if (booking
                          .isRejected) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildTerminalReasonCard(
                          title:
                              'Booking Rejected',
                          reason:
                              booking
                                  .rejectionReason,
                          icon:
                              Icons.block,
                        ),
                      ],
                      if (booking
                          .isCancelled) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildTerminalReasonCard(
                          title:
                              'Booking Cancelled',
                          reason:
                              booking
                                  .cancellationReason,
                          icon:
                              Icons.cancel,
                        ),
                      ],
                      const SizedBox(
                        height: 16,
                      ),
                      _buildTimelineCard(
                        booking,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildPaymentCard(
                        booking,
                      ),
                      if (booking.notes
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildNotesCard(
                          booking,
                        ),
                      ],
                      if (booking
                          .canViewInvoice) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildInvoiceCard(
                          booking,
                        ),
                      ],
                      if (booking
                          .canCustomerCancel) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _isCancelling
                              ? null
                              : () {
                                  _cancelBooking(
                                    booking,
                                  );
                                },
                          icon: const Icon(
                            Icons
                                .cancel_outlined,
                          ),
                          label: Text(
                            _isCancelling
                                ? 'CANCELLING'
                                : 'CANCEL BOOKING',
                          ),
                          style: OutlinedButton
                              .styleFrom(
                            foregroundColor:
                                Colors.red,
                            minimumSize:
                                const Size(
                              double.infinity,
                              50,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isBusy)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Colors.black
                          .withValues(
                        alpha: 0.06,
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
          bottomNavigationBar:
              _buildBottomActions(
            booking,
          ),
        );
      },
    );
  }

  // =====================================================
  // STATUS CARD
  // =====================================================

  Widget _buildStatusCard(
    BookingModel booking,
  ) {
    final color =
        _statusColor(
      booking,
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    color.withValues(
                  alpha: 0.12,
                ),
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
                    _statusIcon(
                      booking,
                    ),
                    size: 19,
                    color: color,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _statusLabel(
                      booking,
                    ),
                    style:
                        TextStyle(
                      color: color,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              booking
                  .displayBookingNumber,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _statusDescription(
                booking,
              ),
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors
                    .grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SERVICE CARD
  // =====================================================

  Widget _buildServiceCard(
    BookingModel booking,
  ) {
    return _sectionCard(
      title: 'Service Details',
      child: ListTile(
        contentPadding:
            EdgeInsets.zero,
        leading: Container(
          width: 58,
          height: 58,
          decoration:
              BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            Icons.business_center,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
        title: Text(
          booking
              .displayServiceName,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          booking
              .displayProviderName,
        ),
      ),
    );
  }

  // =====================================================
  // PROVIDER CARD
  // =====================================================

  Widget _buildProviderCard(
    BookingModel booking,
  ) {
    final canContactProvider =
        booking.isAccepted ||
        booking.isOtpVerified ||
        booking.isInProgress;

    return _sectionCard(
      title: 'Service Provider',
      child: Column(
        children: [
          ListTile(
            contentPadding:
                EdgeInsets.zero,
            leading:
                const CircleAvatar(
              child: Icon(
                Icons.person,
              ),
            ),
            title: Text(
              booking
                  .displayProviderName,
            ),
            subtitle: Text(
              canContactProvider
                  ? _textOrFallback(
                      booking
                          .providerPhone,
                    )
                  : 'Contact details available after acceptance',
            ),
          ),
          if (booking
              .providerArrived)
            Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color: Colors
                    .teal.shade50,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                border:
                    Border.all(
                  color: Colors
                      .teal.shade200,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .location_on,
                    color:
                        Colors.teal,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      booking
                              .providerArrivalVerified
                          ? 'Provider arrival location verified.'
                          : 'Provider reported arrival at your location.',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (canContactProvider)
            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _callProvider(
                        booking,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .call_outlined,
                    ),
                    label:
                        const Text(
                      'Call',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _openMaps(
                        booking,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .map_outlined,
                    ),
                    label:
                        const Text(
                      'Maps',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      _openChat(
                        booking,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .chat_outlined,
                    ),
                    label:
                        const Text(
                      'Chat',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =====================================================
  // BOOKING INFORMATION
  // =====================================================

  Widget _buildBookingInformationCard(
    BookingModel booking,
  ) {
    return _sectionCard(
      title: 'Booking Information',
      child: Column(
        children: [
          _infoRow(
            'Booking Date',
            _formatDate(
              booking.bookingDate,
            ),
          ),
          _infoRow(
            'Time Slot',
            _textOrFallback(
              booking.bookingTime,
            ),
          ),
          _infoRow(
            'Location',
            _textOrFallback(
              booking.address,
              fallback:
                  booking.location,
            ),
          ),
          if (booking.landmark
              .trim()
              .isNotEmpty)
            _infoRow(
              'Landmark',
              booking.landmark,
            ),
          _infoRow(
            'Created',
            _formatDateTime(
              booking.createdAt,
            ),
          ),
          if (booking.acceptedAt !=
              null)
            _infoRow(
              'Accepted',
              _formatDateTime(
                booking.acceptedAt,
              ),
            ),
          if (booking
                  .providerArrivedAt !=
              null)
            _infoRow(
              'Provider Arrived',
              _formatDateTime(
                booking
                    .providerArrivedAt,
              ),
            ),
          if (booking.otpVerifiedAt !=
              null)
            _infoRow(
              'OTP Verified',
              _formatDateTime(
                booking
                    .otpVerifiedAt,
              ),
            ),
          if (booking.startedAt !=
              null)
            _infoRow(
              'Started',
              _formatDateTime(
                booking.startedAt,
              ),
            ),
          if (booking.completedAt !=
              null)
            _infoRow(
              'Completed',
              _formatDateTime(
                booking.completedAt,
              ),
            ),
          if (booking.durationMinutes >
              0)
            _infoRow(
              'Service Duration',
              _formatDuration(
                booking
                    .durationMinutes,
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // OTP CARD
  // =====================================================

  Widget _buildOtpCard(
    BookingModel booking,
  ) {
    return Card(
      color: Colors.deepPurple
          .withValues(
        alpha: 0.05,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.password,
              size: 34,
              color:
                  Colors.deepPurple,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Service Verification OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              booking.providerArrived
                  ? 'The Provider has arrived. '
                      'Confirm the Provider identity '
                      'before sharing the OTP.'
                  : 'The OTP is available, but do not '
                      'share it until the Provider arrives.',
              textAlign:
                  TextAlign.center,
            ),
            if (_serviceOtp !=
                null) ...[
              const SizedBox(
                height: 16,
              ),
              Text(
                _serviceOtp!,
                style:
                    const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 10,
                  color:
                      Colors.deepPurple,
                ),
              ),
            ],
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed:
                  _isOtpLoading
                  ? null
                  : () {
                      _showServiceOtp(
                        booking,
                      );
                    },
              icon: const Icon(
                Icons.visibility,
              ),
              label: Text(
                _isOtpLoading
                    ? 'LOADING OTP'
                    : 'SHOW SERVICE OTP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpVerifiedCard(
    BookingModel booking,
  ) {
    return Card(
      color:
          Colors.green.shade50,
      child: ListTile(
        leading: const Icon(
          Icons.verified,
          color: Colors.green,
          size: 34,
        ),
        title: const Text(
          'Service OTP Verified',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          booking.isInProgress
              ? 'The service is now in progress.'
              : 'Waiting for the Provider to start the service.',
        ),
      ),
    );
  }

  Widget _buildTerminalReasonCard({
    required String title,
    required String reason,
    required IconData icon,
  }) {
    return Card(
      color:
          Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.red,
          size: 32,
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            color: Colors.red,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          reason.trim().isEmpty
              ? 'No reason was provided.'
              : reason.trim(),
        ),
      ),
    );
  }

  // =====================================================
  // TIMELINE
  // =====================================================

  Widget _buildTimelineCard(
    BookingModel booking,
  ) {
    return _sectionCard(
      title: 'Booking Timeline',
      child: Column(
        children: [
          _timelineItem(
            title:
                'Booking Created',
            completed: true,
            subtitle:
                _formatDateTime(
              booking.createdAt,
            ),
            isLast: false,
          ),
          _timelineItem(
            title:
                'Provider Accepted',
            completed:
                booking.isAccepted ||
                booking.isOtpVerified ||
                booking.isInProgress ||
                booking.isCompleted,
            subtitle:
                _formatDateTime(
              booking.acceptedAt,
            ),
            isLast: false,
          ),
          _timelineItem(
            title:
                'Provider Arrived',
            completed:
                booking.providerArrived,
            subtitle:
                _formatDateTime(
              booking
                  .providerArrivedAt,
            ),
            isLast: false,
          ),
          _timelineItem(
            title:
                'OTP Verified',
            completed:
                booking.isOtpVerified,
            subtitle:
                _formatDateTime(
              booking.otpVerifiedAt,
            ),
            isLast: false,
          ),
          _timelineItem(
            title:
                'Service Started',
            completed:
                booking.isInProgress ||
                booking.isCompleted,
            subtitle:
                _formatDateTime(
              booking.startedAt,
            ),
            isLast: false,
          ),
          _timelineItem(
            title:
                'Service Completed',
            completed:
                booking.isCompleted,
            subtitle:
                _formatDateTime(
              booking.completedAt,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PAYMENT
  // =====================================================

  Widget _buildPaymentCard(
    BookingModel booking,
  ) {
    final calculatedSubtotal =
        booking.totalAmount -
        booking.serviceFee -
        booking.gst +
        booking.discount;

    final subtotal =
        calculatedSubtotal >= 0
        ? calculatedSubtotal
        : booking.amount;

    return _sectionCard(
      title: 'Payment Summary',
      child: Column(
        children: [
          _infoRow(
            'Service Amount',
            _formatAmount(
              subtotal,
            ),
          ),
          _infoRow(
            'Platform Fee',
            _formatAmount(
              booking.serviceFee,
            ),
          ),
          _infoRow(
            'Tax',
            _formatAmount(
              booking.gst,
            ),
          ),
          if (booking.discount >
              0)
            _infoRow(
              'Discount',
              '-${_formatAmount(booking.discount)}',
              valueColor:
                  Colors.green,
            ),
          const Divider(),
          _infoRow(
            'Total',
            _formatAmount(
              booking.totalAmount,
            ),
            isTotal: true,
          ),
          _infoRow(
            'Payment Method',
            booking.paymentMethod,
          ),
          _infoRow(
            'Payment Status',
            booking.paymentStatus
                .toUpperCase(),
            valueColor:
                booking.isPaid
                ? Colors.green
                : Colors.orange,
          ),
          if (booking.paymentId !=
                  null &&
              booking.paymentId!
                  .trim()
                  .isNotEmpty)
            _infoRow(
              'Payment ID',
              booking.paymentId!,
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(
    BookingModel booking,
  ) {
    return _sectionCard(
      title: 'Notes',
      child: Align(
        alignment:
            Alignment.centerLeft,
        child: Text(
          booking.notes,
        ),
      ),
    );
  }

  // =====================================================
  // INVOICE CARD
  // =====================================================

  Widget _buildInvoiceCard(
    BookingModel booking,
  ) {
    return Card(
      color:
          Colors.green.shade50,
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 34,
              color: Colors.green,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Invoice Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              _textOrFallback(
                booking.invoiceNumber,
                fallback:
                    'View completed booking invoice',
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            ElevatedButton.icon(
              onPressed:
                  _isInvoiceLoading
                  ? null
                  : () {
                      _showInvoice(
                        booking,
                      );
                    },
              icon: const Icon(
                Icons.receipt_long,
              ),
              label: Text(
                _isInvoiceLoading
                    ? 'LOADING INVOICE'
                    : 'VIEW INVOICE',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BOTTOM ACTIONS
  // =====================================================

  Widget _buildBottomActions(
    BookingModel booking,
  ) {
    final canContactProvider =
        booking.isAccepted ||
        booking.isOtpVerified ||
        booking.isInProgress;

    if (canContactProvider) {
      return SafeArea(
        child: Container(
          padding:
              const EdgeInsets.all(
            14,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.08,
                ),
                blurRadius: 10,
                offset:
                    const Offset(
                  0,
                  -2,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    _callProvider(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.call,
                  ),
                  label:
                      const Text(
                    'Call',
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    _openMaps(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.map,
                  ),
                  label:
                      const Text(
                    'Maps',
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    _openChat(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.chat,
                  ),
                  label:
                      const Text(
                    'Chat',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (booking.isCompleted) {
      return SafeArea(
        child: Container(
          padding:
              const EdgeInsets.all(
            14,
          ),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    _showInvoice(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.receipt_long,
                  ),
                  label:
                      const Text(
                    'Invoice',
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    _rebook(
                      booking,
                    );
                  },
                  icon: const Icon(
                    Icons.replay,
                  ),
                  label:
                      const Text(
                    'Rebook',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // =====================================================
  // REUSABLE WIDGETS
  // =====================================================

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  TextStyle(
                color: Colors
                    .grey.shade700,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                fontWeight: isTotal
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: isTotal
                    ? 17
                    : 14,
                color: valueColor ??
                    (
                      isTotal
                          ? Colors.green
                          : Colors.black87
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Text(title),
          ),
          const SizedBox(
            width: 14,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                fontWeight: isTotal
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: isTotal
                    ? Colors.green
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required bool completed,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : Icons
                      .radio_button_unchecked,
              color: completed
                  ? Colors.green
                  : Colors.grey,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: completed
                    ? Colors.green
                        .withValues(
                      alpha: 0.4,
                    )
                    : Colors
                        .grey.shade300,
              ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 1,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    fontWeight:
                        completed
                        ? FontWeight
                            .w600
                        : FontWeight
                            .normal,
                    color: completed
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
                if (completed &&
                    subtitle !=
                        'Not available')
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 3,
                    ),
                    child: Text(
                      subtitle,
                      style:
                          TextStyle(
                        fontSize: 12,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}