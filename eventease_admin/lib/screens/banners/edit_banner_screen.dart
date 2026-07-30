import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_validator.dart';
import '../../core/utils/formatters.dart';
import '../../models/banner_model.dart';
import '../../providers/banner_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class EditBannerScreen extends StatefulWidget {
  const EditBannerScreen({
    super.key,
  });

  @override
  State<EditBannerScreen> createState() =>
      _EditBannerScreenState();
}

class _EditBannerScreenState
    extends State<EditBannerScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _subtitleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _targetIdController =
      TextEditingController();

  final TextEditingController _deepLinkController =
      TextEditingController();

  final TextEditingController _priorityController =
      TextEditingController();

  final TextEditingController _buttonTextController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  BannerModel? _banner;

  File? _selectedImage;

  String? _existingImageUrl;

  String? _selectedPlacement;
  String? _selectedTargetType;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isActive = true;
  bool _isFeatured = false;
  bool _removeExistingImage = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is BannerModel) {
      _banner = args;
      _bindBannerData(args);
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _targetIdController.dispose();
    _deepLinkController.dispose();
    _priorityController.dispose();
    _buttonTextController.dispose();

    super.dispose();
  }

  // =====================================================
  // BIND BANNER DATA
  // =====================================================

  void _bindBannerData(
    BannerModel banner,
  ) {
    _titleController.text = banner.title;
    _subtitleController.text = banner.subtitle;
    _descriptionController.text =
        banner.description;
    _targetIdController.text = banner.targetId;
    _deepLinkController.text = banner.deepLink;
    _priorityController.text =
        banner.priority.toString();
    _buttonTextController.text =
        banner.buttonText.isNotEmpty
            ? banner.buttonText
            : 'Explore';

    _existingImageUrl = banner.imageUrl;
    _selectedPlacement = banner.placement;
    _selectedTargetType = banner.targetType;

    _startDate = banner.startDate;
    _endDate = banner.endDate;

    _isActive = banner.isActive;
    _isFeatured = banner.isFeatured;

    _selectedImage = null;
    _removeExistingImage = false;
  }

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _selectedImage = File(
          pickedFile.path,
        );
        _removeExistingImage = false;
      });
    } catch (_) {
      NavigationService.showError(
        'Unable to select banner image',
      );
    }
  }

  // =====================================================
  // REMOVE IMAGE
  // =====================================================

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
      _removeExistingImage = true;
    });
  }

  // =====================================================
  // PICK START DATE
  // =====================================================

  Future<void> _pickStartDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (pickedDate == null) return;

    setState(() {
      _startDate = pickedDate;

      if (_endDate != null &&
          _endDate!.isBefore(pickedDate)) {
        _endDate = null;
      }
    });
  }

  // =====================================================
  // PICK END DATE
  // =====================================================

  Future<void> _pickEndDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate: _endDate ??
          _startDate ??
          DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (pickedDate == null) return;

    setState(() {
      _endDate = pickedDate;
    });
  }

  // =====================================================
  // CLEAR DATE RANGE
  // =====================================================

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  // =====================================================
  // RESET FORM
  // =====================================================

  void _resetForm() {
    if (_banner == null) return;

    setState(() {
      _bindBannerData(_banner!);
    });

    NavigationService.showInfo(
      'Banner form reset to original values',
    );
  }

  // =====================================================
  // UPDATE BANNER
  // =====================================================

  Future<void> _updateBanner() async {
    FocusScope.of(context).unfocus();

    if (_banner == null) {
      NavigationService.showError(
        'Banner data not found',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPlacement == null ||
        _selectedPlacement!.isEmpty) {
      NavigationService.showWarning(
        'Please select banner placement',
      );
      return;
    }

    if (_selectedTargetType == null ||
        _selectedTargetType!.isEmpty) {
      NavigationService.showWarning(
        'Please select target type',
      );
      return;
    }

    if (_selectedImage == null &&
        (_existingImageUrl == null ||
            _existingImageUrl!.isEmpty) &&
        !_removeExistingImage) {
      NavigationService.showWarning(
        'Please select banner image',
      );
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      NavigationService.showWarning(
        'End date cannot be before start date',
      );
      return;
    }

    final priority =
        int.tryParse(
              _priorityController.text.trim(),
            ) ??
            0;

    final success =
        await context
            .read<BannerProvider>()
            .updateBanner(
              bannerId: _banner!.id,
              title: _titleController.text.trim(),
              subtitle:
                  _subtitleController.text.trim(),
              description:
                  _descriptionController.text.trim(),
              placement: _selectedPlacement!,
              targetType: _selectedTargetType!,
              targetId:
                  _targetIdController.text.trim(),
              deepLink:
                  _deepLinkController.text.trim(),
              buttonText:
                  _buttonTextController.text.trim(),
              priority: priority,
              startDate: _startDate,
              endDate: _endDate,
              isActive: _isActive,
              isFeatured: _isFeatured,
              imageFile: _selectedImage,
              removeImage: _removeExistingImage,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Banner updated successfully',
      );

      Navigator.pop(
        context,
        true,
      );
    } else {
      final error =
          context
              .read<BannerProvider>()
              .errorMessage;

      NavigationService.showError(
        error ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_banner == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Banner',
          ),
        ),
        body: const Center(
          child: Text(
            'Banner data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Banner',
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetForm,
            icon: const Icon(
              Icons.restart_alt_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<BannerProvider>(
          builder: (
            context,
            bannerProvider,
            child,
          ) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(
                    height: AppDimensions.padding24,
                  ),

                  if (bannerProvider.errorMessage !=
                      null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom:
                            AppDimensions.padding16,
                      ),
                      child: ErrorCard(
                        message: bannerProvider
                            .errorMessage!,
                      ),
                    ),

                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final bool isMobile =
                            constraints.maxWidth <
                                950;

                        if (isMobile) {
                          return Column(
                            children: [
                              _buildBannerInfoCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildImageCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildTargetCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildScheduleCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildSettingsCard(),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildActions(
                                bannerProvider,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child:
                                      _buildBannerInfoCard(),
                                ),

                                const SizedBox(
                                  width: 16,
                                ),

                                Expanded(
                                  child:
                                      _buildImageCard(),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      _buildTargetCard(),
                                ),

                                const SizedBox(
                                  width: 16,
                                ),

                                Expanded(
                                  child:
                                      _buildScheduleCard(),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            _buildSettingsCard(),

                            const SizedBox(
                              height: 24,
                            ),

                            _buildActions(
                              bannerProvider,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color:
                AppColors.primary.withOpacity(
              0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.radius16,
            ),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: AppColors.primary,
            size: 30,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Banner',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Update banner content, image, target, schedule, priority, and visibility settings.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Banner ID: ${_banner!.id}',
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BANNER INFO CARD
  // =====================================================

  Widget _buildBannerInfoCard() {
    return _SectionCard(
      title: 'Banner Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          CustomTextField(
            controller: _titleController,
            labelText: 'Banner Title',
            hintText:
                'Example: Wedding Photography Offers',
            prefixIcon: const Icon(
              Icons.title_outlined,
            ),
            validator: (value) {
              return AppValidator.required(
                value,
                fieldName: 'Banner title',
              );
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _subtitleController,
            labelText: 'Subtitle',
            hintText:
                'Example: Book trusted providers near you',
            prefixIcon: const Icon(
              Icons.subtitles_outlined,
            ),
            validator: (value) {
              return AppValidator.required(
                value,
                fieldName: 'Subtitle',
              );
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller:
                _descriptionController,
            labelText: 'Description',
            hintText:
                'Write a short description for this banner',
            maxLines: 4,
            textInputAction:
                TextInputAction.newline,
            prefixIcon: const Icon(
              Icons.description_outlined,
            ),
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller:
                _buttonTextController,
            labelText: 'Button Text',
            hintText:
                'Example: Explore, Book Now, View Offers',
            prefixIcon: const Icon(
              Icons.smart_button_outlined,
            ),
            validator: (value) {
              return AppValidator.required(
                value,
                fieldName: 'Button text',
              );
            },
          ),
        ],
      ),
    );
  }

  // =====================================================
  // IMAGE CARD
  // =====================================================

  Widget _buildImageCard() {
    return _SectionCard(
      title: 'Banner Image',
      icon: Icons.image_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                AppDimensions.radius16,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: _buildImagePreview(),
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: _selectedImage == null &&
                          (_existingImageUrl == null ||
                              _existingImageUrl!
                                  .isEmpty)
                      ? 'Choose Image'
                      : 'Change Image',
                  type: ButtonType.outline,
                  icon: Icons.upload_file_rounded,
                  onPressed: _pickImage,
                ),
              ),

              if (_selectedImage != null ||
                  (_existingImageUrl != null &&
                      _existingImageUrl!
                          .isNotEmpty)) ...[
                const SizedBox(width: 12),

                Expanded(
                  child: CustomButton(
                    text: 'Remove',
                    type: ButtonType.danger,
                    icon: Icons.delete_outline,
                    onPressed: _removeImage,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(
            height: AppDimensions.padding12,
          ),

          const Text(
            'Supported formats: JPG, PNG, WEBP. Updating image will replace existing banner image.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (_existingImageUrl != null &&
        _existingImageUrl!.isNotEmpty &&
        !_removeExistingImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _emptyImagePlaceholder(
              'Unable to load image',
            );
          },
        ),
      );
    }

    return _emptyImagePlaceholder(
      'No banner image selected',
    );
  }

  Widget _emptyImagePlaceholder(
    String title,
  ) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: AppColors.primary
                .withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.primary,
            size: 34,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Recommended ratio: 16:9 or 3:1',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // TARGET CARD
  // =====================================================

  Widget _buildTargetCard() {
    return _SectionCard(
      title: 'Placement & Target',
      icon: Icons.ads_click_outlined,
      child: Column(
        children: [
          CustomDropdown<String>(
            labelText: 'Placement',
            hintText: 'Select placement',
            value: _selectedPlacement,
            items: const [
              'home',
              'category',
              'service',
              'checkout',
              'profile',
              'offers',
            ],
            itemLabelBuilder: _placementLabel,
            prefixIcon: const Icon(
              Icons.place_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Placement is required';
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedPlacement = value;
              });
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomDropdown<String>(
            labelText: 'Target Type',
            hintText: 'Select target type',
            value: _selectedTargetType,
            items: const [
              'none',
              'category',
              'service',
              'provider',
              'coupon',
              'external',
              'deep_link',
            ],
            itemLabelBuilder: _targetTypeLabel,
            prefixIcon: const Icon(
              Icons.link_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Target type is required';
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedTargetType = value;
              });
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _targetIdController,
            labelText: 'Target ID / URL',
            hintText:
                'Enter categoryId, serviceId, couponId or external URL',
            prefixIcon: const Icon(
              Icons.tag_outlined,
            ),
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _deepLinkController,
            labelText: 'Deep Link',
            hintText:
                'Example: eventease://category/123',
            prefixIcon: const Icon(
              Icons.route_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SCHEDULE CARD
  // =====================================================

  Widget _buildScheduleCard() {
    return _SectionCard(
      title: 'Schedule',
      icon: Icons.calendar_month_outlined,
      child: Column(
        children: [
          _DateSelectorTile(
            title: 'Start Date',
            value: _startDate == null
                ? 'No start date'
                : AppFormatters.formatDate(
                    _startDate,
                  ),
            icon: Icons.play_arrow_rounded,
            onTap: _pickStartDate,
          ),

          const SizedBox(
            height: AppDimensions.padding12,
          ),

          _DateSelectorTile(
            title: 'End Date',
            value: _endDate == null
                ? 'No end date'
                : AppFormatters.formatDate(
                    _endDate,
                  ),
            icon: Icons.stop_rounded,
            onTap: _pickEndDate,
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Clear Dates',
              type: ButtonType.outline,
              icon: Icons.clear_rounded,
              onPressed: _clearDateRange,
            ),
          ),

          const SizedBox(
            height: AppDimensions.padding12,
          ),

          const Text(
            'Leave dates empty to make this banner available without a fixed schedule.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SETTINGS CARD
  // =====================================================

  Widget _buildSettingsCard() {
    return _SectionCard(
      title: 'Banner Settings',
      icon: Icons.tune_rounded,
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool isMobile =
              constraints.maxWidth < 800;

          final priorityField = CustomTextField(
            controller: _priorityController,
            labelText: 'Priority',
            hintText: '0',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(
              Icons.low_priority_rounded,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Priority is required';
              }

              final priority =
                  int.tryParse(value.trim());

              if (priority == null) {
                return 'Enter valid priority';
              }

              if (priority < 0) {
                return 'Priority cannot be negative';
              }

              return null;
            },
          );

          final toggles = Column(
            children: [
              SwitchListTile(
                value: _isActive,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Active Banner',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _isActive
                      ? 'Banner can be visible to users'
                      : 'Banner will remain hidden',
                  style: const TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              const Divider(
                color: AppColors.border,
              ),

              SwitchListTile(
                value: _isFeatured,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Featured Banner',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _isFeatured
                      ? 'Banner can appear in highlighted/priority slots'
                      : 'Banner will work as normal banner',
                  style: const TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
            ],
          );

          if (isMobile) {
            return Column(
              children: [
                priorityField,

                const SizedBox(
                  height: AppDimensions.padding16,
                ),

                toggles,
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: priorityField,
              ),

              const SizedBox(width: 24),

              Expanded(
                flex: 2,
                child: toggles,
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // ACTIONS
  // =====================================================

  Widget _buildActions(
    BannerProvider provider,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 150,
          child: CustomButton(
            text: AppStrings.cancel,
            type: ButtonType.outline,
            isEnabled: !provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
        ),

        const SizedBox(width: 16),

        SizedBox(
          width: 150,
          child: CustomButton(
            text: 'Reset',
            type: ButtonType.outline,
            icon: Icons.restart_alt_rounded,
            isEnabled: !provider.isLoading,
            onPressed:
                provider.isLoading ? null : _resetForm,
          ),
        ),

        const SizedBox(width: 16),

        SizedBox(
          width: 180,
          child: CustomButton(
            text: 'Update Banner',
            icon: Icons.save_outlined,
            isLoading: provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : _updateBanner,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LABEL HELPERS
  // =====================================================

  String _placementLabel(
    String item,
  ) {
    switch (item) {
      case 'home':
        return 'Home';
      case 'category':
        return 'Category';
      case 'service':
        return 'Service';
      case 'checkout':
        return 'Checkout';
      case 'profile':
        return 'Profile';
      case 'offers':
        return 'Offers';
      default:
        return AppFormatters.formatStatus(item);
    }
  }

  String _targetTypeLabel(
    String item,
  ) {
    switch (item) {
      case 'none':
        return 'No Target';
      case 'category':
        return 'Category';
      case 'service':
        return 'Service';
      case 'provider':
        return 'Provider';
      case 'coupon':
        return 'Coupon';
      case 'external':
        return 'External URL';
      case 'deep_link':
        return 'Deep Link';
      default:
        return AppFormatters.formatStatus(item);
    }
  }
}

// =====================================================
// DATE SELECTOR TILE
// =====================================================

class _DateSelectorTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateSelectorTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        AppDimensions.radius12,
      ),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          AppDimensions.padding14,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius10,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SECTION CARD
// =====================================================

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.padding20,
            ),

            child,
          ],
        ),
      ),
    );
  }
}