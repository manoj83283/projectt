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

class TermsScreen extends StatefulWidget {
  const TermsScreen({
    super.key,
  });

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isPublished = true;

  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTerms();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoading = true;
    });

    final CmsProvider provider = context.read<CmsProvider>();

    await provider.getTerms();

    if (!mounted) return;

    final terms = provider.terms;

    if (terms != null) {
      _titleController.text = terms.title;
      _summaryController.text = terms.summary;
      _contentController.text = terms.content;
      _versionController.text = terms.version;
      _isPublished = terms.isPublished;
      _lastUpdatedAt = terms.updatedAt;
    } else {
      _setDefaultContent();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setDefaultContent() {
    _titleController.text = 'Terms and Conditions';
    _versionController.text = '1.0.0';
    _summaryController.text =
        'These Terms and Conditions define the rules, responsibilities, limitations, and usage policies for EventEase customers, providers, vendors, and admins.';

    _contentController.text = '''
Terms and Conditions

Effective Date: ${AppFormatters.formatDate(DateTime.now())}

Welcome to EventEase. These Terms and Conditions govern access to and use of the EventEase platform, including customer apps, provider apps, admin portals, websites, services, booking flows, order flows, payment flows, support systems, and marketplace features.

By accessing or using EventEase, users agree to follow these Terms and Conditions.

1. Platform Overview

EventEase is a marketplace platform that connects customers with service providers, vendors, event-related services, products, bookings, payments, settlements, support, complaints, and dispute resolution services.

EventEase may support services such as event venues, photographers, makeup artists, catering, decorations, DJs, farm products, marketplace items, and other categories available on the platform.

2. User Eligibility

Users must provide accurate and complete information while creating an account or using platform services.

Users are responsible for maintaining account confidentiality, password safety, and all activities performed through their account.

EventEase may suspend, restrict, or terminate accounts that violate platform policies, misuse services, provide false information, or engage in fraudulent activities.

3. Customer Responsibilities

Customers agree to:

- Provide accurate booking, delivery, event, and payment information.
- Use the platform only for lawful and genuine service requirements.
- Make payments as required for bookings, orders, and additional services.
- Respect service providers, vendors, support teams, and platform policies.
- Avoid misuse, fraud, harassment, false complaints, fake bookings, or abusive behavior.

4. Provider Responsibilities

Providers agree to:

- Provide accurate service details, prices, availability, KYC, documents, and portfolio information.
- Deliver services professionally and within agreed timelines.
- Maintain quality, safety, communication, and customer satisfaction standards.
- Avoid fake listings, misleading pricing, poor-quality service, fraud, or unauthorized cancellations.
- Follow settlement, commission, refund, and dispute policies.

5. Bookings and Orders

Bookings and orders are subject to provider availability, category rules, pricing, location, event date, service confirmation, payment status, and platform approval.

EventEase may cancel, reschedule, hold, or review bookings or orders when fraud, payment issues, policy violations, provider unavailability, or operational issues are detected.

6. Payments, Refunds, and Settlements

Payments may be processed through approved payment gateways, wallets, UPI, cards, net banking, cash, or other supported payment methods.

Refunds are subject to cancellation rules, service status, provider policy, dispute outcomes, payment gateway timelines, and EventEase platform policies.

Provider settlements may be subject to commission deductions, penalties, refund adjustments, tax rules, KYC verification, settlement cycles, and operational checks.

7. Cancellations

Cancellation rules may vary depending on service category, provider policy, booking stage, payment status, event date, and platform rules.

Cancellation charges may apply. Refund eligibility is determined according to EventEase policies and applicable terms.

8. Reviews and Ratings

Customers may submit reviews and ratings based on genuine experiences.

EventEase may moderate, hide, reject, or remove reviews that are fake, abusive, hateful, misleading, spam, irrelevant, or policy-violating.

9. Complaints and Disputes

Users may raise tickets, complaints, or disputes through support channels.

EventEase may review evidence, communication, booking details, payment records, provider responses, customer inputs, and internal logs to resolve complaints and disputes.

Platform decisions may include refund, rejection, settlement adjustment, penalty, warning, suspension, or closure.

10. Prohibited Activities

Users must not:

- Use EventEase for illegal, fraudulent, harmful, or abusive activities.
- Create fake accounts, fake bookings, fake reviews, or misleading listings.
- Attempt unauthorized access to systems, data, APIs, or admin tools.
- Upload harmful files, malware, offensive content, or illegal material.
- Harass, threaten, abuse, discriminate, or exploit customers, providers, admins, or support teams.
- Bypass platform payments, commissions, service charges, or policies.

11. Platform Rights

EventEase reserves the right to:

- Update, modify, suspend, or discontinue any feature or service.
- Review, approve, reject, suspend, or remove providers, listings, coupons, banners, categories, services, reviews, orders, bookings, and accounts.
- Investigate policy violations, fraud, misuse, security issues, and suspicious activity.
- Apply penalties, restrictions, account suspension, or legal action when required.

12. Content and Intellectual Property

All platform content, branding, UI, design, logos, trademarks, workflows, code, databases, and business processes belong to EventEase or its authorized owners.

Users may not copy, reproduce, distribute, reverse engineer, or misuse platform materials without written permission.

13. Limitation of Liability

EventEase works to provide a reliable platform, but it does not guarantee uninterrupted, error-free, or risk-free service.

EventEase is not liable for indirect losses, business losses, delays, third-party failures, provider misconduct, customer misuse, payment gateway downtime, internet issues, or external service failures beyond reasonable control.

14. Privacy

Use of EventEase is also governed by the Privacy Policy. Users should review the Privacy Policy to understand how data is collected, used, stored, and protected.

15. Changes to Terms

EventEase may update these Terms and Conditions from time to time. Updated terms will be posted on the platform with a revised effective date.

Continued use of EventEase after updates means users accept the revised terms.

16. Contact

For questions, complaints, disputes, or support requests, users can contact EventEase through official support channels available on the app, website, or admin-approved communication methods.
''';
  }

  Future<void> _saveTerms() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().saveTerms(
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
        'Terms and Conditions saved successfully',
      );

      await _loadTerms();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to save Terms and Conditions',
    );
  }

  Future<void> _publishTerms() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool confirmed = await _showConfirmationDialog(
      title: 'Publish Terms',
      message:
          'Are you sure you want to publish these Terms and Conditions? Published content will be visible to users.',
      confirmText: 'Publish',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().publishTerms(
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
        'Terms and Conditions published successfully',
      );

      await _loadTerms();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to publish Terms and Conditions',
    );
  }

  Future<void> _unpublishTerms() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Unpublish Terms',
      message:
          'Are you sure you want to unpublish these Terms and Conditions? They may no longer be visible to users.',
      confirmText: 'Unpublish',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().unpublishTerms();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'Terms and Conditions unpublished successfully',
      );

      await _loadTerms();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to unpublish Terms and Conditions',
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    _loadTerms();
  }

  void _previewTerms() {
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
                          Icons.gavel_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Terms and Conditions Preview',
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
                              ? 'Terms and Conditions'
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
                              ? 'No Terms and Conditions content available.'
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
      title: 'Terms and Conditions',
      subtitle:
          'Create, update, preview, publish and manage EventEase platform Terms and Conditions.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewTerms,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Refresh',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading || _isSaving ? null : _loadTerms,
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
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
              const SizedBox(width: 14),
              Expanded(child: cards[2]),
            ],
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
      labelText: 'Terms Title',
      hintText: 'Terms and Conditions',
      prefixIcon: Icons.title_outlined,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Terms title is required';
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
      title: 'Terms Summary',
      icon: Icons.summarize_outlined,
      child: CustomTextField(
        controller: _summaryController,
        labelText: 'Summary',
        hintText: 'Short summary shown internally or on terms page',
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
      title: 'Terms Content',
      icon: Icons.article_outlined,
      child: CustomTextField(
        controller: _contentController,
        labelText: 'Terms and Conditions Content',
        hintText: 'Enter complete Terms and Conditions content',
        prefixIcon: Icons.description_outlined,
        maxLines: 24,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Terms and Conditions content is required';
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
              ? 'Terms and Conditions are visible to users'
              : 'Terms and Conditions are saved as draft',
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
            onPressed: _isSaving ? null : _saveTerms,
          ),
          CustomButton(
            text: 'Publish',
            icon: Icons.publish_outlined,
            onPressed: _isSaving ? null : _publishTerms,
          ),
          CustomButton(
            text: 'Unpublish',
            type: ButtonType.outline,
            icon: Icons.visibility_off_outlined,
            onPressed: _isSaving || !_isPublished ? null : _unpublishTerms,
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
                  onRefresh: _loadTerms,
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
                if (_isSaving)
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