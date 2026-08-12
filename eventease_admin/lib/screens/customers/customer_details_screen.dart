import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({
    super.key,
  });

  @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState
    extends State<CustomerDetailsScreen> {
  CustomerModel? _customer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    if (arguments is CustomerModel) {
      _customer = arguments;
    }
  }

  Future<void> _refreshCustomer() async {
    if (_customer == null) return;

    await context
        .read<CustomerProvider>()
        .getCustomerDetails(
          _customer!.id,
        );
  }

  Future<void> _blockCustomer() async {
    if (_customer == null) return;

    final success =
        await context
            .read<CustomerProvider>()
            .blockCustomer(
              _customer!.id,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer blocked successfully',
          ),
        ),
      );

      await _refreshCustomer();
    }
  }

  Future<void> _unblockCustomer() async {
    if (_customer == null) return;

    final success =
        await context
            .read<CustomerProvider>()
            .unblockCustomer(
              _customer!.id,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer unblocked successfully',
          ),
        ),
      );

      await _refreshCustomer();
    }
  }

  Future<void> _deleteCustomer() async {
    if (_customer == null) return;

    final confirmed =
        await DeleteCustomerDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<CustomerProvider>()
            .deleteCustomer(
              _customer!.id,
            );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer deleted successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Customer Details',
          ),
        ),
        body: const Center(
          child: Text(
            'Customer data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Details',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _refreshCustomer,
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading) {
            return const Center(
              child: LoadingWidget(),
            );
          }

          final customer =
              provider.selectedCustomer ??
                  _customer!;

          return RefreshIndicator(
            onRefresh: _refreshCustomer,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                children: [
                  _buildProfileCard(
                    customer,
                  ),

                  const SizedBox(height: 24),

                  _buildOverviewGrid(
                    customer,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:
                            _buildPersonalInfoCard(
                          customer,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child:
                            _buildActivityCard(
                          customer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildActionsCard(
                    customer,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
    CustomerModel customer,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor:
                  AppColors.primary
                      .withValues(alpha: 0.1),
              backgroundImage:
                  customer.profileImage !=
                              null &&
                          customer
                              .profileImage!
                              .isNotEmpty
                      ? NetworkImage(
                          customer.profileImage!,
                        )
                      : null,
              child: customer.profileImage ==
                          null ||
                      customer
                          .profileImage!
                          .isEmpty
                  ? Text(
                      AppFormatters
                          .getInitials(
                        customer.displayName,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.displayName,
                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    customer.email,
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    customer.phone,
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            _buildStatusChip(
              customer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewGrid(
    CustomerModel customer,
  ) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _StatCard(
          title: 'Bookings',
          value: customer.totalBookings
              .toString(),
          icon:
              Icons.calendar_month_outlined,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Orders',
          value:
              customer.totalOrders.toString(),
          icon:
              Icons.shopping_bag_outlined,
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Spent',
          value: AppFormatters
              .formatCurrency(
            customer.totalSpent,
          ),
          icon:
              Icons.currency_rupee_outlined,
          color: AppColors.warning,
        ),
        _StatCard(
          title: 'Reviews',
          value:
              customer.totalReviews.toString(),
          icon: Icons.star_outline,
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(
    CustomerModel customer,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _InfoRow(
              label: 'Customer ID',
              value: customer.id,
            ),
            _InfoRow(
              label: 'Full Name',
              value:
                  customer.displayName,
            ),
            _InfoRow(
              label: 'Email',
              value: customer.email,
            ),
            _InfoRow(
              label: 'Phone',
              value: customer.phone,
            ),
            _InfoRow(
              label: 'Joined',
              value: AppFormatters
                  .formatDate(
                customer.createdAt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    CustomerModel customer,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _InfoRow(
              label: 'Status',
              value: customer.isBlocked
                  ? 'Blocked'
                  : 'Active',
            ),

            _InfoRow(
              label: 'Verified',
              value:
                  customer.isVerified
                      ? 'Yes'
                      : 'No',
            ),

            _InfoRow(
              label: 'Last Login',
              value: customer.lastLoginAt !=
                      null
                  ? AppFormatters
                      .formatDateTime(
                      customer.lastLoginAt!,
                    )
                  : '-',
            ),

            _InfoRow(
              label: 'Wallet Balance',
              value: AppFormatters
                  .formatCurrency(
                customer.walletBalance,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    CustomerModel customer,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Edit Customer',
                icon: Icons.edit_outlined,
                onPressed: () {},
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: CustomButton(
                text: customer.isBlocked
                    ? 'Unblock'
                    : 'Block',
                type: customer.isBlocked
                    ? ButtonType.success
                    : ButtonType.warning,
                icon: customer.isBlocked
                    ? Icons.lock_open
                    : Icons.block,
                onPressed:
                    customer.isBlocked
                        ? _unblockCustomer
                        : _blockCustomer,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: CustomButton(
                text: 'Delete',
                type: ButtonType.danger,
                icon:
                    Icons.delete_outline,
                onPressed:
                    _deleteCustomer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    CustomerModel customer,
  ) {
    Color color = AppColors.success;
    String label = 'Active';

    if (customer.isBlocked) {
      color = AppColors.error;
      label = 'Blocked';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}