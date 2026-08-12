import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/faq_model.dart';
import '../../providers/cms_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({
    super.key,
  });

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _faqCategories = const [
    'general',
    'account',
    'booking',
    'payment',
    'refund',
    'provider',
    'orders',
    'settlements',
    'support',
    'privacy',
    'other',
  ];

  final List<String> _faqStatuses = const [
    'published',
    'draft',
    'archived',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFaqs();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFaqs() async {
    await context.read<CmsProvider>().getFaqs(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          category: _selectedCategory,
          status: _selectedStatus,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchFaqs();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchFaqs();
      },
    );
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedCategory = value;
    });

    _fetchFaqs();
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchFaqs();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedCategory = null;
      _selectedStatus = null;
      _searchController.clear();
    });

    _fetchFaqs();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchFaqs();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchFaqs();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchFaqs();
  }

  Future<void> _createFaq() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _FaqFormDialog(
          title: 'Create FAQ',
          categories: _faqCategories,
          onSubmit: ({
            required String question,
            required String answer,
            required String category,
            required String status,
            required int sortOrder,
            required bool isFeatured,
          }) {
            return context.read<CmsProvider>().createFaq(
                  question: question,
                  answer: answer,
                  category: category,
                  status: status,
                  sortOrder: sortOrder,
                  isFeatured: isFeatured,
                );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      NavigationService.showSuccess('FAQ created successfully');
      _fetchFaqs();
    }
  }

  Future<void> _editFaq(FaqModel faq) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _FaqFormDialog(
          title: 'Edit FAQ',
          faq: faq,
          categories: _faqCategories,
          onSubmit: ({
            required String question,
            required String answer,
            required String category,
            required String status,
            required int sortOrder,
            required bool isFeatured,
          }) {
            return context.read<CmsProvider>().updateFaq(
                  faqId: faq.id,
                  question: question,
                  answer: answer,
                  category: category,
                  status: status,
                  sortOrder: sortOrder,
                  isFeatured: isFeatured,
                );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      NavigationService.showSuccess('FAQ updated successfully');
      _fetchFaqs();
    }
  }

  Future<void> _viewFaq(FaqModel faq) async {
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
              maxHeight: 720,
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
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.help_outline,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'FAQ Details',
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
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _CategoryBadge(category: faq.category),
                      _FaqStatusBadge(status: faq.status),
                      if (faq.isFeatured)
                        const _StatusChip(
                          label: 'Featured',
                          color: Colors.purple,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    faq.question,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        faq.answer,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade800,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Sort Order',
                    value: faq.sortOrder.toString(),
                  ),
                  _DetailRow(
                    label: 'Created Date',
                    value: _formatDate(faq.createdAt),
                  ),
                  _DetailRow(
                    label: 'Updated Date',
                    value: _formatDate(faq.updatedAt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _publishFaq(FaqModel faq) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Publish FAQ',
      message: 'Are you sure you want to publish this FAQ?',
      confirmText: 'Publish',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().publishFaq(faq.id);

    _handleMutationResult(
      success: success,
      successMessage: 'FAQ published successfully',
      errorMessage: 'Failed to publish FAQ',
    );
  }

  Future<void> _archiveFaq(FaqModel faq) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Archive FAQ',
      message: 'Are you sure you want to archive this FAQ?',
      confirmText: 'Archive',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().archiveFaq(faq.id);

    _handleMutationResult(
      success: success,
      successMessage: 'FAQ archived successfully',
      errorMessage: 'Failed to archive FAQ',
    );
  }

  Future<void> _toggleFeatured(FaqModel faq) async {
    final bool success = await context.read<CmsProvider>().toggleFaqFeatured(
          faqId: faq.id,
          isFeatured: !faq.isFeatured,
        );

    _handleMutationResult(
      success: success,
      successMessage:
          faq.isFeatured ? 'FAQ removed from featured' : 'FAQ marked featured',
      errorMessage: 'Failed to update featured status',
    );
  }

  Future<void> _deleteFaq(FaqModel faq) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete FAQ',
      message: 'This action cannot be undone. Are you sure you want to delete this FAQ?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().deleteFaq(faq.id);

    _handleMutationResult(
      success: success,
      successMessage: 'FAQ deleted successfully',
      errorMessage: 'Failed to delete FAQ',
    );
  }

  Future<void> _exportFaqs() async {
    await context.read<CmsProvider>().exportFaqs();

    if (!mounted) return;

    NavigationService.showSuccess('FAQs export started successfully');
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
      _fetchFaqs();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(CmsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'FAQs',
          subtitle:
              'Create, update, publish and manage frequently asked questions for EventEase users.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportFaqs,
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
              text: 'Create FAQ',
              icon: Icons.add,
              onPressed: _createFaq,
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
                        : 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile
                    ? 3.6
                    : isTablet
                        ? 2.15
                        : 1.55,
              ),
              children: [
                _FaqSummaryCard(
                  title: 'Total FAQs',
                  value: provider.totalFaqs.toString(),
                  icon: Icons.help_outline,
                  color: AppColors.primary,
                ),
                _FaqSummaryCard(
                  title: 'Published',
                  value: provider.publishedFaqs.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _FaqSummaryCard(
                  title: 'Drafts',
                  value: provider.draftFaqs.toString(),
                  icon: Icons.edit_note_outlined,
                  color: AppColors.warning,
                ),
                _FaqSummaryCard(
                  title: 'Archived',
                  value: provider.archivedFaqs.toString(),
                  icon: Icons.archive_outlined,
                  color: Colors.blueGrey,
                ),
                _FaqSummaryCard(
                  title: 'Featured',
                  value: provider.featuredFaqs.toString(),
                  icon: Icons.star_outline,
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
            hintText: 'Search question, answer, category...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildCategoryDropdown(),
                    const SizedBox(height: 14),
                    _buildStatusDropdown(),
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
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildStatusDropdown()),
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

  Widget _buildCategoryDropdown() {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _selectedCategory,
      items: _faqCategories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onCategoryChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _faqStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CmsProvider>(
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
                  FaqsTable(
                    faqs: provider.faqs,
                    isLoading: provider.isLoading,
                    onView: _viewFaq,
                    onEdit: _editFaq,
                    onPublish: _publishFaq,
                    onArchive: _archiveFaq,
                    onToggleFeatured: _toggleFeatured,
                    onDelete: _deleteFaq,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalFaqs,
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

class FaqsTable extends StatelessWidget {
  final List<FaqModel> faqs;
  final bool isLoading;
  final ValueChanged<FaqModel> onView;
  final ValueChanged<FaqModel> onEdit;
  final ValueChanged<FaqModel> onPublish;
  final ValueChanged<FaqModel> onArchive;
  final ValueChanged<FaqModel> onToggleFeatured;
  final ValueChanged<FaqModel> onDelete;

  const FaqsTable({
    super.key,
    required this.faqs,
    required this.isLoading,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onToggleFeatured,
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
          else if (faqs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No FAQs found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'FAQs matching your filters will appear here.',
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
                dataRowMaxHeight: 92,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Question')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Featured')),
                  DataColumn(label: Text('Sort Order')),
                  DataColumn(label: Text('Updated Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: faqs.map(
                  (faq) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _FaqQuestionCell(
                            faq: faq,
                          ),
                        ),
                        DataCell(
                          _CategoryBadge(
                            category: faq.category,
                          ),
                        ),
                        DataCell(
                          _FaqStatusBadge(
                            status: faq.status,
                          ),
                        ),
                        DataCell(
                          faq.isFeatured
                              ? const _StatusChip(
                                  label: 'Featured',
                                  color: Colors.purple,
                                )
                              : const _StatusChip(
                                  label: 'No',
                                  color: Colors.grey,
                                ),
                        ),
                        DataCell(
                          Text(
                            faq.sortOrder.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _FaqScreenState._formatDate(faq.updatedAt),
                          ),
                        ),
                        DataCell(
                          _FaqActions(
                            faq: faq,
                            onView: onView,
                            onEdit: onEdit,
                            onPublish: onPublish,
                            onArchive: onArchive,
                            onToggleFeatured: onToggleFeatured,
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

class _FaqQuestionCell extends StatelessWidget {
  final FaqModel faq;

  const _FaqQuestionCell({
    required this.faq,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.help_outline,
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
                  faq.question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  faq.answer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _FaqActions extends StatelessWidget {
  final FaqModel faq;
  final ValueChanged<FaqModel> onView;
  final ValueChanged<FaqModel> onEdit;
  final ValueChanged<FaqModel> onPublish;
  final ValueChanged<FaqModel> onArchive;
  final ValueChanged<FaqModel> onToggleFeatured;
  final ValueChanged<FaqModel> onDelete;

  const _FaqActions({
    required this.faq,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onToggleFeatured,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPublish = faq.status == 'draft' || faq.status == 'archived';
    final bool canArchive = faq.status == 'published';

    return PopupMenuButton<String>(
      tooltip: 'FAQ Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(faq);
            break;
          case 'edit':
            onEdit(faq);
            break;
          case 'publish':
            onPublish(faq);
            break;
          case 'archive':
            onArchive(faq);
            break;
          case 'featured':
            onToggleFeatured(faq);
            break;
          case 'delete':
            onDelete(faq);
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
            label: 'Edit FAQ',
          ),
        ),
        PopupMenuItem(
          value: 'publish',
          enabled: canPublish,
          child: _MenuItem(
            icon: Icons.publish_outlined,
            label: 'Publish',
            color: canPublish ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          enabled: canArchive,
          child: _MenuItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            color: canArchive ? AppColors.warning : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'featured',
          child: _MenuItem(
            icon: faq.isFeatured ? Icons.star : Icons.star_outline,
            label: faq.isFeatured ? 'Remove Featured' : 'Mark Featured',
            color: Colors.purple,
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

class _FaqFormDialog extends StatefulWidget {
  final String title;
  final FaqModel? faq;
  final List<String> categories;
  final Future<bool> Function({
    required String question,
    required String answer,
    required String category,
    required String status,
    required int sortOrder,
    required bool isFeatured,
  }) onSubmit;

  const _FaqFormDialog({
    required this.title,
    this.faq,
    required this.categories,
    required this.onSubmit,
  });

  @override
  State<_FaqFormDialog> createState() => _FaqFormDialogState();
}

class _FaqFormDialogState extends State<_FaqFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  String? _category;
  String? _status;

  bool _isFeatured = false;
  bool _isSubmitting = false;

  final List<String> _statuses = const [
    'published',
    'draft',
    'archived',
  ];

  @override
  void initState() {
    super.initState();

    final FaqModel? faq = widget.faq;

    if (faq != null) {
      _questionController.text = faq.question;
      _answerController.text = faq.answer;
      _sortOrderController.text = faq.sortOrder.toString();
      _category = faq.category;
      _status = faq.status;
      _isFeatured = faq.isFeatured;
    } else {
      _sortOrderController.text = '0';
      _category = 'general';
      _status = 'draft';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_category == null) {
      NavigationService.showWarning('Please select FAQ category');
      return;
    }

    if (_status == null) {
      NavigationService.showWarning('Please select FAQ status');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await widget.onSubmit(
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      category: _category!,
      status: _status!,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      isFeatured: _isFeatured,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError('Failed to save FAQ');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
          maxHeight: 820,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.padding24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                CustomTextField(
                  controller: _questionController,
                  labelText: 'Question',
                  hintText: 'Enter FAQ question',
                  prefixIcon: Icons.question_answer_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question is required';
                    }

                    if (value.trim().length < 5) {
                      return 'Question must be at least 5 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _answerController,
                  labelText: 'Answer',
                  hintText: 'Enter FAQ answer',
                  prefixIcon: Icons.article_outlined,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Answer is required';
                    }

                    if (value.trim().length < 20) {
                      return 'Answer must be at least 20 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          _buildStatusDropdown(),
                          const SizedBox(height: 16),
                          _buildSortOrderField(),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildCategoryDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatusDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSortOrderField()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isFeatured,
                  activeThumbColor: Colors.purple,
                  title: const Text(
                    'Featured FAQ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    _isFeatured
                        ? 'This FAQ will be highlighted for users'
                        : 'This FAQ will appear in regular listing',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  secondary: Icon(
                    _isFeatured ? Icons.star : Icons.star_outline,
                    color: _isFeatured ? Colors.purple : Colors.grey,
                  ),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        type: ButtonType.outline,
                        icon: Icons.close,
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: widget.faq == null ? 'Create FAQ' : 'Update FAQ',
                        icon: Icons.check_circle_outline,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _category,
      items: widget.categories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _category = value;
        });
      },
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _status,
      items: _statuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _status = value;
        });
      },
    );
  }

  Widget _buildSortOrderField() {
    return CustomTextField(
      controller: _sortOrderController,
      labelText: 'Sort Order',
      hintText: '0',
      prefixIcon: Icons.sort_outlined,
      keyboardType: TextInputType.number,
      validator: (value) {
        final int? sortOrder = int.tryParse(value?.trim() ?? '');

        if (sortOrder == null) {
          return 'Sort order is required';
        }

        if (sortOrder < 0) {
          return 'Sort order cannot be negative';
        }

        return null;
      },
    );
  }
}

class _FaqSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _FaqSummaryCard({
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

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (category) {
      case 'general':
        color = AppColors.primary;
        break;
      case 'account':
        color = AppColors.info;
        break;
      case 'booking':
        color = Colors.deepPurple;
        break;
      case 'payment':
        color = AppColors.success;
        break;
      case 'refund':
        color = Colors.purple;
        break;
      case 'provider':
        color = Colors.teal;
        break;
      case 'orders':
        color = Colors.orange;
        break;
      case 'settlements':
        color = Colors.indigo;
        break;
      case 'support':
        color = AppColors.warning;
        break;
      case 'privacy':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(category),
      color: color,
    );
  }
}

class _FaqStatusBadge extends StatelessWidget {
  final String status;

  const _FaqStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'published':
        color = AppColors.success;
        break;
      case 'draft':
        color = AppColors.warning;
        break;
      case 'archived':
        color = Colors.blueGrey;
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
            Icons.help_outline,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'FAQ Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Frequently asked questions CMS',
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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