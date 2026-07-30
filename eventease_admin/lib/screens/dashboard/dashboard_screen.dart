import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/admin_menu_config.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/charts/booking_chart.dart';
import '../../widgets/charts/customer_chart.dart';
import '../../widgets/charts/order_chart.dart';
import '../../widgets/charts/provider_chart.dart';
import '../../widgets/charts/revenue_chart.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  String _selectedRange = 'monthly';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context
            .read<DashboardProvider>()
            .loadDashboard();
      },
    );
  }

  // =====================================================
  // REFRESH DASHBOARD
  // =====================================================

  Future<void> _refreshDashboard() async {
    await context
        .read<DashboardProvider>()
        .refreshDashboard();
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    NavigationService.pushAndRemoveUntil(
      AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor:
          AppColors.background,
      drawer: isMobile
          ? const _DashboardDrawer()
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              const _DashboardSidebar(),

            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (
                  context,
                  dashboardProvider,
                  child,
                ) {
                  return RefreshIndicator(
                    onRefresh: _refreshDashboard,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child:
                              _DashboardHeader(
                            selectedRange:
                                _selectedRange,
                            onRangeChanged:
                                (value) {
                              if (value ==
                                  null) {
                                return;
                              }

                              setState(() {
                                _selectedRange =
                                    value;
                              });

                              dashboardProvider
                                  .loadRevenueChart(
                                range: value,
                              );

                              dashboardProvider
                                  .loadBookingsChart(
                                range: value,
                              );
                            },
                            onLogout: _logout,
                          ),
                        ),

                        if (dashboardProvider
                            .isLoading)
                          const SliverFillRemaining(
                            child:
                                FullScreenLoadingWidget(
                              message:
                                  'Loading dashboard...',
                            ),
                          )
                        else if (dashboardProvider
                                .errorMessage !=
                            null)
                          SliverFillRemaining(
                            child: AppErrorWidget(
                              message:
                                  dashboardProvider
                                      .errorMessage!,
                              onRetry: () {
                                dashboardProvider
                                    .loadDashboard();
                              },
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child:
                                _DashboardContent(
                              provider:
                                  dashboardProvider,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// DASHBOARD HEADER
// =====================================================

class _DashboardHeader extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String?> onRangeChanged;
  final VoidCallback onLogout;

  const _DashboardHeader({
    required this.selectedRange,
    required this.onRangeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveHelper.horizontalPadding(
          context,
        ),
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          if (ResponsiveHelper.isMobile(
            context,
          ))
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                  ),
                  onPressed: () {
                    Scaffold.of(context)
                        .openDrawer();
                  },
                );
              },
            ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dashboard,
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

                const SizedBox(height: 4),

                Text(
                  'Welcome back, ${authProvider.adminName.isNotEmpty ? authProvider.adminName : 'Admin'}',
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
          ),

          if (!ResponsiveHelper.isMobile(
            context,
          )) ...[
            SizedBox(
              width: 160,
              child:
                  DropdownButtonFormField<String>(
                value: selectedRange,
                decoration:
                    const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: 'yearly',
                    child: Text('Yearly'),
                  ),
                ],
                onChanged: onRangeChanged,
              ),
            ),

            const SizedBox(width: 16),

            IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.notifications,
                );
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
              ),
            ),

            const SizedBox(width: 8),

            PopupMenuButton<String>(
              tooltip: 'Profile',
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profile,
                    );
                    break;

                  case 'settings':
                    Navigator.pushNamed(
                      context,
                      AppRoutes.settings,
                    );
                    break;

                  case 'logout':
                    onLogout();
                    break;
                }
              },
              itemBuilder: (_) {
                return const [
                  PopupMenuItem(
                    value: 'profile',
                    child: _MenuItem(
                      icon:
                          Icons.person_outline,
                      label: 'Profile',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: _MenuItem(
                      icon:
                          Icons.settings_outlined,
                      label: 'Settings',
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: _MenuItem(
                      icon:
                          Icons.logout_rounded,
                      label: 'Logout',
                      color: AppColors.error,
                    ),
                  ),
                ];
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors
                    .primary
                    .withOpacity(0.10),
                child: Text(
                  AppFormatters.getInitials(
                    authProvider.adminName
                            .isNotEmpty
                        ? authProvider.adminName
                        : 'Admin',
                  ),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================
// DASHBOARD CONTENT
// =====================================================

class _DashboardContent extends StatelessWidget {
  final DashboardProvider provider;

  const _DashboardContent({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.horizontalPadding(
          context,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _KpiGrid(provider: provider),

          const SizedBox(
            height: AppDimensions.padding24,
          ),

          _ChartsSection(provider: provider),

          const SizedBox(
            height: AppDimensions.padding24,
          ),

          _InsightsSection(provider: provider),

          const SizedBox(
            height: AppDimensions.padding32,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// KPI GRID
// =====================================================

class _KpiGrid extends StatelessWidget {
  final DashboardProvider provider;

  const _KpiGrid({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCardData(
        title: 'Total Revenue',
        value: AppFormatters.formatCurrency(
          provider.totalRevenue,
        ),
        icon: Icons.currency_rupee_rounded,
        color: AppColors.totalRevenueCard,
        route: AppRoutes.payments,
      ),
      _KpiCardData(
        title: 'Total Bookings',
        value: AppFormatters.formatNumber(
          provider.totalBookings,
        ),
        icon: Icons.calendar_month_outlined,
        color: AppColors.totalBookingsCard,
        route: AppRoutes.bookings,
      ),
      _KpiCardData(
        title: 'Total Orders',
        value: AppFormatters.formatNumber(
          provider.totalOrders,
        ),
        icon: Icons.shopping_bag_outlined,
        color: AppColors.totalOrdersCard,
        route: AppRoutes.orders,
      ),
      _KpiCardData(
        title: 'Customers',
        value: AppFormatters.formatNumber(
          provider.totalCustomers,
        ),
        icon: Icons.people_outline,
        color: AppColors.totalCustomersCard,
        route: AppRoutes.customers,
      ),
      _KpiCardData(
        title: 'Providers',
        value: AppFormatters.formatNumber(
          provider.totalProviders,
        ),
        icon: Icons.business_center_outlined,
        color: AppColors.totalProvidersCard,
        route: AppRoutes.providers,
      ),
      _KpiCardData(
        title: 'Pending KYC',
        value: AppFormatters.formatNumber(
          provider.pendingKyc,
        ),
        icon: Icons.verified_user_outlined,
        color: AppColors.kycPending,
        route: AppRoutes.kycRequests,
      ),
      _KpiCardData(
        title: 'Commission',
        value: AppFormatters.formatCurrency(
          provider.totalCommission,
        ),
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.analyticsCard,
        route: AppRoutes.settlements,
      ),
      _KpiCardData(
        title: 'Today Revenue',
        value: AppFormatters.formatCurrency(
          provider.todayRevenue,
        ),
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        route: AppRoutes.analytics,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            ResponsiveHelper.dashboardGridCount(
          context,
        ),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 145,
      ),
      itemBuilder: (context, index) {
        return _KpiCard(
          data: cards[index],
        );
      },
    );
  }
}

class _KpiCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String route;

  const _KpiCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiCardData data;

  const _KpiCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        AppDimensions.radius16,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          data.route,
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: data.color
                          .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radius12,
                      ),
                    ),
                    child: Icon(
                      data.icon,
                      color: data.color,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors
                        .textSecondary
                        .withOpacity(0.7),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                data.value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
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

              const SizedBox(height: 6),

              Text(
                data.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

// =====================================================
// CHARTS SECTION
// =====================================================

class _ChartsSection extends StatelessWidget {
  final DashboardProvider provider;

  const _ChartsSection({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        ResponsiveHelper.isDesktop(context);

    final revenueData =
        _DashboardMapper.revenueData(
      provider.revenueChart,
    );

    final bookingData =
        _DashboardMapper.bookingData(
      provider.bookingChart,
    );

    final orderData =
        _DashboardMapper.orderData(
      provider.bookingChart,
    );

    if (isDesktop) {
      return Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: RevenueChart(
                  revenueData:
                      revenueData,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: BookingChart(
                  data: bookingData,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OrderChart(
                  data: orderData,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ProviderChart(
                  data:
                      _DashboardMapper
                          .providerData(
                    provider.topProviders,
                  ),
                  title:
                      'Top Providers',
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        RevenueChart(
          revenueData: revenueData,
        ),
        const SizedBox(height: 16),
        BookingChart(
          data: bookingData,
        ),
        const SizedBox(height: 16),
        OrderChart(
          data: orderData,
        ),
      ],
    );
  }
}

// =====================================================
// INSIGHTS SECTION
// =====================================================

class _InsightsSection extends StatelessWidget {
  final DashboardProvider provider;

  const _InsightsSection({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        ResponsiveHelper.isDesktop(context);

    final widgets = [
      _TopListCard(
        title: 'Top Services',
        icon: Icons.miscellaneous_services_outlined,
        items: _DashboardMapper.topList(
          provider.topServices,
          titleKeys: [
            'name',
            'serviceName',
            'title',
          ],
          valueKeys: [
            'bookings',
            'count',
            'totalBookings',
          ],
        ),
        emptyMessage:
            'No service insights available',
      ),
      _TopListCard(
        title: 'Top Providers',
        icon: Icons.business_center_outlined,
        items: _DashboardMapper.topList(
          provider.topProviders,
          titleKeys: [
            'name',
            'providerName',
            'businessName',
          ],
          valueKeys: [
            'bookings',
            'count',
            'totalBookings',
          ],
        ),
        emptyMessage:
            'No provider insights available',
      ),
      _RecentListCard(
        title: 'Recent Bookings',
        icon: Icons.calendar_today_outlined,
        items: _DashboardMapper.recentList(
          provider.recentBookings,
          titleKeys: [
            'bookingNumber',
            'customerName',
            'serviceName',
          ],
          statusKeys: [
            'status',
            'bookingStatus',
          ],
          amountKeys: [
            'totalAmount',
            'amount',
            'finalAmount',
          ],
        ),
        onViewAll: () {
          Navigator.pushNamed(
            context,
            AppRoutes.bookings,
          );
        },
      ),
      _RecentListCard(
        title: 'Recent Orders',
        icon: Icons.shopping_bag_outlined,
        items: _DashboardMapper.recentList(
          provider.recentOrders,
          titleKeys: [
            'orderNumber',
            'customerName',
            'providerName',
          ],
          statusKeys: [
            'status',
            'orderStatus',
          ],
          amountKeys: [
            'totalAmount',
            'amount',
            'finalAmount',
          ],
        ),
        onViewAll: () {
          Navigator.pushNamed(
            context,
            AppRoutes.orders,
          );
        },
      ),
    ];

    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: widgets.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 360,
        ),
        itemBuilder: (_, index) {
          return widgets[index];
        },
      );
    }

    return Column(
      children: widgets
          .map(
            (widget) => Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: widget,
            ),
          )
          .toList(),
    );
  }
}

// =====================================================
// TOP LIST CARD
// =====================================================

class _TopListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ListInsightItem> items;
  final String emptyMessage;

  const _TopListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: title,
      icon: icon,
      child: items.isEmpty
          ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) {
                return const Divider(
                  color: AppColors.border,
                );
              },
              itemBuilder: (_, index) {
                final item = items[index];

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors
                          .primary
                          .withOpacity(0.10),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color:
                              AppColors.primary,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      item.value,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// =====================================================
// RECENT LIST CARD
// =====================================================

class _RecentListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_RecentInsightItem> items;
  final VoidCallback onViewAll;

  const _RecentListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: title,
      icon: icon,
      action: TextButton(
        onPressed: onViewAll,
        child: const Text('View All'),
      ),
      child: items.isEmpty
          ? const Center(
              child: Text(
                'No recent records available',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) {
                return const Divider(
                  color: AppColors.border,
                );
              },
              itemBuilder: (_, index) {
                final item = items[index];

                return Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: AppColors.info
                            .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(
                          AppDimensions.radius12,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters
                                .formatStatus(
                              item.status,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      AppFormatters.formatCurrency(
                        item.amount,
                      ),
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// =====================================================
// DASHBOARD CARD
// =====================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),

                if (action != null) action!,
              ],
            ),

            const SizedBox(height: 16),

            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SIDEBAR
// =====================================================

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sidebarWidth,
      height: double.infinity,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          _SidebarHeader(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount:
                  AdminMenuConfig.menuItems.length,
              itemBuilder: (_, index) {
                final item =
                    AdminMenuConfig.menuItems[
                        index];

                return _SidebarMenuTile(
                  title:
                      item['title'].toString(),
                  icon: item['icon'] as IconData,
                  route:
                      item['route'].toString(),
                );
              },
            ),
          ),

          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer();

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: _DashboardSidebar(),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(
        AppDimensions.padding20,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color:
                        AppColors.sidebarText,
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

class _SidebarMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const _SidebarMenuTile({
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        ModalRoute.of(context)
            ?.settings
            .name;

    final bool selected =
        currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: ListTile(
        selected: selected,
        selectedTileColor:
            AppColors.sidebarSelected,
        hoverColor:
            AppColors.sidebarHover,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius12,
          ),
        ),
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          if (selected) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            return;
          }

          Navigator.pushNamed(
            context,
            route,
          );
        },
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      child: Text(
        'v${AppConfig.appVersion} • ${AppConfig.environmentName}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 12,
        ),
      ),
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
// DASHBOARD DATA MAPPER
// =====================================================

class _DashboardMapper {
  static List<RevenueData> revenueData(
    List<dynamic> items,
  ) {
    if (items.isEmpty) {
      return const [
        RevenueData(label: 'Jan', amount: 0),
        RevenueData(label: 'Feb', amount: 0),
        RevenueData(label: 'Mar', amount: 0),
        RevenueData(label: 'Apr', amount: 0),
      ];
    }

    return items.map((item) {
      return RevenueData(
        label: _stringValue(
          item,
          [
            'label',
            'month',
            'date',
            'name',
          ],
          fallback: '-',
        ),
        amount: _doubleValue(
          item,
          [
            'amount',
            'revenue',
            'value',
            'total',
          ],
        ),
      );
    }).toList();
  }

  static List<BookingChartData> bookingData(
    List<dynamic> items,
  ) {
    if (items.isEmpty) {
      return const [
        BookingChartData(label: 'Jan', bookings: 0),
        BookingChartData(label: 'Feb', bookings: 0),
        BookingChartData(label: 'Mar', bookings: 0),
        BookingChartData(label: 'Apr', bookings: 0),
      ];
    }

    return items.map((item) {
      return BookingChartData(
        label: _stringValue(
          item,
          [
            'label',
            'month',
            'date',
            'name',
          ],
          fallback: '-',
        ),
        bookings: _intValue(
          item,
          [
            'bookings',
            'count',
            'value',
            'total',
          ],
        ),
      );
    }).toList();
  }

  static List<OrderChartData> orderData(
    List<dynamic> items,
  ) {
    if (items.isEmpty) {
      return const [
        OrderChartData(label: 'Jan', orders: 0),
        OrderChartData(label: 'Feb', orders: 0),
        OrderChartData(label: 'Mar', orders: 0),
        OrderChartData(label: 'Apr', orders: 0),
      ];
    }

    return items.map((item) {
      return OrderChartData(
        label: _stringValue(
          item,
          [
            'label',
            'month',
            'date',
            'name',
          ],
          fallback: '-',
        ),
        orders: _intValue(
          item,
          [
            'orders',
            'count',
            'value',
            'total',
          ],
        ),
      );
    }).toList();
  }

  static List<ProviderChartData> providerData(
    List<dynamic> items,
  ) {
    if (items.isEmpty) {
      return const [
        ProviderChartData(
          category: 'No Data',
          count: 1,
        ),
      ];
    }

    return items.take(6).map((item) {
      return ProviderChartData(
        category: _stringValue(
          item,
          [
            'name',
            'providerName',
            'businessName',
            'category',
          ],
          fallback: 'Provider',
        ),
        count: _intValue(
          item,
          [
            'count',
            'bookings',
            'totalBookings',
            'value',
          ],
          fallback: 1,
        ),
      );
    }).toList();
  }

  static List<_ListInsightItem> topList(
    List<dynamic> items, {
    required List<String> titleKeys,
    required List<String> valueKeys,
  }) {
    return items.take(8).map((item) {
      return _ListInsightItem(
        title: _stringValue(
          item,
          titleKeys,
          fallback: 'Unknown',
        ),
        value: AppFormatters.formatNumber(
          _intValue(
            item,
            valueKeys,
          ),
        ),
      );
    }).toList();
  }

  static List<_RecentInsightItem> recentList(
    List<dynamic> items, {
    required List<String> titleKeys,
    required List<String> statusKeys,
    required List<String> amountKeys,
  }) {
    return items.take(8).map((item) {
      return _RecentInsightItem(
        title: _stringValue(
          item,
          titleKeys,
          fallback: 'Record',
        ),
        status: _stringValue(
          item,
          statusKeys,
          fallback: 'pending',
        ),
        amount: _doubleValue(
          item,
          amountKeys,
        ),
      );
    }).toList();
  }

  static String _stringValue(
    dynamic item,
    List<String> keys, {
    String fallback = '',
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value != null &&
          value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  static int _intValue(
    dynamic item,
    List<String> keys, {
    int fallback = 0,
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value is int) return value;

      if (value is num) return value.toInt();

      final parsed =
          int.tryParse(value?.toString() ?? '');

      if (parsed != null) {
        return parsed;
      }
    }

    return fallback;
  }

  static double _doubleValue(
    dynamic item,
    List<String> keys, {
    double fallback = 0,
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value is double) return value;

      if (value is num) return value.toDouble();

      final parsed =
          double.tryParse(
        value?.toString() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return fallback;
  }

  static Map<String, dynamic> _toMap(
    dynamic item,
  ) {
    if (item is Map<String, dynamic>) {
      return item;
    }

    try {
      final json =
          item.toJson();

      if (json is Map<String, dynamic>) {
        return json;
      }
    } catch (_) {
      //
    }

    return {};
  }
}

class _ListInsightItem {
  final String title;
  final String value;

  const _ListInsightItem({
    required this.title,
    required this.value,
  });
}

class _RecentInsightItem {
  final String title;
  final String status;
  final double amount;

  const _RecentInsightItem({
    required this.title,
    required this.status,
    required this.amount,
  });
}