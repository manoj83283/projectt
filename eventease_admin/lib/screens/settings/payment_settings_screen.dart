import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/settings_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({
    super.key,
  });

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _razorpayKeyIdController =
      TextEditingController();
  final TextEditingController _razorpayKeySecretController =
      TextEditingController();
  final TextEditingController _webhookSecretController =
      TextEditingController();
  final TextEditingController _minimumOrderAmountController =
      TextEditingController();
  final TextEditingController _maximumOrderAmountController =
      TextEditingController();
  final TextEditingController _refundWindowDaysController =
      TextEditingController();
  final TextEditingController _paymentTimeoutMinutesController =
      TextEditingController();
  final TextEditingController _codLimitController = TextEditingController();

  String _paymentGateway = 'razorpay';
  String _settlementMode = 'manual';
  String _refundMode = 'automatic';

  bool _onlinePaymentsEnabled = true;
  bool _cashPaymentsEnabled = true;
  bool _upiEnabled = true;
  bool _cardEnabled = true;
  bool _walletEnabled = false;
  bool _netBankingEnabled = true;
  bool _cashOnDeliveryEnabled = false;
  bool _autoRefundEnabled = true;
  bool _partialPaymentEnabled = false;
  bool _paymentRetryEnabled = true;
  bool _webhookEnabled = true;
  bool _isTestMode = true;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _obscureSecret = true;
  bool _obscureWebhookSecret = true;

  final List<String> _paymentGateways = const [
    'razorpay',
    'stripe',
    'cashfree',
    'payu',
    'manual',
  ];

  final List<String> _settlementModes = const [
    'manual',
    'daily',
    'weekly',
    'biweekly',
    'monthly',
  ];

  final List<String> _refundModes = const [
    'automatic',
    'manual',
    'approval_required',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentSettings();
    });
  }

  @override
  void dispose() {
    _razorpayKeyIdController.dispose();
    _razorpayKeySecretController.dispose();
    _webhookSecretController.dispose();
    _minimumOrderAmountController.dispose();
    _maximumOrderAmountController.dispose();
    _refundWindowDaysController.dispose();
    _paymentTimeoutMinutesController.dispose();
    _codLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentSettings() async {
    setState(() {
      _isLoading = true;
    });

    final SettingsProvider provider = context.read<SettingsProvider>();

    await provider.getPaymentSettings();

    if (!mounted) return;

    _paymentGateway =
        provider.paymentGateway.isEmpty ? 'razorpay' : provider.paymentGateway;
    _settlementMode =
        provider.paymentSettlementMode.isEmpty ? 'manual' : provider.paymentSettlementMode;
    _refundMode =
        provider.refundMode.isEmpty ? 'automatic' : provider.refundMode;

    _razorpayKeyIdController.text = provider.razorpayKeyId;
    _razorpayKeySecretController.text = provider.razorpayKeySecret;
    _webhookSecretController.text = provider.paymentWebhookSecret;

    _minimumOrderAmountController.text =
        provider.minimumOrderAmount.toStringAsFixed(2);
    _maximumOrderAmountController.text =
        provider.maximumOrderAmount.toStringAsFixed(2);
    _refundWindowDaysController.text = provider.refundWindowDays.toString();
    _paymentTimeoutMinutesController.text =
        provider.paymentTimeoutMinutes.toString();
    _codLimitController.text = provider.codLimit.toStringAsFixed(2);

    _onlinePaymentsEnabled = provider.onlinePaymentsEnabled;
    _cashPaymentsEnabled = provider.cashPaymentsEnabled;
    _upiEnabled = provider.upiEnabled;
    _cardEnabled = provider.cardEnabled;
    _walletEnabled = provider.walletEnabled;
    _netBankingEnabled = provider.netBankingEnabled;
    _cashOnDeliveryEnabled = provider.cashOnDeliveryEnabled;
    _autoRefundEnabled = provider.autoRefundEnabled;
    _partialPaymentEnabled = provider.partialPaymentEnabled;
    _paymentRetryEnabled = provider.paymentRetryEnabled;
    _webhookEnabled = provider.paymentWebhookEnabled;
    _isTestMode = provider.paymentTestMode;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadPaymentSettings();
  }

  void _resetSettings() {
    FocusScope.of(context).unfocus();

    final SettingsProvider provider = context.read<SettingsProvider>();

    setState(() {
      _paymentGateway =
          provider.paymentGateway.isEmpty ? 'razorpay' : provider.paymentGateway;
      _settlementMode =
          provider.paymentSettlementMode.isEmpty ? 'manual' : provider.paymentSettlementMode;
      _refundMode =
          provider.refundMode.isEmpty ? 'automatic' : provider.refundMode;

      _razorpayKeyIdController.text = provider.razorpayKeyId;
      _razorpayKeySecretController.text = provider.razorpayKeySecret;
      _webhookSecretController.text = provider.paymentWebhookSecret;

      _minimumOrderAmountController.text =
          provider.minimumOrderAmount.toStringAsFixed(2);
      _maximumOrderAmountController.text =
          provider.maximumOrderAmount.toStringAsFixed(2);
      _refundWindowDaysController.text = provider.refundWindowDays.toString();
      _paymentTimeoutMinutesController.text =
          provider.paymentTimeoutMinutes.toString();
      _codLimitController.text = provider.codLimit.toStringAsFixed(2);

      _onlinePaymentsEnabled = provider.onlinePaymentsEnabled;
      _cashPaymentsEnabled = provider.cashPaymentsEnabled;
      _upiEnabled = provider.upiEnabled;
      _cardEnabled = provider.cardEnabled;
      _walletEnabled = provider.walletEnabled;
      _netBankingEnabled = provider.netBankingEnabled;
      _cashOnDeliveryEnabled = provider.cashOnDeliveryEnabled;
      _autoRefundEnabled = provider.autoRefundEnabled;
      _partialPaymentEnabled = provider.partialPaymentEnabled;
      _paymentRetryEnabled = provider.paymentRetryEnabled;
      _webhookEnabled = provider.paymentWebhookEnabled;
      _isTestMode = provider.paymentTestMode;
    });
  }

  Future<void> _savePaymentSettings() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double minimumOrderAmount =
        double.tryParse(_minimumOrderAmountController.text.trim()) ?? 0;
    final double maximumOrderAmount =
        double.tryParse(_maximumOrderAmountController.text.trim()) ?? 0;
    final int refundWindowDays =
        int.tryParse(_refundWindowDaysController.text.trim()) ?? 0;
    final int paymentTimeoutMinutes =
        int.tryParse(_paymentTimeoutMinutesController.text.trim()) ?? 0;
    final double codLimit =
        double.tryParse(_codLimitController.text.trim()) ?? 0;

    if (maximumOrderAmount > 0 && minimumOrderAmount > maximumOrderAmount) {
      NavigationService.showWarning(
        'Minimum order amount cannot be greater than maximum order amount',
      );
      return;
    }

    if (!_onlinePaymentsEnabled && !_cashPaymentsEnabled) {
      NavigationService.showWarning(
        'At least one payment mode must be enabled',
      );
      return;
    }

    if (_onlinePaymentsEnabled &&
        !_upiEnabled &&
        !_cardEnabled &&
        !_walletEnabled &&
        !_netBankingEnabled) {
      NavigationService.showWarning(
        'Enable at least one online payment method',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().updatePaymentSettings(
              paymentGateway: _paymentGateway,
              settlementMode: _settlementMode,
              refundMode: _refundMode,
              razorpayKeyId: _razorpayKeyIdController.text.trim(),
              razorpayKeySecret: _razorpayKeySecretController.text.trim(),
              webhookSecret: _webhookSecretController.text.trim(),
              minimumOrderAmount: minimumOrderAmount,
              maximumOrderAmount: maximumOrderAmount,
              refundWindowDays: refundWindowDays,
              paymentTimeoutMinutes: paymentTimeoutMinutes,
              codLimit: codLimit,
              onlinePaymentsEnabled: _onlinePaymentsEnabled,
              cashPaymentsEnabled: _cashPaymentsEnabled,
              upiEnabled: _upiEnabled,
              cardEnabled: _cardEnabled,
              walletEnabled: _walletEnabled,
              netBankingEnabled: _netBankingEnabled,
              cashOnDeliveryEnabled: _cashOnDeliveryEnabled,
              autoRefundEnabled: _autoRefundEnabled,
              partialPaymentEnabled: _partialPaymentEnabled,
              paymentRetryEnabled: _paymentRetryEnabled,
              webhookEnabled: _webhookEnabled,
              testMode: _isTestMode,
            );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Payment settings updated successfully',
      );

      await _loadPaymentSettings();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to update payment settings',
    );
  }

  Future<void> _testPaymentGateway() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Test Payment Gateway',
      message:
          'Do you want to test the configured payment gateway connection?',
      confirmText: 'Test',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<SettingsProvider>().testPaymentGateway(
          paymentGateway: _paymentGateway,
          razorpayKeyId: _razorpayKeyIdController.text.trim(),
          razorpayKeySecret: _razorpayKeySecretController.text.trim(),
          testMode: _isTestMode,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Payment gateway connection successful',
      );
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Payment gateway connection failed',
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
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Payment Settings Preview',
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
                    label: 'Gateway',
                    value: AppFormatters.formatStatus(_paymentGateway),
                  ),
                  _PreviewRow(
                    label: 'Mode',
                    value: _isTestMode ? 'Test Mode' : 'Live Mode',
                  ),
                  _PreviewRow(
                    label: 'Settlement',
                    value: AppFormatters.formatStatus(_settlementMode),
                  ),
                  _PreviewRow(
                    label: 'Refund Mode',
                    value: AppFormatters.formatStatus(_refundMode),
                  ),
                  _PreviewRow(
                    label: 'Order Amount Range',
                    value:
                        '${_minimumOrderAmountController.text.trim()} to ${_maximumOrderAmountController.text.trim()}',
                  ),
                  _PreviewRow(
                    label: 'Refund Window',
                    value: '${_refundWindowDaysController.text.trim()} days',
                  ),
                  _PreviewRow(
                    label: 'Payment Timeout',
                    value:
                        '${_paymentTimeoutMinutesController.text.trim()} minutes',
                  ),
                  _PreviewRow(
                    label: 'COD Limit',
                    value: _cashOnDeliveryEnabled
                        ? _codLimitController.text.trim()
                        : 'Disabled',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: _onlinePaymentsEnabled
                            ? 'Online Payments On'
                            : 'Online Payments Off',
                        color: _onlinePaymentsEnabled
                            ? AppColors.success
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label:
                            _cashPaymentsEnabled ? 'Cash On' : 'Cash Off',
                        color: _cashPaymentsEnabled
                            ? AppColors.warning
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _autoRefundEnabled
                            ? 'Auto Refund On'
                            : 'Auto Refund Off',
                        color: _autoRefundEnabled
                            ? AppColors.success
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _webhookEnabled ? 'Webhook On' : 'Webhook Off',
                        color:
                            _webhookEnabled ? AppColors.primary : Colors.blueGrey,
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

  Widget _buildHeader() {
    return PageHeader(
      title: 'Payment Settings',
      subtitle:
          'Configure payment gateway, Razorpay credentials, payment methods, refunds, COD, timeout, webhooks and settlement rules.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewSettings,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Test Gateway',
          type: ButtonType.outline,
          icon: Icons.bolt_outlined,
          onPressed: _isLoading || _isSaving ? null : _testPaymentGateway,
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
            _PaymentSummaryCard(
              title: 'Gateway',
              value: AppFormatters.formatStatus(provider.paymentGateway),
              icon: Icons.payment_outlined,
              color: AppColors.primary,
            ),
            _PaymentSummaryCard(
              title: 'Online Payments',
              value: provider.onlinePaymentsEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.account_balance_wallet_outlined,
              color: provider.onlinePaymentsEnabled
                  ? AppColors.success
                  : Colors.blueGrey,
            ),
            _PaymentSummaryCard(
              title: 'Refund Mode',
              value: AppFormatters.formatStatus(provider.refundMode),
              icon: Icons.currency_exchange,
              color: AppColors.warning,
            ),
            _PaymentSummaryCard(
              title: 'Environment',
              value: provider.paymentTestMode ? 'Test' : 'Live',
              icon: provider.paymentTestMode
                  ? Icons.science_outlined
                  : Icons.public_outlined,
              color:
                  provider.paymentTestMode ? Colors.orange : AppColors.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGatewaySection() {
    return _SectionCard(
      title: 'Gateway Configuration',
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildGatewayDropdown(),
                    const SizedBox(height: 16),
                    _buildSettlementDropdown(),
                    const SizedBox(height: 16),
                    _buildRefundModeDropdown(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildGatewayDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSettlementDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRefundModeDropdown()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Test Mode',
            subtitle: _isTestMode
                ? 'Payments will use sandbox/test credentials'
                : 'Payments will use live production credentials',
            icon: _isTestMode ? Icons.science_outlined : Icons.public_outlined,
            color: _isTestMode ? Colors.orange : AppColors.success,
            value: _isTestMode,
            onChanged: (value) {
              setState(() {
                _isTestMode = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayDropdown() {
    return CustomDropdown<String>(
      labelText: 'Payment Gateway',
      value: _paymentGateway,
      items: _paymentGateways,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _paymentGateway = value;
        });
      },
    );
  }

  Widget _buildSettlementDropdown() {
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

  Widget _buildRefundModeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Refund Mode',
      value: _refundMode,
      items: _refundModes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _refundMode = value;
        });
      },
    );
  }

  Widget _buildCredentialsSection() {
    return _SectionCard(
      title: 'Gateway Credentials',
      icon: Icons.vpn_key_outlined,
      child: Column(
        children: [
          _TextFieldWrapper(
            controller: _razorpayKeyIdController,
            labelText: 'Razorpay Key ID',
            hintText: 'rzp_test_xxxxxxxxx',
            prefixIcon: Icons.key_outlined,
            validator: (value) {
              if (_paymentGateway != 'razorpay') return null;

              if (value == null || value.trim().isEmpty) {
                return 'Razorpay Key ID is required';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _razorpayKeySecretController,
            labelText: 'Razorpay Key Secret',
            hintText: 'Enter Razorpay key secret',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureSecret,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureSecret = !_obscureSecret;
                });
              },
              icon: Icon(
                _obscureSecret
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if (_paymentGateway != 'razorpay') return null;

              if (value == null || value.trim().isEmpty) {
                return 'Razorpay Key Secret is required';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _webhookSecretController,
            labelText: 'Webhook Secret',
            hintText: 'Enter payment webhook secret',
            prefixIcon: Icons.webhook_outlined,
            obscureText: _obscureWebhookSecret,
            enabled: _webhookEnabled,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureWebhookSecret = !_obscureWebhookSecret;
                });
              },
              icon: Icon(
                _obscureWebhookSecret
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if (!_webhookEnabled) return null;

              if (value == null || value.trim().isEmpty) {
                return 'Webhook secret is required when webhook is enabled';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Enable Payment Webhook',
            subtitle:
                'Receive gateway callbacks for payment, refund and settlement events',
            icon: Icons.webhook_outlined,
            color: AppColors.primary,
            value: _webhookEnabled,
            onChanged: (value) {
              setState(() {
                _webhookEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return _SectionCard(
      title: 'Payment Methods',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable Online Payments',
            subtitle: 'Allow customers to pay through gateway methods',
            icon: Icons.payment_outlined,
            color: AppColors.success,
            value: _onlinePaymentsEnabled,
            onChanged: (value) {
              setState(() {
                _onlinePaymentsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable UPI',
            subtitle: 'Allow UPI payments',
            icon: Icons.qr_code_2_outlined,
            color: AppColors.primary,
            value: _upiEnabled,
            onChanged: _onlinePaymentsEnabled
                ? (value) {
                    setState(() {
                      _upiEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Cards',
            subtitle: 'Allow debit and credit card payments',
            icon: Icons.credit_card_outlined,
            color: Colors.purple,
            value: _cardEnabled,
            onChanged: _onlinePaymentsEnabled
                ? (value) {
                    setState(() {
                      _cardEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Wallet',
            subtitle: 'Allow wallet based payments',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.info,
            value: _walletEnabled,
            onChanged: _onlinePaymentsEnabled
                ? (value) {
                    setState(() {
                      _walletEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Net Banking',
            subtitle: 'Allow net banking payments',
            icon: Icons.account_balance_outlined,
            color: Colors.teal,
            value: _netBankingEnabled,
            onChanged: _onlinePaymentsEnabled
                ? (value) {
                    setState(() {
                      _netBankingEnabled = value;
                    });
                  }
                : null,
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Cash Payments',
            subtitle: 'Allow offline cash collection for eligible orders',
            icon: Icons.money_outlined,
            color: AppColors.warning,
            value: _cashPaymentsEnabled,
            onChanged: (value) {
              setState(() {
                _cashPaymentsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Cash on Delivery',
            subtitle: 'Allow COD for marketplace orders within configured limit',
            icon: Icons.local_shipping_outlined,
            color: Colors.orange,
            value: _cashOnDeliveryEnabled,
            onChanged: _cashPaymentsEnabled
                ? (value) {
                    setState(() {
                      _cashOnDeliveryEnabled = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection() {
    return _SectionCard(
      title: 'Limits and Rules',
      icon: Icons.rule_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildMinimumAmountField(),
                    const SizedBox(height: 16),
                    _buildMaximumAmountField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildMinimumAmountField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMaximumAmountField()),
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
                    _buildRefundWindowField(),
                    const SizedBox(height: 16),
                    _buildPaymentTimeoutField(),
                    const SizedBox(height: 16),
                    _buildCodLimitField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildRefundWindowField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPaymentTimeoutField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCodLimitField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SwitchOptionTile(
            title: 'Enable Auto Refund',
            subtitle: 'Automatically initiate refunds for eligible cancellations',
            icon: Icons.currency_exchange,
            color: AppColors.success,
            value: _autoRefundEnabled,
            onChanged: (value) {
              setState(() {
                _autoRefundEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Partial Payment',
            subtitle: 'Allow customers to pay advance amount for bookings',
            icon: Icons.payments_outlined,
            color: Colors.purple,
            value: _partialPaymentEnabled,
            onChanged: (value) {
              setState(() {
                _partialPaymentEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Enable Payment Retry',
            subtitle: 'Allow retry for failed or interrupted payment sessions',
            icon: Icons.refresh_outlined,
            color: AppColors.info,
            value: _paymentRetryEnabled,
            onChanged: (value) {
              setState(() {
                _paymentRetryEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumAmountField() {
    return _NumberTextField(
      controller: _minimumOrderAmountController,
      labelText: 'Minimum Order Amount',
      hintText: 'Example: 100',
      prefixIcon: Icons.arrow_downward_outlined,
      validator: _numberValidator(
        fieldName: 'Minimum order amount',
        allowZero: true,
      ),
    );
  }

  Widget _buildMaximumAmountField() {
    return _NumberTextField(
      controller: _maximumOrderAmountController,
      labelText: 'Maximum Order Amount',
      hintText: 'Example: 500000',
      prefixIcon: Icons.arrow_upward_outlined,
      validator: _numberValidator(
        fieldName: 'Maximum order amount',
        allowZero: true,
      ),
    );
  }

  Widget _buildRefundWindowField() {
    return _IntegerTextField(
      controller: _refundWindowDaysController,
      labelText: 'Refund Window Days',
      hintText: 'Example: 7',
      prefixIcon: Icons.calendar_month_outlined,
      validator: _integerValidator(
        fieldName: 'Refund window',
        allowZero: true,
      ),
    );
  }

  Widget _buildPaymentTimeoutField() {
    return _IntegerTextField(
      controller: _paymentTimeoutMinutesController,
      labelText: 'Payment Timeout Minutes',
      hintText: 'Example: 15',
      prefixIcon: Icons.timer_outlined,
      validator: _integerValidator(
        fieldName: 'Payment timeout',
        allowZero: false,
      ),
    );
  }

  Widget _buildCodLimitField() {
    return _NumberTextField(
      controller: _codLimitController,
      labelText: 'COD Limit',
      hintText: 'Example: 5000',
      prefixIcon: Icons.local_shipping_outlined,
      enabled: _cashOnDeliveryEnabled,
      validator: _numberValidator(
        fieldName: 'COD limit',
        allowZero: true,
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
            text: 'Test Gateway',
            type: ButtonType.outline,
            icon: Icons.bolt_outlined,
            onPressed: _isSaving ? null : _testPaymentGateway,
          ),
          CustomButton(
            text: 'Save Settings',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _savePaymentSettings,
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
            const SizedBox(width: 12),
            Expanded(child: actions[3]),
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

  String? Function(String?) _integerValidator({
    required String fieldName,
    bool allowZero = false,
  }) {
    return (value) {
      final String raw = value?.trim() ?? '';

      if (raw.isEmpty) {
        return '$fieldName is required';
      }

      final int? number = int.tryParse(raw);

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
                          _buildSummaryCards(provider),
                          const SizedBox(height: 20),
                          _buildGatewaySection(),
                          const SizedBox(height: 20),
                          _buildCredentialsSection(),
                          const SizedBox(height: 20),
                          _buildPaymentMethodsSection(),
                          const SizedBox(height: 20),
                          _buildLimitsSection(),
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
                    color: Colors.black.withOpacity(0.04),
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

class _PaymentSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PaymentSummaryCard({
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

class _IntegerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;

  const _IntegerTextField({
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
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _TextFieldWrapper({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
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
  final ValueChanged<bool>? onChanged;

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
      activeColor: color,
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
        color: onChanged == null ? Colors.grey : color,
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
            width: 155,
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
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
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