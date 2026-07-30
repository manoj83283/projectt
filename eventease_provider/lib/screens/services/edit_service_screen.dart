import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const EditServiceScreen({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceScreen> createState() =>
      _EditServiceScreenState();
}

class _EditServiceScreenState
    extends State<EditServiceScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late TextEditingController
      _nameController;

  late TextEditingController
      _descriptionController;

  late TextEditingController
      _priceController;

  late TextEditingController
      _durationController;

  late TextEditingController
      _locationController;

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

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.service.name,
    );

    _descriptionController =
        TextEditingController(
      text: widget.service.description,
    );

    _priceController =
        TextEditingController(
      text: widget.service.price.toString(),
    );

    _durationController =
        TextEditingController(
      text: widget.service.duration ?? '',
    );

    _locationController =
        TextEditingController(
      text: widget.service.location ?? '',
    );

    _selectedCategory =
        widget.service.category;

    _isActive =
        widget.service.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
        context.read<ServiceProvider>();

    final success =
        await provider.updateService(
      serviceId: widget.service.id,
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
        'isActive': _isActive,
      },
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Service updated successfully'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update service',
          ),
        ),
      );
    }
  }

  Future<void> _deleteService() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete Service'),
          content: const Text(
            'Are you sure you want to delete this service?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final provider =
        context.read<ServiceProvider>();

    final success =
        await provider.deleteService(
      widget.service.id,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Service deleted successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Service'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
            ),
            onPressed: _deleteService,
          ),
        ],
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
                  if (widget
                      .service.images.isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      child: Image.network(
                        widget.service.images
                            .first,
                        height: 220,
                        width:
                            double.infinity,
                        fit: BoxFit.cover,
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
                            value:
                                category,
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
                      prefixIcon: Icon(
                        Icons.access_time,
                      ),
                    ),
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
                          'Location',
                      prefixIcon: Icon(
                        Icons.location_on,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SwitchListTile(
                    value: _isActive,
                    title:
                        const Text('Active'),
                    subtitle: Text(
                      _isActive
                          ? 'Customers can book this service'
                          : 'Service hidden from customers',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 24,
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
                        color: Colors
                            .grey.shade300,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.photo_library,
                          size: 40,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${widget.service.images.length} Images Uploaded',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Upload/Manage Images
                          },
                          icon: const Icon(
                            Icons.upload,
                          ),
                          label: const Text(
                            'Manage Images',
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
                              : _updateService,
                      child: provider
                              .isLoading
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )
                          : const Text(
                              'UPDATE SERVICE',
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