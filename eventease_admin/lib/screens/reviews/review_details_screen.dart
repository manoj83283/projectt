import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/page_header.dart';

class ReviewDetailsScreen extends StatefulWidget {
  final ReviewModel review;

  const ReviewDetailsScreen({
    super.key,
    required this.review,
  });

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  late ReviewModel _review;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  Future<void> _approveReview() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Approve Review',
      message: 'Are you sure you want to approve this review?',
      confirmText: 'Approve',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<ReviewProvider>().approveReview(_review.id),
      successMessage: 'Review approved successfully',
      errorMessage: 'Failed to approve review',
      shouldPop: true,
    );
  }

  Future<void> _rejectReview() async {
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

    await _performAction(
      action: () => context.read<ReviewProvider>().rejectReview(
            reviewId: _review.id,
            reason: reason,
          ),
      successMessage: 'Review rejected successfully',
      errorMessage: 'Failed to reject review',
      shouldPop: true,
    );
  }

  Future<void> _hideReview() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Hide Review',
      message: 'Do you want to hide this review from customers?',
      confirmText: 'Hide',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<ReviewProvider>().hideReview(_review.id),
      successMessage: 'Review hidden successfully',
      errorMessage: 'Failed to hide review',
      shouldPop: true,
    );
  }

  Future<void> _restoreReview() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Restore Review',
      message: 'Do you want to restore this review?',
      confirmText: 'Restore',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<ReviewProvider>().restoreReview(_review.id),
      successMessage: 'Review restored successfully',
      errorMessage: 'Failed to restore review',
      shouldPop: true,
    );
  }

  Future<void> _deleteReview() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Review',
      message:
          'This action cannot be undone. Are you sure you want to delete this review?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<ReviewProvider>().deleteReview(_review.id),
      successMessage: 'Review deleted successfully',
      errorMessage: 'Failed to delete review',
      shouldPop: true,
    );
  }

  Future<void> _performAction({
    required Future<bool> Function() action,
    required String successMessage,
    required String errorMessage,
    bool shouldPop = false,
  }) async {
    setState(() {
      _isLoading = true;
    });

    final bool success = await action();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(successMessage);

      if (shouldPop) {
        Navigator.pop(context, true);
      }

      return;
    }

    NavigationService.showError(
      context.read<ReviewProvider>().errorMessage ?? errorMessage,
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

  bool get _canApprove {
    return _review.status == 'pending' || _review.status == 'reported';
  }

  bool get _canReject {
    return _review.status == 'pending' || _review.status == 'reported';
  }

  bool get _canHide {
    return _review.status == 'approved' || _review.status == 'reported';
  }

  bool get _canRestore {
    return _review.status == 'hidden' || _review.status == 'rejected';
  }

  Widget _buildHeader() {
    return PageHeader(
      title: 'Review Details',
      subtitle:
          'View review information, rating breakdown, moderation status and customer feedback.',
      actions: [
        CustomButton(
          text: 'Back',
          type: ButtonType.outline,
          icon: Icons.arrow_back,
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding24),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingBlock(),
                const SizedBox(height: 20),
                _buildReviewSummaryBlock(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: _buildRatingBlock(),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _buildReviewSummaryBlock(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.padding20),
          decoration: BoxDecoration(
            color: _ratingColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            border: Border.all(
              color: _ratingColor.withValues(alpha: 0.24),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.star_rounded,
                color: _ratingColor,
                size: 52,
              ),
              const SizedBox(height: 8),
              Text(
                '${_review.rating}/5',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _ratingColor,
                    ),
              ),
              const SizedBox(height: 8),
              _RatingStars(
                rating: _review.rating,
                color: _ratingColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSummaryBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ReviewStatusBadge(
              status: _review.status,
            ),
            _ReviewTypeBadge(
              type: _review.reviewType,
            ),
            if (_review.isReported)
              const _StatusChip(
                label: 'Reported',
                color: AppColors.error,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _review.title.trim().isEmpty ? 'Review Feedback' : _review.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          _review.comment.trim().isEmpty
              ? 'No comment provided by customer.'
              : _review.comment,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
        ),
        if (_review.reportReason.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.padding16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.report_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _review.reportReason,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewInformation() {
    return _SectionCard(
      title: 'Review Information',
      icon: Icons.rate_review_outlined,
      child: Column(
        children: [
          _DetailGrid(
            children: [
              _InfoTile(
                label: 'Review ID',
                value: _review.id,
                icon: Icons.tag_outlined,
              ),
              _InfoTile(
                label: 'Review Type',
                value: AppFormatters.formatStatus(_review.reviewType),
                icon: Icons.category_outlined,
              ),
              _InfoTile(
                label: 'Status',
                value: AppFormatters.formatStatus(_review.status),
                icon: Icons.verified_outlined,
              ),
              _InfoTile(
                label: 'Rating',
                value: '${_review.rating} / 5',
                icon: Icons.star_outline,
              ),
              _InfoTile(
                label: 'Created Date',
                value: _formatDate(_review.createdAt),
                icon: Icons.calendar_today_outlined,
              ),
              _InfoTile(
                label: 'Updated Date',
                value: _formatDate(_review.updatedAt),
                icon: Icons.update_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerProviderInformation() {
    return _SectionCard(
      title: 'Customer and Provider',
      icon: Icons.people_alt_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Customer ID',
            value: _emptyFallback(_review.customerId),
            icon: Icons.person_outline,
          ),
          _InfoTile(
            label: 'Customer Name',
            value: _emptyFallback(_review.customerName),
            icon: Icons.account_circle_outlined,
          ),
          _InfoTile(
            label: 'Provider ID',
            value: _emptyFallback(_review.providerId),
            icon: Icons.engineering_outlined,
          ),
          _InfoTile(
            label: 'Provider Name',
            value: _emptyFallback(_review.providerName),
            icon: Icons.person_pin_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceReferenceInformation() {
    return _SectionCard(
      title: 'Service and Reference',
      icon: Icons.assignment_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Service ID',
            value: _emptyFallback(_review.serviceId),
            icon: Icons.miscellaneous_services_outlined,
          ),
          _InfoTile(
            label: 'Service Name',
            value: _emptyFallback(_review.serviceName),
            icon: Icons.design_services_outlined,
          ),
          _InfoTile(
            label: 'Booking ID',
            value: _emptyFallback(_review.bookingId),
            icon: Icons.event_available_outlined,
          ),
          _InfoTile(
            label: 'Order ID',
            value: _emptyFallback(_review.orderId),
            icon: Icons.shopping_bag_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildModerationActions() {
    return _SectionCard(
      title: 'Moderation Actions',
      icon: Icons.admin_panel_settings_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          final List<Widget> actions = [
            CustomButton(
              text: 'Approve',
              icon: Icons.check_circle_outline,
              onPressed: !_canApprove || _isLoading ? null : _approveReview,
            ),
            CustomButton(
              text: 'Reject',
              type: ButtonType.outline,
              icon: Icons.cancel_outlined,
              onPressed: !_canReject || _isLoading ? null : _rejectReview,
            ),
            CustomButton(
              text: 'Hide',
              type: ButtonType.outline,
              icon: Icons.visibility_off_outlined,
              onPressed: !_canHide || _isLoading ? null : _hideReview,
            ),
            CustomButton(
              text: 'Restore',
              type: ButtonType.outline,
              icon: Icons.restore_outlined,
              onPressed: !_canRestore || _isLoading ? null : _restoreReview,
            ),
            CustomButton(
              text: 'Delete',
              type: ButtonType.danger,
              icon: Icons.delete_outline,
              onPressed: _isLoading ? null : _deleteReview,
            ),
          ];

          if (isCompact) {
            return Column(
              children: actions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: action,
                      ),
                    ),
                  )
                  .toList(),
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions,
          );
        },
      ),
    );
  }

  Color get _ratingColor {
    if (_review.rating >= 4) return AppColors.success;
    if (_review.rating == 3) return AppColors.warning;
    return AppColors.error;
  }

  String _emptyFallback(String value) {
    return value.trim().isEmpty ? 'Not Available' : value.trim();
  }

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDateTime(dateTime);
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
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppDimensions.padding24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
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
                      _buildOverviewCard(),
                      const SizedBox(height: 20),
                      _buildReviewInformation(),
                      const SizedBox(height: 20),
                      _buildCustomerProviderInformation(),
                      const SizedBox(height: 20),
                      _buildServiceReferenceInformation(),
                      const SizedBox(height: 20),
                      _buildModerationActions(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<Widget> children;

  const _DetailGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 760;

        if (isCompact) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 4.4,
          children: children,
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
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

class _RatingStars extends StatelessWidget {
  final int rating;
  final Color color;

  const _RatingStars({
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final bool filled = index < rating;

          return Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? color : Colors.grey.shade400,
            size: 22,
          );
        },
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}