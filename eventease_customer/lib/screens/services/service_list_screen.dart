import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({
    super.key,
  });

  @override
  State<ServiceListScreen> createState() =>
      _ServiceListScreenState();
}

class _ServiceListScreenState
    extends State<ServiceListScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<ServiceModel> _filteredServices =
      <ServiceModel>[];

  String? _selectedCategory;

  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // INITIALIZATION
  // =====================================================

  Future<void> _initializeScreen() async {
    _readRouteArguments();

    await _loadServices();

    if (!mounted) {
      return;
    }

    setState(() {
      _initialLoadCompleted = true;
    });
  }

  void _readRouteArguments() {
    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    String? incomingCategory;
    String? incomingSearch;

    if (arguments is Map) {
      incomingCategory =
          arguments['category']?.toString();

      incomingSearch =
          arguments['search']?.toString() ??
              arguments['query']?.toString();
    } else if (arguments is String) {
      incomingCategory = arguments;
    }

    if (incomingCategory != null &&
        incomingCategory.trim().isNotEmpty) {
      _selectedCategory =
          incomingCategory.trim();
    }

    if (incomingSearch != null &&
        incomingSearch.trim().isNotEmpty) {
      searchController.text =
          incomingSearch.trim();
    }
  }

  // =====================================================
  // LOAD SERVICES FROM BACKEND
  // =====================================================

  Future<void> _loadServices() async {
    final serviceProvider =
        context.read<ServiceProvider>();

    await serviceProvider.getServices(
      page: 1,
      limit: 100,
      category: _selectedCategory,
      search: searchController.text.trim().isEmpty
          ? null
          : searchController.text.trim(),
      sort: 'newest',
    );

    if (!mounted) {
      return;
    }

    _applyLocalFilter();
  }

  // =====================================================
  // REFRESH SERVICES
  // =====================================================

  Future<void> _refreshServices() async {
    await _loadServices();
  }

  // =====================================================
  // SEARCH
  // =====================================================

  void _searchServices(String value) {
    _applyLocalFilter();
  }

  void _applyLocalFilter() {
    final serviceProvider =
        context.read<ServiceProvider>();

    final query =
        searchController.text.trim().toLowerCase();

    final selectedCategory =
        _selectedCategory?.trim().toLowerCase();

    final sourceServices =
        serviceProvider.services;

    final filtered = sourceServices.where(
      (service) {
        final matchesSearch = query.isEmpty ||
            service.name
                .toLowerCase()
                .contains(query) ||
            service.description
                .toLowerCase()
                .contains(query) ||
            service.displayCategory
                .toLowerCase()
                .contains(query) ||
            service.displayProviderName
                .toLowerCase()
                .contains(query) ||
            (service.address ?? '')
                .toLowerCase()
                .contains(query) ||
            service.tags.any(
              (tag) => tag
                  .toLowerCase()
                  .contains(query),
            );

        final matchesCategory =
            selectedCategory == null ||
                selectedCategory.isEmpty ||
                service.categoryName
                    .toLowerCase()
                    .contains(
                      selectedCategory,
                    ) ||
                service.categoryId
                    .toLowerCase()
                    .contains(
                      selectedCategory,
                    ) ||
                service.categories.any(
                  (category) =>
                      category
                          .toLowerCase()
                          .contains(
                            selectedCategory,
                          ) ||
                      selectedCategory.contains(
                        category.toLowerCase(),
                      ),
                );

        return matchesSearch &&
            matchesCategory &&
            service.isCustomerVisible;
      },
    ).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredServices = filtered;
    });
  }

  void _clearSearch() {
    searchController.clear();

    _applyLocalFilter();
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = null;
    });

    _applyLocalFilter();
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  void _openServiceDetails(
    ServiceModel service,
  ) {
    context
        .read<ServiceProvider>()
        .setSelectedService(service);

    Navigator.pushNamed(
      context,
      RouteConfig.serviceDetails,
      arguments: service.toMap(),
    );
  }

  Future<void> _openFilter() async {
    final result = await Navigator.pushNamed(
      context,
      RouteConfig.serviceFilter,
      arguments: {
        'category': _selectedCategory,
      },
    );

    if (!mounted || result == null) {
      return;
    }

    if (result is Map) {
      final category =
          result['category']?.toString();

      setState(() {
        _selectedCategory =
            category?.trim().isEmpty ?? true
                ? null
                : category!.trim();
      });

      await _loadServices();
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'Services',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshServices,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          IconButton(
            tooltip: 'Filter',
            onPressed: _openFilter,
            icon: const Icon(
              Icons.filter_list,
            ),
          ),
        ],
      ),
      body: Consumer<ServiceProvider>(
        builder: (
          context,
          serviceProvider,
          child,
        ) {
          if (serviceProvider.isLoading &&
              !_initialLoadCompleted) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (serviceProvider.hasError &&
              serviceProvider.services.isEmpty) {
            return _buildErrorState(
              serviceProvider,
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshServices,
            child: Column(
              children: [
                // =========================================
                // SEARCH
                // =========================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _searchServices,
                    textInputAction:
                        TextInputAction.search,
                    decoration: InputDecoration(
                      hintText:
                          'Search services, providers or locations...',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon: searchController
                              .text
                              .trim()
                              .isNotEmpty
                          ? IconButton(
                              tooltip: 'Clear search',
                              onPressed: _clearSearch,
                              icon: const Icon(
                                Icons.close,
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: (_) {
                      _loadServices();
                    },
                  ),
                ),

                // =========================================
                // ACTIVE CATEGORY FILTER
                // =========================================

                if (_selectedCategory != null &&
                    _selectedCategory!
                        .trim()
                        .isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        InputChip(
                          avatar: const Icon(
                            Icons.category,
                            size: 18,
                          ),
                          label: Text(
                            _selectedCategory!,
                          ),
                          onDeleted:
                              _clearCategoryFilter,
                        ),
                      ],
                    ),
                  ),

                // =========================================
                // RESULT COUNT
                // =========================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredServices.length} Services Found',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (serviceProvider.isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                // =========================================
                // LIVE SERVICE LIST
                // =========================================

                Expanded(
                  child: _filteredServices.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.only(
                            bottom: 24,
                          ),
                          itemCount:
                              _filteredServices.length,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final service =
                                _filteredServices[
                                    index];

                            return _serviceCard(
                              service: service,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // SERVICE CARD
  // =====================================================

  Widget _serviceCard({
    required ServiceModel service,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: () {
          _openServiceDetails(service);
        },
        child: Padding(
          padding: const EdgeInsets.all(
            12,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _serviceImage(service),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      service.displayProviderName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: ThemeConfig
                              .primaryColor,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            _formatCategory(
                              service
                                  .displayCategory,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: const TextStyle(
                              color: ThemeConfig
                                  .primaryColor,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          child: Text(
                            service.address ??
                                'Location unavailable',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          service.formattedRating,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '(${service.reviewsCount})',
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      service.formattedPrice,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    if (service.hasDiscount) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '₹${service.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                          decoration: TextDecoration
                              .lineThrough,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(
                      width: 82,
                      height: 40,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _openServiceDetails(
                            service,
                          );
                        },
                        child: const Text(
                          'View',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SERVICE IMAGE
  // =====================================================

  Widget _serviceImage(
    ServiceModel service,
  ) {
    final imageUrl = service.imageUrl.trim();

    return Container(
      width: 90,
      height: 90,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ThemeConfig.primaryColor
            .withValues(
          alpha: 0.1,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.business_center,
              size: 35,
              color:
                  ThemeConfig.primaryColor,
            )
          : Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.business_center,
                  size: 35,
                  color: ThemeConfig
                      .primaryColor,
                );
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              },
            ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState(
    ServiceProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          const SizedBox(
            height: 120,
          ),
          Icon(
            Icons.cloud_off,
            size: 90,
            color: Colors.red.shade300,
          ),
          const SizedBox(
            height: 16,
          ),
          const Center(
            child: Text(
              'Unable to Load Services',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            _cleanError(
              provider.error ??
                  'Please check the backend connection and try again.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    0,
                    46,
                  ),
                ),
                onPressed: _refreshServices,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      children: [
        const SizedBox(
          height: 100,
        ),
        Icon(
          Icons.search_off,
          size: 90,
          color: Colors.grey.shade400,
        ),
        const SizedBox(
          height: 16,
        ),
        const Center(
          child: Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Center(
          child: Text(
            searchController.text
                    .trim()
                    .isNotEmpty
                ? 'Try searching with another keyword.'
                : 'No active services are currently available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Center(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              style:
                  OutlinedButton.styleFrom(
                minimumSize: const Size(
                  0,
                  46,
                ),
              ),
              onPressed: () {
                _clearSearch();
                _clearCategoryFilter();
                _refreshServices();
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Refresh Services',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  String _formatCategory(
    String value,
  ) {
    if (value.trim().isEmpty) {
      return 'Service';
    }

    return value
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
        )
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _cleanError(
    String error,
  ) {
    return error
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();
  }
}