import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedRating;
  String? _selectedReviewType;

  final List<String> _reviewStatuses = const [
    'pending',
    'approved',
    'rejected',
    'reported',
    'hidden',
  ];

  final List<String> _ratings = const [
    '5',
    '4',
    '3',
    '2',
    '1',
  ];

  final List<String> _reviewTypes = const [
    'service',
    'provider',
    'product',
    'booking',
    'order',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    await context.read<ReviewProvider>().getReviews(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          rating: _selectedRating == null ? null : int.parse(_selectedRating!),
          reviewType: _selectedReviewType,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchReviews();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchReviews();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchReviews();
  }

  void _onRatingChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedRating = value;
    });

    _fetchReviews();
  }

  void _onReviewTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedReviewType = value;
    });

    _fetchReviews();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedRating = null;
      _selectedReviewType = null;
      _searchController.clear();
    });

    _fetchReviews();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchReviews();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchReviews();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchReviews();
  }

  Future<void> _viewReview(ReviewModel review) async {
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
                          Icons.rate_review_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Review Details',
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
                    label: 'Review ID',
                    value: review.id,
                  ),
                  _DetailRow(
                    label: 'Customer',
                    value: review.customerName,
                  ),
                  _DetailRow(
                    label: 'Provider',
                    value: review.providerName.trim().isEmpty
                        ? 'Not Available'
                        : review.providerName,
                  ),
                  _DetailRow(
                    label: 'Service',
                    value: review.serviceName.trim().isEmpty
                        ? 'Not Available'
                        : review.serviceName,
                  ),
                  _DetailRow(
                    label: 'Booking ID',
                    value: review.bookingId.trim().isEmpty
                        ? 'Not Available'
                        : review.bookingId,
                  ),
                  _DetailRow(
                    label: 'Order ID',
                    value: review.orderId.trim().isEmpty
                        ? 'Not Available'
                        : review.orderId,
                  ),
                  _DetailRow(
                    label: 'Review Type',
                    value: AppFormatters.formatStatus(review.reviewType),
                  ),
                  _DetailRow(
                    label: 'Rating',
                    value: '${review.rating} / 5',
                  ),
                  _DetailRow(
                    label: 'Title',
                    value: review.title.trim().isEmpty
                        ? 'Not Available'
                        : review.title,
                  ),
                  _DetailRow(
                    label: 'Comment',
                    value: review.comment.trim().isEmpty
                        ? 'No comment provided'
                        : review.comment,
                  ),
                  _DetailRow(
                    label: 'Reported Reason',
                    value: review.reportReason.trim().isEmpty
                        ? 'Not Reported'
                        : review.reportReason,
                  ),
                  _DetailRow(
                    label: 'Created Date',
                    value: _formatDate(review.createdAt),
                  ),
                  _DetailRow(
                    label: 'Updated Date',
                    value: _formatDate(review.updatedAt),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _RatingBadge(
                        rating: review.rating,
                      ),
                      _ReviewStatusBadge(
                        status: review.status,
                      ),
                      _ReviewTypeBadge(
                        type: review.reviewType,
                      ),
                      if (review.isReported)
                        const _StatusChip(
                          label: 'Reported',
                          color: AppColors.error,
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

  Future<void> _approveReview(ReviewModel review) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Approve Review',
      message: 'Are you sure you want to approve this review?',
      confirmText: 'Approve',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<ReviewProvider>().approveReview(review.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Review approved successfully',
      errorMessage: 'Failed to approve review',
    );
  }

  Future<void> _rejectReview(ReviewModel review) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject Review'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Enter valid rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) return;

    final bool success = await context.read<ReviewProvider>().rejectReview(
          reviewId: review.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Review rejected successfully',
      errorMessage: 'Failed to reject review',
    );
  }

  Future<void> _hideReview(ReviewModel review) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Hide Review',
      message: 'Do you want to hide this review from customers?',
      confirmText: 'Hide',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<ReviewProvider>().hideReview(review.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Review hidden successfully',
      errorMessage: 'Failed to hide review',
    );
  }

  Future<void> _restoreReview(ReviewModel review) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Restore Review',
      message: 'Do you want to restore this review?',
      confirmText: 'Restore',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<ReviewProvider>().restoreReview(review.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Review restored successfully',
      errorMessage: 'Failed to restore review',
    );
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Review',
      message:
          'This action cannot be undone. Are you sure you want to delete this review?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<ReviewProvider>().deleteReview(review.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Review deleted successfully',
      errorMessage: 'Failed to delete review',
    );
  }

  Future<void> _exportReviews() async {
    await context.read<ReviewProvider>().exportReviews();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Reviews export started successfully',
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
      _fetchReviews();
      return;
    }

    NavigationService.showError(
      context.read<ReviewProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(ReviewProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Reviews',
          subtitle:
              'Monitor ratings, moderate customer feedback, handle reports and maintain marketplace trust.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportReviews,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.outline,
              icon: Icons.refresh,
              onPressed: _refresh,
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
                _ReviewSummaryCard(
                  title: 'Total Reviews',
                  value: provider.totalReviews.toString(),
                  icon: Icons.rate_review_outlined,
                  color: AppColors.primary,
                ),
                _ReviewSummaryCard(
                  title: 'Average Rating',
                  value: provider.averageRating.toStringAsFixed(1),
                  icon: Icons.star_outline,
                  color: Colors.orange,
                ),
                _ReviewSummaryCard(
                  title: 'Pending',
                  value: provider.pendingReviews.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _ReviewSummaryCard(
                  title: 'Approved',
                  value: provider.approvedReviews.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _ReviewSummaryCard(
                  title: 'Reported',
                  value: provider.reportedReviews.toString(),
                  icon: Icons.report_outlined,
                  color: AppColors.error,
                ),
                _ReviewSummaryCard(
                  title: 'Hidden',
                  value: provider.hiddenReviews.toString(),
                  icon: Icons.visibility_off_outlined,
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
            hintText:
                'Search review id, customer, provider, service, comment...',
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
                    _buildRatingDropdown(),
                    const SizedBox(height: 14),
                    _buildReviewTypeDropdown(),
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
                  Expanded(child: _buildRatingDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildReviewTypeDropdown()),
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
      labelText: 'Review Status',
      value: _selectedStatus,
      items: _reviewStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildRatingDropdown() {
    return CustomDropdown<String>(
      labelText: 'Rating',
      value: _selectedRating,
      items: _ratings,
      itemLabelBuilder: (value) => '$value Star${value == '1' ? '' : 's'}',
      onChanged: _onRatingChanged,
    );
  }

  Widget _buildReviewTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Review Type',
      value: _selectedReviewType,
      items: _reviewTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onReviewTypeChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
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
                  ReviewsTable(
                    reviews: provider.reviews,
                    isLoading: provider.isLoading,
                    onView: _viewReview,
                    onApprove: _approveReview,
                    onReject: _rejectReview,
                    onHide: _hideReview,
                    onRestore: _restoreReview,
                    onDelete: _deleteReview,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalReviews,
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

class ReviewsTable extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final ValueChanged<ReviewModel> onView;
  final ValueChanged<ReviewModel> onApprove;
  final ValueChanged<ReviewModel> onReject;
  final ValueChanged<ReviewModel> onHide;
  final ValueChanged<ReviewModel> onRestore;
  final ValueChanged<ReviewModel> onDelete;

  const ReviewsTable({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onHide,
    required this.onRestore,
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
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No reviews found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reviews matching your filters will appear here.',
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
                  DataColumn(label: Text('Review')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Rating')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Reported')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: reviews.map(
                  (review) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _ReviewInfoCell(
                            review: review,
                          ),
                        ),
                        DataCell(
                          _CustomerCell(
                            review: review,
                          ),
                        ),
                        DataCell(
                          _ProviderCell(
                            review: review,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 180,
                            child: Text(
                              review.serviceName.trim().isEmpty
                                  ? 'Not Available'
                                  : review.serviceName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          _RatingBadge(
                            rating: review.rating,
                          ),
                        ),
                        DataCell(
                          _ReviewTypeBadge(
                            type: review.reviewType,
                          ),
                        ),
                        DataCell(
                          _ReviewStatusBadge(
                            status: review.status,
                          ),
                        ),
                        DataCell(
                          review.isReported
                              ? const _StatusChip(
                                  label: 'Reported',
                                  color: AppColors.error,
                                )
                              : const _StatusChip(
                                  label: 'No',
                                  color: Colors.grey,
                                ),
                        ),
                        DataCell(
                          Text(
                            _ReviewsScreenState._formatDate(
                              review.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _ReviewActions(
                            review: review,
                            onView: onView,
                            onApprove: onApprove,
                            onReject: onReject,
                            onHide: onHide,
                            onRestore: onRestore,
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

class _ReviewInfoCell extends StatelessWidget {
  final ReviewModel review;

  const _ReviewInfoCell({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Colors.orange.withValues(alpha: 0.12),
            child: const Icon(
              Icons.star_outline,
              color: Colors.orange,
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
                  review.title.trim().isEmpty ? 'Review Feedback' : review.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment.trim().isEmpty
                      ? 'No comment provided'
                      : review.comment,
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

class _CustomerCell extends StatelessWidget {
  final ReviewModel review;

  const _CustomerCell({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final String customerName = review.customerName.trim().isEmpty
        ? 'Unknown Customer'
        : review.customerName.trim();

    return SizedBox(
      width: 175,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              customerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              customerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCell extends StatelessWidget {
  final ReviewModel review;

  const _ProviderCell({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final String providerName = review.providerName.trim().isEmpty
        ? 'Not Assigned'
        : review.providerName.trim();

    final bool hasProvider = review.providerName.trim().isNotEmpty;

    return SizedBox(
      width: 175,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: hasProvider
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            child: Icon(
              hasProvider ? Icons.person_outline : Icons.person_off_outlined,
              size: 18,
              color: hasProvider ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              providerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: hasProvider ? Colors.black87 : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final int rating;

  const _RatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = rating >= 4
        ? AppColors.success
        : rating == 3
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            rating.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTypeBadge extends StatelessWidget {
  final String type;

  const _ReviewTypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (type) {
      case 'service':
        color = AppColors.primary;
        break;
      case 'provider':
        color = AppColors.info;
        break;
      case 'product':
        color = Colors.deepPurple;
        break;
      case 'booking':
        color = AppColors.success;
        break;
      case 'order':
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

class _ReviewStatusBadge extends StatelessWidget {
  final String status;

  const _ReviewStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'approved':
        color = AppColors.success;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      case 'reported':
        color = Colors.deepOrange;
        break;
      case 'hidden':
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

class _ReviewActions extends StatelessWidget {
  final ReviewModel review;
  final ValueChanged<ReviewModel> onView;
  final ValueChanged<ReviewModel> onApprove;
  final ValueChanged<ReviewModel> onReject;
  final ValueChanged<ReviewModel> onHide;
  final ValueChanged<ReviewModel> onRestore;
  final ValueChanged<ReviewModel> onDelete;

  const _ReviewActions({
    required this.review,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onHide,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canApprove =
        review.status == 'pending' || review.status == 'reported';

    final bool canReject =
        review.status == 'pending' || review.status == 'reported';

    final bool canHide =
        review.status == 'approved' || review.status == 'reported';

    final bool canRestore =
        review.status == 'hidden' || review.status == 'rejected';

    return PopupMenuButton<String>(
      tooltip: 'Review Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(review);
            break;
          case 'approve':
            onApprove(review);
            break;
          case 'reject':
            onReject(review);
            break;
          case 'hide':
            onHide(review);
            break;
          case 'restore':
            onRestore(review);
            break;
          case 'delete':
            onDelete(review);
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
          value: 'approve',
          enabled: canApprove,
          child: _MenuItem(
            icon: Icons.check_circle_outline,
            label: 'Approve',
            color: canApprove ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'reject',
          enabled: canReject,
          child: _MenuItem(
            icon: Icons.cancel_outlined,
            label: 'Reject',
            color: canReject ? AppColors.error : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'hide',
          enabled: canHide,
          child: _MenuItem(
            icon: Icons.visibility_off_outlined,
            label: 'Hide',
            color: canHide ? AppColors.warning : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'restore',
          enabled: canRestore,
          child: _MenuItem(
            icon: Icons.restore_outlined,
            label: 'Restore',
            color: canRestore ? AppColors.primary : Colors.grey,
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

class _ReviewSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReviewSummaryCard({
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
            Icons.rate_review_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Review Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Customer feedback and moderation overview',
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