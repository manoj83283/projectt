import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/coupon_provider.dart';
import '../../widgets/common/custom_dropdown.dart';

class AddCouponScreen extends StatefulWidget {
  const AddCouponScreen({
    super.key,
  });

  @override
  State<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  final TextEditingController _minimumOrderAmountController =
      TextEditingController();
  final TextEditingController _maximumDiscountAmountController =
      TextEditingController();
  final TextEditingController _usageLimitController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedDiscountType;
  String? _selectedStatus;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;

  final List<String> _discountTypes = const [
    'percentage',
    'fixed',
    'free_delivery',
    'cashback',
  ];

  final List<String> _couponStatuses = const [
    'active',
    'inactive',
    'scheduled',
  ];

  @override
  void initState() {
    super.initState();

    _selectedDiscountType = 'percentage';
    _selectedStatus = 'inactive';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minimumOrderAmountController.dispose();
    _maximumDiscountAmountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    final CouponProvider provider = context.read<CouponProvider>();

    if (provider.categories.isEmpty) {
      await provider.getCouponCategories();
    }
  }

  Future<void> _selectDate({
    required bool isStartDate,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime initialDate = isStartDate
        ? _startDate ?? now
        : _endDate ?? _startDate ?? now.add(const Duration(days: 1));

    final DateTime firstDate = isStartDate ? now : _startDate ?? now;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      helpText: isStartDate ? 'Select Start Date' : 'Select End Date',
    );

    if (selectedDate == null) return;

    setState(() {
      if (isStartDate) {
        _startDate = selectedDate;

        if (_endDate != null && _endDate!.isBefore(selectedDate)) {
          _endDate = null;
        }
      } else {
        _endDate = selectedDate;
      }
    });
  }

  Future<void> _createCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      _showSnackBar(
        message: 'Please select start date',
        isError: true,
      );
      return;
    }

    if (_endDate == null) {
      _showSnackBar(
        message: 'Please select end date',
        isError: true,
      );
      return;
    }

    if (_selectedDiscountType == null) {
      _showSnackBar(
        message: 'Please select discount type',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await context.read<CouponProvider>().createCoupon(
          code: _codeController.text.trim().toUpperCase(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          discountType: _selectedDiscountType!,
          discountValue: double.tryParse(
                _discountValueController.text.trim(),
              ) ??
              0,
          minimumOrderAmount: double.tryParse(
                _minimumOrderAmountController.text.trim(),
              ) ??
              0,
          maximumDiscountAmount: double.tryParse(
                _maximumDiscountAmountController.text.trim(),
              ) ??
              0,
          usageLimit: int.tryParse(
                _usageLimitController.text.trim(),
              ) ??
              0,
          status: _selectedStatus ?? 'inactive',
          startDate: _startDate!,
          endDate: _endDate!,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      _showSnackBar(
        message: 'Coupon created successfully',
        isError: false,
      );

      Navigator.pop(context, true);
      return;
    }

    _showSnackBar(
      message: 'Failed to create coupon',
      isError: true,
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    setState(() {
      _codeController.clear();
      _titleController.clear();
      _descriptionController.clear();
      _discountValueController.clear();
      _minimumOrderAmountController.clear();
      _maximumDiscountAmountController.clear();
      _usageLimitController.clear();

      _selectedCategoryId = null;
      _selectedDiscountType = 'percentage';
      _selectedStatus = 'inactive';

      _startDate = null;
      _endDate = null;
    });
  }

  void _showSnackBar({
    required String message,
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Coupon',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Configure coupon code, discount rules, validity, usage limit, and category eligibility.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponBasicDetails() {
    return _SectionCard(
      title: 'Coupon Basic Details',
      icon: Icons.info_outline,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 760;

            if (isCompact) {
              return Column(
                children: [
                  _buildCodeField(),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildCodeField()),
                const SizedBox(width: 16),
                Expanded(child: _buildTitleField()),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter coupon description',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }

            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      controller: _codeController,
      textCapitalization: TextCapitalization.characters,
      decoration: const InputDecoration(
        labelText: 'Coupon Code',
        hintText: 'EX: EVENTEASE20',
        prefixIcon: Icon(Icons.confirmation_number_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        final String formatted = value.toUpperCase().replaceAll(' ', '');

        if (formatted != value) {
          _codeController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(
              offset: formatted.length,
            ),
          );
        }
      },
      validator: (value) {
        final String code = value?.trim() ?? '';

        if (code.isEmpty) {
          return 'Coupon code is required';
        }

        if (code.length < 4) {
          return 'Coupon code must be at least 4 characters';
        }

        if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(code)) {
          return 'Only uppercase letters, numbers, underscore and hyphen are allowed';
        }

        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Coupon Title',
        hintText: 'EX: Festival offer',
        prefixIcon: Icon(Icons.title_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Coupon title is required';
        }

        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }

        return null;
      },
    );
  }

  Widget _buildDiscountDetails() {
    return _SectionCard(
      title: 'Discount Configuration',
      icon: Icons.discount_outlined,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 760;

            if (isCompact) {
              return Column(
                children: [
                  _buildDiscountTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildDiscountValueField(),
                  const SizedBox(height: 16),
                  _buildMaximumDiscountField(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildDiscountTypeDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildDiscountValueField()),
                const SizedBox(width: 16),
                Expanded(child: _buildMaximumDiscountField()),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 760;

            if (isCompact) {
              return Column(
                children: [
                  _buildMinimumOrderField(),
                  const SizedBox(height: 16),
                  _buildUsageLimitField(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildMinimumOrderField()),
                const SizedBox(width: 16),
                Expanded(child: _buildUsageLimitField()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Discount Type',
      value: _selectedDiscountType,
      items: _discountTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _selectedDiscountType = value;

          if (value == 'free_delivery') {
            _discountValueController.text = '0';
            _maximumDiscountAmountController.text = '0';
          }
        });
      },
    );
  }

  Widget _buildDiscountValueField() {
    return TextFormField(
      controller: _discountValueController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      enabled: _selectedDiscountType != 'free_delivery',
      decoration: InputDecoration(
        labelText: _selectedDiscountType == 'percentage'
            ? 'Discount Percentage'
            : 'Discount Value',
        hintText: _selectedDiscountType == 'percentage' ? 'EX: 20' : 'EX: 500',
        prefixIcon: Icon(
          _selectedDiscountType == 'percentage'
              ? Icons.percent
              : Icons.currency_rupee_rounded,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (_selectedDiscountType == 'free_delivery') return null;

        final double? amount = double.tryParse(value?.trim() ?? '');

        if (amount == null) {
          return 'Discount value is required';
        }

        if (amount <= 0) {
          return 'Discount value must be greater than 0';
        }

        if (_selectedDiscountType == 'percentage' && amount > 100) {
          return 'Percentage cannot be greater than 100';
        }

        return null;
      },
    );
  }

  Widget _buildMaximumDiscountField() {
    return TextFormField(
      controller: _maximumDiscountAmountController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      enabled: _selectedDiscountType != 'free_delivery',
      decoration: const InputDecoration(
        labelText: 'Maximum Discount',
        hintText: 'EX: 1000',
        prefixIcon: Icon(Icons.currency_rupee_rounded),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_selectedDiscountType == 'free_delivery') return null;

        final double amount = double.tryParse(value?.trim() ?? '') ?? 0;

        if (_selectedDiscountType == 'percentage' && amount <= 0) {
          return 'Maximum discount is required for percentage coupons';
        }

        return null;
      },
    );
  }

  Widget _buildMinimumOrderField() {
    return TextFormField(
      controller: _minimumOrderAmountController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: const InputDecoration(
        labelText: 'Minimum Order Amount',
        hintText: 'EX: 999',
        prefixIcon: Icon(Icons.shopping_cart_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final double amount = double.tryParse(value?.trim() ?? '') ?? 0;

        if (amount < 0) {
          return 'Minimum order amount cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildUsageLimitField() {
    return TextFormField(
      controller: _usageLimitController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Usage Limit',
        hintText: '0 means unlimited',
        prefixIcon: Icon(Icons.redeem_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final int limit = int.tryParse(value?.trim() ?? '') ?? 0;

        if (limit < 0) {
          return 'Usage limit cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildEligibilityDetails(CouponProvider provider) {
    return _SectionCard(
      title: 'Eligibility and Status',
      icon: Icons.rule_outlined,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 760;

            if (isCompact) {
              return Column(
                children: [
                  _buildCategoryDropdown(provider),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _buildCategoryDropdown(provider)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusDropdown()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(CouponProvider provider) {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _selectedCategoryId,
      items: provider.categories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _couponStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }

  Widget _buildValidityDetails() {
    return _SectionCard(
      title: 'Validity Period',
      icon: Icons.date_range_outlined,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 760;

            if (isCompact) {
              return Column(
                children: [
                  _DateSelectorTile(
                    label: 'Start Date',
                    value: _startDate,
                    onTap: () => _selectDate(isStartDate: true),
                  ),
                  const SizedBox(height: 16),
                  _DateSelectorTile(
                    label: 'End Date',
                    value: _endDate,
                    onTap: () => _selectDate(isStartDate: false),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _DateSelectorTile(
                    label: 'Start Date',
                    value: _startDate,
                    onTap: () => _selectDate(isStartDate: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateSelectorTile(
                    label: 'End Date',
                    value: _endDate,
                    onTap: () => _selectDate(isStartDate: false),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _clearForm,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear'),
          ),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _createCoupon,
            icon: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSubmitting ? 'Creating...' : 'Create Coupon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
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
                    _buildCouponBasicDetails(),
                    const SizedBox(height: 18),
                    _buildDiscountDetails(),
                    const SizedBox(height: 18),
                    _buildEligibilityDetails(provider),
                    const SizedBox(height: 18),
                    _buildValidityDetails(),
                    const SizedBox(height: 24),
                    _buildFormActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateSelectorTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayValue = value == null
        ? 'Select date'
        : AppFormatters.formatDate(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(
          displayValue,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: value == null ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ),
    );
  }
}