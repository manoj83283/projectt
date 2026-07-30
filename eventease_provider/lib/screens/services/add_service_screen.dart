import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/service_provider.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() =>
      _AddServiceScreenState();
}

class _AddServiceScreenState
    extends State<AddServiceScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _descriptionController =
      TextEditingController();

  final TextEditingController
      _priceController =
      TextEditingController();

  final TextEditingController
      _durationController =
      TextEditingController();

  final TextEditingController
      _locationController =
      TextEditingController();

  String? _selectedCategory;

  final List<String> _categories = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<ServiceProvider>();

    final success =
        await provider.createService(
      data: {
        'name':
            _nameController.text.trim(),
        'description':
            _descriptionController.text
                .trim(),
        'price': double.tryParse(
              _priceController.text,
            ) ??
            0,
        'duration':
            _durationController.text.trim(),
        'location':
            _locationController.text.trim(),
        'category':
            _selectedCategory,
        'isActive': true,
      },
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Service created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to create service',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Service',
        ),
      ),
      body: Consumer<ServiceProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .business_center_rounded,
                      color:
                          Colors.white,
                      size: 60,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  TextFormField(
                    controller:
                        _nameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Service Name',
                      prefixIcon: Icon(
                        Icons
                            .business_center,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Service name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButtonFormField<
                      String>(
                    value:
                        _selectedCategory,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Category',
                      prefixIcon: Icon(
                        Icons.category,
                      ),
                    ),
                    items: _categories
                        .map(
                          (category) =>
                              DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory =
                            value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Select category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _descriptionController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Description',
                      prefixIcon: Icon(
                        Icons.description,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _priceController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Price is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _durationController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Duration',
                      hintText:
                          'Example: 4 Hours',
                      prefixIcon: Icon(
                        Icons.access_time,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Duration is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _locationController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Service Location',
                      prefixIcon: Icon(
                        Icons.location_on,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    decoration:
                        BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.grey.shade300,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.image,
                          size: 40,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          'Service Images',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Upload Images
                          },
                          icon: const Icon(
                            Icons.upload,
                          ),
                          label: const Text(
                            'Upload Images',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed:
                          provider.isLoading
                              ? null
                              : _createService,
                      child: provider
                              .isLoading
                          ? const CircularProgressIndicator(
                              color: Colors
                                  .white,
                            )
                          : const Text(
                              'CREATE SERVICE',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}