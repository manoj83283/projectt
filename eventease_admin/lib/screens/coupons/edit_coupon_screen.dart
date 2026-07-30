import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/coupon_model.dart';
import '../../providers/coupon_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/date_picker_field.dart';
import '../../widgets/common/page_header.dart';

class EditCouponScreen extends StatefulWidget {
  final CouponModel coupon;

  const EditCouponScreen({
    super.key,
    required this.coupon,
  });

  @override
  State<EditCouponScreen> createState() => _EditCouponScreenState();
}

class _EditCouponScreenState extends State<EditCouponScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  final TextEditingController _minimumOrderController =
      TextEditingController();
  final TextEditingController _maximumDiscountController =
      TextEditingController();
  final TextEditingController _usageLimitController = TextEditingController();
  final TextEditingController _perUserLimitController =
      TextEditingController();

  String? _discountType;
  String? _selectedCategory;
  String? _selectedService;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _discountTypes = const [
    'percentage',
    'fixed',
    'cashback',
    'free_delivery',
  ];

  @override
  void initState() {
    super.initState();

    _setInitialValues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setInitialValues() {
    final CouponModel coupon = widget.coupon;

    _codeController.text = coupon.code;
    _titleController.text = coupon.title;
    _descriptionController.text = coupon.description;
    _discountValueController.text = coupon.discountValue.toString();
    _minimumOrderController.text = coupon.minimumOrderAmount.toString();
    _maximumDiscountController.text = coupon.maximumDiscountAmount.toString();
    _usageLimitController.text = coupon.usageLimit.toString();

    _perUserLimitController.text = coupon.perUserLimit.toString();

    _discountType = coupon.discountType;
    _selectedCategory = coupon.categoryId.isEmpty ? null : coupon.categoryId;
    _selectedService = coupon.serviceId.isEmpty ? null : coupon.serviceId;

    _startDate = coupon.startDate;
    _endDate = coupon.endDate;

    _isActive = coupon.isActive;
  }

  Future<void> _loadInitialData() async {
    final CouponProvider provider = context.read<CouponProvider>();

    if (provider.categories.isEmpty) {
      await provider.getCouponCategories();
    }

    if (provider.services.isEmpty) {
      await provider.getCouponServices();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minimumOrderController.dispose();
    _maximumDiscountController.dispose();
    _usageLimitController.dispose();
    _perUserLimitController.dispose();
    super.dispose();
  }

  void _generateCouponCode() {
    final String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(8);

    setState(() {
      _codeController.text = 'EVT$timestamp';
    });
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime initialDate = _startDate ?? now;

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(2035),
      helpText: 'Select Start Date',
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;

      if (_endDate != null && _endDate!.isBefore(selected)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime now = DateTime.now();

    final DateTime firstDate = _startDate ?? now;

    final DateTime initialDate = _endDate ??
        (_startDate != null
            ? _startDate!.add(const Duration(days: 1))
            : now.add(const Duration(days: 1)));

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2035),
      helpText: 'Select End Date',
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
    });
  }

  Future<void> _updateCoupon() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_discountType == null) {
      NavigationService.showWarning(
        'Select discount type',
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      NavigationService.showWarning(
        'Select coupon validity',
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      NavigationService.showWarning(
        'End date cannot be before start date',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await context.read<CouponProvider>().updateCoupon(
          couponId: widget.coupon.id,
          code: _codeController.text.trim().toUpperCase(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          discountType: _discountType!,
          discountValue: double.parse(
            _discountValueController.text.trim(),
          ),
          minimumOrderAmount: double.parse(
            _minimumOrderController.text.trim(),
          ),
          maximumDiscountAmount: double.parse(
            _maximumDiscountController.text.trim(),
          ),
          usageLimit: int.parse(
            _usageLimitController.text.trim(),
          ),
          perUserLimit: int.parse(
            _perUserLimitController.text.trim(),
          ),
          categoryId: _selectedCategory,
          serviceId: _selectedService,
          startDate: _startDate!,
          endDate: _endDate!,
          isActive: _isActive,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Coupon updated successfully',
      );

      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError(
      context.read<CouponProvider>().errorMessage ?? 'Failed to update coupon',
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    setState(() {
      _setInitialValues();
    });
  }

  Widget _buildCouponInfoSection() {
    return _SectionCard(
      title: 'Coupon Information',
      icon: Icons.confirmation_number_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildCouponCodeField(),
                    const SizedBox(height: 16),
                    _buildTitleField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildCouponCodeField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTitleField(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'Enter coupon description',
            maxLines: 4,
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
      ),
    );
  }

  Widget _buildCouponCodeField() {
    return CustomTextField(
      controller: _codeController,
      labelText: 'Coupon Code',
      hintText: 'Example: EVT2026',
      prefixIcon: Icons.confirmation_number_outlined,
      suffixIcon: Icons.auto_awesome,
      onSuffixTap: _generateCouponCode,
      textCapitalization: TextCapitalization.characters,
      onChanged: (value) {
        final String formatted = value.toUpperCase().replaceAll(' ', '');

        if (formatted == value) return;

        _codeController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: formatted.length,
          ),
        );
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
          return 'Only uppercase letters, numbers, underscore and hyphen allowed';
        }

        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return CustomTextField(
      controller: _titleController,
      labelText: 'Coupon Title',
      hintText: 'Example: Festival offer',
      prefixIcon: Icons.title_outlined,
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

  Widget _buildDiscountSection() {
    return _SectionCard(
      title: 'Discount Details',
      icon: Icons.discount_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return Column(
              children: [
                _buildDiscountTypeDropdown(),
                const SizedBox(height: 16),
                _buildDiscountValueField(),
                const SizedBox(height: 16),
                _buildMinimumOrderField(),
                const SizedBox(height: 16),
                _buildMaximumDiscountField(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildDiscountTypeDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDiscountValueField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMinimumOrderField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMaximumDiscountField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Discount Type',
      value: _discountType,
      items: _discountTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _discountType = value;

          if (value == 'free_delivery') {
            _discountValueController.text = '0';
            _maximumDiscountController.text = '0';
          }
        });
      },
    );
  }

  Widget _buildDiscountValueField() {
    return CustomTextField(
      controller: _discountValueController,
      labelText: _discountType == 'percentage'
          ? 'Discount Percentage'
          : 'Discount Value',
      hintText: _discountType == 'percentage' ? 'Example: 20' : 'Example: 500',
      prefixIcon:
          _discountType == 'percentage' ? Icons.percent : Icons.currency_rupee,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      enabled: _discountType != 'free_delivery',
      validator: (value) {
        if (_discountType == 'free_delivery') {
          return null;
        }

        final double? discount = double.tryParse(value?.trim() ?? '');

        if (discount == null) {
          return 'Discount value is required';
        }

        if (discount <= 0) {
          return 'Discount value must be greater than 0';
        }

        if (_discountType == 'percentage' && discount > 100) {
          return 'Percentage cannot be greater than 100';
        }

        return null;
      },
    );
  }

  Widget _buildMinimumOrderField() {
    return CustomTextField(
      controller: _minimumOrderController,
      labelText: 'Minimum Order Amount',
      hintText: 'Example: 999',
      prefixIcon: Icons.shopping_cart_outlined,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: (value) {
        final double? amount = double.tryParse(value?.trim() ?? '');

        if (amount == null) {
          return 'Minimum order amount is required';
        }

        if (amount < 0) {
          return 'Amount cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildMaximumDiscountField() {
    return CustomTextField(
      controller: _maximumDiscountController,
      labelText: 'Maximum Discount Amount',
      hintText: 'Example: 1000',
      prefixIcon: Icons.currency_rupee_rounded,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      enabled: _discountType != 'free_delivery',
      validator: (value) {
        if (_discountType == 'free_delivery') {
          return null;
        }

        final double? amount = double.tryParse(value?.trim() ?? '');

        if (amount == null) {
          return 'Maximum discount is required';
        }

        if (amount < 0) {
          return 'Maximum discount cannot be negative';
        }

        if (_discountType == 'percentage' && amount <= 0) {
          return 'Maximum discount is required for percentage coupons';
        }

        return null;
      },
    );
  }

  Widget _buildUsageSection() {
    return _SectionCard(
      title: 'Usage Rules',
      icon: Icons.redeem_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildUsageLimitField(),
                const SizedBox(height: 16),
                _buildPerUserLimitField(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildUsageLimitField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerUserLimitField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsageLimitField() {
    return CustomTextField(
      controller: _usageLimitController,
      labelText: 'Usage Limit',
      hintText: '0 means unlimited',
      prefixIcon: Icons.redeem_outlined,
      keyboardType: TextInputType.number,
      validator: (value) {
        final int? limit = int.tryParse(value?.trim() ?? '');

        if (limit == null) {
          return 'Usage limit is required';
        }

        if (limit < 0) {
          return 'Usage limit cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildPerUserLimitField() {
    return CustomTextField(
      controller: _perUserLimitController,
      labelText: 'Per User Limit',
      hintText: 'Example: 1',
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.number,
      validator: (value) {
        final int? limit = int.tryParse(value?.trim() ?? '');

        if (limit == null) {
          return 'Per user limit is required';
        }

        if (limit <= 0) {
          return 'Per user limit must be greater than 0';
        }

        return null;
      },
    );
  }

  Widget _buildEligibilitySection(CouponProvider provider) {
    return _SectionCard(
      title: 'Eligibility',
      icon: Icons.rule_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildCategoryDropdown(provider),
                const SizedBox(height: 16),
                _buildServiceDropdown(provider),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildCategoryDropdown(provider),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildServiceDropdown(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(CouponProvider provider) {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _selectedCategory,
      items: provider.categories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
          _selectedService = null;
        });
      },
    );
  }

  Widget _buildServiceDropdown(CouponProvider provider) {
    return CustomDropdown<String>(
      labelText: 'Service',
      value: _selectedService,
      items: provider.services,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _selectedService = value;
        });
      },
    );
  }

  Widget _buildValiditySection() {
    return _SectionCard(
      title: 'Validity',
      icon: Icons.date_range_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    DatePickerField(
                      title: 'Start Date',
                      value: _startDate,
                      onTap: _pickStartDate,
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      title: 'End Date',
                      value: _endDate,
                      onTap: _pickEndDate,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: DatePickerField(
                      title: 'Start Date',
                      value: _startDate,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DatePickerField(
                      title: 'End Date',
                      value: _endDate,
                      onTap: _pickEndDate,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          SwitchListTile(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.success,
            title: const Text(
              'Coupon Active',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              _isActive
                  ? 'Coupon is available for customers'
                  : 'Coupon is inactive and hidden from customers',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            secondary: Icon(
              _isActive
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              color: _isActive ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Reset',
            type: ButtonType.outline,
            icon: Icons.refresh,
            onPressed: _isSubmitting ? null : _resetForm,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Update Coupon',
            icon: Icons.check_circle_outline,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _updateCoupon,
          ),
        ),
      ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      title: 'Edit Coupon',
                      subtitle:
                          'Update coupon campaign rules, validity, eligibility and usage limits.',
                      actions: [
                        CustomButton(
                          text: 'Back',
                          type: ButtonType.outline,
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildCouponInfoSection(),
                    const SizedBox(height: 20),
                    _buildDiscountSection(),
                    const SizedBox(height: 20),
                    _buildUsageSection(),
                    const SizedBox(height: 20),
                    _buildEligibilitySection(provider),
                    const SizedBox(height: 20),
                    _buildValiditySection(),
                    const SizedBox(height: 28),
                    _buildActions(),
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
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