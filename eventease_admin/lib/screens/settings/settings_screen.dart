import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/settings_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/page_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsOverview();
    });
  }

  Future<void> _loadSettingsOverview() async {
    setState(() {
      _isLoading = true;
    });

    await context.read<SettingsProvider>().getSettingsOverview();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadSettingsOverview();
  }

  Future<void> _syncSettings() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Sync Settings',
      message:
          'Do you want to sync the latest platform configuration and app settings?',
      confirmText: 'Sync',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    final bool success = await context.read<SettingsProvider>().syncSettings();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Settings synced successfully',
      );

      await _loadSettingsOverview();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to sync settings',
    );
  }

  Future<void> _clearCache() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Clear Cache',
      message:
          'Are you sure you want to clear cached configuration and temporary admin data?',
      confirmText: 'Clear Cache',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    final bool success = await context.read<SettingsProvider>().clearCache();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Cache cleared successfully',
      );

      await _loadSettingsOverview();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ?? 'Failed to clear cache',
    );
  }

  Future<void> _backupSettings() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Backup Settings',
      message: 'Do you want to create a backup of current platform settings?',
      confirmText: 'Backup',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    final bool success =
        await context.read<SettingsProvider>().backupSettings();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Settings backup started successfully',
      );
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to backup settings',
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

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route).then((_) {
      if (!mounted) return;

      _loadSettingsOverview();
    });
  }

  Widget _buildHeader(SettingsProvider provider) {
    return PageHeader(
      title: 'Settings',
      subtitle:
          'Manage platform configuration, business rules, payments, notifications, security, integrations and system maintenance.',
      actions: [
        CustomButton(
          text: 'Backup',
          type: ButtonType.outline,
          icon: Icons.backup_outlined,
          onPressed: _isLoading || provider.isLoading ? null : _backupSettings,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Clear Cache',
          type: ButtonType.outline,
          icon: Icons.cleaning_services_outlined,
          onPressed: _isLoading || provider.isLoading ? null : _clearCache,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Sync',
          icon: Icons.sync_outlined,
          onPressed: _isLoading || provider.isLoading ? null : _syncSettings,
        ),
      ],
    );
  }

  Widget _buildOverviewCards(SettingsProvider provider) {
    return LayoutBuilder(
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
                    : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile
                ? 3.8
                : isTablet
                    ? 2.2
                    : 1.85,
          ),
          children: [
            _SettingsSummaryCard(
              title: 'Active Settings',
              value: provider.activeSettings.toString(),
              icon: Icons.settings_outlined,
              color: AppColors.primary,
            ),
            _SettingsSummaryCard(
              title: 'Integrations',
              value: provider.activeIntegrations.toString(),
              icon: Icons.hub_outlined,
              color: AppColors.info,
            ),
            _SettingsSummaryCard(
              title: 'Enabled Features',
              value: provider.enabledFeatures.toString(),
              icon: Icons.toggle_on_outlined,
              color: AppColors.success,
            ),
            _SettingsSummaryCard(
              title: 'Pending Updates',
              value: provider.pendingUpdates.toString(),
              icon: Icons.update_outlined,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSystemHealth(SettingsProvider provider) {
    return _SectionCard(
      title: 'System Health',
      icon: Icons.health_and_safety_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          final List<Widget> items = [
            _HealthTile(
              title: 'API Status',
              value: provider.apiStatus,
              icon: Icons.api_outlined,
              color: _statusColor(provider.apiStatus),
            ),
            _HealthTile(
              title: 'Database',
              value: provider.databaseStatus,
              icon: Icons.storage_outlined,
              color: _statusColor(provider.databaseStatus),
            ),
            _HealthTile(
              title: 'Payment Gateway',
              value: provider.paymentGatewayStatus,
              icon: Icons.payments_outlined,
              color: _statusColor(provider.paymentGatewayStatus),
            ),
            _HealthTile(
              title: 'Notification Service',
              value: provider.notificationServiceStatus,
              icon: Icons.notifications_outlined,
              color: _statusColor(provider.notificationServiceStatus),
            ),
          ];

          if (isCompact) {
            return Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: item,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: 12),
              Expanded(child: items[1]),
              const SizedBox(width: 12),
              Expanded(child: items[2]),
              const SizedBox(width: 12),
              Expanded(child: items[3]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return _SectionCard(
      title: 'Quick Actions',
      icon: Icons.flash_on_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          final List<Widget> actions = [
            _QuickActionButton(
              title: 'Refresh Config',
              icon: Icons.refresh,
              color: AppColors.primary,
              onTap: _refresh,
            ),
            _QuickActionButton(
              title: 'Sync Settings',
              icon: Icons.sync_outlined,
              color: AppColors.info,
              onTap: _syncSettings,
            ),
            _QuickActionButton(
              title: 'Clear Cache',
              icon: Icons.cleaning_services_outlined,
              color: AppColors.warning,
              onTap: _clearCache,
            ),
            _QuickActionButton(
              title: 'Backup Settings',
              icon: Icons.backup_outlined,
              color: AppColors.success,
              onTap: _backupSettings,
            ),
          ];

          if (isCompact) {
            return Column(
              children: actions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: action,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: [
              Expanded(child: actions[0]),
              const SizedBox(width: 12),
              Expanded(child: actions[1]),
              const SizedBox(width: 12),
              Expanded(child: actions[2]),
              const SizedBox(width: 12),
              Expanded(child: actions[3]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsModules() {
    final List<_SettingsSectionItem> sections = [
      _SettingsSectionItem(
        title: 'General Settings',
        subtitle: 'App name, logo, currency, timezone and platform defaults',
        icon: Icons.tune_outlined,
        color: AppColors.primary,
        route: AppRoutes.generalSettings,
      ),
      _SettingsSectionItem(
        title: 'Business Settings',
        subtitle: 'Commission, taxes, radius, booking and order rules',
        icon: Icons.business_center_outlined,
        color: AppColors.success,
        route: AppRoutes.businessSettings,
      ),
      _SettingsSectionItem(
        title: 'Payment Settings',
        subtitle: 'Razorpay, gateway rules, refund rules and payment modes',
        icon: Icons.payments_outlined,
        color: Colors.purple,
        route: AppRoutes.paymentSettings,
      ),
      _SettingsSectionItem(
        title: 'Notification Settings',
        subtitle: 'Push, email, SMS, WhatsApp and in-app notifications',
        icon: Icons.notifications_active_outlined,
        color: AppColors.info,
        route: AppRoutes.notificationSettings,
      ),
      _SettingsSectionItem(
        title: 'Security Settings',
        subtitle: 'Admin access, sessions, password policy and restrictions',
        icon: Icons.security_outlined,
        color: AppColors.error,
        route: AppRoutes.securitySettings,
      ),
      _SettingsSectionItem(
        title: 'Content Settings',
        subtitle: 'CMS visibility, banners, SEO and legal page settings',
        icon: Icons.article_outlined,
        color: Colors.orange,
        route: AppRoutes.contentSettings,
      ),
      _SettingsSectionItem(
        title: 'Provider Settings',
        subtitle: 'KYC rules, onboarding, availability and payout settings',
        icon: Icons.engineering_outlined,
        color: Colors.teal,
        route: AppRoutes.providerSettings,
      ),
      _SettingsSectionItem(
        title: 'Customer Settings',
        subtitle: 'Onboarding, wallet, referral and customer account rules',
        icon: Icons.people_alt_outlined,
        color: Colors.indigo,
        route: AppRoutes.customerSettings,
      ),
      _SettingsSectionItem(
        title: 'Order and Booking Settings',
        subtitle: 'Cancellation, reschedule, assignment and SLA policies',
        icon: Icons.event_note_outlined,
        color: AppColors.warning,
        route: AppRoutes.orderBookingSettings,
      ),
      _SettingsSectionItem(
        title: 'Integration Settings',
        subtitle: 'Maps, Cloudinary, Firebase, analytics and third-party APIs',
        icon: Icons.integration_instructions_outlined,
        color: Colors.blueGrey,
        route: AppRoutes.integrationSettings,
      ),
      _SettingsSectionItem(
        title: 'System Logs',
        subtitle: 'Admin activity, audit logs, sync logs and errors',
        icon: Icons.receipt_long_outlined,
        color: Colors.deepPurple,
        route: AppRoutes.systemLogs,
      ),
      _SettingsSectionItem(
        title: 'Maintenance Mode',
        subtitle: 'Maintenance state, downtime message and admin locks',
        icon: Icons.construction_outlined,
        color: Colors.deepOrange,
        route: AppRoutes.maintenanceSettings,
      ),
    ];

    return _SectionCard(
      title: 'Settings Modules',
      icon: Icons.settings_applications_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth < 1100;
          final bool isMobile = constraints.maxWidth < 650;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile
                  ? 1
                  : isTablet
                      ? 2
                      : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile
                  ? 3.2
                  : isTablet
                      ? 2.1
                      : 2.22,
            ),
            itemBuilder: (context, index) {
              final _SettingsSectionItem item = sections[index];

              return _SettingsSectionCard(
                item: item,
                onTap: () => _navigateTo(item.route),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'healthy':
      case 'online':
      case 'connected':
      case 'enabled':
        return AppColors.success;
      case 'warning':
      case 'degraded':
      case 'pending':
      case 'maintenance':
        return AppColors.warning;
      case 'error':
      case 'failed':
      case 'offline':
      case 'disabled':
      case 'disconnected':
        return AppColors.error;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(
                      AppDimensions.padding24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(provider),
                        const SizedBox(height: 24),
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
                        _buildOverviewCards(provider),
                        const SizedBox(height: 20),
                        _buildSystemHealth(provider),
                        const SizedBox(height: 20),
                        _buildQuickActions(),
                        const SizedBox(height: 20),
                        _buildSettingsModules(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  if (_isLoading || provider.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.04),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSectionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _SettingsSectionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _SettingsSectionCard extends StatelessWidget {
  final _SettingsSectionItem item;
  final VoidCallback onTap;

  const _SettingsSectionCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(AppDimensions.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius14),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.padding16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radius14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SettingsSummaryCard({
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

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.padding16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            border: Border.all(
              color: color.withOpacity(0.22),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HealthTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.13),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? 'Unknown' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
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
            color: Colors.black.withOpacity(0.035),
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
                backgroundColor: AppColors.primary.withOpacity(0.1),
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