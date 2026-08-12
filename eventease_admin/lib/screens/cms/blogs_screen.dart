import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/blog_model.dart';
import '../../providers/cms_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({
    super.key,
  });

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _blogCategories = const [
    'general',
    'events',
    'weddings',
    'venues',
    'photography',
    'catering',
    'decorations',
    'marketplace',
    'providers',
    'payments',
    'support',
    'announcements',
    'other',
  ];

  final List<String> _blogStatuses = const [
    'published',
    'draft',
    'scheduled',
    'archived',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBlogs();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBlogs() async {
    await context.read<CmsProvider>().getBlogs(
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

    await _fetchBlogs();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchBlogs();
      },
    );
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedCategory = value;
    });

    _fetchBlogs();
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchBlogs();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedCategory = null;
      _selectedStatus = null;
      _searchController.clear();
    });

    _fetchBlogs();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchBlogs();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchBlogs();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchBlogs();
  }

  Future<void> _createBlog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _BlogFormDialog(
          title: 'Create Blog',
          categories: _blogCategories,
          onSubmit: ({
            required String title,
            required String slug,
            required String summary,
            required String content,
            required String category,
            required String status,
            required String coverImageUrl,
            required String authorName,
            required String tags,
            required bool isFeatured,
          }) {
            return context.read<CmsProvider>().createBlog(
                  title: title,
                  slug: slug,
                  summary: summary,
                  content: content,
                  category: category,
                  status: status,
                  coverImageUrl: coverImageUrl,
                  authorName: authorName,
                  tags: tags,
                  isFeatured: isFeatured,
                );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      NavigationService.showSuccess('Blog created successfully');
      _fetchBlogs();
    }
  }

  Future<void> _editBlog(BlogModel blog) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _BlogFormDialog(
          title: 'Edit Blog',
          blog: blog,
          categories: _blogCategories,
          onSubmit: ({
            required String title,
            required String slug,
            required String summary,
            required String content,
            required String category,
            required String status,
            required String coverImageUrl,
            required String authorName,
            required String tags,
            required bool isFeatured,
          }) {
            return context.read<CmsProvider>().updateBlog(
                  blogId: blog.id,
                  title: title,
                  slug: slug,
                  summary: summary,
                  content: content,
                  category: category,
                  status: status,
                  coverImageUrl: coverImageUrl,
                  authorName: authorName,
                  tags: tags,
                  isFeatured: isFeatured,
                );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      NavigationService.showSuccess('Blog updated successfully');
      _fetchBlogs();
    }
  }

  Future<void> _viewBlog(BlogModel blog) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 840,
              maxHeight: 820,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.padding20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.article_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Blog Details',
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
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.padding24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (blog.coverImageUrl.trim().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius16,
                            ),
                            child: Image.network(
                              blog.coverImageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  height: 220,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radius16,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.grey.shade500,
                                  ),
                                );
                              },
                            ),
                          ),
                        if (blog.coverImageUrl.trim().isNotEmpty)
                          const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _CategoryBadge(category: blog.category),
                            _BlogStatusBadge(status: blog.status),
                            if (blog.isFeatured)
                              const _StatusChip(
                                label: 'Featured',
                                color: Colors.purple,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          blog.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          blog.summary,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        _DetailRow(
                          label: 'Slug',
                          value: blog.slug,
                        ),
                        _DetailRow(
                          label: 'Author',
                          value: blog.authorName.trim().isEmpty
                              ? 'Admin'
                              : blog.authorName,
                        ),
                        _DetailRow(
                          label: 'Views',
                          value: blog.viewCount.toString(),
                        ),
                        _DetailRow(
                          label: 'Tags',
                          value: blog.tags.trim().isEmpty
                              ? 'Not Available'
                              : blog.tags,
                        ),
                        _DetailRow(
                          label: 'Published Date',
                          value: _formatDate(blog.publishedAt),
                        ),
                        _DetailRow(
                          label: 'Created Date',
                          value: _formatDate(blog.createdAt),
                        ),
                        _DetailRow(
                          label: 'Updated Date',
                          value: _formatDate(blog.updatedAt),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          blog.content,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade800,
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _publishBlog(BlogModel blog) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Publish Blog',
      message: 'Are you sure you want to publish "${blog.title}"?',
      confirmText: 'Publish',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().publishBlog(blog.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Blog published successfully',
      errorMessage: 'Failed to publish blog',
    );
  }

  Future<void> _archiveBlog(BlogModel blog) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Archive Blog',
      message: 'Are you sure you want to archive "${blog.title}"?',
      confirmText: 'Archive',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().archiveBlog(blog.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Blog archived successfully',
      errorMessage: 'Failed to archive blog',
    );
  }

  Future<void> _toggleFeatured(BlogModel blog) async {
    final bool success = await context.read<CmsProvider>().toggleBlogFeatured(
          blogId: blog.id,
          isFeatured: !blog.isFeatured,
        );

    _handleMutationResult(
      success: success,
      successMessage:
          blog.isFeatured ? 'Blog removed from featured' : 'Blog marked featured',
      errorMessage: 'Failed to update featured status',
    );
  }

  Future<void> _deleteBlog(BlogModel blog) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Blog',
      message:
          'This action cannot be undone. Are you sure you want to delete "${blog.title}"?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success = await context.read<CmsProvider>().deleteBlog(blog.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Blog deleted successfully',
      errorMessage: 'Failed to delete blog',
    );
  }

  Future<void> _exportBlogs() async {
    await context.read<CmsProvider>().exportBlogs();

    if (!mounted) return;

    NavigationService.showSuccess('Blogs export started successfully');
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
      _fetchBlogs();
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
          title: 'Blogs',
          subtitle:
              'Create, update, publish and manage EventEase blogs, announcements and knowledge content.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportBlogs,
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
              text: 'Create Blog',
              icon: Icons.add,
              onPressed: _createBlog,
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
                _BlogSummaryCard(
                  title: 'Total Blogs',
                  value: provider.totalBlogs.toString(),
                  icon: Icons.article_outlined,
                  color: AppColors.primary,
                ),
                _BlogSummaryCard(
                  title: 'Published',
                  value: provider.publishedBlogs.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _BlogSummaryCard(
                  title: 'Drafts',
                  value: provider.draftBlogs.toString(),
                  icon: Icons.edit_note_outlined,
                  color: AppColors.warning,
                ),
                _BlogSummaryCard(
                  title: 'Archived',
                  value: provider.archivedBlogs.toString(),
                  icon: Icons.archive_outlined,
                  color: Colors.blueGrey,
                ),
                _BlogSummaryCard(
                  title: 'Featured',
                  value: provider.featuredBlogs.toString(),
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
            hintText: 'Search blog title, slug, summary, category, author...',
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
      items: _blogCategories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onCategoryChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _blogStatuses,
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
                  BlogsTable(
                    blogs: provider.blogs,
                    isLoading: provider.isLoading,
                    onView: _viewBlog,
                    onEdit: _editBlog,
                    onPublish: _publishBlog,
                    onArchive: _archiveBlog,
                    onToggleFeatured: _toggleFeatured,
                    onDelete: _deleteBlog,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalBlogs,
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

class BlogsTable extends StatelessWidget {
  final List<BlogModel> blogs;
  final bool isLoading;
  final ValueChanged<BlogModel> onView;
  final ValueChanged<BlogModel> onEdit;
  final ValueChanged<BlogModel> onPublish;
  final ValueChanged<BlogModel> onArchive;
  final ValueChanged<BlogModel> onToggleFeatured;
  final ValueChanged<BlogModel> onDelete;

  const BlogsTable({
    super.key,
    required this.blogs,
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
          else if (blogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No blogs found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Blogs matching your filters will appear here.',
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
                dataRowMinHeight: 76,
                dataRowMaxHeight: 96,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Blog')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Featured')),
                  DataColumn(label: Text('Author')),
                  DataColumn(label: Text('Views')),
                  DataColumn(label: Text('Published Date')),
                  DataColumn(label: Text('Updated Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: blogs.map(
                  (blog) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _BlogInfoCell(
                            blog: blog,
                          ),
                        ),
                        DataCell(
                          _CategoryBadge(
                            category: blog.category,
                          ),
                        ),
                        DataCell(
                          _BlogStatusBadge(
                            status: blog.status,
                          ),
                        ),
                        DataCell(
                          blog.isFeatured
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
                          SizedBox(
                            width: 140,
                            child: Text(
                              blog.authorName.trim().isEmpty
                                  ? 'Admin'
                                  : blog.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            blog.viewCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _BlogsScreenState._formatDate(blog.publishedAt),
                          ),
                        ),
                        DataCell(
                          Text(
                            _BlogsScreenState._formatDate(blog.updatedAt),
                          ),
                        ),
                        DataCell(
                          _BlogActions(
                            blog: blog,
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

class _BlogInfoCell extends StatelessWidget {
  final BlogModel blog;

  const _BlogInfoCell({
    required this.blog,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: Row(
        children: [
          _BlogThumbnail(
            imageUrl: blog.coverImageUrl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  blog.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  blog.slug,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
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

class _BlogThumbnail extends StatelessWidget {
  final String imageUrl;

  const _BlogThumbnail({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        height: 48,
        width: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.article_outlined,
          color: AppColors.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 48,
        width: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            height: 48,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade500,
            ),
          );
        },
      ),
    );
  }
}

class _BlogActions extends StatelessWidget {
  final BlogModel blog;
  final ValueChanged<BlogModel> onView;
  final ValueChanged<BlogModel> onEdit;
  final ValueChanged<BlogModel> onPublish;
  final ValueChanged<BlogModel> onArchive;
  final ValueChanged<BlogModel> onToggleFeatured;
  final ValueChanged<BlogModel> onDelete;

  const _BlogActions({
    required this.blog,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onToggleFeatured,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPublish =
        blog.status == 'draft' || blog.status == 'scheduled' || blog.status == 'archived';

    final bool canArchive = blog.status == 'published';

    return PopupMenuButton<String>(
      tooltip: 'Blog Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(blog);
            break;
          case 'edit':
            onEdit(blog);
            break;
          case 'publish':
            onPublish(blog);
            break;
          case 'archive':
            onArchive(blog);
            break;
          case 'featured':
            onToggleFeatured(blog);
            break;
          case 'delete':
            onDelete(blog);
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
            label: 'Edit Blog',
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
            icon: blog.isFeatured ? Icons.star : Icons.star_outline,
            label: blog.isFeatured ? 'Remove Featured' : 'Mark Featured',
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

class _BlogFormDialog extends StatefulWidget {
  final String title;
  final BlogModel? blog;
  final List<String> categories;
  final Future<bool> Function({
    required String title,
    required String slug,
    required String summary,
    required String content,
    required String category,
    required String status,
    required String coverImageUrl,
    required String authorName,
    required String tags,
    required bool isFeatured,
  }) onSubmit;

  const _BlogFormDialog({
    required this.title,
    this.blog,
    required this.categories,
    required this.onSubmit,
  });

  @override
  State<_BlogFormDialog> createState() => _BlogFormDialogState();
}

class _BlogFormDialogState extends State<_BlogFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _coverImageController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _category;
  String? _status;

  bool _isFeatured = false;
  bool _isSubmitting = false;

  final List<String> _statuses = const [
    'published',
    'draft',
    'scheduled',
    'archived',
  ];

  @override
  void initState() {
    super.initState();

    final BlogModel? blog = widget.blog;

    if (blog != null) {
      _titleController.text = blog.title;
      _slugController.text = blog.slug;
      _summaryController.text = blog.summary;
      _contentController.text = blog.content;
      _coverImageController.text = blog.coverImageUrl;
      _authorController.text = blog.authorName;
      _tagsController.text = blog.tags;
      _category = blog.category;
      _status = blog.status;
      _isFeatured = blog.isFeatured;
    } else {
      _category = 'general';
      _status = 'draft';
      _authorController.text = 'Admin';
    }

    _titleController.addListener(_autoGenerateSlug);
  }

  @override
  void dispose() {
    _titleController.removeListener(_autoGenerateSlug);
    _titleController.dispose();
    _slugController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _coverImageController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _autoGenerateSlug() {
    if (widget.blog != null) return;
    if (_titleController.text.trim().isEmpty) return;

    final String slug = _titleController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');

    if (_slugController.text == slug) return;

    _slugController.text = slug;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_category == null) {
      NavigationService.showWarning('Please select blog category');
      return;
    }

    if (_status == null) {
      NavigationService.showWarning('Please select blog status');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await widget.onSubmit(
      title: _titleController.text.trim(),
      slug: _slugController.text.trim(),
      summary: _summaryController.text.trim(),
      content: _contentController.text.trim(),
      category: _category!,
      status: _status!,
      coverImageUrl: _coverImageController.text.trim(),
      authorName: _authorController.text.trim(),
      tags: _tagsController.text.trim(),
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

    NavigationService.showError('Failed to save blog');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 860,
          maxHeight: 880,
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
                        Icons.article_outlined,
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
                  controller: _titleController,
                  labelText: 'Blog Title',
                  hintText: 'Enter blog title',
                  prefixIcon: Icons.title_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Blog title is required';
                    }

                    if (value.trim().length < 5) {
                      return 'Title must be at least 5 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _slugController,
                  labelText: 'Slug',
                  hintText: 'eventease-blog-title',
                  prefixIcon: Icons.link_outlined,
                  validator: (value) {
                    final String slug = value?.trim() ?? '';

                    if (slug.isEmpty) {
                      return 'Slug is required';
                    }

                    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(slug)) {
                      return 'Slug can contain lowercase letters, numbers and hyphen only';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _summaryController,
                  labelText: 'Summary',
                  hintText: 'Short blog summary',
                  prefixIcon: Icons.summarize_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Summary is required';
                    }

                    if (value.trim().length < 20) {
                      return 'Summary must be at least 20 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentController,
                  labelText: 'Content',
                  hintText: 'Enter full blog content',
                  prefixIcon: Icons.article_outlined,
                  maxLines: 12,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Content is required';
                    }

                    if (value.trim().length < 100) {
                      return 'Content must be at least 100 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 700;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          _buildStatusDropdown(),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildCategoryDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatusDropdown()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _coverImageController,
                  labelText: 'Cover Image URL',
                  hintText: 'https://example.com/blog-cover.png',
                  prefixIcon: Icons.image_outlined,
                  validator: (value) {
                    final String url = value?.trim() ?? '';

                    if (url.isEmpty) return null;

                    final Uri? uri = Uri.tryParse(url);

                    if (uri == null || !uri.hasScheme) {
                      return 'Enter valid cover image URL';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 700;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildAuthorField(),
                          const SizedBox(height: 16),
                          _buildTagsField(),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildAuthorField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTagsField()),
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
                    'Featured Blog',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    _isFeatured
                        ? 'This blog will be highlighted for users'
                        : 'This blog will appear in regular listing',
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
                        text:
                            widget.blog == null ? 'Create Blog' : 'Update Blog',
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

  Widget _buildAuthorField() {
    return CustomTextField(
      controller: _authorController,
      labelText: 'Author Name',
      hintText: 'Admin',
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Author name is required';
        }

        return null;
      },
    );
  }

  Widget _buildTagsField() {
    return CustomTextField(
      controller: _tagsController,
      labelText: 'Tags',
      hintText: 'events,wedding,booking',
      prefixIcon: Icons.sell_outlined,
    );
  }
}

class _BlogSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BlogSummaryCard({
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
      case 'events':
        color = AppColors.info;
        break;
      case 'weddings':
        color = Colors.pink;
        break;
      case 'venues':
        color = Colors.deepPurple;
        break;
      case 'photography':
        color = Colors.indigo;
        break;
      case 'catering':
        color = Colors.orange;
        break;
      case 'decorations':
        color = Colors.teal;
        break;
      case 'marketplace':
        color = AppColors.success;
        break;
      case 'providers':
        color = Colors.blueGrey;
        break;
      case 'payments':
        color = Colors.purple;
        break;
      case 'support':
        color = AppColors.warning;
        break;
      case 'announcements':
        color = AppColors.error;
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

class _BlogStatusBadge extends StatelessWidget {
  final String status;

  const _BlogStatusBadge({
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
      case 'scheduled':
        color = AppColors.info;
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
            Icons.article_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Blog Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Content publishing and knowledge center CMS',
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
            width: 130,
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