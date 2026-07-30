import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/provider_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _fullNameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  final TextEditingController
      _businessNameController =
      TextEditingController();

  final TextEditingController
      _addressController =
      TextEditingController();

  final TextEditingController
      _bioController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final provider =
        context.read<ProviderProvider>();

    await provider.getProfile();

    final profile = provider.provider;

    if (profile != null && mounted) {
      setState(() {
        _fullNameController.text =
            profile.fullName ?? '';

        _emailController.text =
            profile.email ?? '';

        _phoneController.text =
            profile.phone ?? '';

        _businessNameController.text =
            profile.businessName ?? '';

        _addressController.text =
            profile.address ?? '';

        _bioController.text =
            profile.bio ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
        context.read<ProviderProvider>();

    final success =
        await provider.updateProfile(
      data: {
        'fullName':
            _fullNameController.text.trim(),
        'email':
            _emailController.text.trim(),
        'phone':
            _phoneController.text.trim(),
        'businessName':
            _businessNameController.text
                .trim(),
        'address':
            _addressController.text.trim(),
        'bio':
            _bioController.text.trim(),
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully'
              : 'Failed to update profile',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit Profile',
            ),
          ),
          body: provider.isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =====================
                        // PROFILE IMAGE
                        // =====================

                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor:
                                  Theme.of(
                                context,
                              ).primaryColor,
                              child: const Icon(
                                Icons.person,
                                color:
                                    Colors.white,
                                size: 55,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor:
                                    Colors.blue,
                                child:
                                    IconButton(
                                  icon:
                                      const Icon(
                                    Icons.camera_alt,
                                    color: Colors
                                        .white,
                                    size: 18,
                                  ),
                                  onPressed:
                                      () {
                                    // Upload Profile Image
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        TextFormField(
                          controller:
                              _fullNameController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Full Name',
                            prefixIcon:
                                Icon(
                              Icons.person,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Full Name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _emailController,
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Email',
                            prefixIcon:
                                Icon(
                              Icons.email,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Email is required';
                            }

                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(
                              value,
                            )) {
                              return 'Enter valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _phoneController,
                          keyboardType:
                              TextInputType
                                  .phone,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Phone Number',
                            prefixIcon:
                                Icon(
                              Icons.phone,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _businessNameController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Business Name',
                            prefixIcon:
                                Icon(
                              Icons.business,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _addressController,
                          maxLines: 2,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Address',
                            prefixIcon:
                                Icon(
                              Icons.location_on,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                              _bioController,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Business Description',
                            prefixIcon:
                                Icon(
                              Icons.description,
                            ),
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
                              ElevatedButton.icon(
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : _updateProfile,
                            icon:
                                const Icon(
                              Icons.save,
                            ),
                            label:
                                provider.isLoading
                                    ? const SizedBox(
                                        height:
                                            22,
                                        width:
                                            22,
                                        child:
                                            CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                          strokeWidth:
                                              2,
                                        ),
                                      )
                                    : const Text(
                                        'UPDATE PROFILE',
                                      ),
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
}