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

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({
    super.key,
  });

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isPublished = true;

  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAboutUs();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _missionController.dispose();
    _visionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _loadAboutUs() async {
    setState(() {
      _isLoading = true;
    });

    final CmsProvider provider = context.read<CmsProvider>();

    await provider.getAboutUs();

    if (!mounted) return;

    final aboutUs = provider.aboutUs;

    if (aboutUs != null) {
      _titleController.text = aboutUs.title;
      _subtitleController.text = aboutUs.subtitle;
      _summaryController.text = aboutUs.summary;
      _contentController.text = aboutUs.content;
      _missionController.text = aboutUs.mission;
      _visionController.text = aboutUs.vision;
      _emailController.text = aboutUs.email;
      _phoneController.text = aboutUs.phone;
      _websiteController.text = aboutUs.website;
      _addressController.text = aboutUs.address;
      _versionController.text = aboutUs.version;
      _isPublished = aboutUs.isPublished;
      _lastUpdatedAt = aboutUs.updatedAt;
    } else {
      _setDefaultContent();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setDefaultContent() {
    _titleController.text = 'About EventEase';
    _subtitleController.text =
        'Your trusted marketplace for events, services, products, providers and local experiences.';
    _versionController.text = '1.0.0';

    _summaryController.text =
        'EventEase is a marketplace platform designed to simplify event planning, service discovery, provider bookings, product ordering, payments, support, complaints and dispute resolution.';

    _contentController.text = '''
EventEase is a modern marketplace platform built to help customers discover, compare, book and manage event-related services and marketplace products in one place.

The platform connects customers with trusted service providers, vendors, venues and local businesses across multiple categories such as convention halls, resorts, photographers, makeup artists, catering, decoration, DJs, farm products, groceries and other marketplace items.

EventEase focuses on making the entire service journey simple, transparent and reliable. From discovery to booking, payment, provider assignment, order tracking, reviews, support, complaints and dispute resolution, the platform is designed to support both customers and providers with a scalable digital experience.

For customers, EventEase helps reduce the effort involved in planning events, finding reliable providers, comparing services, managing bookings and making secure payments.

For providers, EventEase creates a digital marketplace where they can list services, manage availability, receive bookings, track earnings, complete KYC, handle settlements and grow their business.

EventEase Admin helps the platform team manage bookings, services, providers, payments, settlements, coupons, notifications, reviews, complaints, disputes, CMS pages and operational workflows from one centralized dashboard.
''';

    _missionController.text =
        'Our mission is to make event planning, service booking and local marketplace access simple, reliable and scalable for customers, providers and communities.';

    _visionController.text =
        'Our vision is to become a trusted digital marketplace that connects people, services, products and local businesses across cities, towns and rural regions.';

    _emailController.text = 'support@eventease.com';
    _phoneController.text = '+91 90000 00000';
    _websiteController.text = 'https://eventease.com';
    _addressController.text = 'Hyderabad, Telangana, India';
  }

  Future<void> _saveAboutUs() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().saveAboutUs(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          mission: _missionController.text.trim(),
          vision: _visionController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          website: _websiteController.text.trim(),
          address: _addressController.text.trim(),
          version: _versionController.text.trim(),
          isPublished: _isPublished,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'About Us content saved successfully',
      );

      await _loadAboutUs();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to save About Us content',
    );
  }

  Future<void> _publishAboutUs() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool confirmed = await _showConfirmationDialog(
      title: 'Publish About Us',
      message:
          'Are you sure you want to publish this About Us page? Published content will be visible to users.',
      confirmText: 'Publish',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().publishAboutUs(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          mission: _missionController.text.trim(),
          vision: _visionController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          website: _websiteController.text.trim(),
          address: _addressController.text.trim(),
          version: _versionController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'About Us page published successfully',
      );

      await _loadAboutUs();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to publish About Us page',
    );
  }

  Future<void> _unpublishAboutUs() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Unpublish About Us',
      message:
          'Are you sure you want to unpublish this About Us page? It may no longer be visible to users.',
      confirmText: 'Unpublish',
      confirmColor: AppColors.warning,
    );

    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    final bool success = await context.read<CmsProvider>().unpublishAboutUs();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      NavigationService.showSuccess(
        'About Us page unpublished successfully',
      );

      await _loadAboutUs();
      return;
    }

    NavigationService.showError(
      context.read<CmsProvider>().errorMessage ??
          'Failed to unpublish About Us page',
    );
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    _loadAboutUs();
  }

  void _previewAboutUs() {
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
              maxWidth: 860,
              maxHeight: 780,
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
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'About Us Preview',
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
                              ? 'About EventEase'
                              : _titleController.text.trim(),
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (_subtitleController.text.trim().isNotEmpty)
                          Text(
                            _subtitleController.text.trim(),
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey.shade700,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 20),
                        if (_summaryController.text.trim().isNotEmpty)
                          _PreviewBox(
                            title: 'Summary',
                            icon: Icons.summarize_outlined,
                            color: AppColors.info,
                            message: _summaryController.text.trim(),
                          ),
                        const SizedBox(height: 18),
                        Text(
                          _contentController.text.trim().isEmpty
                              ? 'No About Us content available.'
                              : _contentController.text.trim(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.55,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 20),
                        _PreviewBox(
                          title: 'Mission',
                          icon: Icons.flag_outlined,
                          color: AppColors.primary,
                          message: _missionController.text.trim().isEmpty
                              ? 'Not Available'
                              : _missionController.text.trim(),
                        ),
                        const SizedBox(height: 14),
                        _PreviewBox(
                          title: 'Vision',
                          icon: Icons.visibility_outlined,
                          color: AppColors.success,
                          message: _visionController.text.trim().isEmpty
                              ? 'Not Available'
                              : _visionController.text.trim(),
                        ),
                        const SizedBox(height: 20),
                        _PreviewBox(
                          title: 'Contact',
                          icon: Icons.contact_support_outlined,
                          color: Colors.purple,
                          message:
                              'Email: ${_emailController.text.trim().isEmpty ? 'Not Available' : _emailController.text.trim()}\n'
                              'Phone: ${_phoneController.text.trim().isEmpty ? 'Not Available' : _phoneController.text.trim()}\n'
                              'Website: ${_websiteController.text.trim().isEmpty ? 'Not Available' : _websiteController.text.trim()}\n'
                              'Address: ${_addressController.text.trim().isEmpty ? 'Not Available' : _addressController.text.trim()}',
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
      title: 'About Us',
      subtitle:
          'Create, update, preview, publish and manage EventEase About Us page content.',
      actions: [
        CustomButton(
          text: 'Preview',
          type: ButtonType.outline,
          icon: Icons.visibility_outlined,
          onPressed: _isLoading || _isSaving ? null : _previewAboutUs,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Refresh',
          type: ButtonType.outline,
          icon: Icons.refresh,
          onPressed: _isLoading || _isSaving ? null : _loadAboutUs,
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
      child: Column(
        children: [
          LayoutBuilder(
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
          const SizedBox(height: 16),
          CustomTextField(
            controller: _subtitleController,
            labelText: 'Subtitle',
            hintText: 'Short subtitle displayed below About Us title',
            prefixIcon: Icons.subtitles_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Subtitle is required';
              }

              if (value.trim().length < 10) {
                return 'Subtitle must be at least 10 characters';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return CustomTextField(
      controller: _titleController,
      labelText: 'Page Title',
      hintText: 'About EventEase',
      prefixIcon: Icons.title_outlined,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Page title is required';
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
      title: 'About Summary',
      icon: Icons.summarize_outlined,
      child: CustomTextField(
        controller: _summaryController,
        labelText: 'Summary',
        hintText: 'Short summary shown internally or on About Us page',
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
      title: 'About Content',
      icon: Icons.article_outlined,
      child: CustomTextField(
        controller: _contentController,
        labelText: 'About Us Content',
        hintText: 'Enter complete About Us content',
        prefixIcon: Icons.description_outlined,
        maxLines: 18,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'About Us content is required';
          }

          if (value.trim().length < 100) {
            return 'Content must be at least 100 characters';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildMissionVisionSection() {
    return _SectionCard(
      title: 'Mission and Vision',
      icon: Icons.flag_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              children: [
                _buildMissionField(),
                const SizedBox(height: 16),
                _buildVisionField(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildMissionField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVisionField(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionField() {
    return CustomTextField(
      controller: _missionController,
      labelText: 'Mission',
      hintText: 'Enter EventEase mission',
      prefixIcon: Icons.flag_outlined,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Mission is required';
        }

        if (value.trim().length < 20) {
          return 'Mission must be at least 20 characters';
        }

        return null;
      },
    );
  }

  Widget _buildVisionField() {
    return CustomTextField(
      controller: _visionController,
      labelText: 'Vision',
      hintText: 'Enter EventEase vision',
      prefixIcon: Icons.visibility_outlined,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vision is required';
        }

        if (value.trim().length < 20) {
          return 'Vision must be at least 20 characters';
        }

        return null;
      },
    );
  }

  Widget _buildContactSection() {
    return _SectionCard(
      title: 'Contact Information',
      icon: Icons.contact_support_outlined,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildEmailField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhoneField(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _websiteController,
            labelText: 'Website',
            hintText: 'https://eventease.com',
            prefixIcon: Icons.language_outlined,
            validator: (value) {
              final String website = value?.trim() ?? '';

              if (website.isEmpty) {
                return 'Website is required';
              }

              final Uri? uri = Uri.tryParse(website);

              if (uri == null || !uri.hasScheme) {
                return 'Enter valid website URL';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter business address',
            prefixIcon: Icons.location_on_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }

              if (value.trim().length < 5) {
                return 'Address must be at least 5 characters';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      labelText: 'Support Email',
      hintText: 'support@eventease.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        final String email = value?.trim() ?? '';

        if (email.isEmpty) {
          return 'Email is required';
        }

        final bool isValid = RegExp(
          r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
        ).hasMatch(email);

        if (!isValid) {
          return 'Enter valid email';
        }

        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      labelText: 'Support Phone',
      hintText: '+91 90000 00000',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }

        if (value.trim().length < 8) {
          return 'Enter valid phone number';
        }

        return null;
      },
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
              ? 'About Us page is visible to users'
              : 'About Us page is saved as draft',
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
            onPressed: _isSaving ? null : _saveAboutUs,
          ),
          CustomButton(
            text: 'Publish',
            icon: Icons.publish_outlined,
            onPressed: _isSaving ? null : _publishAboutUs,
          ),
          CustomButton(
            text: 'Unpublish',
            type: ButtonType.outline,
            icon: Icons.visibility_off_outlined,
            onPressed: _isSaving || !_isPublished ? null : _unpublishAboutUs,
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
                  onRefresh: _loadAboutUs,
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
                          _buildMissionVisionSection(),
                          const SizedBox(height: 20),
                          _buildContactSection(),
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

class _PreviewBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String message;

  const _PreviewBox({
    required this.title,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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