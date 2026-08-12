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

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firebaseServerKeyController =
      TextEditingController();
  final TextEditingController _firebaseSenderIdController =
      TextEditingController();
  final TextEditingController _emailFromNameController =
      TextEditingController();
  final TextEditingController _emailFromAddressController =
      TextEditingController();
  final TextEditingController _smtpHostController = TextEditingController();
  final TextEditingController _smtpPortController = TextEditingController();
  final TextEditingController _smtpUsernameController = TextEditingController();
  final TextEditingController _smtpPasswordController = TextEditingController();
  final TextEditingController _smsApiKeyController = TextEditingController();
  final TextEditingController _smsSenderIdController = TextEditingController();
  final TextEditingController _whatsappApiKeyController =
      TextEditingController();
  final TextEditingController _whatsappBusinessNumberController =
      TextEditingController();
  final TextEditingController _quietStartTimeController =
      TextEditingController();
  final TextEditingController _quietEndTimeController = TextEditingController();

  String _notificationProvider = 'firebase';
  String _emailProvider = 'smtp';
  String _smsProvider = 'textlocal';
  String _whatsappProvider = 'meta';

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _whatsappEnabled = false;
  bool _inAppEnabled = true;

  bool _bookingNotificationsEnabled = true;
  bool _paymentNotificationsEnabled = true;
  bool _orderNotificationsEnabled = true;
  bool _providerNotificationsEnabled = true;
  bool _supportNotificationsEnabled = true;
  bool _marketingNotificationsEnabled = false;
  bool _adminAlertsEnabled = true;
  bool _quietHoursEnabled = false;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _obscureFirebaseKey = true;
  bool _obscureSmtpPassword = true;
  bool _obscureSmsApiKey = true;
  bool _obscureWhatsappApiKey = true;

  final List<String> _notificationProviders = const [
    'firebase',
    'onesignal',
    'manual',
  ];

  final List<String> _emailProviders = const [
    'smtp',
    'sendgrid',
    'mailgun',
    'ses',
    'manual',
  ];

  final List<String> _smsProviders = const [
    'textlocal',
    'twilio',
    'msg91',
    'aws_sns',
    'manual',
  ];

  final List<String> _whatsappProviders = const [
    'meta',
    'twilio',
    'gupshup',
    'manual',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificationSettings();
    });
  }

  @override
  void dispose() {
    _firebaseServerKeyController.dispose();
    _firebaseSenderIdController.dispose();
    _emailFromNameController.dispose();
    _emailFromAddressController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _smtpUsernameController.dispose();
    _smtpPasswordController.dispose();
    _smsApiKeyController.dispose();
    _smsSenderIdController.dispose();
    _whatsappApiKeyController.dispose();
    _whatsappBusinessNumberController.dispose();
    _quietStartTimeController.dispose();
    _quietEndTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    final SettingsProvider provider = context.read<SettingsProvider>();

    await provider.getNotificationSettings();

    if (!mounted) return;

    _notificationProvider = provider.notificationProvider.isEmpty
        ? 'firebase'
        : provider.notificationProvider;
    _emailProvider =
        provider.emailProvider.isEmpty ? 'smtp' : provider.emailProvider;
    _smsProvider =
        provider.smsProvider.isEmpty ? 'textlocal' : provider.smsProvider;
    _whatsappProvider = provider.whatsappProvider.isEmpty
        ? 'meta'
        : provider.whatsappProvider;

    _firebaseServerKeyController.text = provider.firebaseServerKey;
    _firebaseSenderIdController.text = provider.firebaseSenderId;
    _emailFromNameController.text = provider.emailFromName;
    _emailFromAddressController.text = provider.emailFromAddress;
    _smtpHostController.text = provider.smtpHost;
    _smtpPortController.text = provider.smtpPort.toString();
    _smtpUsernameController.text = provider.smtpUsername;
    _smtpPasswordController.text = provider.smtpPassword;
    _smsApiKeyController.text = provider.smsApiKey;
    _smsSenderIdController.text = provider.smsSenderId;
    _whatsappApiKeyController.text = provider.whatsappApiKey;
    _whatsappBusinessNumberController.text = provider.whatsappBusinessNumber;
    _quietStartTimeController.text = provider.quietStartTime;
    _quietEndTimeController.text = provider.quietEndTime;

    _pushEnabled = provider.pushNotificationsEnabled;
    _emailEnabled = provider.emailNotificationsEnabled;
    _smsEnabled = provider.smsNotificationsEnabled;
    _whatsappEnabled = provider.whatsappNotificationsEnabled;
    _inAppEnabled = provider.inAppNotificationsEnabled;

    _bookingNotificationsEnabled = provider.bookingNotificationsEnabled;
    _paymentNotificationsEnabled = provider.paymentNotificationsEnabled;
    _orderNotificationsEnabled = provider.orderNotificationsEnabled;
    _providerNotificationsEnabled = provider.providerNotificationsEnabled;
    _supportNotificationsEnabled = provider.supportNotificationsEnabled;
    _marketingNotificationsEnabled = provider.marketingNotificationsEnabled;
    _adminAlertsEnabled = provider.adminAlertsEnabled;
    _quietHoursEnabled = provider.quietHoursEnabled;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadNotificationSettings();
  }

  void _resetSettings() {
    FocusScope.of(context).unfocus();

    final SettingsProvider provider = context.read<SettingsProvider>();

    setState(() {
      _notificationProvider = provider.notificationProvider.isEmpty
          ? 'firebase'
          : provider.notificationProvider;
      _emailProvider =
          provider.emailProvider.isEmpty ? 'smtp' : provider.emailProvider;
      _smsProvider =
          provider.smsProvider.isEmpty ? 'textlocal' : provider.smsProvider;
      _whatsappProvider = provider.whatsappProvider.isEmpty
          ? 'meta'
          : provider.whatsappProvider;

      _firebaseServerKeyController.text = provider.firebaseServerKey;
      _firebaseSenderIdController.text = provider.firebaseSenderId;
      _emailFromNameController.text = provider.emailFromName;
      _emailFromAddressController.text = provider.emailFromAddress;
      _smtpHostController.text = provider.smtpHost;
      _smtpPortController.text = provider.smtpPort.toString();
      _smtpUsernameController.text = provider.smtpUsername;
      _smtpPasswordController.text = provider.smtpPassword;
      _smsApiKeyController.text = provider.smsApiKey;
      _smsSenderIdController.text = provider.smsSenderId;
      _whatsappApiKeyController.text = provider.whatsappApiKey;
      _whatsappBusinessNumberController.text = provider.whatsappBusinessNumber;
      _quietStartTimeController.text = provider.quietStartTime;
      _quietEndTimeController.text = provider.quietEndTime;

      _pushEnabled = provider.pushNotificationsEnabled;
      _emailEnabled = provider.emailNotificationsEnabled;
      _smsEnabled = provider.smsNotificationsEnabled;
      _whatsappEnabled = provider.whatsappNotificationsEnabled;
      _inAppEnabled = provider.inAppNotificationsEnabled;

      _bookingNotificationsEnabled = provider.bookingNotificationsEnabled;
      _paymentNotificationsEnabled = provider.paymentNotificationsEnabled;
      _orderNotificationsEnabled = provider.orderNotificationsEnabled;
      _providerNotificationsEnabled = provider.providerNotificationsEnabled;
      _supportNotificationsEnabled = provider.supportNotificationsEnabled;
      _marketingNotificationsEnabled = provider.marketingNotificationsEnabled;
      _adminAlertsEnabled = provider.adminAlertsEnabled;
      _quietHoursEnabled = provider.quietHoursEnabled;
    });
  }

  Future<void> _saveNotificationSettings() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_pushEnabled &&
        !_emailEnabled &&
        !_smsEnabled &&
        !_whatsappEnabled &&
        !_inAppEnabled) {
      NavigationService.showWarning(
        'At least one notification channel must be enabled',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().updateNotificationSettings(
              notificationProvider: _notificationProvider,
              emailProvider: _emailProvider,
              smsProvider: _smsProvider,
              whatsappProvider: _whatsappProvider,
              firebaseServerKey: _firebaseServerKeyController.text.trim(),
              firebaseSenderId: _firebaseSenderIdController.text.trim(),
              emailFromName: _emailFromNameController.text.trim(),
              emailFromAddress: _emailFromAddressController.text.trim(),
              smtpHost: _smtpHostController.text.trim(),
              smtpPort: int.tryParse(_smtpPortController.text.trim()) ?? 0,
              smtpUsername: _smtpUsernameController.text.trim(),
              smtpPassword: _smtpPasswordController.text.trim(),
              smsApiKey: _smsApiKeyController.text.trim(),
              smsSenderId: _smsSenderIdController.text.trim(),
              whatsappApiKey: _whatsappApiKeyController.text.trim(),
              whatsappBusinessNumber:
                  _whatsappBusinessNumberController.text.trim(),
              quietStartTime: _quietStartTimeController.text.trim(),
              quietEndTime: _quietEndTimeController.text.trim(),
              pushEnabled: _pushEnabled,
              emailEnabled: _emailEnabled,
              smsEnabled: _smsEnabled,
              whatsappEnabled: _whatsappEnabled,
              inAppEnabled: _inAppEnabled,
              bookingNotificationsEnabled: _bookingNotificationsEnabled,
              paymentNotificationsEnabled: _paymentNotificationsEnabled,
              orderNotificationsEnabled: _orderNotificationsEnabled,
              providerNotificationsEnabled: _providerNotificationsEnabled,
              supportNotificationsEnabled: _supportNotificationsEnabled,
              marketingNotificationsEnabled: _marketingNotificationsEnabled,
              adminAlertsEnabled: _adminAlertsEnabled,
              quietHoursEnabled: _quietHoursEnabled,
            );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Notification settings updated successfully',
      );

      await _loadNotificationSettings();
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to update notification settings',
    );
  }

  Future<void> _sendTestNotification() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Send Test Notification',
      message:
          'Do you want to send a test notification using the current configuration?',
      confirmText: 'Send Test',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<SettingsProvider>().sendTestNotification(
              notificationProvider: _notificationProvider,
              emailProvider: _emailProvider,
              smsProvider: _smsProvider,
              whatsappProvider: _whatsappProvider,
              pushEnabled: _pushEnabled,
              emailEnabled: _emailEnabled,
              smsEnabled: _smsEnabled,
              whatsappEnabled: _whatsappEnabled,
              inAppEnabled: _inAppEnabled,
            );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Test notification sent successfully',
      );
      return;
    }

    NavigationService.showError(
      context.read<SettingsProvider>().errorMessage ??
          'Failed to send test notification',
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
              maxWidth: 720,
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
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notification Settings Preview',
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
                    label: 'Push Provider',
                    value: AppFormatters.formatStatus(_notificationProvider),
                  ),
                  _PreviewRow(
                    label: 'Email Provider',
                    value: AppFormatters.formatStatus(_emailProvider),
                  ),
                  _PreviewRow(
                    label: 'SMS Provider',
                    value: AppFormatters.formatStatus(_smsProvider),
                  ),
                  _PreviewRow(
                    label: 'WhatsApp Provider',
                    value: AppFormatters.formatStatus(_whatsappProvider),
                  ),
                  _PreviewRow(
                    label: 'Email From',
                    value:
                        '${_emailFromNameController.text.trim()} <${_emailFromAddressController.text.trim()}>',
                  ),
                  _PreviewRow(
                    label: 'Quiet Hours',
                    value: _quietHoursEnabled
                        ? '${_quietStartTimeController.text.trim()} to ${_quietEndTimeController.text.trim()}'
                        : 'Disabled',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: _pushEnabled ? 'Push On' : 'Push Off',
                        color: _pushEnabled
                            ? AppColors.success
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _emailEnabled ? 'Email On' : 'Email Off',
                        color: _emailEnabled
                            ? AppColors.primary
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _smsEnabled ? 'SMS On' : 'SMS Off',
                        color:
                            _smsEnabled ? AppColors.warning : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label:
                            _whatsappEnabled ? 'WhatsApp On' : 'WhatsApp Off',
                        color: _whatsappEnabled
                            ? AppColors.success
                            : Colors.blueGrey,
                      ),
                      _StatusChip(
                        label: _inAppEnabled ? 'In-App On' : 'In-App Off',
                        color: _inAppEnabled ? Colors.purple : Colors.blueGrey,
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
      title: 'Notification Settings',
      subtitle:
          'Configure push, email, SMS, WhatsApp, in-app notifications, templates, alerts, quiet hours and delivery providers.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewSettings,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Send Test',
          type: ButtonType.outline,
          icon: Icons.send_outlined,
          onPressed: _isLoading || _isSaving ? null : _sendTestNotification,
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
            _NotificationSummaryCard(
              title: 'Push',
              value: provider.pushNotificationsEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.notifications_active_outlined,
              color: provider.pushNotificationsEnabled
                  ? AppColors.success
                  : Colors.blueGrey,
            ),
            _NotificationSummaryCard(
              title: 'Email',
              value:
                  provider.emailNotificationsEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.email_outlined,
              color: provider.emailNotificationsEnabled
                  ? AppColors.primary
                  : Colors.blueGrey,
            ),
            _NotificationSummaryCard(
              title: 'SMS',
              value: provider.smsNotificationsEnabled ? 'Enabled' : 'Disabled',
              icon: Icons.sms_outlined,
              color: provider.smsNotificationsEnabled
                  ? AppColors.warning
                  : Colors.blueGrey,
            ),
            _NotificationSummaryCard(
              title: 'WhatsApp',
              value: provider.whatsappNotificationsEnabled
                  ? 'Enabled'
                  : 'Disabled',
              icon: Icons.chat_outlined,
              color: provider.whatsappNotificationsEnabled
                  ? AppColors.success
                  : Colors.blueGrey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderSection() {
    return _SectionCard(
      title: 'Provider Configuration',
      icon: Icons.hub_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return Column(
              children: [
                _buildNotificationProviderDropdown(),
                const SizedBox(height: 16),
                _buildEmailProviderDropdown(),
                const SizedBox(height: 16),
                _buildSmsProviderDropdown(),
                const SizedBox(height: 16),
                _buildWhatsappProviderDropdown(),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildNotificationProviderDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEmailProviderDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSmsProviderDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWhatsappProviderDropdown()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationProviderDropdown() {
    return CustomDropdown<String>(
      labelText: 'Push Provider',
      value: _notificationProvider,
      items: _notificationProviders,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _notificationProvider = value;
        });
      },
    );
  }

  Widget _buildEmailProviderDropdown() {
    return CustomDropdown<String>(
      labelText: 'Email Provider',
      value: _emailProvider,
      items: _emailProviders,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _emailProvider = value;
        });
      },
    );
  }

  Widget _buildSmsProviderDropdown() {
    return CustomDropdown<String>(
      labelText: 'SMS Provider',
      value: _smsProvider,
      items: _smsProviders,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _smsProvider = value;
        });
      },
    );
  }

  Widget _buildWhatsappProviderDropdown() {
    return CustomDropdown<String>(
      labelText: 'WhatsApp Provider',
      value: _whatsappProvider,
      items: _whatsappProviders,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _whatsappProvider = value;
        });
      },
    );
  }

  Widget _buildPushSection() {
    return _SectionCard(
      title: 'Push Notification Configuration',
      icon: Icons.notifications_active_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable Push Notifications',
            subtitle: 'Send app push notifications through configured provider',
            icon: Icons.notifications_active_outlined,
            color: AppColors.success,
            value: _pushEnabled,
            onChanged: (value) {
              setState(() {
                _pushEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _TextFieldWrapper(
            controller: _firebaseServerKeyController,
            labelText: 'Firebase Server Key',
            hintText: 'Enter Firebase server key',
            prefixIcon: Icons.vpn_key_outlined,
            enabled: _pushEnabled,
            obscureText: _obscureFirebaseKey,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureFirebaseKey = !_obscureFirebaseKey;
                });
              },
              icon: Icon(
                _obscureFirebaseKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if (!_pushEnabled || _notificationProvider != 'firebase') {
                return null;
              }

              if (value == null || value.trim().isEmpty) {
                return 'Firebase server key is required';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _firebaseSenderIdController,
            labelText: 'Firebase Sender ID',
            hintText: 'Enter Firebase sender id',
            prefixIcon: Icons.tag_outlined,
            enabled: _pushEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
    return _SectionCard(
      title: 'Email Notification Configuration',
      icon: Icons.email_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable Email Notifications',
            subtitle: 'Send transactional and marketing emails',
            icon: Icons.email_outlined,
            color: AppColors.primary,
            value: _emailEnabled,
            onChanged: (value) {
              setState(() {
                _emailEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildEmailFromNameField(),
                    const SizedBox(height: 16),
                    _buildEmailFromAddressField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildEmailFromNameField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEmailFromAddressField()),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _smtpHostController,
            labelText: 'SMTP Host',
            hintText: 'smtp.example.com',
            prefixIcon: Icons.dns_outlined,
            enabled: _emailEnabled,
            validator: (value) {
              if (!_emailEnabled || _emailProvider != 'smtp') return null;

              if (value == null || value.trim().isEmpty) {
                return 'SMTP host is required';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildSmtpPortField(),
                    const SizedBox(height: 16),
                    _buildSmtpUsernameField(),
                    const SizedBox(height: 16),
                    _buildSmtpPasswordField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildSmtpPortField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmtpUsernameField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmtpPasswordField()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailFromNameField() {
    return _TextFieldWrapper(
      controller: _emailFromNameController,
      labelText: 'Email From Name',
      hintText: 'EventEase',
      prefixIcon: Icons.business_outlined,
      enabled: _emailEnabled,
    );
  }

  Widget _buildEmailFromAddressField() {
    return _TextFieldWrapper(
      controller: _emailFromAddressController,
      labelText: 'Email From Address',
      hintText: 'support@eventease.com',
      prefixIcon: Icons.alternate_email_outlined,
      keyboardType: TextInputType.emailAddress,
      enabled: _emailEnabled,
      validator: (value) {
        if (!_emailEnabled) return null;

        final String email = value?.trim() ?? '';

        if (email.isEmpty) {
          return 'Email from address is required';
        }

        final bool valid = RegExp(
          r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
        ).hasMatch(email);

        if (!valid) {
          return 'Enter valid email address';
        }

        return null;
      },
    );
  }

  Widget _buildSmtpPortField() {
    return _TextFieldWrapper(
      controller: _smtpPortController,
      labelText: 'SMTP Port',
      hintText: '587',
      prefixIcon: Icons.settings_ethernet_outlined,
      keyboardType: TextInputType.number,
      enabled: _emailEnabled,
      validator: (value) {
        if (!_emailEnabled || _emailProvider != 'smtp') return null;

        final int? port = int.tryParse(value?.trim() ?? '');

        if (port == null || port <= 0) {
          return 'Enter valid SMTP port';
        }

        return null;
      },
    );
  }

  Widget _buildSmtpUsernameField() {
    return _TextFieldWrapper(
      controller: _smtpUsernameController,
      labelText: 'SMTP Username',
      hintText: 'SMTP username',
      prefixIcon: Icons.person_outline,
      enabled: _emailEnabled,
    );
  }

  Widget _buildSmtpPasswordField() {
    return _TextFieldWrapper(
      controller: _smtpPasswordController,
      labelText: 'SMTP Password',
      hintText: 'SMTP password',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureSmtpPassword,
      enabled: _emailEnabled,
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscureSmtpPassword = !_obscureSmtpPassword;
          });
        },
        icon: Icon(
          _obscureSmtpPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    );
  }

  Widget _buildSmsWhatsappSection() {
    return _SectionCard(
      title: 'SMS and WhatsApp Configuration',
      icon: Icons.sms_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable SMS Notifications',
            subtitle: 'Send OTP, booking, order and payment alerts by SMS',
            icon: Icons.sms_outlined,
            color: AppColors.warning,
            value: _smsEnabled,
            onChanged: (value) {
              setState(() {
                _smsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _TextFieldWrapper(
            controller: _smsApiKeyController,
            labelText: 'SMS API Key',
            hintText: 'Enter SMS API key',
            prefixIcon: Icons.vpn_key_outlined,
            enabled: _smsEnabled,
            obscureText: _obscureSmsApiKey,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureSmsApiKey = !_obscureSmsApiKey;
                });
              },
              icon: Icon(
                _obscureSmsApiKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _smsSenderIdController,
            labelText: 'SMS Sender ID',
            hintText: 'EVNTES',
            prefixIcon: Icons.badge_outlined,
            enabled: _smsEnabled,
          ),
          const Divider(height: 30),
          _SwitchOptionTile(
            title: 'Enable WhatsApp Notifications',
            subtitle: 'Send booking, order and support updates through WhatsApp',
            icon: Icons.chat_outlined,
            color: AppColors.success,
            value: _whatsappEnabled,
            onChanged: (value) {
              setState(() {
                _whatsappEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _TextFieldWrapper(
            controller: _whatsappApiKeyController,
            labelText: 'WhatsApp API Key',
            hintText: 'Enter WhatsApp provider API key',
            prefixIcon: Icons.vpn_key_outlined,
            enabled: _whatsappEnabled,
            obscureText: _obscureWhatsappApiKey,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureWhatsappApiKey = !_obscureWhatsappApiKey;
                });
              },
              icon: Icon(
                _obscureWhatsappApiKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TextFieldWrapper(
            controller: _whatsappBusinessNumberController,
            labelText: 'WhatsApp Business Number',
            hintText: '+91 90000 00000',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            enabled: _whatsappEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsSection() {
    return _SectionCard(
      title: 'Notification Channels and Event Rules',
      icon: Icons.rule_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable In-App Notifications',
            subtitle: 'Show notifications inside customer, provider and admin apps',
            icon: Icons.notifications_none_outlined,
            color: Colors.purple,
            value: _inAppEnabled,
            onChanged: (value) {
              setState(() {
                _inAppEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Booking Notifications',
            subtitle: 'Notify customers and providers for booking updates',
            icon: Icons.event_available_outlined,
            color: AppColors.primary,
            value: _bookingNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _bookingNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Payment Notifications',
            subtitle: 'Notify users for payment, refund and settlement events',
            icon: Icons.payments_outlined,
            color: AppColors.success,
            value: _paymentNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _paymentNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Order Notifications',
            subtitle: 'Notify users for marketplace order updates',
            icon: Icons.shopping_bag_outlined,
            color: Colors.orange,
            value: _orderNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _orderNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Provider Notifications',
            subtitle: 'Notify providers for KYC, bookings, settlements and reviews',
            icon: Icons.engineering_outlined,
            color: AppColors.info,
            value: _providerNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _providerNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Support Notifications',
            subtitle: 'Notify users and admins for tickets, complaints and disputes',
            icon: Icons.support_agent_outlined,
            color: AppColors.warning,
            value: _supportNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _supportNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Marketing Notifications',
            subtitle: 'Allow campaign, coupon, offer and promotional notifications',
            icon: Icons.campaign_outlined,
            color: Colors.deepPurple,
            value: _marketingNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _marketingNotificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          _SwitchOptionTile(
            title: 'Admin Alerts',
            subtitle: 'Send alerts to admins for failures, disputes and critical events',
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.error,
            value: _adminAlertsEnabled,
            onChanged: (value) {
              setState(() {
                _adminAlertsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return _SectionCard(
      title: 'Quiet Hours',
      icon: Icons.nightlight_outlined,
      child: Column(
        children: [
          _SwitchOptionTile(
            title: 'Enable Quiet Hours',
            subtitle: 'Pause non-critical notifications during configured hours',
            icon: Icons.nightlight_outlined,
            color: Colors.indigo,
            value: _quietHoursEnabled,
            onChanged: (value) {
              setState(() {
                _quietHoursEnabled = value;
              });
            },
          ),
          const Divider(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildQuietStartField(),
                    const SizedBox(height: 16),
                    _buildQuietEndField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildQuietStartField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuietEndField()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuietStartField() {
    return _TextFieldWrapper(
      controller: _quietStartTimeController,
      labelText: 'Quiet Start Time',
      hintText: '22:00',
      prefixIcon: Icons.schedule_outlined,
      enabled: _quietHoursEnabled,
    );
  }

  Widget _buildQuietEndField() {
    return _TextFieldWrapper(
      controller: _quietEndTimeController,
      labelText: 'Quiet End Time',
      hintText: '07:00',
      prefixIcon: Icons.schedule_outlined,
      enabled: _quietHoursEnabled,
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
            text: 'Send Test',
            type: ButtonType.outline,
            icon: Icons.send_outlined,
            onPressed: _isSaving ? null : _sendTestNotification,
          ),
          CustomButton(
            text: 'Save Settings',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveNotificationSettings,
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
                          _buildProviderSection(),
                          const SizedBox(height: 20),
                          _buildPushSection(),
                          const SizedBox(height: 20),
                          _buildEmailSection(),
                          const SizedBox(height: 20),
                          _buildSmsWhatsappSection(),
                          const SizedBox(height: 20),
                          _buildChannelsSection(),
                          const SizedBox(height: 20),
                          _buildQuietHoursSection(),
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

class _NotificationSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _NotificationSummaryCard({
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