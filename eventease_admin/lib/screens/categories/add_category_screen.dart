import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_validator.dart';
import '../../providers/category_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({
    super.key,
  });

  @override
  State<AddCategoryScreen> createState() =>
      _AddCategoryScreenState();
}

class _AddCategoryScreenState
    extends State<AddCategoryScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _sortOrderController =
      TextEditingController();

  final TextEditingController _commissionController =
      TextEditingController();

  bool _isActive = true;
  bool _isFeatured = false;

  File? _selectedImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _sortOrderController.text = '0';
    _commissionController.text = '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    _commissionController.dispose();

    super.dispose();
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
      });
    } catch (e) {
      NavigationService.showError(
        'Unable to select image',
      );
    }
  }

  // =====================================================
  // REMOVE IMAGE
  // =====================================================

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // =====================================================
  // CREATE CATEGORY
  // =====================================================

  Future<void> _createCategory() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sortOrder =
        int.tryParse(
              _sortOrderController.text.trim(),
            ) ??
            0;

    final commission =
        double.tryParse(
              _commissionController.text.trim(),
            ) ??
            0;

    final success =
        await context
            .read<CategoryProvider>()
            .createCategory(
              name: _nameController.text.trim(),
              description:
                  _descriptionController.text.trim(),
              sortOrder: sortOrder,
              commissionPercentage: commission,
              isActive: _isActive,
              isFeatured: _isFeatured,
              imageFile: _selectedImage,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Category created successfully',
      );

      Navigator.pop(
        context,
        true,
      );
    } else {
      final error =
          context
              .read<CategoryProvider>()
              .errorMessage;

      NavigationService.showError(
        error ?? AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // RESET FORM
  // =====================================================

  void _resetForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _descriptionController.clear();
    _sortOrderController.text = '0';
    _commissionController.text = '0';

    setState(() {
      _selectedImage = null;
      _isActive = true;
      _isFeatured = false;
    });

    NavigationService.showInfo(
      'Form reset successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Category',
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
        child: Consumer<CategoryProvider>(
          builder: (
            context,
            categoryProvider,
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

                  if (categoryProvider.errorMessage !=
                      null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom:
                            AppDimensions.padding16,
                      ),
                      child: ErrorCard(
                        message: categoryProvider
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
                                900;

                        if (isMobile) {
                          return Column(
                            children: [
                              _buildBasicInfoCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildImageCard(),

                              const SizedBox(
                                height: 16,
                              ),

                              _buildSettingsCard(),

                              const SizedBox(
                                height: 24,
                              ),

                              _buildActions(
                                categoryProvider,
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
                                      _buildBasicInfoCard(),
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

                            _buildSettingsCard(),

                            const SizedBox(
                              height: 24,
                            ),

                            _buildActions(
                              categoryProvider,
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
                AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.radius16,
            ),
          ),
          child: const Icon(
            Icons.category_outlined,
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
                'Create Category',
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
                'Add a new EventEase service category with image, order, commission, and visibility settings.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BASIC INFO CARD
  // =====================================================

  Widget _buildBasicInfoCard() {
    return _SectionCard(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: 'Category Name',
            hintText:
                'Example: Photography, Catering, Decoration',
            prefixIcon: const Icon(
              Icons.category_outlined,
            ),
            validator: (value) {
              return AppValidator.required(
                value,
                fieldName: 'Category name',
              );
            },
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          CustomTextField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText:
                'Write a short description about this category',
            maxLines: 5,
            textInputAction:
                TextInputAction.newline,
            prefixIcon: const Icon(
              Icons.description_outlined,
            ),
            validator: (value) {
              return AppValidator.minLength(
                value,
                length: 10,
                fieldName: 'Description',
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
      title: 'Category Image',
      icon: Icons.image_outlined,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
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
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .add_photo_alternate_outlined,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'No image selected',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Recommended size: 512 x 512',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radius16,
                    ),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          const SizedBox(
            height: AppDimensions.padding16,
          ),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: _selectedImage == null
                      ? 'Choose Image'
                      : 'Change Image',
                  type: ButtonType.outline,
                  icon: Icons.upload_file_rounded,
                  onPressed: _pickImage,
                ),
              ),

              if (_selectedImage != null) ...[
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
            'Supported formats: JPG, PNG, WEBP. Keep image lightweight for faster dashboard loading.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
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
      title: 'Category Settings',
      icon: Icons.tune_rounded,
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool isMobile =
              constraints.maxWidth < 800;

          final sortOrderField = CustomTextField(
            controller: _sortOrderController,
            labelText: 'Sort Order',
            hintText: '0',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(
              Icons.sort_rounded,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Sort order is required';
              }

              if (int.tryParse(value.trim()) ==
                  null) {
                return 'Enter valid sort order';
              }

              return null;
            },
          );

          final commissionField = CustomTextField(
            controller: _commissionController,
            labelText: 'Commission %',
            hintText: '0',
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            prefixIcon: const Icon(
              Icons.percent_rounded,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Commission is required';
              }

              final commission =
                  double.tryParse(value.trim());

              if (commission == null) {
                return 'Enter valid commission';
              }

              if (commission < 0 ||
                  commission > 100) {
                return 'Commission must be between 0 and 100';
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
                  'Active Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _isActive
                      ? 'Category will be visible to users'
                      : 'Category will be hidden from users',
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
                  'Featured Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _isFeatured
                      ? 'Category can appear in featured sections'
                      : 'Category will not be highlighted',
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
                sortOrderField,

                const SizedBox(
                  height: AppDimensions.padding16,
                ),

                commissionField,

                const SizedBox(
                  height: AppDimensions.padding16,
                ),

                toggles,
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: sortOrderField,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: commissionField,
                  ),
                ],
              ),

              const SizedBox(
                height: AppDimensions.padding16,
              ),

              toggles,
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
    CategoryProvider provider,
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
            text: 'Create Category',
            icon: Icons.add_rounded,
            isLoading: provider.isLoading,
            onPressed: provider.isLoading
                ? null
                : _createCategory,
          ),
        ),
      ],
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