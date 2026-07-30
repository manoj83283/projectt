import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../providers/notification_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/page_header.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({
    super.key,
  });

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _deepLinkController = TextEditingController();
  final TextEditingController _scheduleNoteController = TextEditingController();

  String? _notificationType;
  String? _targetAudience;

  DateTime? _scheduledDate;

  bool _sendImmediately = true;
  bool _isLoading = false;
  bool _saveAsDraft = false;

  final List<String> _notificationTypes = const [
    'push',
    'in_app',
    'email',
    'sms',
    'broadcast',
  ];

  final List<String> _targetAudiences = const [
    'all',
    'customers',
    'providers',
    'admins',
  ];

  @override
  void initState() {
    super.initState();

    _notificationType = 'push';
    _targetAudience = 'all';

    _titleController.addListener(_refreshPreview);
    _messageController.addListener(_refreshPreview);
    _imageUrlController.addListener(_refreshPreview);
    _deepLinkController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshPreview);
    _messageController.removeListener(_refreshPreview);
    _imageUrlController.removeListener(_refreshPreview);
    _deepLinkController.removeListener(_refreshPreview);

    _titleController.dispose();
    _messageController.dispose();
    _imageUrlController.dispose();
    _deepLinkController.dispose();
    _scheduleNoteController.dispose();

    super.dispose();
  }

  void _refreshPreview() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickScheduleDate() async {
    final DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(2035),
      helpText: 'Select Schedule Date',
    );

    if (date == null) return;

    if (!mounted) return;

    setState(() {
      _scheduledDate = date;
    });
  }

  Future<void> _sendNotification() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_notificationType == null) {
      NavigationService.showWarning(
        'Please select notification type',
      );
      return;
    }

    if (_targetAudience == null) {
      NavigationService.showWarning(
        'Please select audience',
      );
      return;
    }

    if (!_sendImmediately && _scheduledDate == null) {
      NavigationService.showWarning(
        'Select scheduled date',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final bool success =
        await context.read<NotificationProvider>().sendNotification(
              title: _titleController.text.trim(),
              body: _messageController.text.trim(),
              notificationType: _notificationType!,
              audience: _targetAudience!,
              imageUrl: _imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim(),
              deepLink: _deepLinkController.text.trim().isEmpty
                  ? null
                  : _deepLinkController.text.trim(),
              sendImmediately: _sendImmediately,
              scheduledAt: _sendImmediately ? null : _scheduledDate,
            );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(
        _sendImmediately
            ? 'Notification sent successfully'
            : 'Notification scheduled successfully',
      );

      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError(
      context.read<NotificationProvider>().errorMessage ??
          'Failed to send notification',
    );
  }

  void _saveDraft() {
    FocusScope.of(context).unfocus();

    setState(() {
      _saveAsDraft = true;
    });

    NavigationService.showSuccess(
      'Notification draft saved locally',
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    setState(() {
      _titleController.clear();
      _messageController.clear();
      _imageUrlController.clear();
      _deepLinkController.clear();
      _scheduleNoteController.clear();

      _notificationType = 'push';
      _targetAudience = 'all';

      _scheduledDate = null;
      _sendImmediately = true;
      _saveAsDraft = false;
    });
  }

  void _showPreview() {
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
              maxWidth: 560,
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
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notification Preview',
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
                  const SizedBox(height: 20),
                  _NotificationPreviewCard(
                    title: _titleController.text.trim(),
                    message: _messageController.text.trim(),
                    imageUrl: _imageUrlController.text.trim(),
                    deepLink: _deepLinkController.text.trim(),
                    notificationType: _notificationType,
                    audience: _targetAudience,
                    sendImmediately: _sendImmediately,
                    scheduledDate: _scheduledDate,
                  ),
                  const SizedBox(height: 20),
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

  Widget _buildComposerSection() {
    return _SectionCard(
      title: 'Notification Composer',
      icon: Icons.edit_notifications_outlined,
      child: Column(
        children: [
          CustomTextField(
            controller: _titleController,
            labelText: 'Notification Title',
            hintText: 'Example: Your booking has been confirmed',
            prefixIcon: Icons.title_outlined,
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _messageController,
            labelText: 'Message',
            hintText: 'Write message body for users...',
            prefixIcon: Icons.message_outlined,
            maxLines: 6,
            validator: Validators.required,
          ),
        ],
      ),
    );
  }

  Widget _buildRichNotificationSection() {
    return _SectionCard(
      title: 'Rich Notification Support',
      icon: Icons.image_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildImageUrlField(),
                const SizedBox(height: 16),
                _buildDeepLinkField(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildImageUrlField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDeepLinkField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageUrlField() {
    return CustomTextField(
      controller: _imageUrlController,
      labelText: 'Image URL',
      hintText: 'Optional image URL',
      prefixIcon: Icons.image_outlined,
      validator: (value) {
        final String url = value?.trim() ?? '';

        if (url.isEmpty) return null;

        final Uri? uri = Uri.tryParse(url);

        if (uri == null || !uri.hasScheme) {
          return 'Enter valid image URL';
        }

        return null;
      },
    );
  }

  Widget _buildDeepLinkField() {
    return CustomTextField(
      controller: _deepLinkController,
      labelText: 'Deep Link',
      hintText: 'Example: eventease://booking/details',
      prefixIcon: Icons.link_outlined,
      validator: (value) {
        final String url = value?.trim() ?? '';

        if (url.isEmpty) return null;

        final Uri? uri = Uri.tryParse(url);

        if (uri == null || uri.toString().isEmpty) {
          return 'Enter valid deep link';
        }

        return null;
      },
    );
  }

  Widget _buildTargetingSection() {
    return _SectionCard(
      title: 'Audience Selection',
      icon: Icons.groups_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildNotificationTypeDropdown(),
                const SizedBox(height: 16),
                _buildAudienceDropdown(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildNotificationTypeDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAudienceDropdown(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Notification Type',
      value: _notificationType,
      items: _notificationTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _notificationType = value;
        });
      },
    );
  }

  Widget _buildAudienceDropdown() {
    return CustomDropdown<String>(
      labelText: 'Target Audience',
      value: _targetAudience,
      items: _targetAudiences,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _targetAudience = value;
        });
      },
    );
  }

  Widget _buildScheduleSection() {
    return _SectionCard(
      title: 'Send Now or Schedule Notification',
      icon: Icons.schedule_send_outlined,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Send Immediately',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              _sendImmediately
                  ? 'Notification will be delivered immediately'
                  : 'Notification will be delivered on selected date',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            value: _sendImmediately,
            activeColor: AppColors.success,
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              _sendImmediately
                  ? Icons.send_outlined
                  : Icons.schedule_outlined,
              color: _sendImmediately ? AppColors.success : AppColors.primary,
            ),
            onChanged: (value) {
              setState(() {
                _sendImmediately = value;

                if (value) {
                  _scheduledDate = null;
                  _scheduleNoteController.clear();
                }
              });
            },
          ),
          if (!_sendImmediately) ...[
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.schedule_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Schedule Date',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                _scheduledDate == null
                    ? 'Select date'
                    : AppFormatters.formatDate(
                        _scheduledDate!,
                      ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: _pickScheduleDate,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _scheduleNoteController,
              labelText: 'Schedule Note',
              hintText: 'Optional internal note for scheduled notification',
              prefixIcon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return _SectionCard(
      title: 'Live Preview',
      icon: Icons.visibility_outlined,
      child: _NotificationPreviewCard(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        deepLink: _deepLinkController.text.trim(),
        notificationType: _notificationType,
        audience: _targetAudience,
        sendImmediately: _sendImmediately,
        scheduledDate: _scheduledDate,
      ),
    );
  }

  Widget _buildDraftSection() {
    return _SectionCard(
      title: 'Draft Support',
      icon: Icons.drafts_outlined,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _saveAsDraft,
        activeColor: AppColors.primary,
        title: const Text(
          'Save as Draft',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          _saveAsDraft
              ? 'Current notification is marked as local draft'
              : 'Use draft mode before final delivery',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        secondary: Icon(
          _saveAsDraft ? Icons.drafts : Icons.drafts_outlined,
          color: _saveAsDraft ? AppColors.primary : Colors.grey,
        ),
        onChanged: (value) {
          setState(() {
            _saveAsDraft = value;
          });

          if (value) {
            _saveDraft();
          }
        },
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
            onPressed: _isLoading ? null : _resetForm,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Preview',
            type: ButtonType.outline,
            icon: Icons.visibility_outlined,
            onPressed: _isLoading ? null : _showPreview,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _sendImmediately
                ? 'Send Notification'
                : 'Schedule Notification',
            icon: _sendImmediately
                ? Icons.send_outlined
                : Icons.schedule_send_outlined,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _sendNotification,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActions() {
    return Column(
      children: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading ? null : _showPreview,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: _sendImmediately ? 'Send Notification' : 'Schedule Notification',
          icon:
              _sendImmediately ? Icons.send_outlined : Icons.schedule_send_outlined,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _sendNotification,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Reset',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading ? null : _resetForm,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 760;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: 'Send Notification',
                          subtitle:
                              'Create and deliver notifications to customers, providers and admins.',
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
                        _buildComposerSection(),
                        const SizedBox(height: 20),
                        _buildRichNotificationSection(),
                        const SizedBox(height: 20),
                        _buildTargetingSection(),
                        const SizedBox(height: 20),
                        _buildScheduleSection(),
                        const SizedBox(height: 20),
                        _buildDraftSection(),
                        const SizedBox(height: 20),
                        _buildPreviewSection(),
                        const SizedBox(height: 28),
                        isCompact ? _buildMobileActions() : _buildActions(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationPreviewCard extends StatelessWidget {
  final String title;
  final String message;
  final String imageUrl;
  final String deepLink;
  final String? notificationType;
  final String? audience;
  final bool sendImmediately;
  final DateTime? scheduledDate;

  const _NotificationPreviewCard({
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.deepLink,
    required this.notificationType,
    required this.audience,
    required this.sendImmediately,
    required this.scheduledDate,
  });

  @override
  Widget build(BuildContext context) {
    final String displayTitle =
        title.isEmpty ? 'Notification Title' : title;

    final String displayMessage =
        message.isEmpty ? 'Notification message body will appear here.' : message;

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Container(
                height: 160,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade500,
                          size: 42,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  displayMessage,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(
                  label: AppFormatters.formatStatus(
                    notificationType ?? 'push',
                  ),
                  icon: Icons.category_outlined,
                  color: AppColors.primary,
                ),
                _InfoChip(
                  label: AppFormatters.formatStatus(
                    audience ?? 'all',
                  ),
                  icon: Icons.groups_outlined,
                  color: AppColors.info,
                ),
                _InfoChip(
                  label: sendImmediately
                      ? 'Send Now'
                      : scheduledDate == null
                          ? 'Scheduled'
                          : AppFormatters.formatDate(scheduledDate!),
                  icon: sendImmediately
                      ? Icons.send_outlined
                      : Icons.schedule_outlined,
                  color: sendImmediately ? AppColors.success : AppColors.warning,
                ),
                if (deepLink.isNotEmpty)
                  const _InfoChip(
                    label: 'Deep Link',
                    icon: Icons.link_outlined,
                    color: Colors.purple,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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