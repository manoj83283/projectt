import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool currentPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Call API Here

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Password changed successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          "Change Password",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Update Your Password",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Use a strong password to keep your account secure.",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CURRENT PASSWORD

                      TextFormField(
                        controller:
                            currentPasswordController,
                        obscureText:
                            !currentPasswordVisible,
                        decoration:
                            InputDecoration(
                          labelText:
                              "Current Password",
                          prefixIcon:
                              const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                currentPasswordVisible =
                                    !currentPasswordVisible;
                              });
                            },
                            icon: Icon(
                              currentPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "Enter current password";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // NEW PASSWORD

                      TextFormField(
                        controller:
                            newPasswordController,
                        obscureText:
                            !newPasswordVisible,
                        decoration:
                            InputDecoration(
                          labelText:
                              "New Password",
                          prefixIcon:
                              const Icon(
                            Icons.lock,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                newPasswordVisible =
                                    !newPasswordVisible;
                              });
                            },
                            icon: Icon(
                              newPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "Enter new password";
                          }

                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // CONFIRM PASSWORD

                      TextFormField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            !confirmPasswordVisible,
                        decoration:
                            InputDecoration(
                          labelText:
                              "Confirm Password",
                          prefixIcon:
                              const Icon(
                            Icons.password,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                confirmPasswordVisible =
                                    !confirmPasswordVisible;
                              });
                            },
                            icon: Icon(
                              confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "Confirm your password";
                          }

                          if (value !=
                              newPasswordController.text) {
                            return "Passwords do not match";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Password Requirements",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                          "• At least 8 characters"),
                      Text(
                          "• One uppercase letter"),
                      Text(
                          "• One lowercase letter"),
                      Text(
                          "• One number"),
                      Text(
                          "• One special character"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : changePassword,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: Text(
                    isLoading
                        ? "Updating..."
                        : "Change Password",
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