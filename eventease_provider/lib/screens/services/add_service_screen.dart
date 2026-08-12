import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/service_provider.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({
    super.key,
  });

  @override
  State<AddServiceScreen> createState() =>
      _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  final TextEditingController _durationController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _tagsController =
      TextEditingController();

  String? _selectedCategory;
  String _selectedServiceType = 'fixed';

  bool _isSubmitting = false;

  final List<String> _categories = const [
    'Photography',
    'Videography',
    'Convention Hall',
    'Resort',
    'Catering',
    'Decoration',
    'DJ',
    'Makeup Artist',
    'Event Planner',
    'Dance Choreography',
  ];

  final Map<String, String> _serviceTypes = const {
    'fixed': 'Fixed Price',
    'hourly': 'Hourly Price',
    'daily': 'Daily Price',
    'package': 'Package Price',
    'custom': 'Custom Price',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _tagsController.dispose();

    super.dispose();
  }

  Future<void> _createService() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    final isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final category = _selectedCategory;

    if (category == null || category.trim().isEmpty) {
      _showMessage(
        'Please select a service category.',
        isError: true,
      );
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || price <= 0) {
      _showMessage(
        'Please enter a valid service price.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final serviceProvider =
        context.read<ServiceProvider>();

    final normalizedCategory =
        category.trim().toLowerCase();

    final duration =
        _durationController.text.trim();

    final tags = _parseTags(
      _tagsController.text,
    );

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description':
          _descriptionController.text.trim(),

      // Category fields expected by backend.
      'category': normalizedCategory,
      'categories': <String>[
        normalizedCategory,
      ],

      // Pricing fields expected by backend.
      'price': price,
      'basePrice': price,
      'pricePerHour':
          _selectedServiceType == 'hourly'
              ? price
              : 0,
      'pricePerDay':
          _selectedServiceType == 'daily'
              ? price
              : 0,
      'currency': 'INR',

      // Service details.
      'serviceType': _selectedServiceType,
      'duration': duration,
      'location':
          _locationController.text.trim(),

      // Search and display values.
      'tags': tags,
      'features': <String>[
        'Duration: $duration',
      ],

      // Images can be updated after upload integration.
      'image': '',
      'imageUrl': '',
      'images': <String>[],

      // Customer visibility.
      'isAvailable': true,
      'isActive': true,
      'isPopular': false,
      'isRecommended': false,
      'isFeatured': false,
    };

    try {
      final success =
          await serviceProvider.createService(
        data: data,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showMessage(
          _cleanErrorMessage(
            serviceProvider.errorMessage ??
                'Failed to create service.',
          ),
          isError: true,
        );
        return;
      }

      // Reload provider services after successful creation.
      try {
        await serviceProvider.refreshData();
      } catch (_) {
        // Creation is still successful if refresh fails.
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        'Service created successfully.',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanErrorMessage(
          error.toString(),
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map(
          (tag) => tag.trim().toLowerCase(),
        )
        .where(
          (tag) => tag.isNotEmpty,
        )
        .toSet()
        .toList();
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor:
              isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanErrorMessage(String message) {
    return message
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Service name is required';
    }

    final serviceName = value.trim();

    if (serviceName.length < 2) {
      return 'Service name must contain at least 2 characters';
    }

    if (serviceName.length > 150) {
      return 'Service name cannot exceed 150 characters';
    }

    return null;
  }

  String? _descriptionValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    if (value.trim().length < 10) {
      return 'Description must contain at least 10 characters';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(
      value.trim(),
    );

    if (price == null) {
      return 'Enter a valid numeric price';
    }

    if (price <= 0) {
      return 'Price must be greater than zero';
    }

    return null;
  }

  String? _durationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required';
    }

    return null;
  }

  String? _locationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    if (value.trim().length < 2) {
      return 'Enter a valid service location';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Service',
        ),
      ),
      body: SafeArea(
        child: Consumer<ServiceProvider>(
          builder: (
            context,
            serviceProvider,
            child,
          ) {
            final isLoading =
                _isSubmitting ||
                serviceProvider.isLoading;

            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(
                16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Icon(
                          Icons.business_center_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Service Information',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // SERVICE NAME
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      textInputAction:
                          TextInputAction.next,
                      textCapitalization:
                          TextCapitalization.words,
                      maxLength: 150,
                      decoration:
                          const InputDecoration(
                        labelText: 'Service Name *',
                        hintText:
                            'Example: Wedding Photography',
                        prefixIcon: Icon(
                          Icons.business_center,
                        ),
                      ),
                      validator: _nameValidator,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(
                          Icons.category,
                        ),
                      ),
                      items: _categories.map(
                        (category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategory =
                                    value;
                              });
                            },
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Select category';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // SERVICE TYPE
                    DropdownButtonFormField<String>(
                      value: _selectedServiceType,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText: 'Pricing Type *',
                        prefixIcon: Icon(
                          Icons.sell_outlined,
                        ),
                      ),
                      items:
                          _serviceTypes.entries.map(
                        (entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _selectedServiceType =
                                    value;
                              });
                            },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // DESCRIPTION
                    TextFormField(
                      controller:
                          _descriptionController,
                      enabled: !isLoading,
                      minLines: 4,
                      maxLines: 6,
                      textCapitalization:
                          TextCapitalization.sentences,
                      keyboardType:
                          TextInputType.multiline,
                      decoration:
                          const InputDecoration(
                        labelText: 'Description *',
                        hintText:
                            'Describe the service and included features',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(
                          Icons.description_outlined,
                        ),
                      ),
                      validator:
                          _descriptionValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // PRICE
                    TextFormField(
                      controller: _priceController,
                      enabled: !isLoading,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            r'^\d*\.?\d{0,2}$',
                          ),
                        ),
                      ],
                      textInputAction:
                          TextInputAction.next,
                      decoration: InputDecoration(
                        labelText:
                            _selectedServiceType ==
                                    'hourly'
                                ? 'Price Per Hour *'
                                : _selectedServiceType ==
                                        'daily'
                                    ? 'Price Per Day *'
                                    : 'Service Price *',
                        hintText: 'Example: 15000',
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                      ),
                      validator: _priceValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // DURATION
                    TextFormField(
                      controller:
                          _durationController,
                      enabled: !isLoading,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'Duration *',
                        hintText:
                            'Example: 4 Hours or 2 Days',
                        prefixIcon: Icon(
                          Icons.access_time,
                        ),
                      ),
                      validator:
                          _durationValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // LOCATION
                    TextFormField(
                      controller:
                          _locationController,
                      enabled: !isLoading,
                      textInputAction:
                          TextInputAction.next,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Service Location *',
                        hintText:
                            'Example: Hyderabad, Telangana',
                        prefixIcon: Icon(
                          Icons.location_on,
                        ),
                      ),
                      validator:
                          _locationValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // TAGS
                    TextFormField(
                      controller: _tagsController,
                      enabled: !isLoading,
                      textInputAction:
                          TextInputAction.done,
                      decoration:
                          const InputDecoration(
                        labelText: 'Search Tags',
                        hintText:
                            'wedding, photography, premium',
                        prefixIcon: Icon(
                          Icons.tag,
                        ),
                        helperText:
                            'Separate multiple tags using commas',
                      ),
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          _createService();
                        }
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // IMAGE UPLOAD PLACEHOLDER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 40,
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Service Images',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Image upload can be connected after configuring the backend upload endpoint.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              style:
                                  OutlinedButton.styleFrom(
                                minimumSize:
                                    const Size(
                                  0,
                                  44,
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _showMessage(
                                        'Image upload is not configured yet.',
                                        isError: true,
                                      );
                                    },
                              icon: const Icon(
                                Icons.upload,
                              ),
                              label: const Text(
                                'Upload Images',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // CREATE SERVICE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            55,
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : _createService,
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'CREATE SERVICE',
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}