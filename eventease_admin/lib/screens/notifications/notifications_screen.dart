import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/search_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedType;
  String? _selectedStatus;
  String? _selectedChannel;

  final List<String> _notificationTypes = const [
    'booking',
    'payment',
    'order',
    'coupon',
    'system',
    'promotion',
    'kyc',
    'settlement',
  ];

  final List<String> _notificationStatuses = const [
    'pending',
    'sent',
    'failed',
    'scheduled',
    'read',
    'unread',
  ];

  final List<String> _notificationChannels = const [
    'push',
    'email',
    'sms',
    'whatsapp',
    'in_app',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    await context.read<NotificationProvider>().getNotifications(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          type: _selectedType,
          status: _selectedStatus,
          channel: _selectedChannel,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchNotifications();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchNotifications();
      },
    );
  }

  void _onTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedType = value;
    });

    _fetchNotifications();
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchNotifications();
  }

  void _onChannelChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedChannel = value;
    });

    _fetchNotifications();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedType = null;
      _selectedStatus = null;
      _selectedChannel = null;
      _searchController.clear();
    });

    _fetchNotifications();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchNotifications();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchNotifications();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchNotifications();
  }

  Future<void> _createNotification() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.addNotification,
    );

    if (!mounted) return;

    _fetchNotifications();
  }

  Future<void> _viewNotification(NotificationModel notification) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Notification Details',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _DetailRow(
                    label: 'Notification ID',
                    value: notification.id,
                  ),
                  _DetailRow(
                    label: 'Title',
                    value: notification.title,
                  ),
                  _DetailRow(
                    label: 'Message',
                    value: notification.message,
                  ),
                  _DetailRow(
                    label: 'Type',
                    value: AppFormatters.formatStatus(notification.type),
                  ),
                  _DetailRow(
                    label: 'Channel',
                    value: AppFormatters.formatStatus(notification.channel),
                  ),
                  _DetailRow(
                    label: 'Recipient Type',
                    value: AppFormatters.formatStatus(
                      notification.recipientType,
                    ),
                  ),
                  _DetailRow(
                    label: 'Recipient',
                    value: notification.recipientName.trim().isEmpty
                        ? 'All Users'
                        : notification.recipientName,
                  ),
                  _DetailRow(
                    label: 'Created Date',
                    value: _formatDate(notification.createdAt),
                  ),
                  _DetailRow(
                    label: 'Scheduled Date',
                    value: _formatDate(notification.scheduledAt),
                  ),
                  _DetailRow(
                    label: 'Sent Date',
                    value: _formatDate(notification.sentAt),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _NotificationTypeBadge(
                        type: notification.type,
                      ),
                      _NotificationStatusBadge(
                        status: notification.status,
                      ),
                      _ReadStatusBadge(
                        isRead: notification.isRead,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    final bool success = await context
        .read<NotificationProvider>()
        .markNotificationAsRead(notification.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Notification marked as read',
      errorMessage: 'Failed to mark notification as read',
    );
  }

  Future<void> _resendNotification(NotificationModel notification) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Resend Notification',
      message: 'Are you sure you want to resend "${notification.title}"?',
      confirmText: 'Resend',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<NotificationProvider>()
        .resendNotification(notification.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Notification resent successfully',
      errorMessage: 'Failed to resend notification',
    );
  }

  Future<void> _sendNow(NotificationModel notification) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Send Notification Now',
      message: 'Do you want to send "${notification.title}" immediately?',
      confirmText: 'Send Now',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<NotificationProvider>().sendNotificationNow(
              notification.id,
            );

    _handleMutationResult(
      success: success,
      successMessage: 'Notification sent successfully',
      errorMessage: 'Failed to send notification',
    );
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Notification',
      message:
          'This action cannot be undone. Are you sure you want to delete "${notification.title}"?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<NotificationProvider>()
        .deleteNotification(notification.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Notification deleted successfully',
      errorMessage: 'Failed to delete notification',
    );
  }

  Future<void> _exportNotifications() async {
    await context.read<NotificationProvider>().exportNotifications();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Notifications export started successfully',
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

    if (success) {
      NavigationService.showSuccess(successMessage);
      _fetchNotifications();
      return;
    }

    NavigationService.showError(
      context.read<NotificationProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(NotificationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Notifications',
          subtitle:
              'Manage customer, provider, payment, booking, promotional and system notifications.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportNotifications,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.outline,
              icon: Icons.refresh,
              onPressed: _refresh,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Create Notification',
              icon: Icons.add,
              onPressed: _createNotification,
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
                _NotificationSummaryCard(
                  title: 'Total',
                  value: provider.totalNotifications.toString(),
                  icon: Icons.notifications_outlined,
                  color: AppColors.primary,
                ),
                _NotificationSummaryCard(
                  title: 'Sent',
                  value: provider.sentNotifications.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _NotificationSummaryCard(
                  title: 'Pending',
                  value: provider.pendingNotifications.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _NotificationSummaryCard(
                  title: 'Failed',
                  value: provider.failedNotifications.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
                _NotificationSummaryCard(
                  title: 'Scheduled',
                  value: provider.scheduledNotifications.toString(),
                  icon: Icons.schedule_outlined,
                  color: AppColors.info,
                ),
                _NotificationSummaryCard(
                  title: 'Unread',
                  value: provider.unreadNotifications.toString(),
                  icon: Icons.mark_email_unread_outlined,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search notification title, message, recipient...',
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
                    _buildTypeDropdown(),
                    const SizedBox(height: 14),
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildChannelDropdown(),
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
                  Expanded(child: _buildTypeDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildChannelDropdown()),
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

  Widget _buildTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Notification Type',
      value: _selectedType,
      items: _notificationTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onTypeChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _notificationStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildChannelDropdown() {
    return CustomDropdown<String>(
      labelText: 'Channel',
      value: _selectedChannel,
      items: _notificationChannels,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onChannelChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
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
                  _buildFilters(),
                  if (provider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.25),
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
                  NotificationsTable(
                    notifications: provider.notifications,
                    isLoading: provider.isLoading,
                    onView: _viewNotification,
                    onMarkRead: _markAsRead,
                    onResend: _resendNotification,
                    onSendNow: _sendNow,
                    onDelete: _deleteNotification,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalNotifications,
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

    return AppFormatters.formatDateTime(dateTime);
  }
}

class NotificationsTable extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final ValueChanged<NotificationModel> onView;
  final ValueChanged<NotificationModel> onMarkRead;
  final ValueChanged<NotificationModel> onResend;
  final ValueChanged<NotificationModel> onSendNow;
  final ValueChanged<NotificationModel> onDelete;

  const NotificationsTable({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.onView,
    required this.onMarkRead,
    required this.onResend,
    required this.onSendNow,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
          else if (notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No notifications found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Notifications matching your filters will appear here.',
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
                dataRowMinHeight: 68,
                dataRowMaxHeight: 82,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Message')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Channel')),
                  DataColumn(label: Text('Recipient')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Read')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: notifications.map(
                  (notification) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _NotificationTitleCell(
                            notification: notification,
                          ),
                        ),
                        DataCell(
                          _NotificationMessageCell(
                            notification: notification,
                          ),
                        ),
                        DataCell(
                          _NotificationTypeBadge(
                            type: notification.type,
                          ),
                        ),
                        DataCell(
                          _ChannelChip(
                            channel: notification.channel,
                          ),
                        ),
                        DataCell(
                          _RecipientCell(
                            notification: notification,
                          ),
                        ),
                        DataCell(
                          _NotificationStatusBadge(
                            status: notification.status,
                          ),
                        ),
                        DataCell(
                          _ReadStatusBadge(
                            isRead: notification.isRead,
                          ),
                        ),
                        DataCell(
                          Text(
                            _NotificationsScreenState._formatDate(
                              notification.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _NotificationActions(
                            notification: notification,
                            onView: onView,
                            onMarkRead: onMarkRead,
                            onResend: onResend,
                            onSendNow: onSendNow,
                            onDelete: onDelete,
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

class _NotificationTitleCell extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTitleCell({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notification.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.assignment_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'coupon':
        return Icons.confirmation_number_outlined;
      case 'promotion':
        return Icons.campaign_outlined;
      case 'kyc':
        return Icons.verified_user_outlined;
      case 'settlement':
        return Icons.account_balance_wallet_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}

class _NotificationMessageCell extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationMessageCell({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Text(
        notification.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RecipientCell extends StatelessWidget {
  final NotificationModel notification;

  const _RecipientCell({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final String recipientName = notification.recipientName.trim().isEmpty
        ? 'All Users'
        : notification.recipientName.trim();

    return SizedBox(
      width: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipientName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatStatus(notification.recipientType),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  final String channel;

  const _ChannelChip({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: AppFormatters.formatStatus(channel),
      color: AppColors.primary,
    );
  }
}

class _NotificationTypeBadge extends StatelessWidget {
  final String type;

  const _NotificationTypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (type) {
      case 'booking':
        color = AppColors.info;
        break;
      case 'payment':
        color = AppColors.success;
        break;
      case 'order':
        color = Colors.deepPurple;
        break;
      case 'coupon':
        color = Colors.orange;
        break;
      case 'promotion':
        color = Colors.pink;
        break;
      case 'kyc':
        color = Colors.teal;
        break;
      case 'settlement':
        color = Colors.blueGrey;
        break;
      case 'system':
        color = AppColors.primary;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(type),
      color: color,
    );
  }
}

class _NotificationStatusBadge extends StatelessWidget {
  final String status;

  const _NotificationStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'sent':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'scheduled':
        color = AppColors.info;
        break;
      case 'read':
        color = AppColors.success;
        break;
      case 'unread':
        color = Colors.purple;
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

class _ReadStatusBadge extends StatelessWidget {
  final bool isRead;

  const _ReadStatusBadge({
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: isRead ? 'Read' : 'Unread',
      color: isRead ? AppColors.success : Colors.purple,
    );
  }
}

class _NotificationActions extends StatelessWidget {
  final NotificationModel notification;
  final ValueChanged<NotificationModel> onView;
  final ValueChanged<NotificationModel> onMarkRead;
  final ValueChanged<NotificationModel> onResend;
  final ValueChanged<NotificationModel> onSendNow;
  final ValueChanged<NotificationModel> onDelete;

  const _NotificationActions({
    required this.notification,
    required this.onView,
    required this.onMarkRead,
    required this.onResend,
    required this.onSendNow,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canMarkRead = !notification.isRead;
    final bool canResend = notification.status == 'failed' ||
        notification.status == 'sent';
    final bool canSendNow = notification.status == 'pending' ||
        notification.status == 'scheduled';

    return PopupMenuButton<String>(
      tooltip: 'Notification Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(notification);
            break;
          case 'mark_read':
            onMarkRead(notification);
            break;
          case 'resend':
            onResend(notification);
            break;
          case 'send_now':
            onSendNow(notification);
            break;
          case 'delete':
            onDelete(notification);
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
        PopupMenuItem(
          value: 'mark_read',
          enabled: canMarkRead,
          child: _MenuItem(
            icon: Icons.mark_email_read_outlined,
            label: 'Mark as Read',
            color: canMarkRead ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'send_now',
          enabled: canSendNow,
          child: _MenuItem(
            icon: Icons.send_outlined,
            label: 'Send Now',
            color: canSendNow ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'resend',
          enabled: canResend,
          child: _MenuItem(
            icon: Icons.refresh,
            label: 'Resend',
            color: canResend ? AppColors.warning : Colors.grey,
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

class _NotificationSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _NotificationSummaryCard({
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
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
              color: color.withOpacity(0.11),
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
            Icons.notifications_active_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Notification Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Messaging and alert delivery overview',
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
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}