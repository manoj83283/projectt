import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/banner_model.dart';
import '../../providers/banner_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({
    super.key,
  });

  @override
  State<BannersScreen> createState() =>
      _BannersScreenState();
}

class _BannersScreenState
    extends State<BannersScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedStatus;
  String? _selectedPlacement;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadBanners();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD BANNERS
  // =====================================================

  Future<void> _loadBanners({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<BannerProvider>()
        .getBanners(
          page: _page,
          limit: _limit,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          status: _selectedStatus,
          placement: _selectedPlacement,
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadBanners(
      page: 1,
    );
  }

  // =====================================================
  // STATUS FILTER
  // =====================================================

  Future<void> _onStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedStatus = value;
    });

    await _loadBanners(
      page: 1,
    );
  }

  // =====================================================
  // PLACEMENT FILTER
  // =====================================================

  Future<void> _onPlacementChanged(
    String? value,
  ) async {
    setState(() {
      _selectedPlacement = value;
    });

    await _loadBanners(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _selectedPlacement = null;
      _page = 1;
    });

    await _loadBanners(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadBanners(
      page: _page,
    );
  }

  // =====================================================
  // ADD BANNER
  // =====================================================

  void _addBanner() {
    Navigator.pushNamed(
      context,
      AppRoutes.addBanner,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // VIEW BANNER
  // =====================================================

  void _viewBanner(
    BannerModel banner,
  ) {
    NavigationService.showInfo(
      'Banner details screen will be available soon.',
    );
  }

  // =====================================================
  // EDIT BANNER
  // =====================================================

  void _editBanner(
    BannerModel banner,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.editBanner,
      arguments: banner,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // ACTIVATE BANNER
  // =====================================================

  Future<void> _activateBanner(
    BannerModel banner,
  ) async {
    final success =
        await context
            .read<BannerProvider>()
            .activateBanner(
              banner.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Banner activated successfully',
      );

      await _refresh();
    } else {
      _showBannerError();
    }
  }

  // =====================================================
  // DEACTIVATE BANNER
  // =====================================================

  Future<void> _deactivateBanner(
    BannerModel banner,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Deactivate Banner',
          ),
          content: Text(
            'Are you sure you want to deactivate "${banner.title}"?',
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
                    AppColors.warning,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<BannerProvider>()
            .deactivateBanner(
              banner.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Banner deactivated successfully',
      );

      await _refresh();
    } else {
      _showBannerError();
    }
  }

  // =====================================================
  // TOGGLE FEATURED
  // =====================================================

  Future<void> _toggleFeatured(
    BannerModel banner,
  ) async {
    final success =
        await context
            .read<BannerProvider>()
            .toggleFeaturedBanner(
              bannerId: banner.id,
              isFeatured: !banner.isFeatured,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        banner.isFeatured
            ? 'Banner removed from featured'
            : 'Banner marked as featured',
      );

      await _refresh();
    } else {
      _showBannerError();
    }
  }

  // =====================================================
  // UPDATE PRIORITY
  // =====================================================

  Future<void> _updatePriority(
    BannerModel banner,
  ) async {
    final priorityController =
        TextEditingController(
      text: banner.priority.toString(),
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Update Banner Priority',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                banner.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    priorityController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Priority',
                  hintText:
                      'Lower number appears first',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Example: priority 1 appears before priority 2.',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
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
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      priorityController.dispose();
      return;
    }

    final priority =
        int.tryParse(
              priorityController.text.trim(),
            ) ??
            0;

    priorityController.dispose();

    if (priority < 0) {
      NavigationService.showWarning(
        'Priority cannot be negative',
      );
      return;
    }

    final success =
        await context
            .read<BannerProvider>()
            .updateBannerPriority(
              bannerId: banner.id,
              priority: priority,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Banner priority updated successfully',
      );

      await _refresh();
    } else {
      _showBannerError();
    }
  }

  // =====================================================
  // DELETE BANNER
  // =====================================================

  Future<void> _deleteBanner(
    BannerModel banner,
  ) async {
    final confirmed =
        await DeleteBannerDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<BannerProvider>()
            .deleteBanner(
              banner.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Banner deleted successfully',
      );

      await _refresh();
    } else {
      _showBannerError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showBannerError() {
    final error =
        context
            .read<BannerProvider>()
            .errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _previousPage() async {
    if (_page <= 1) return;

    await _loadBanners(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadBanners(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadBanners(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Banners',
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Consumer<BannerProvider>(
          builder: (
            context,
            bannerProvider,
            child,
          ) {
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
                    _buildHeader(
                      bannerProvider,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height:
                          AppDimensions.padding20,
                    ),

                    if (bannerProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: bannerProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    BannersTable(
                      banners:
                          bannerProvider.banners,
                      isLoading:
                          bannerProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewBanner,
                      onEdit: _editBanner,
                      onActivate:
                          _activateBanner,
                      onDeactivate:
                          _deactivateBanner,
                      onToggleFeatured:
                          _toggleFeatured,
                      onUpdatePriority:
                          _updatePriority,
                      onDelete: _deleteBanner,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          bannerProvider.currentPage,
                      totalPages:
                          bannerProvider.totalPages,
                      totalRecords:
                          bannerProvider.totalBanners,
                      pageSize: _limit,
                      onPrevious:
                          _previousPage,
                      onNext: () {
                        _nextPage(
                          bannerProvider.totalPages,
                        );
                      },
                      onPageSelected:
                          _goToPage,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addBanner,
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Banner',
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    BannerProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 950;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Banners',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Manage promotional banners for home screen, category pages, offers, events, and marketing campaigns.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );

        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _BannerSummaryCard(
              title: 'Total Banners',
              value: provider.totalBanners
                  .toString(),
              icon: Icons.image_outlined,
              color: AppColors.primary,
            ),
            _BannerSummaryCard(
              title: 'Active',
              value: provider.activeBanners
                  .toString(),
              icon:
                  Icons.check_circle_outline,
              color: AppColors.success,
            ),
            _BannerSummaryCard(
              title: 'Inactive',
              value: provider.inactiveBanners
                  .toString(),
              icon: Icons.block_outlined,
              color: AppColors.warning,
            ),
            _BannerSummaryCard(
              title: 'Featured',
              value: provider.featuredBanners
                  .toString(),
              icon:
                  Icons.star_outline_rounded,
              color: AppColors.info,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  titleSection,
                ],
              ),

              const SizedBox(height: 16),

              summaryCards,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            titleSection,

            const SizedBox(width: 16),

            summaryCards,
          ],
        );
      },
    );
  }

  // =====================================================
  // FILTERS
  // =====================================================

  Widget _buildFilters() {
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
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 900;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search banners by title, placement or target...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'active',
                'inactive',
                'expired',
                'scheduled',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged:
                  _onStatusChanged,
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
              ),
            );

            final placementDropdown =
                CustomDropdown<String>(
              labelText: 'Placement',
              hintText: 'All Placements',
              value: _selectedPlacement,
              items: const [
                'home',
                'category',
                'service',
                'checkout',
                'profile',
                'offers',
              ],
              itemLabelBuilder: (item) {
                switch (item) {
                  case 'home':
                    return 'Home';
                  case 'category':
                    return 'Category';
                  case 'service':
                    return 'Service';
                  case 'checkout':
                    return 'Checkout';
                  case 'profile':
                    return 'Profile';
                  case 'offers':
                    return 'Offers';
                  default:
                    return AppFormatters
                        .formatStatus(item);
                }
              },
              onChanged:
                  _onPlacementChanged,
              prefixIcon: const Icon(
                Icons.place_outlined,
              ),
            );

            final clearButton =
                CustomButton(
              text: 'Clear',
              type: ButtonType.outline,
              icon: Icons.clear_rounded,
              onPressed: _clearFilters,
            );

            if (isMobile) {
              return Column(
                children: [
                  search,

                  const SizedBox(height: 12),

                  statusDropdown,

                  const SizedBox(height: 12),

                  placementDropdown,

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: clearButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: search,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 210,
                  child: statusDropdown,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 220,
                  child: placementDropdown,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 130,
                  child: clearButton,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// BANNERS TABLE
// =====================================================

class BannersTable extends StatelessWidget {
  final List<BannerModel> banners;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(BannerModel banner)? onView;
  final Function(BannerModel banner)? onEdit;
  final Function(BannerModel banner)? onActivate;
  final Function(BannerModel banner)? onDeactivate;
  final Function(BannerModel banner)? onToggleFeatured;
  final Function(BannerModel banner)? onUpdatePriority;
  final Function(BannerModel banner)? onDelete;

  const BannersTable({
    super.key,
    required this.banners,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onToggleFeatured,
    this.onUpdatePriority,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading banners...',
      );
    }

    if (banners.isEmpty) {
      return EmptyWidget(
        icon: Icons.image_outlined,
        title: 'No Banners Found',
        description:
            'Create banners to promote offers, services, categories, or events.',
        buttonText: AppStrings.refresh,
        onButtonPressed: onRefresh,
      );
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight:
                AppDimensions.headingRowHeight,
            dataRowMinHeight:
                AppDimensions.dataRowHeight,
            dataRowMaxHeight:
                AppDimensions.dataRowHeight,
            headingRowColor:
                WidgetStateProperty.all(
              AppColors.background,
            ),
            columnSpacing: 28,
            horizontalMargin: 20,
            columns: const [
              DataColumn(
                label: _TableHeader(
                  title: 'Banner',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Placement',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Target',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Priority',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Date Range',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Featured',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Created',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: banners.map(
              (banner) {
                return DataRow(
                  cells: [
                    DataCell(
                      _BannerInfoCell(
                        banner: banner,
                      ),
                    ),
                    DataCell(
                      _PlacementBadge(
                        placement:
                            banner.placement,
                      ),
                    ),
                    DataCell(
                      _TargetCell(
                        banner: banner,
                      ),
                    ),
                    DataCell(
                      _PriorityBadge(
                        priority:
                            banner.priority,
                      ),
                    ),
                    DataCell(
                      _DateRangeCell(
                        banner: banner,
                      ),
                    ),
                    DataCell(
                      _BannerStatusBadge(
                        banner: banner,
                      ),
                    ),
                    DataCell(
                      _FeaturedBadge(
                        isFeatured:
                            banner.isFeatured,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          banner.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _BannerActions(
                        banner: banner,
                        onView: onView,
                        onEdit: onEdit,
                        onActivate:
                            onActivate,
                        onDeactivate:
                            onDeactivate,
                        onToggleFeatured:
                            onToggleFeatured,
                        onUpdatePriority:
                            onUpdatePriority,
                        onDelete: onDelete,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TABLE HEADER
// =====================================================

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// =====================================================
// BANNER INFO CELL
// =====================================================

class _BannerInfoCell extends StatelessWidget {
  final BannerModel banner;

  const _BannerInfoCell({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        banner.imageUrl.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 380,
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 86,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(
                        banner.imageUrl,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title.isNotEmpty
                      ? banner.title
                      : '-',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  banner.subtitle.isNotEmpty
                      ? banner.subtitle
                      : banner.id,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
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

// =====================================================
// TARGET CELL
// =====================================================

class _TargetCell extends StatelessWidget {
  final BannerModel banner;

  const _TargetCell({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 220,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            banner.targetType.isNotEmpty
                ? AppFormatters.formatStatus(
                    banner.targetType,
                  )
                : '-',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            banner.targetId.isNotEmpty
                ? banner.targetId
                : '-',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DATE RANGE CELL
// =====================================================

class _DateRangeCell extends StatelessWidget {
  final BannerModel banner;

  const _DateRangeCell({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 230,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            banner.startDate != null
                ? AppFormatters.formatDate(
                    banner.startDate,
                  )
                : '-',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            banner.endDate != null
                ? 'to ${AppFormatters.formatDate(banner.endDate)}'
                : 'No end date',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PLACEMENT BADGE
// =====================================================

class _PlacementBadge extends StatelessWidget {
  final String placement;

  const _PlacementBadge({
    required this.placement,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: placement.isNotEmpty
          ? AppFormatters.formatStatus(
              placement,
            )
          : '-',
      color: AppColors.primary,
    );
  }
}

// =====================================================
// PRIORITY BADGE
// =====================================================

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.info
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius8,
        ),
        border: Border.all(
          color: AppColors.info
              .withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        priority.toString(),
        style: const TextStyle(
          color: AppColors.info,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// =====================================================
// BANNER STATUS BADGE
// =====================================================

class _BannerStatusBadge extends StatelessWidget {
  final BannerModel banner;

  const _BannerStatusBadge({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    if (banner.isExpired) {
      return const _StatusChip(
        label: 'Expired',
        color: AppColors.error,
      );
    }

    if (banner.isScheduled) {
      return const _StatusChip(
        label: 'Scheduled',
        color: AppColors.info,
      );
    }

    if (banner.isActive) {
      return const _StatusChip(
        label: 'Active',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'Inactive',
      color: AppColors.warning,
    );
  }
}

// =====================================================
// FEATURED BADGE
// =====================================================

class _FeaturedBadge extends StatelessWidget {
  final bool isFeatured;

  const _FeaturedBadge({
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: isFeatured
          ? 'Featured'
          : 'Normal',
      color: isFeatured
          ? AppColors.warning
          : AppColors.textSecondary,
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
        horizontal: 10,
        vertical: 6,
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

// =====================================================
// BANNER ACTIONS
// =====================================================

class _BannerActions extends StatelessWidget {
  final BannerModel banner;

  final Function(BannerModel banner)? onView;
  final Function(BannerModel banner)? onEdit;
  final Function(BannerModel banner)? onActivate;
  final Function(BannerModel banner)? onDeactivate;
  final Function(BannerModel banner)? onToggleFeatured;
  final Function(BannerModel banner)? onUpdatePriority;
  final Function(BannerModel banner)? onDelete;

  const _BannerActions({
    required this.banner,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onToggleFeatured,
    this.onUpdatePriority,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(
        Icons.more_vert,
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call(banner);
            break;

          case 'edit':
            onEdit?.call(banner);
            break;

          case 'activate':
            onActivate?.call(banner);
            break;

          case 'deactivate':
            onDeactivate?.call(banner);
            break;

          case 'featured':
            onToggleFeatured?.call(banner);
            break;

          case 'priority':
            onUpdatePriority?.call(banner);
            break;

          case 'delete':
            onDelete?.call(banner);
            break;
        }
      },
      itemBuilder: (context) {
        final items =
            <PopupMenuEntry<String>>[];

        if (onView != null) {
          items.add(
            const PopupMenuItem(
              value: 'view',
              child: _MenuItem(
                icon:
                    Icons.visibility_outlined,
                label: 'View',
              ),
            ),
          );
        }

        if (onEdit != null) {
          items.add(
            const PopupMenuItem(
              value: 'edit',
              child: _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
            ),
          );
        }

        if (!banner.isActive &&
            onActivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'activate',
              child: _MenuItem(
                icon:
                    Icons.check_circle_outline,
                label: 'Activate',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (banner.isActive &&
            onDeactivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'deactivate',
              child: _MenuItem(
                icon:
                    Icons.block_outlined,
                label: 'Deactivate',
                color: AppColors.warning,
              ),
            ),
          );
        }

        if (onToggleFeatured != null) {
          items.add(
            PopupMenuItem(
              value: 'featured',
              child: _MenuItem(
                icon: banner.isFeatured
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                label: banner.isFeatured
                    ? 'Unfeature'
                    : 'Feature',
                color: AppColors.warning,
              ),
            ),
          );
        }

        if (onUpdatePriority != null) {
          items.add(
            const PopupMenuItem(
              value: 'priority',
              child: _MenuItem(
                icon:
                    Icons.low_priority_rounded,
                label: 'Update Priority',
                color: AppColors.info,
              ),
            ),
          );
        }

        if (onDelete != null) {
          items.add(
            const PopupMenuDivider(),
          );

          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: _MenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}

// =====================================================
// MENU ITEM
// =====================================================

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
    final itemColor =
        color ?? AppColors.textPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: itemColor,
        ),

        const SizedBox(width: 10),

        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

class _BannerSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BannerSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 160,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}