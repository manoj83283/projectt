import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/category_commission_model.dart';
import '../../providers/settings_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class CommissionSettingsScreen extends StatefulWidget {
  const CommissionSettingsScreen({
    super.key,
  });

  @override
  State<CommissionSettingsScreen> createState() =>
      _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _platformCommissionController =
      TextEditingController();
  final TextEditingController _providerCommissionController =
      TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _minimumCommissionController =
      TextEditingController();
  final TextEditingController _maximumCommissionController =
      TextEditingController();
  final TextEditingController _settlementCycleController =
      TextEditingController();

  String _commissionType = 'percentage';
  String _settlementMode = 'weekly';

  bool _autoSettlementEnabled = true;
  bool _revenueSharingEnabled = false;
  bool _gstEnabled = true;
  bool _categoryWiseCommissionEnabled = true;
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _commissionTypes = const [
    'percentage',
    'fixed',
  ];

  final List<String> _settlementModes = const [
    'daily',
    'weekly',
    'biweekly',
    'monthly',
    'manual',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommissionSettings();
    });
  }

  @override
  void dispose() {
    _platformCommissionController.dispose();
    _providerCommissionController.dispose();
    _gstController.dispose();
    _minimumCommissionController.dispose();
    _maximumCommissionController.dispose();
    _settlementCycleController.dispose();
    super.dispose();
  }

  Future<void> _loadCommissionSettings() async {
    setState(() {
      _isLoading = true;
    });

    final SettingsProvider provider = context.read<SettingsProvider>();

    await provider.getCommissionSettings();

    if (!mounted) return;

    _commissionType = provider.commissionType.isEmpty
        ? 'percentage'
        : provider.commissionType;

    _settlementMode = provider.settlementMode.isEmpty
        ? 'weekly'
        : provider.settlementMode;

    _platformCommissionController.text =
        provider.platformCommission.toStringAsFixed(2);
    _providerCommissionController.text =
        provider.providerCommission.toStringAsFixed(2);
    _gstController.text = provider.gstPercentage.toStringAsFixed(2);
    _minimumCommissionController.text =
        provider.minimumCommission.toStringAsFixed(2);
    _maximumCommissionController.text =
        provider.maximumCommission.toStringAsFixed(2);
    _settlementCycleController.text = provider.settlementCycleDays.toString();

    _autoSettlementEnabled = provider.autoSettlementEnabled;
    _revenueSharingEnabled = provider.revenueSharingEnabled;
    _gstEnabled = provider.gstEnabled;
    _categoryWiseCommissionEnabled = provider.categoryWiseCommissionEnabled;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadCommissionSettings();
  }

  void _resetSettings() {
    FocusScope.of(context).unfocus();

    final SettingsProvider provider = context.read<SettingsProvider>();

    setState(() {
      _commissionType =
          provider.commissionType.isEmpty ? 'percentage' : provider.commissionType;
      _settlementMode =
          provider.settlementMode.isEmpty ? 'weekly' : provider.settlementMode;

      _platformCommissionController.text =
          provider.platformCommission.toStringAsFixed(2);
      _providerCommissionController.text =
          provider.providerCommission.toStringAsFixed(2);
      _gstController.text = provider.gstPercentage.toStringAsFixed(2);
      _minimumCommissionController.text =
          provider.minimumCommission.toStringAsFixed(2);
      _maximumCommissionController.text =
          provider.maximumCommission.toStringAsFixed(2);
      _settlementCycleController.text = provider.settlementCycleDays.toString();

      _autoSettlementEnabled = provider.autoSettlementEnabled;
      _revenueSharingEnabled = provider.revenueSharingEnabled;
      _gstEnabled = provider.gstEnabled;
      _categoryWiseCommissionEnabled = provider.categoryWiseCommissionEnabled;
    });
  }

  Future<void> _saveSettings() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double platformCommission =
        double.tryParse(_platformCommissionController.text.trim()) ?? 0;
    final double providerCommission =
        double.tryParse(_providerCommissionController.text.trim()) ?? 0;
    final double gst = double.tryParse(_gstController.text.trim()) ?? 0;
    final double minCommission =
        double.tryParse(_minimumCommissionController.text.trim()) ?? 0;
    final double maxCommission =
        double.tryParse(_maximumCommissionController.text.trim()) ?? 0;
    final int settlementCycleDays =
        int.tryParse(_settlementCycleController.text.trim()) ?? 0;

    if (_commissionType == 'percentage' && platformCommission > 100) {
      NavigationService.showWarning(
        'Platform commission cannot be greater than 100%',
      );
      return;
    }

    if (_commissionType == 'percentage' && providerCommission > 100) {
      NavigationService.showWarning(
        'Provider commission cannot be greater than 100%',
      );
      return;
    }

    if (maxCommission > 0 && minCommission > maxCommission) {
      NavigationService.showWarning(
        'Minimum commission cannot be greater than maximum commission',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().updateCommissionSettings(
              commissionType: _commissionType,
              platformCommission: platformCommission,
              providerCommission: providerCommission,
              gst: gst,
              minCommission: minCommission,
              maxCommission: maxCommission,
              autoSettlement: _autoSettlementEnabled,
              revenueSharing: _revenueSharingEnabled,
              gstEnabled: _gstEnabled,
              categoryWiseCommissionEnabled: _categoryWiseCommissionEnabled,
              settlementMode: _settlementMode,
              settlementCycleDays: settlementCycleDays,
            );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Commission settings updated successfully',
      );

      await _loadCommissionSettings();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to update commission settings',
    );
  }

  Future<void> _editCategoryCommission(CategoryCommissionModel item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _CategoryCommissionDialog(
          item: item,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _loadCommissionSettings();
    }
  }

  Future<void> _deleteCategoryCommission(CategoryCommissionModel item) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Category Commission',
      message:
          'Are you sure you want to delete commission rule for ${item.categoryName}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<SettingsProvider>()
        .deleteCategoryCommission(item.categoryId);

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Category commission deleted successfully',
      );

      await _loadCommissionSettings();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to delete category commission',
    );
  }

  Future<void> _addCategoryCommission() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return const _CategoryCommissionDialog();
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _loadCommissionSettings();
    }
  }

  void _previewSettings() {
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
              maxWidth: 680,
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
                          Icons.percent_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Commission Settings Preview',
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
                    label: 'Commission Type',
                    value: AppFormatters.formatStatus(_commissionType),
                  ),
                  _PreviewRow(
                    label: 'Platform Commission',
                    value:
                        '${_platformCommissionController.text.trim()}${_commissionType == 'percentage' ? '%' : ''}',
                  ),
                  _PreviewRow(
                    label: 'Provider Share',
                    value:
                        '${_providerCommissionController.text.trim()}${_commissionType == 'percentage' ? '%' : ''}',
                  ),
                  _PreviewRow(
                    label: 'GST',
                    value: _gstEnabled
                        ? '${_gstController.text.trim()}%'
                        : 'Disabled',
                  ),
                  _PreviewRow(
                    label: 'Commission Range',
                    value:
                        '${_minimumCommissionController.text.trim()} to ${_maximumCommissionController.text.trim()}',
                  ),
                  _PreviewRow(
                    label: 'Settlement Mode',
                    value: AppFormatters.formatStatus(_settlementMode),
                  ),
                  _PreviewRow(
                    label: 'Settlement Cycle',
                    value: '${_settlementCycleController.text.trim()} days',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: _autoSettlementEnabled
                            ? 'Auto Settlement On'
                            : 'Auto Settlement Off',
                        color: _autoSettlementEnabled
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      _StatusChip(
                        label: _revenueSharingEnabled
                            ? 'Revenue Sharing On'
                            : 'Revenue Sharing Off',
                        color: _revenueSharingEnabled
                            ? AppColors.primary
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _categoryWiseCommissionEnabled
                            ? 'Category Rules On'
                            : 'Category Rules Off',
                        color: _categoryWiseCommissionEnabled
                            ? Colors.purple
                            : Colors.blueGrey,
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

  Widget _buildHeader() {
    return PageHeader(
      title: 'Commission Settings',
      subtitle:
          'Configure platform commission, provider share, GST, category-wise rules, settlement mode and revenue sharing.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewSettings,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Refresh',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading || _isSaving ? null : _refresh,
        ),
      ],
    );
  }

  Widget _buildSummaryCards(SettingsProvider provider) {
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
            _CommissionSummaryCard(
              title: 'Platform Commission',
              value:
                  '${provider.platformCommission.toStringAsFixed(2)}${provider.commissionType == 'percentage' ? '%' : ''}',
              icon: Icons.percent_outlined,
              color: AppColors.primary,
            ),
            _CommissionSummaryCard(
              title: 'Provider Share',
              value:
                  '${provider.providerCommission.toStringAsFixed(2)}${provider.commissionType == 'percentage' ? '%' : ''}',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.success,
            ),
            _CommissionSummaryCard(
              title: 'GST',
              value: provider.gstEnabled
                  ? '${provider.gstPercentage.toStringAsFixed(2)}%'
                  : 'Off',
              icon: Icons.receipt_long_outlined,
              color: AppColors.warning,
            ),
            _CommissionSummaryCard(
              title: 'Category Rules',
              value: provider.categoryCommissions.length.toString(),
              icon: Icons.category_outlined,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommissionRulesSection() {
    return _SectionCard(
      title: 'Commission Rules',
      icon: Icons.tune_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildCommissionTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildPlatformCommissionField(),
                    const SizedBox(height: 16),
                    _buildProviderCommissionField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildCommissionTypeDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPlatformCommissionField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProviderCommissionField()),
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
                    _buildMinimumCommissionField(),
                    const SizedBox(height: 16),
                    _buildMaximumCommissionField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildMinimumCommissionField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMaximumCommissionField()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Commission Type',
      value: _commissionType,
      items: _commissionTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _commissionType = value;
        });
      },
    );
  }

  Widget _buildPlatformCommissionField() {
    return _NumberTextField(
      controller: _platformCommissionController,
      labelText: 'Platform Commission',
      hintText: _commissionType == 'percentage' ? 'Example: 10' : 'Example: 100',
      prefixIcon: Icons.percent_outlined,
      validator: _numberValidator(
        fieldName: 'Platform commission',
        allowZero: true,
      ),
    );
  }

  Widget _buildProviderCommissionField() {
    return _NumberTextField(
      controller: _providerCommissionController,
      labelText: 'Provider Commission',
      hintText: _commissionType == 'percentage' ? 'Example: 90' : 'Example: 900',
      prefixIcon: Icons.account_balance_wallet_outlined,
      validator: _numberValidator(
        fieldName: 'Provider commission',
        allowZero: true,
      ),
    );
  }

  Widget _buildMinimumCommissionField() {
    return _NumberTextField(
      controller: _minimumCommissionController,
      labelText: 'Minimum Commission',
      hintText: 'Example: 0',
      prefixIcon: Icons.arrow_downward_outlined,
      validator: _numberValidator(
        fieldName: 'Minimum commission',
        allowZero: true,
      ),
    );
  }

  Widget _buildMaximumCommissionField() {
    return _NumberTextField(
      controller: _maximumCommissionController,
      labelText: 'Maximum Commission',
      hintText: 'Example: 9999',
      prefixIcon: Icons.arrow_upward_outlined,
      validator: _numberValidator(
        fieldName: 'Maximum commission',
        allowZero: true,
      ),
    );
  }

  Widget _buildTaxSettlementSection() {
    return _SectionCard(
      title: 'Tax and Settlement',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildGstField(),
                    const SizedBox(height: 16),
                    _buildSettlementModeDropdown(),
                    const SizedBox(height: 16),
                    _buildSettlementCycleField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildGstField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSettlementModeDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSettlementCycleField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Enable GST',
            subtitle: 'Apply GST on platform commission and service invoices',
            icon: Icons.receipt_long_outlined,
            color: AppColors.warning,
            value: _gstEnabled,
            onChanged: (value) {
              setState(() {
                _gstEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Auto Settlement',
            subtitle: 'Automatically settle provider earnings based on cycle',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.success,
            value: _autoSettlementEnabled,
            onChanged: (value) {
              setState(() {
                _autoSettlementEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Revenue Sharing',
            subtitle: 'Allow shared revenue rules across platform and providers',
            icon: Icons.handshake_outlined,
            color: AppColors.primary,
            value: _revenueSharingEnabled,
            onChanged: (value) {
              setState(() {
                _revenueSharingEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Category-wise Commission',
            subtitle: 'Use category-specific commission rules when available',
            icon: Icons.category_outlined,
            color: Colors.purple,
            value: _categoryWiseCommissionEnabled,
            onChanged: (value) {
              setState(() {
                _categoryWiseCommissionEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGstField() {
    return _NumberTextField(
      controller: _gstController,
      labelText: 'GST (%)',
      hintText: 'Example: 18',
      prefixIcon: Icons.receipt_long_outlined,
      enabled: _gstEnabled,
      validator: _numberValidator(
        fieldName: 'GST',
        allowZero: true,
      ),
    );
  }

  Widget _buildSettlementModeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Settlement Mode',
      value: _settlementMode,
      items: _settlementModes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _settlementMode = value;
        });
      },
    );
  }

  Widget _buildSettlementCycleField() {
    return _NumberTextField(
      controller: _settlementCycleController,
      labelText: 'Settlement Cycle Days',
      hintText: 'Example: 7',
      prefixIcon: Icons.schedule_outlined,
      validator: (value) {
        final int? number = int.tryParse(value?.trim() ?? '');

        if (number == null) {
          return 'Settlement cycle is required';
        }

        if (number < 0) {
          return 'Settlement cycle cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildCategoryCommissionSection(SettingsProvider provider) {
    return _SectionCard(
      title: 'Category-wise Commission Rules',
      icon: Icons.category_outlined,
      action: CustomButton(
        text: 'Add Rule',
        icon: Icons.add,
        onPressed: _categoryWiseCommissionEnabled ? _addCategoryCommission : null,
      ),
      child: _categoryWiseCommissionEnabled
          ? CategoryCommissionTable(
              commissions: provider.categoryCommissions,
              onEdit: _editCategoryCommission,
              onDelete: _deleteCategoryCommission,
            )
          : const _DisabledState(
              title: 'Category-wise commission disabled',
              subtitle:
                  'Enable category-wise commission to configure custom rules for each service or product category.',
              icon: Icons.category_outlined,
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
            onPressed: _isSaving ? null : _resetSettings,
          ),
          CustomButton(
            text: 'Preview',
            type: ButtonType.outline,
            icon: Icons.visibility_outlined,
            onPressed: _isSaving ? null : _previewSettings,
          ),
          CustomButton(
            text: 'Save Settings',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveSettings,
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

  String? Function(String?) _numberValidator({
    required String fieldName,
    bool allowZero = false,
  }) {
    return (value) {
      final String raw = value?.trim() ?? '';

      if (raw.isEmpty) {
        return '$fieldName is required';
      }

      final double? number = double.tryParse(raw);

      if (number == null) {
        return 'Enter valid number';
      }

      if (!allowZero && number <= 0) {
        return '$fieldName must be greater than zero';
      }

      if (allowZero && number < 0) {
        return '$fieldName cannot be negative';
      }

      return null;
    };
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
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                          _buildSummaryCards(provider),
                          const SizedBox(height: 20),
                          _buildCommissionRulesSection(),
                          const SizedBox(height: 20),
                          _buildTaxSettlementSection(),
                          const SizedBox(height: 20),
                          _buildCategoryCommissionSection(provider),
                          const SizedBox(height: 28),
                          _buildActions(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading || provider.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.04),
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

class CategoryCommissionTable extends StatelessWidget {
  final List<CategoryCommissionModel> commissions;
  final ValueChanged<CategoryCommissionModel> onEdit;
  final ValueChanged<CategoryCommissionModel> onDelete;

  const CategoryCommissionTable({
    super.key,
    required this.commissions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (commissions.isEmpty) {
      return const _DisabledState(
        title: 'No category commission rules found',
        subtitle: 'Add category-wise commission rules to override global rules.',
        icon: Icons.category_outlined,
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 76,
          columnSpacing: 28,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Commission')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Min')),
            DataColumn(label: Text('Max')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: commissions.map(
            (item) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.category_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.type == 'percentage'
                          ? '${item.commission.toStringAsFixed(2)}%'
                          : AppFormatters.formatCurrency(item.commission),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  DataCell(
                    _StatusChip(
                      label: AppFormatters.formatStatus(item.type),
                      color: item.type == 'percentage'
                          ? AppColors.primary
                          : Colors.purple,
                    ),
                  ),
                  DataCell(
                    Text(
                      item.minCommission <= 0
                          ? 'N/A'
                          : AppFormatters.formatCurrency(item.minCommission),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.maxCommission <= 0
                          ? 'N/A'
                          : AppFormatters.formatCurrency(item.maxCommission),
                    ),
                  ),
                  DataCell(
                    _StatusChip(
                      label: item.isActive ? 'Active' : 'Inactive',
                      color: item.isActive
                          ? AppColors.success
                          : Colors.blueGrey,
                    ),
                  ),
                  DataCell(
                    PopupMenuButton<String>(
                      tooltip: 'Category Commission Actions',
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit(item);
                            break;
                          case 'delete':
                            onDelete(item);
                            break;
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: _MenuItem(
                            icon: Icons.edit_outlined,
                            label: 'Edit Rule',
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: _MenuItem(
                            icon: Icons.delete_outline,
                            label: 'Delete Rule',
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
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class _CategoryCommissionDialog extends StatefulWidget {
  final CategoryCommissionModel? item;

  const _CategoryCommissionDialog({
    this.item,
  });

  @override
  State<_CategoryCommissionDialog> createState() =>
      _CategoryCommissionDialogState();
}

class _CategoryCommissionDialogState extends State<_CategoryCommissionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  String _type = 'percentage';
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _types = const [
    'percentage',
    'fixed',
  ];

  @override
  void initState() {
    super.initState();

    final CategoryCommissionModel? item = widget.item;

    if (item != null) {
      _categoryIdController.text = item.categoryId;
      _categoryNameController.text = item.categoryName;
      _commissionController.text = item.commission.toStringAsFixed(2);
      _minController.text = item.minCommission.toStringAsFixed(2);
      _maxController.text = item.maxCommission.toStringAsFixed(2);
      _type = item.type;
      _isActive = item.isActive;
    } else {
      _type = 'percentage';
      _commissionController.text = '0';
      _minController.text = '0';
      _maxController.text = '0';
    }
  }

  @override
  void dispose() {
    _categoryIdController.dispose();
    _categoryNameController.dispose();
    _commissionController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final double commission =
        double.tryParse(_commissionController.text.trim()) ?? 0;
    final double minCommission =
        double.tryParse(_minController.text.trim()) ?? 0;
    final double maxCommission =
        double.tryParse(_maxController.text.trim()) ?? 0;

    if (_type == 'percentage' && commission > 100) {
      NavigationService.showWarning(
        'Category commission cannot be greater than 100%',
      );
      return;
    }

    if (maxCommission > 0 && minCommission > maxCommission) {
      NavigationService.showWarning(
        'Minimum commission cannot be greater than maximum commission',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final SettingsProvider provider = context.read<SettingsProvider>();

    final bool success = widget.item == null
        ? await provider.createCategoryCommission(
            categoryId: _categoryIdController.text.trim(),
            categoryName: _categoryNameController.text.trim(),
            commission: commission,
            type: _type,
            minCommission: minCommission,
            maxCommission: maxCommission,
            isActive: _isActive,
          )
        : await provider.updateCategoryCommission(
            categoryId: _categoryIdController.text.trim(),
            categoryName: _categoryNameController.text.trim(),
            commission: commission,
            type: _type,
            minCommission: minCommission,
            maxCommission: maxCommission,
            isActive: _isActive,
          );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      NavigationService.showSuccess(
        widget.item == null
            ? 'Category commission created successfully'
            : 'Category commission updated successfully',
      );

      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError(
      provider.errorMessage ?? 'Failed to save category commission',
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _numberValidator(String? value, String fieldName) {
    final String raw = value?.trim() ?? '';

    if (raw.isEmpty) {
      return '$fieldName is required';
    }

    final double? number = double.tryParse(raw);

    if (number == null) {
      return 'Enter valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
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
                      backgroundColor: Colors.purple.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.category_outlined,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item == null
                            ? 'Add Category Commission'
                            : 'Edit Category Commission',
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _TextFieldWrapper(
                            controller: _categoryIdController,
                            labelText: 'Category ID',
                            hintText: 'category_id',
                            prefixIcon: Icons.tag_outlined,
                            enabled: widget.item == null,
                            validator: (value) =>
                                _requiredValidator(value, 'Category ID'),
                          ),
                          const SizedBox(height: 16),
                          _TextFieldWrapper(
                            controller: _categoryNameController,
                            labelText: 'Category Name',
                            hintText: 'Photography',
                            prefixIcon: Icons.category_outlined,
                            validator: (value) =>
                                _requiredValidator(value, 'Category name'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _TextFieldWrapper(
                            controller: _categoryIdController,
                            labelText: 'Category ID',
                            hintText: 'category_id',
                            prefixIcon: Icons.tag_outlined,
                            enabled: widget.item == null,
                            validator: (value) =>
                                _requiredValidator(value, 'Category ID'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TextFieldWrapper(
                            controller: _categoryNameController,
                            labelText: 'Category Name',
                            hintText: 'Photography',
                            prefixIcon: Icons.category_outlined,
                            validator: (value) =>
                                _requiredValidator(value, 'Category name'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildTypeDropdown(),
                          const SizedBox(height: 16),
                          _TextFieldWrapper(
                            controller: _commissionController,
                            labelText: 'Commission',
                            hintText: _type == 'percentage'
                                ? 'Example: 10'
                                : 'Example: 100',
                            prefixIcon: Icons.percent_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Commission'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildTypeDropdown()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TextFieldWrapper(
                            controller: _commissionController,
                            labelText: 'Commission',
                            hintText: _type == 'percentage'
                                ? 'Example: 10'
                                : 'Example: 100',
                            prefixIcon: Icons.percent_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Commission'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _TextFieldWrapper(
                            controller: _minController,
                            labelText: 'Minimum Commission',
                            hintText: '0',
                            prefixIcon: Icons.arrow_downward_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Minimum commission'),
                          ),
                          const SizedBox(height: 16),
                          _TextFieldWrapper(
                            controller: _maxController,
                            labelText: 'Maximum Commission',
                            hintText: '0',
                            prefixIcon: Icons.arrow_upward_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Maximum commission'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _TextFieldWrapper(
                            controller: _minController,
                            labelText: 'Minimum Commission',
                            hintText: '0',
                            prefixIcon: Icons.arrow_downward_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Minimum commission'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TextFieldWrapper(
                            controller: _maxController,
                            labelText: 'Maximum Commission',
                            hintText: '0',
                            prefixIcon: Icons.arrow_upward_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _numberValidator(value, 'Maximum commission'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  activeThumbColor: AppColors.success,
                  title: const Text(
                    'Active Rule',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'This category commission rule is active'
                        : 'This category commission rule is inactive',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  secondary: Icon(
                    _isActive
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: _isActive ? AppColors.success : AppColors.warning,
                  ),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _isActive = value;
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
                        text: widget.item == null ? 'Create Rule' : 'Save Rule',
                        icon: Icons.save_outlined,
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

  Widget _buildTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Commission Type',
      value: _type,
      items: _types,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _type = value;
        });
      },
    );
  }
}

class _NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;

  const _NumberTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return _TextFieldWrapper(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      enabled: enabled,
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}

class _TextFieldWrapper extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;

  const _TextFieldWrapper({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
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

class _CommissionSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CommissionSummaryCard({
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

class _DisabledState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DisabledState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(42),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
            width: 160,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
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
              ?action,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}