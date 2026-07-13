import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController(
    text: 'Manoj Kumar',
  );

  final TextEditingController emailController =
      TextEditingController(
    text: 'manoj@example.com',
  );

  final TextEditingController phoneController =
      TextEditingController(
    text: '+91 9876543210',
  );

  final TextEditingController bioController =
      TextEditingController(
    text:
        'EventEase customer and event planner.',
  );

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Profile updated successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // =========================
              // PROFILE IMAGE
              // =========================

              Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        ThemeConfig.primaryColor,
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () {
                        // Pick Image
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          8,
                        ),
                        decoration:
                            const BoxDecoration(
                          color:
                              ThemeConfig.primaryColor,
                          shape:
                              BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // =========================
              // NAME
              // =========================

              TextFormField(
                controller:
                    nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon:
                      Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Enter name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // EMAIL
              // =========================

              TextFormField(
                controller:
                    emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Enter email';
                  }

                  if (!value.contains('@')) {
                    return 'Enter valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // PHONE
              // =========================

              TextFormField(
                controller:
                    phoneController,
                keyboardType:
                    TextInputType.phone,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Phone Number',
                  prefixIcon:
                      Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Enter phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // BIO
              // =========================

              TextFormField(
                controller:
                    bioController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint:
                      true,
                  prefixIcon:
                      Icon(Icons.info),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // SAVE BUTTON
              // =========================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : saveProfile,
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}