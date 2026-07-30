import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cms_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/page_header.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isPublished = true;

  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrivacyPolicy();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _versionController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
    });

    final CmsProvider provider = context.read<CmsProvider>();

    await provider.getPrivacyPolicy();

    if (!mounted) return;

    final privacyPolicy = provider.privacyPolicy;

    if (privacyPolicy != null) {
      _titleController.text = privacyPolicy.title;
      _contentController.text = privacyPolicy.content;
      _versionController.text = privacyPolicy.version;
      _summaryController.text = privacyPolicy.summary;
      _isPublished = privacyPolicy.isPublished;
      _lastUpdatedAt = privacyPolicy.updatedAt;
    } else {
      _setDefaultContent();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setDefaultContent() {
    _titleController.text = 'Privacy Policy';
    _versionController.text = '1.0.0';
    _summaryController.text =
        'This Privacy Policy explains how EventEase collects, uses, stores, protects, and shares user information.';

    _contentController.text = '''
Privacy Policy

Effective Date: ${AppFormatters.formatDate(DateTime.now())}

Welcome to EventEase. Your privacy is important to us. This Privacy Policy explains how EventEase collects, uses, stores, protects, and shares information when customers, providers, vendors, admins, and other users access or use the EventEase platform.

1. Information We Collect

We may collect the following information:

- Personal information such as name, email address, phone number, profile photo, and address.
- Account information such as login credentials, role, preferences, and account status.
- Booking information such as service details, event dates, location, provider details, and payment status.
- Payment information such as transaction ID, payment mode, refund details, settlement information, and invoice references.
- Provider information such as KYC documents, service categories, availability, pricing, portfolio, reviews, and payout details.
- Location information when required for service discovery, delivery, booking, navigation, and operational support.
- Device information such as device type, IP address, operating system, browser information, app version, and usage logs.
- Support information such as tickets, complaints, disputes, chat messages, feedback, and moderation records.

2. How We Use Information

We use collected information to:

- Create and manage user accounts.
- Process bookings, orders, payments, refunds, and settlements.
- Connect customers with service providers.
- Verify provider identity and eligibility.
- Improve platform safety, reliability, and user experience.
- Provide customer support and dispute resolution.
- Send service updates, notifications, offers, and operational communication.
- Prevent fraud, abuse, unauthorized access, and policy violations.
- Comply with applicable laws, regulations, audit requirements, and legal obligations.

3. Information Sharing

We may share limited information with:

- Customers and providers for booking fulfillment.
- Payment gateway partners for transaction processing.
- Logistics, support, verification, analytics, and operational service providers.
- Government authorities or legal bodies when required by law.
- Internal admin and support teams for platform operations.

We do not sell personal information to third parties.

4. Data Security

We use reasonable administrative, technical, and organizational safeguards to protect user information from unauthorized access, misuse, alteration, disclosure, or destruction.

However, no digital platform can guarantee complete security. Users are responsible for maintaining the confidentiality of their account credentials.

5. Data Retention

We retain personal information only as long as necessary for:

- Providing platform services.
- Legal, tax, accounting, audit, and compliance requirements.
- Fraud prevention and dispute resolution.
- Business operations and record keeping.

Users may request account deletion or data updates as permitted by applicable law and platform policies.

6. User Rights

Depending on applicable laws, users may have rights to:

- Access their personal information.
- Correct inaccurate information.
- Request data deletion.
- Withdraw consent where processing is based on consent.
- Object to certain processing activities.
- Request support regarding privacy concerns.

7. Cookies and Tracking

EventEase may use cookies, analytics tools, device identifiers, and similar technologies to improve platform performance, personalize experience, measure usage, and enhance security.

8. Children’s Privacy

EventEase is intended for users who are legally eligible to use marketplace and payment services. We do not knowingly collect personal information from children without appropriate consent where required by law.

9. Policy Updates

We may update this Privacy Policy from time to time. Updated versions will be posted on the platform with the revised effective date. Continued use of EventEase after updates means users accept the revised policy.

10. Contact Us

For privacy-related questions, requests, or complaints, users can contact EventEase support through the app, website, or official support channels.
''';
  }

  Future<void> _savePrivacyPolicy() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().savePrivacyPolicy(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          version: _versionController.text.trim(),
          isPublished: _isPublished,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Privacy policy saved successfully',
      );

      await _loadPrivacyPolicy();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to save privacy policy',
    );
  }

  Future<void> _publishPrivacyPolicy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool confirmed = await _showConfirmationDialog(
      title: 'Publish Privacy Policy',
      message:
          'Are you sure you want to publish this Privacy Policy? Published content will be visible to users.',
      confirmText: 'Publish',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().publishPrivacyPolicy(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          version: _versionController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Privacy policy published successfully',
      );

      await _loadPrivacyPolicy();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to publish privacy policy',
    );
  }

  Future<void> _unpublishPrivacyPolicy() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Unpublish Privacy Policy',
      message:
          'Are you sure you want to unpublish this Privacy Policy? It may no longer be visible to users.',
      confirmText: 'Unpublish',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success =
        await context.read<CmsProvider>().unpublishPrivacyPolicy();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Privacy policy unpublished successfully',
      );

      await _loadPrivacyPolicy();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to unpublish privacy policy',
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    _loadPrivacyPolicy();
  }

  void _previewPrivacyPolicy() {
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
              maxWidth: 840,
              maxHeight: 760,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.padding20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Privacy Policy Preview',
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
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.padding24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text.trim().isEmpty
                              ? 'Privacy Policy'
                              : _titleController.text.trim(),
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatusChip(
                              label:
                                  'Version ${_versionController.text.trim().isEmpty ? '1.0.0' : _versionController.text.trim()}',
                              color: AppColors.primary,
                            ),
                            _StatusChip(
                              label: _isPublished ? 'Published' : 'Draft',
                              color: _isPublished
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (_summaryController.text.trim().isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(AppDimensions.padding16),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius12,
                              ),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.22),
                              ),
                            ),
                            child: Text(
                              _summaryController.text.trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          _contentController.text.trim().isEmpty
                              ? 'No privacy policy content available.'
                              : _contentController.text.trim(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.55,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      title: 'Privacy Policy',
      subtitle:
          'Create, update, preview, publish and manage EventEase platform privacy policy content.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewPrivacyPolicy,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Refresh',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading || _isSaving ? null : _loadPrivacyPolicy,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          final List<Widget> cards = [
            _InfoTile(
              label: 'Content Status',
              value: _isPublished ? 'Published' : 'Draft',
              icon: _isPublished
                  ? Icons.check_circle_outline
                  : Icons.edit_note_outlined,
              color: _isPublished ? AppColors.success : AppColors.warning,
            ),
            _InfoTile(
              label: 'Version',
              value: _versionController.text.trim().isEmpty
                  ? '1.0.0'
                  : _versionController.text.trim(),
              icon: Icons.account_tree_outlined,
              color: AppColors.primary,
            ),
            _InfoTile(
              label: 'Last Updated',
              value: _lastUpdatedAt == null
                  ? 'Not Available'
                  : AppFormatters.formatDateTime(_lastUpdatedAt!),
              icon: Icons.update_outlined,
              color: AppColors.info,
            ),
          ];

          if (isCompact) {
            return Column(
              children: cards
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: card,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return _SectionCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildVersionField(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTitleField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVersionField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return CustomTextField(
      controller: _titleController,
      labelText: 'Policy Title',
      hintText: 'Privacy Policy',
      prefixIcon: Icons.title_outlined,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Policy title is required';
        }

        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }

        return null;
      },
    );
  }

  Widget _buildVersionField() {
    return CustomTextField(
      controller: _versionController,
      labelText: 'Version',
      hintText: 'Example: 1.0.0',
      prefixIcon: Icons.account_tree_outlined,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Version is required';
        }

        return null;
      },
    );
  }

  Widget _buildSummarySection() {
    return _SectionCard(
      title: 'Policy Summary',
      icon: Icons.summarize_outlined,
      child: CustomTextField(
        controller: _summaryController,
        labelText: 'Summary',
        hintText: 'Short summary shown internally or on policy pages',
        prefixIcon: Icons.notes_outlined,
        maxLines: 4,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Summary is required';
          }

          if (value.trim().length < 20) {
            return 'Summary must be at least 20 characters';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildContentSection() {
    return _SectionCard(
      title: 'Policy Content',
      icon: Icons.article_outlined,
      child: CustomTextField(
        controller: _contentController,
        labelText: 'Privacy Policy Content',
        hintText: 'Enter complete privacy policy content',
        prefixIcon: Icons.description_outlined,
        maxLines: 24,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Privacy policy content is required';
          }

          if (value.trim().length < 100) {
            return 'Content must be at least 100 characters';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildPublishSection() {
    return _SectionCard(
      title: 'Publishing Settings',
      icon: Icons.publish_outlined,
      child: SwitchListTile(
        value: _isPublished,
        activeColor: AppColors.success,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Published',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          _isPublished
              ? 'Privacy Policy is visible to users'
              : 'Privacy Policy is saved as draft',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        secondary: Icon(
          _isPublished ? Icons.visibility_outlined : Icons.visibility_off,
          color: _isPublished ? AppColors.success : AppColors.warning,
        ),
        onChanged: _isSaving
            ? null
            : (value) {
                setState(() {
                  _isPublished = value;
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
            onPressed: _isSaving ? null : _resetForm,
          ),
          CustomButton(
            text: 'Save Draft',
            type: ButtonType.outline,
            icon: Icons.save_outlined,
            isLoading: _isSaving && !_isPublished,
            onPressed: _isSaving ? null : _savePrivacyPolicy,
          ),
          CustomButton(
            text: 'Publish',
            icon: Icons.publish_outlined,
            isLoading: _isSaving && _isPublished,
            onPressed: _isSaving ? null : _publishPrivacyPolicy,
          ),
          CustomButton(
            text: 'Unpublish',
            type: ButtonType.outline,
            icon: Icons.visibility_off_outlined,
            onPressed:
                _isSaving || !_isPublished ? null : _unpublishPrivacyPolicy,
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
          children: actions
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: action,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CmsProvider>(
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
                  onRefresh: _loadPrivacyPolicy,
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
                          _buildStatusCard(),
                          const SizedBox(height: 20),
                          _buildBasicInformationSection(),
                          const SizedBox(height: 20),
                          _buildSummarySection(),
                          const SizedBox(height: 20),
                          _buildContentSection(),
                          const SizedBox(height: 20),
                          _buildPublishSection(),
                          const SizedBox(height: 28),
                          _buildActions(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.06),
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoTile({
    required this.label,
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
            backgroundColor: color.withOpacity(0.12),
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
                  label,
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
                  value,
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