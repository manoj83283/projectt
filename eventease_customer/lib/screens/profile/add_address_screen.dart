import 'package:flutter/material.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() =>
      _AddAddressScreenState();
}

class _AddAddressScreenState
    extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController houseController =
      TextEditingController();

  final TextEditingController landmarkController =
      TextEditingController();

  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController stateController =
      TextEditingController();

  final TextEditingController pincodeController =
      TextEditingController();

  String addressType = 'Home';
  bool setAsDefault = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    houseController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    final addressData = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'house': houseController.text.trim(),
      'landmark': landmarkController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'pincode':
          pincodeController.text.trim(),
      'type': addressType,
      'default': setAsDefault,
    };

    Navigator.pop(
      context,
      addressData,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Address added successfully',
        ),
      ),
    );
  }

  Widget buildTypeChip(String type) {
    return ChoiceChip(
      label: Text(type),
      selected: addressType == type,
      onSelected: (_) {
        setState(() {
          addressType = type;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Add Address',
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                            nameController,
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
                                  .isEmpty) {
                            return 'Enter full name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            phoneController,
                        keyboardType:
                            TextInputType
                                .phone,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Mobile Number',
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
                                      .length <
                                  10) {
                            return 'Enter valid mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            houseController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'House / Flat / Building',
                          prefixIcon:
                              Icon(
                            Icons.home,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return 'Enter address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            landmarkController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Landmark',
                          prefixIcon:
                              Icon(
                            Icons.place,
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            cityController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'City',
                          prefixIcon:
                              Icon(
                            Icons.location_city,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return 'Enter city';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            stateController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'State',
                          prefixIcon:
                              Icon(
                            Icons.map,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return 'Enter state';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 16),

                      TextFormField(
                        controller:
                            pincodeController,
                        keyboardType:
                            TextInputType
                                .number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Pincode',
                          prefixIcon:
                              Icon(
                            Icons.pin,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                      .trim()
                                      .length !=
                                  6) {
                            return 'Enter valid pincode';
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
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Address Type',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 12),

                      Wrap(
                        spacing: 10,
                        children: [
                          buildTypeChip(
                              'Home'),
                          buildTypeChip(
                              'Work'),
                          buildTypeChip(
                              'Other'),
                        ],
                      ),

                      const SizedBox(
                          height: 16),

                      SwitchListTile(
                        value:
                            setAsDefault,
                        title: const Text(
                          'Set as Default Address',
                        ),
                        onChanged:
                            (value) {
                          setState(() {
                            setAsDefault =
                                value;
                          });
                        },
                      ),
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
                          : saveAddress,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: Text(
                    isLoading
                        ? 'Saving...'
                        : 'Save Address',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}