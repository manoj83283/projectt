import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/report_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class BookingReportScreen extends StatefulWidget {
  const BookingReportScreen({
    super.key,
  });

  @override
  State<BookingReportScreen> createState() => _BookingReportScreenState();
}

class _BookingReportScreenState extends State<BookingReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _reportTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedPeriod = 'monthly';
  String _selectedFormat = 'excel';
  String _selectedBookingType = 'all';
  String _selectedBookingStatus = 'all';

  DateTime? _startDate;
  DateTime? _endDate;

  bool _includeCustomerDetails = true;
  bool _includeProviderDetails = true;
  bool _includePaymentDetails = true;
  bool _includeCancellationDetails = true;
  bool _includeServiceBreakdown = true;
  bool _scheduleReport = false;
  bool _isGenerating = false;

  final List<String> _periods = const [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
    'custom',
  ];

  final List<String> _formats = const [
    'excel',
    'pdf',
    'csv',
  ];

  final List<String> _bookingTypes = const [
    'all',
    'event',
    'service',
    'venue',
    'catering',
    'decoration',
    'photography',
    'makeup',
    'dj',
  ];

  final List<String> _bookingStatuses = const [
    'all',
    'pending',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
    'rescheduled',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    _reportTitleController.text = 'Monthly Booking Report';
    _descriptionController.text =
        'Booking report including customer details, provider details, service breakdown, payments, cancellations and booking status summary.';
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Start Date',
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;

      if (_endDate != null && _endDate!.isBefore(selected)) {
        _endDate = selected;
      }

      _selectedPeriod = 'custom';
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? DateTime(2020),
      lastDate: now,
      helpText: 'Select End Date',
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
      _selectedPeriod = 'custom';
    });
  }

  void _onPeriodChanged(String? value) {
    if (value == null) return;

    final DateTime now = DateTime.now();

    setState(() {
      _selectedPeriod = value;

      switch (value) {
        case 'daily':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day);
          _reportTitleController.text = 'Daily Booking Report';
          break;
        case 'weekly':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          _reportTitleController.text = 'Weekly Booking Report';
          break;
        case 'monthly':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          _reportTitleController.text = 'Monthly Booking Report';
          break;
        case 'quarterly':
          final int quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
          _startDate = DateTime(now.year, quarterStartMonth, 1);
          _endDate = DateTime(now.year, quarterStartMonth + 3, 0);
          _reportTitleController.text = 'Quarterly Booking Report';
          break;
        case 'yearly':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          _reportTitleController.text = 'Yearly Booking Report';
          break;
        case 'custom':
          _reportTitleController.text = 'Custom Booking Report';
          break;
      }
    });
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    final DateTime now = DateTime.now();

    _formKey.currentState?.reset();

    setState(() {
      _selectedPeriod = 'monthly';
      _selectedFormat = 'excel';
      _selectedBookingType = 'all';
      _selectedBookingStatus = 'all';

      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);

      _reportTitleController.text = 'Monthly Booking Report';
      _descriptionController.text =
          'Booking report including customer details, provider details, service breakdown, payments, cancellations and booking status summary.';

      _includeCustomerDetails = true;
      _includeProviderDetails = true;
      _includePaymentDetails = true;
      _includeCancellationDetails = true;
      _includeServiceBreakdown = true;
      _scheduleReport = false;
    });
  }

  Future<void> _generateBookingReport() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      NavigationService.showWarning(
        'Please select report date range',
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
      _isGenerating = true;
    });

    final bool success =
        await context.read<ReportProvider>().generateBookingReport(
              title: _reportTitleController.text.trim(),
              description: _descriptionController.text.trim(),
              period: _selectedPeriod,
              format: _selectedFormat,
              bookingType: _selectedBookingType,
              bookingStatus: _selectedBookingStatus,
              startDate: _startDate!,
              endDate: _endDate!,
              includeCustomerDetails: _includeCustomerDetails,
              includeProviderDetails: _includeProviderDetails,
              includePaymentDetails: _includePaymentDetails,
              includeCancellationDetails: _includeCancellationDetails,
              includeServiceBreakdown: _includeServiceBreakdown,
              scheduleReport: _scheduleReport,
            );

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    if (success) {
      NavigationService.showSuccess(
        _scheduleReport
            ? 'Booking report scheduled successfully'
            : 'Booking report generation started successfully',
      );

      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError(
      context.read<ReportProvider>().errorMessage ??
          'Failed to generate booking report',
    );
  }

  void _previewReportConfiguration() {
    FocusScope.of(context).unfocus();

    showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
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
                          Icons.event_available_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Booking Report Preview',
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
                  const SizedBox(height: 22),
                  _PreviewRow(
                    label: 'Report Title',
                    value: _reportTitleController.text.trim().isEmpty
                        ? 'Booking Report'
                        : _reportTitleController.text.trim(),
                  ),
                  _PreviewRow(
                    label: 'Period',
                    value: AppFormatters.formatStatus(_selectedPeriod),
                  ),
                  _PreviewRow(
                    label: 'Booking Type',
                    value: AppFormatters.formatStatus(_selectedBookingType),
                  ),
                  _PreviewRow(
                    label: 'Booking Status',
                    value: AppFormatters.formatStatus(_selectedBookingStatus),
                  ),
                  _PreviewRow(
                    label: 'Format',
                    value: _selectedFormat.toUpperCase(),
                  ),
                  _PreviewRow(
                    label: 'Date Range',
                    value:
                        '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                  ),
                  _PreviewRow(
                    label: 'Delivery',
                    value: _scheduleReport ? 'Scheduled' : 'Immediate',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (_includeCustomerDetails)
                        const _StatusChip(
                          label: 'Customers',
                          color: AppColors.primary,
                        ),
                      if (_includeProviderDetails)
                        const _StatusChip(
                          label: 'Providers',
                          color: AppColors.info,
                        ),
                      if (_includePaymentDetails)
                        const _StatusChip(
                          label: 'Payments',
                          color: AppColors.success,
                        ),
                      if (_includeCancellationDetails)
                        const _StatusChip(
                          label: 'Cancellations',
                          color: AppColors.error,
                        ),
                      if (_includeServiceBreakdown)
                        const _StatusChip(
                          label: 'Service Breakdown',
                          color: Colors.purple,
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      text: 'Close',
                      type: ButtonType.outline,
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
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

  static String _formatDate(DateTime? value) {
    if (value == null) return 'Not Available';

    return AppFormatters.formatDate(value);
  }

  Widget _buildHeader() {
    return PageHeader(
      title: 'Booking Report',
      subtitle:
          'Generate detailed booking reports with customer, provider, service, payment, cancellation and booking status data.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isGenerating ? null : _previewReportConfiguration,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Back',
          type: ButtonType.outline,
          icon: Icons.arrow_back,
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildReportDetailsSection() {
    return _SectionCard(
      title: 'Report Details',
      icon: Icons.assessment_outlined,
      child: Column(
        children: [
          CustomTextFormFieldWrapper(
            controller: _reportTitleController,
            labelText: 'Report Title',
            hintText: 'Example: Monthly Booking Report',
            prefixIcon: Icons.title_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Report title is required';
              }

              if (value.trim().length < 3) {
                return 'Title must be at least 3 characters';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextFormFieldWrapper(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'Enter report description',
            prefixIcon: Icons.description_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return _SectionCard(
      title: 'Report Configuration',
      icon: Icons.tune_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return Column(
              children: [
                _buildPeriodDropdown(),
                const SizedBox(height: 16),
                _buildBookingTypeDropdown(),
                const SizedBox(height: 16),
                _buildBookingStatusDropdown(),
                const SizedBox(height: 16),
                _buildFormatDropdown(),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildPeriodDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBookingTypeDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildBookingStatusDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFormatDropdown()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return CustomDropdown<String>(
      labelText: 'Report Period',
      value: _selectedPeriod,
      items: _periods,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onPeriodChanged,
    );
  }

  Widget _buildBookingTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Booking Type',
      value: _selectedBookingType,
      items: _bookingTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedBookingType = value;
        });
      },
    );
  }

  Widget _buildBookingStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Booking Status',
      value: _selectedBookingStatus,
      items: _bookingStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedBookingStatus = value;
        });
      },
    );
  }

  Widget _buildFormatDropdown() {
    return CustomDropdown<String>(
      labelText: 'Report Format',
      value: _selectedFormat,
      items: _formats,
      itemLabelBuilder: (value) => value.toUpperCase(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedFormat = value;
        });
      },
    );
  }

  Widget _buildDateRangeSection() {
    return _SectionCard(
      title: 'Date Range',
      icon: Icons.date_range_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _DateTile(
                  title: 'Start Date',
                  value: _startDate,
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 16),
                _DateTile(
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
                child: _DateTile(
                  title: 'Start Date',
                  value: _startDate,
                  onTap: _pickStartDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DateTile(
                  title: 'End Date',
                  value: _endDate,
                  onTap: _pickEndDate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIncludedDataSection() {
    return _SectionCard(
      title: 'Included Data',
      icon: Icons.fact_check_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Include Customer Details',
            subtitle: 'Add customer name, phone, email and booking history',
            icon: Icons.person_outline,
            color: AppColors.primary,
            value: _includeCustomerDetails,
            onChanged: (value) {
              setState(() {
                _includeCustomerDetails = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Include Provider Details',
            subtitle: 'Add provider assignment, provider status and acceptance data',
            icon: Icons.engineering_outlined,
            color: AppColors.info,
            value: _includeProviderDetails,
            onChanged: (value) {
              setState(() {
                _includeProviderDetails = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Include Payment Details',
            subtitle: 'Add payment status, amount, method and transaction reference',
            icon: Icons.payments_outlined,
            color: AppColors.success,
            value: _includePaymentDetails,
            onChanged: (value) {
              setState(() {
                _includePaymentDetails = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Include Cancellation Details',
            subtitle: 'Add cancellation reason, cancelled by and refund impact',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            value: _includeCancellationDetails,
            onChanged: (value) {
              setState(() {
                _includeCancellationDetails = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Include Service Breakdown',
            subtitle: 'Add category, service, event date, location and demand summary',
            icon: Icons.design_services_outlined,
            color: Colors.purple,
            value: _includeServiceBreakdown,
            onChanged: (value) {
              setState(() {
                _includeServiceBreakdown = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _SectionCard(
      title: 'Report Delivery',
      icon: Icons.schedule_outlined,
      child: SwitchListTile(
        value: _scheduleReport,
        activeThumbColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Schedule Report',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          _scheduleReport
              ? 'Report will be generated as a scheduled job'
              : 'Report will be generated immediately',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        secondary: Icon(
          _scheduleReport ? Icons.schedule_outlined : Icons.flash_on_outlined,
          color: _scheduleReport ? AppColors.primary : AppColors.success,
        ),
        onChanged: _isGenerating
            ? null
            : (value) {
                setState(() {
                  _scheduleReport = value;
                });
              },
      ),
    );
  }

  Widget _buildActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 760;

        final List<Widget> actions = [
          CustomButton(
            text: 'Reset',
            type: ButtonType.outline,
            icon: Icons.refresh,
            onPressed: _isGenerating ? null : _resetForm,
          ),
          CustomButton(
            text: 'Preview',
            type: ButtonType.outline,
            icon: Icons.visibility_outlined,
            onPressed: _isGenerating ? null : _previewReportConfiguration,
          ),
          CustomButton(
            text: _scheduleReport ? 'Schedule Report' : 'Generate Report',
            icon: _scheduleReport
                ? Icons.schedule_outlined
                : Icons.add_chart_outlined,
            isLoading: _isGenerating,
            onPressed: _isGenerating ? null : _generateBookingReport,
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

        return Row(
          children: [
            Expanded(child: actions[0]),
            const SizedBox(width: 12),
            Expanded(child: actions[1]),
            const SizedBox(width: 12),
            Expanded(child: actions[2]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
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
                  child: Form(
                    key: _formKey,
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
                        _buildReportDetailsSection(),
                        const SizedBox(height: 20),
                        _buildConfigurationSection(),
                        const SizedBox(height: 20),
                        _buildDateRangeSection(),
                        const SizedBox(height: 20),
                        _buildIncludedDataSection(),
                        const SizedBox(height: 20),
                        _buildScheduleSection(),
                        const SizedBox(height: 28),
                        _buildActions(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                if (_isGenerating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.06),
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

class CustomTextFormFieldWrapper extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomTextFormFieldWrapper({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class _DateTile extends StatelessWidget {
  final String title;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(
          value == null ? 'Select date' : AppFormatters.formatDate(value!),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: value == null ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _SwitchOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: color,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
      secondary: Icon(
        icon,
        color: color,
      ),
      onChanged: onChanged,
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
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
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
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