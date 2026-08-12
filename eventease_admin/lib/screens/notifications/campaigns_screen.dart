import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_campaign_model.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({
    super.key,
  });

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedType;
  String? _selectedAudience;

  final List<String> _campaignStatuses = const [
    'draft',
    'scheduled',
    'running',
    'paused',
    'completed',
    'failed',
    'cancelled',
  ];

  final List<String> _notificationTypes = const [
    'push',
    'in_app',
    'email',
    'sms',
    'broadcast',
  ];

  final List<String> _audiences = const [
    'all',
    'customers',
    'providers',
    'admins',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCampaigns();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCampaigns() async {
    await context.read<NotificationProvider>().getCampaigns(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          notificationType: _selectedType,
          audience: _selectedAudience,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchCampaigns();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchCampaigns();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchCampaigns();
  }

  void _onTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedType = value;
    });

    _fetchCampaigns();
  }

  void _onAudienceChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedAudience = value;
    });

    _fetchCampaigns();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedType = null;
      _selectedAudience = null;
      _searchController.clear();
    });

    _fetchCampaigns();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchCampaigns();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchCampaigns();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchCampaigns();
  }

  Future<void> _createCampaign() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.sendNotification,
    );

    if (!mounted) return;

    _fetchCampaigns();
  }

  Future<void> _viewCampaign(NotificationCampaignModel campaign) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
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
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.campaign_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Campaign Details',
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
                    label: 'Campaign ID',
                    value: campaign.id,
                  ),
                  _DetailRow(
                    label: 'Campaign Name',
                    value: campaign.name,
                  ),
                  _DetailRow(
                    label: 'Title',
                    value: campaign.title,
                  ),
                  _DetailRow(
                    label: 'Message',
                    value: campaign.message,
                  ),
                  _DetailRow(
                    label: 'Type',
                    value: AppFormatters.formatStatus(
                      campaign.notificationType,
                    ),
                  ),
                  _DetailRow(
                    label: 'Audience',
                    value: AppFormatters.formatStatus(
                      campaign.audience,
                    ),
                  ),
                  _DetailRow(
                    label: 'Recipients',
                    value: campaign.totalRecipients.toString(),
                  ),
                  _DetailRow(
                    label: 'Sent',
                    value: campaign.sentCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Failed',
                    value: campaign.failedCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Opened',
                    value: campaign.openedCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Clicked',
                    value: campaign.clickedCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Deep Link',
                    value: campaign.deepLink.trim().isEmpty
                        ? 'Not Available'
                        : campaign.deepLink,
                  ),
                  _DetailRow(
                    label: 'Scheduled Date',
                    value: _formatDate(campaign.scheduledAt),
                  ),
                  _DetailRow(
                    label: 'Started Date',
                    value: _formatDate(campaign.startedAt),
                  ),
                  _DetailRow(
                    label: 'Completed Date',
                    value: _formatDate(campaign.completedAt),
                  ),
                  _DetailRow(
                    label: 'Created By',
                    value: campaign.createdBy.trim().isEmpty
                        ? 'Admin'
                        : campaign.createdBy,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _CampaignStatusBadge(
                        status: campaign.status,
                      ),
                      _CampaignTypeBadge(
                        type: campaign.notificationType,
                      ),
                      _AudienceChip(
                        audience: campaign.audience,
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

  Future<void> _launchCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Launch Campaign',
      message: 'Are you sure you want to launch "${campaign.name}"?',
      confirmText: 'Launch',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<NotificationProvider>()
        .launchCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign launched successfully',
      errorMessage: 'Failed to launch campaign',
    );
  }

  Future<void> _pauseCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Pause Campaign',
      message: 'Do you want to pause "${campaign.name}"?',
      confirmText: 'Pause',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<NotificationProvider>().pauseCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign paused successfully',
      errorMessage: 'Failed to pause campaign',
    );
  }

  Future<void> _resumeCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Resume Campaign',
      message: 'Do you want to resume "${campaign.name}"?',
      confirmText: 'Resume',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<NotificationProvider>().resumeCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign resumed successfully',
      errorMessage: 'Failed to resume campaign',
    );
  }

  Future<void> _cancelCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Cancel Campaign',
      message: 'Are you sure you want to cancel "${campaign.name}"?',
      confirmText: 'Cancel Campaign',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<NotificationProvider>().cancelCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign cancelled successfully',
      errorMessage: 'Failed to cancel campaign',
    );
  }

  Future<void> _duplicateCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Duplicate Campaign',
      message: 'Do you want to duplicate "${campaign.name}"?',
      confirmText: 'Duplicate',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<NotificationProvider>()
        .duplicateCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign duplicated successfully',
      errorMessage: 'Failed to duplicate campaign',
    );
  }

  Future<void> _deleteCampaign(NotificationCampaignModel campaign) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Campaign',
      message:
          'This action cannot be undone. Are you sure you want to delete "${campaign.name}"?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<NotificationProvider>().deleteCampaign(campaign.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Campaign deleted successfully',
      errorMessage: 'Failed to delete campaign',
    );
  }

  Future<void> _exportCampaign(NotificationCampaignModel campaign) async {
    await context.read<NotificationProvider>().exportCampaigns();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Campaign export started successfully',
    );
  }

  Future<void> _exportAllCampaigns() async {
    await context.read<NotificationProvider>().exportCampaigns();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Campaigns export started successfully',
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
      _fetchCampaigns();
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
          title: 'Notification Campaigns',
          subtitle:
              'Manage broadcast campaigns, scheduled notifications, audience targeting, delivery progress and engagement.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportAllCampaigns,
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
              text: 'Create Campaign',
              icon: Icons.add,
              onPressed: _createCampaign,
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
                _CampaignSummaryCard(
                  title: 'Total Campaigns',
                  value: provider.totalCampaigns.toString(),
                  icon: Icons.campaign_outlined,
                  color: AppColors.primary,
                ),
                _CampaignSummaryCard(
                  title: 'Scheduled',
                  value: provider.scheduledCampaigns.toString(),
                  icon: Icons.schedule_outlined,
                  color: AppColors.info,
                ),
                _CampaignSummaryCard(
                  title: 'Running',
                  value: provider.runningCampaigns.toString(),
                  icon: Icons.play_circle_outline,
                  color: AppColors.success,
                ),
                _CampaignSummaryCard(
                  title: 'Completed',
                  value: provider.completedCampaigns.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _CampaignSummaryCard(
                  title: 'Failed',
                  value: provider.failedCampaigns.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
                _CampaignSummaryCard(
                  title: 'Reach',
                  value: provider.totalCampaignReach.toString(),
                  icon: Icons.groups_outlined,
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
            hintText: 'Search campaign name, title, message, audience...',
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
                    _buildTypeDropdown(),
                    const SizedBox(height: 14),
                    _buildAudienceDropdown(),
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
                  Expanded(child: _buildTypeDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildAudienceDropdown()),
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
      labelText: 'Campaign Status',
      value: _selectedStatus,
      items: _campaignStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
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

  Widget _buildAudienceDropdown() {
    return CustomDropdown<String>(
      labelText: 'Audience',
      value: _selectedAudience,
      items: _audiences,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onAudienceChanged,
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
                  CampaignsTable(
                    campaigns: provider.campaigns,
                    isLoading: provider.isLoading,
                    onView: _viewCampaign,
                    onLaunch: _launchCampaign,
                    onPause: _pauseCampaign,
                    onResume: _resumeCampaign,
                    onCancel: _cancelCampaign,
                    onDuplicate: _duplicateCampaign,
                    onDelete: _deleteCampaign,
                    onExport: _exportCampaign,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalCampaigns,
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

  static String _formatPercentage(int part, int total) {
    if (total <= 0) return '0%';

    final double percentage = (part / total) * 100;

    return '${percentage.toStringAsFixed(1)}%';
  }
}

class CampaignsTable extends StatelessWidget {
  final List<NotificationCampaignModel> campaigns;
  final bool isLoading;
  final ValueChanged<NotificationCampaignModel> onView;
  final ValueChanged<NotificationCampaignModel> onLaunch;
  final ValueChanged<NotificationCampaignModel> onPause;
  final ValueChanged<NotificationCampaignModel> onResume;
  final ValueChanged<NotificationCampaignModel> onCancel;
  final ValueChanged<NotificationCampaignModel> onDuplicate;
  final ValueChanged<NotificationCampaignModel> onDelete;
  final ValueChanged<NotificationCampaignModel> onExport;

  const CampaignsTable({
    super.key,
    required this.campaigns,
    required this.isLoading,
    required this.onView,
    required this.onLaunch,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onDuplicate,
    required this.onDelete,
    required this.onExport,
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
          else if (campaigns.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No campaigns found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Campaigns matching your filters will appear here.',
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
                dataRowMinHeight: 72,
                dataRowMaxHeight: 88,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Campaign')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Audience')),
                  DataColumn(label: Text('Recipients')),
                  DataColumn(label: Text('Sent')),
                  DataColumn(label: Text('Failed')),
                  DataColumn(label: Text('Open Rate')),
                  DataColumn(label: Text('Schedule')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: campaigns.map(
                  (campaign) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _CampaignInfoCell(
                            campaign: campaign,
                          ),
                        ),
                        DataCell(
                          _CampaignTypeBadge(
                            type: campaign.notificationType,
                          ),
                        ),
                        DataCell(
                          _AudienceChip(
                            audience: campaign.audience,
                          ),
                        ),
                        DataCell(
                          _MetricCell(
                            value: campaign.totalRecipients.toString(),
                            icon: Icons.groups_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        DataCell(
                          _MetricCell(
                            value: campaign.sentCount.toString(),
                            icon: Icons.send_outlined,
                            color: AppColors.success,
                          ),
                        ),
                        DataCell(
                          _MetricCell(
                            value: campaign.failedCount.toString(),
                            icon: Icons.error_outline,
                            color: AppColors.error,
                          ),
                        ),
                        DataCell(
                          _MetricCell(
                            value: _CampaignsScreenState._formatPercentage(
                              campaign.openedCount,
                              campaign.sentCount,
                            ),
                            icon: Icons.visibility_outlined,
                            color: Colors.purple,
                          ),
                        ),
                        DataCell(
                          _ScheduleCell(
                            campaign: campaign,
                          ),
                        ),
                        DataCell(
                          _CampaignStatusBadge(
                            status: campaign.status,
                          ),
                        ),
                        DataCell(
                          _CampaignActions(
                            campaign: campaign,
                            onView: onView,
                            onLaunch: onLaunch,
                            onPause: onPause,
                            onResume: onResume,
                            onCancel: onCancel,
                            onDuplicate: onDuplicate,
                            onDelete: onDelete,
                            onExport: onExport,
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

class _CampaignInfoCell extends StatelessWidget {
  final NotificationCampaignModel campaign;

  const _CampaignInfoCell({
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

class _ScheduleCell extends StatelessWidget {
  final NotificationCampaignModel campaign;

  const _ScheduleCell({
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime? displayDate =
        campaign.scheduledAt ?? campaign.startedAt ?? campaign.createdAt;

    return SizedBox(
      width: 165,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _CampaignsScreenState._formatDate(displayDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            campaign.scheduledAt != null
                ? 'Scheduled'
                : campaign.startedAt != null
                    ? 'Started'
                    : 'Created',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCell({
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CampaignTypeBadge extends StatelessWidget {
  final String type;

  const _CampaignTypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (type) {
      case 'push':
        color = AppColors.primary;
        break;
      case 'in_app':
        color = AppColors.info;
        break;
      case 'email':
        color = Colors.deepPurple;
        break;
      case 'sms':
        color = Colors.teal;
        break;
      case 'broadcast':
        color = Colors.orange;
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

class _AudienceChip extends StatelessWidget {
  final String audience;

  const _AudienceChip({
    required this.audience,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (audience) {
      case 'all':
        color = AppColors.primary;
        break;
      case 'customers':
        color = AppColors.success;
        break;
      case 'providers':
        color = AppColors.info;
        break;
      case 'admins':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(audience),
      color: color,
    );
  }
}

class _CampaignStatusBadge extends StatelessWidget {
  final String status;

  const _CampaignStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'draft':
        color = Colors.blueGrey;
        break;
      case 'scheduled':
        color = AppColors.info;
        break;
      case 'running':
        color = AppColors.success;
        break;
      case 'paused':
        color = AppColors.warning;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'cancelled':
        color = Colors.grey;
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

class _CampaignActions extends StatelessWidget {
  final NotificationCampaignModel campaign;
  final ValueChanged<NotificationCampaignModel> onView;
  final ValueChanged<NotificationCampaignModel> onLaunch;
  final ValueChanged<NotificationCampaignModel> onPause;
  final ValueChanged<NotificationCampaignModel> onResume;
  final ValueChanged<NotificationCampaignModel> onCancel;
  final ValueChanged<NotificationCampaignModel> onDuplicate;
  final ValueChanged<NotificationCampaignModel> onDelete;
  final ValueChanged<NotificationCampaignModel> onExport;

  const _CampaignActions({
    required this.campaign,
    required this.onView,
    required this.onLaunch,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onDuplicate,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final bool canLaunch =
        campaign.status == 'draft' || campaign.status == 'scheduled';
    final bool canPause = campaign.status == 'running';
    final bool canResume = campaign.status == 'paused';
    final bool canCancel = campaign.status == 'scheduled' ||
        campaign.status == 'running' ||
        campaign.status == 'paused';

    return PopupMenuButton<String>(
      tooltip: 'Campaign Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(campaign);
            break;
          case 'launch':
            onLaunch(campaign);
            break;
          case 'pause':
            onPause(campaign);
            break;
          case 'resume':
            onResume(campaign);
            break;
          case 'cancel':
            onCancel(campaign);
            break;
          case 'duplicate':
            onDuplicate(campaign);
            break;
          case 'export':
            onExport(campaign);
            break;
          case 'delete':
            onDelete(campaign);
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
          value: 'launch',
          enabled: canLaunch,
          child: _MenuItem(
            icon: Icons.play_circle_outline,
            label: 'Launch Campaign',
            color: canLaunch ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'pause',
          enabled: canPause,
          child: _MenuItem(
            icon: Icons.pause_circle_outline,
            label: 'Pause Campaign',
            color: canPause ? AppColors.warning : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'resume',
          enabled: canResume,
          child: _MenuItem(
            icon: Icons.restart_alt_outlined,
            label: 'Resume Campaign',
            color: canResume ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'cancel',
          enabled: canCancel,
          child: _MenuItem(
            icon: Icons.cancel_outlined,
            label: 'Cancel Campaign',
            color: canCancel ? AppColors.error : Colors.grey,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'duplicate',
          child: _MenuItem(
            icon: Icons.copy_outlined,
            label: 'Duplicate',
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: _MenuItem(
            icon: Icons.download_outlined,
            label: 'Export',
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

class _CampaignSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CampaignSummaryCard({
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
            Icons.campaign_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Campaign Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Broadcast delivery and engagement overview',
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
            width: 150,
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